//
//  FJMovieManager.m
//  FJCamera
//
//  Created by Fu Jie on 2018/11/19.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJMovieManager.h"

@interface FJMovieManager()
{
    BOOL                _readyToRecordVideo;
    BOOL                _readyToRecordAudio;
    dispatch_queue_t    _movieWritingQueue;

    NSURL              *_movieURL;
    AVAssetWriter      *_movieWriter;
    AVAssetWriterInput *_movieAudioInput;
    AVAssetWriterInput *_movieVideoInput;
    
    FJAVFileType       _exportAVFileType;
}

@end

@implementation FJMovieManager

- (instancetype)init {
    
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Use -initWithAVFileType:" userInfo:nil];
}

- (instancetype)initWithAVFileType:(FJAVFileType)type {
    
    self = [super init];
    if (self) {
        _exportAVFileType = type;
        _movieWritingQueue = dispatch_queue_create("Movie.Writing.Queue", DISPATCH_QUEUE_SERIAL);
        long long date = [[NSDate date] timeIntervalSince1970];
        NSString *extension = nil;
        switch (type) {
            case FJAVFileTypeMOV:
            {
                extension = @".mov";
                break;
            }
            case FJAVFileTypeMP4:
            {
                extension = @".mp4";
                break;
            }
            default:
                break;
        }
        _movieURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@movie_%lld%@", NSTemporaryDirectory(), date, extension]];
        _referenceOrientation = AVCaptureVideoOrientationPortrait;
    }
    return self;
}

- (void)start:(void(^)(NSError *error))handle{
    [self removeFile:_movieURL];
    dispatch_async(_movieWritingQueue, ^{
        NSError *error;
        if (!self->_movieWriter) {
            AVFileType exportAVFileType;
            switch (self->_exportAVFileType) {
                case FJAVFileTypeMOV:
                {
                    exportAVFileType = AVFileTypeQuickTimeMovie;
                    break;
                }
                case FJAVFileTypeMP4:
                {
                    exportAVFileType = AVFileTypeMPEG4;
                    break;
                }
                default:
                    break;
            }
            self->_movieWriter = [[AVAssetWriter alloc] initWithURL:self->_movieURL fileType:exportAVFileType error:&error];
        }
        handle(error);
    });
}

- (void)stop:(void(^)(NSURL *url, NSError *error))handle{
    _readyToRecordVideo = NO;
    _readyToRecordAudio = NO;
    dispatch_async(_movieWritingQueue, ^{
        [self->_movieWriter finishWritingWithCompletionHandler:^(){
            if (self->_movieWriter.status == AVAssetWriterStatusCompleted) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    handle(self->_movieURL, nil);
                });
            } else {
                handle(nil, self->_movieWriter.error);
            }
            self->_movieWriter = nil;
        }];
    });
}

- (void)writeData:(AVCaptureConnection *)connection video:(AVCaptureConnection*)video audio:(AVCaptureConnection *)audio buffer:(CMSampleBufferRef)buffer {
    CFRetain(buffer);
    dispatch_async(_movieWritingQueue, ^{
        if (connection == video){
            if (!self->_readyToRecordVideo){
                self->_readyToRecordVideo = [self setupAssetWriterVideoInput:CMSampleBufferGetFormatDescription(buffer)] == nil;
            }
            if ([self inputsReadyToRecord]){
                [self writeSampleBuffer:buffer ofType:AVMediaTypeVideo];
            }
        } else if (connection == audio){
            if (!self->_readyToRecordAudio){
                self->_readyToRecordAudio = [self setupAssetWriterAudioInput:CMSampleBufferGetFormatDescription(buffer)] == nil;
            }
            if ([self inputsReadyToRecord]){
                [self writeSampleBuffer:buffer ofType:AVMediaTypeAudio];
            }
        }
        CFRelease(buffer);
    });
}

