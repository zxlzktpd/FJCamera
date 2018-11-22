//
//  FJMovieManager.h
//  FJCamera
//
//  Created by Fu Jie on 2018/11/19.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FJAVFileType) {
    FJAVFileTypeMP4,   // MPEG4
    FJAVFileTypeMOV    // QuickMovie
};

@interface FJMovieManager : NSObject

@property(nonatomic, assign) AVCaptureVideoOrientation referenceOrientation; // 视频播放方向

@property(nonatomic, assign) AVCaptureVideoOrientation currentOrientation;

@property(nonatomic, strong) AVCaptureDevice *currentDevice;

- (instancetype)initWithAVFileType:(FJAVFileType)type;

- (void)start:(void(^)(NSError *error))handle;

- (void)stop:(void(^)(NSURL *url, NSError *error))handle;

- (void)removeAllTemporaryVideoFiles;

- (void)writeData:(AVCaptureConnection *)connection
            video:(AVCaptureConnection*)video
            audio:(AVCaptureConnection *)audio
           buffer:(CMSampleBufferRef)buffer;

@end

NS_ASSUME_NONNULL_END