- (void)writeSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(NSString *)mediaType{
    if (_movieWriter.status == AVAssetWriterStatusUnknown){
        if ([_movieWriter startWriting]){
            [_movieWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        } else {
            NSLog(@"%@", _movieWriter.error);
        }
    }
    if (_movieWriter.status == AVAssetWriterStatusWriting){
        if (mediaType == AVMediaTypeVideo){
            if (!_movieVideoInput.readyForMoreMediaData){
                return;
            }
            if (![_movieVideoInput appendSampleBuffer:sampleBuffer]){
                NSLog(@"%@", _movieWriter.error);
            }
        } else if (mediaType == AVMediaTypeAudio){
            if (!_movieAudioInput.readyForMoreMediaData){
                return;
            }
            if (![_movieAudioInput appendSampleBuffer:sampleBuffer]){
                NSLog(@"%@", _movieWriter.error);
            }
        }
    }
}

- (BOOL)inputsReadyToRecord{
    return _readyToRecordVideo && _readyToRecordAudio;
}

/// 音频源数据写入配置
- (NSError *)setupAssetWriterAudioInput:(CMFormatDescriptionRef)currentFormatDescription {
    size_t aclSize = 0;
    const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(currentFormatDescription);
    const AudioChannelLayout *channelLayout = CMAudioFormatDescriptionGetChannelLayout(currentFormatDescription,&aclSize);
    NSData *dataLayout = aclSize > 0 ? [NSData dataWithBytes:channelLayout length:aclSize] : [NSData data];
    NSDictionary *settings = @{AVFormatIDKey: [NSNumber numberWithInteger: kAudioFormatMPEG4AAC],
                             AVSampleRateKey: [NSNumber numberWithFloat: currentASBD->mSampleRate],
                          AVChannelLayoutKey: dataLayout,
                       AVNumberOfChannelsKey: [NSNumber numberWithInteger: currentASBD->mChannelsPerFrame],
               AVEncoderBitRatePerChannelKey: [NSNumber numberWithInt: 64000]};

    if ([_movieWriter canApplyOutputSettings:settings forMediaType: AVMediaTypeAudio]){
        _movieAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType: AVMediaTypeAudio outputSettings:settings];
        _movieAudioInput.expectsMediaDataInRealTime = YES;
        if ([_movieWriter canAddInput:_movieAudioInput]){
            [_movieWriter addInput:_movieAudioInput];
        } else {
            return _movieWriter.error;
        }
    } else {
        return _movieWriter.error;
    }
    return nil;
}

/// 视频源数据写入配置
- (NSError *)setupAssetWriterVideoInput:(CMFormatDescriptionRef)currentFormatDescription {
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(currentFormatDescription);
    NSUInteger numPixels = dimensions.width * dimensions.height;
    CGFloat bitsPerPixel = numPixels < (640 * 480) ? 4.05 : 11.0;
    NSDictionary *compression = @{AVVideoAverageBitRateKey: [NSNumber numberWithInteger: numPixels * bitsPerPixel],
                                  AVVideoMaxKeyFrameIntervalKey: [NSNumber numberWithInteger:30]};
    NSDictionary *settings = @{AVVideoCodecKey: AVVideoCodecH264,
                               AVVideoWidthKey: [NSNumber numberWithInteger:dimensions.width],
                              AVVideoHeightKey: [NSNumber numberWithInteger:dimensions.height],
               AVVideoCompressionPropertiesKey: compression};

    if ([_movieWriter canApplyOutputSettings:settings forMediaType:AVMediaTypeVideo]){
        _movieVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
        _movieVideoInput.expectsMediaDataInRealTime = YES;
        _movieVideoInput.transform = [self transformFromCurrentVideoOrientationToOrientation:self.referenceOrientation];
        if ([_movieWriter canAddInput:_movieVideoInput]){
            [_movieWriter addInput:_movieVideoInput];
        } else {
            return _movieWriter.error;
        }
    } else {
        return _movieWriter.error;
    }
    return nil;
}

// 获取视频旋转矩阵
- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation{
    CGFloat orientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:orientation];
    CGFloat videoOrientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:self.currentOrientation];
    CGFloat angleOffset;
    if (self.currentDevice.position == AVCaptureDevicePositionBack) {
        angleOffset = videoOrientationAngleOffset - orientationAngleOffset + M_PI_2;
    } else {
        angleOffset = orientationAngleOffset - videoOrientationAngleOffset + M_PI_2;
    }
    CGAffineTransform transform = CGAffineTransformMakeRotation(angleOffset);
    return transform;
}

// 获取视频旋转角度
- (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation{
    CGFloat angle = 0.0;
    switch (orientation){
        case AVCaptureVideoOrientationPortrait:
            angle = 0.0;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
    }
    return angle;
}

// 移除文件
- (void)removeFile:(NSURL *)fileURL{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = fileURL.path;
    if ([fileManager fileExistsAtPath:filePath]){
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        if (!success){
            NSLog(@"删除视频文件失败：%@", error);
        } else {
            NSLog(@"删除视频文件成功");
        }
    }
}

@end
