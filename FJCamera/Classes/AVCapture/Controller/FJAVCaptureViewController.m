//
//  FJAVCaptureViewController.m
//  FJCamera
//
//  Created by Fu Jie on 2018/11/19.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJAVCaptureViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMMetadata.h>
#import <Photos/Photos.h>
#import "FJImagePreviewController.h"
#import "FJCameraView.h"
#import "FJCameraManager.h"
#import "FJMotionManager.h"
#import "FJMovieManager.h"
#import "FJSaveMedia.h"
#import "NSURL+PreviewImage.h"
#import "FJAllMediaPreviewViewController.h"
#import "FJAVCatpureCommonHeader.h"

@interface FJAVCaptureViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, FJCameraViewDelegate>
{
    // 会话
    AVCaptureSession            *_session;
    
    // 输入
    AVCaptureDeviceInput      *_deviceInput;
    
    // 输出
    AVCaptureConnection       *_videoConnection;
    AVCaptureConnection       *_audioConnection;
    AVCaptureVideoDataOutput  *_videoOutput;
    AVCaptureStillImageOutput  *_imageOutput;
    
    // 录制
    BOOL                       _recording;
}

@property (nonatomic, strong) FJCameraView    *cameraView;          // 界面布局
@property (nonatomic, strong) FJMovieManager  *movieManager;      // 视频管理
@property (nonatomic, strong) FJCameraManager *cameraManager;  // 相机管理
@property (nonatomic, strong) FJMotionManager *motionManager;    // 陀螺仪管理
@property (nonatomic, strong) AVCaptureDevice *activeCamera;       // 当前输入设备
@property (nonatomic, strong) AVCaptureDevice *inactiveCamera;    // 不活跃的设备(这里指前摄像头或后摄像头，不包括外接输入设备)

@property (nonatomic, strong) NSMutableArray *medias;

@end

@implementation FJAVCaptureViewController

- (NSMutableArray *)medias {
    
    if (_medias == nil) {
        _medias = [[NSMutableArray alloc] init];
    }
    return _medias;
}

// 默认初始化
- (instancetype)init {
    
    self = [super init];
    if (self) {
        _movieManager  = [[FJMovieManager alloc] initWithAVFileType:FJAVFileTypeMP4 inputSettingConfig:nil];
        _motionManager = [[FJMotionManager alloc] init];
        _cameraManager = [[FJCameraManager alloc] init];
    }
    return self;
}

// 自定义初始化
- (instancetype)initWithAVInputSettingConfig:(FJAVInputSettingConfig *)inputSettingConfig outputExtension:(FJAVFileType)outputExtension {
    
    self = [super init];
    if (self) {
        _movieManager  = [[FJMovieManager alloc] initWithAVFileType:outputExtension inputSettingConfig:inputSettingConfig];
        _motionManager = [[FJMotionManager alloc] init];
        _cameraManager = [[FJCameraManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // 清除所有临时的视频文件
    [_movieManager removeAllTemporaryVideoFiles];
    
    self.cameraView = [[FJCameraView alloc] initWithFrame:self.view.bounds config:self.config];
    self.cameraView.delegate = self;
    [self.view addSubview:self.cameraView];
    
    NSError *error;
    [self setupSession:&error];
    if (!error) {
        [self.cameraView.previewView setCaptureSessionsion:_session];
        [self startCaptureSession];
    }else{
        [self.view showError:error];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self.cameraView updateMedias:self.medias];
}

- (BOOL)prefersStatusBarHidden {
    
    return YES;
}

- (void)dealloc {
    
    MFLog(@"相机界面销毁了");
}

#pragma mark - -输入设备
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)activeCamera {
    
    return _deviceInput.device;
}

- (AVCaptureDevice *)inactiveCamera {
    
    AVCaptureDevice *device = nil;
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        } else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    return device;
}

#pragma mark - -相关配置
/// 会话
- (void)setupSession:(NSError **)error {
    
    _session = [[AVCaptureSession alloc] init];
    _session.sessionPreset = AVCaptureSessionPresetHigh;
    
    [self setupSessionInputs:error];
    [self setupSessionOutputs:error];
}

/// 输入
- (void)setupSessionInputs:(NSError **)error {
    
    // 视频输入
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    if (videoInput) {
        if ([_session canAddInput:videoInput]) {
            [_session addInput:videoInput];
        }
    }
    _deviceInput = videoInput;
    
    // 音频输入
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:error];
    if ([_session canAddInput:audioIn]) {
        [_session addInput:audioIn];
    }
}

/// 输出
- (void)setupSessionOutputs:(NSError **)error {
    
    dispatch_queue_t captureQueue = dispatch_queue_create("com.fj.captureQueue", DISPATCH_QUEUE_SERIAL);
    
    // 视频输出
    AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
    [videoOut setAlwaysDiscardsLateVideoFrames:YES];
    [videoOut setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]}];
    [videoOut setSampleBufferDelegate:self queue:captureQueue];
    if ([_session canAddOutput:videoOut]) {
        [_session addOutput:videoOut];
    }
    _videoOutput = videoOut;
    _videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
    
    // 音频输出
    AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
    [audioOut setSampleBufferDelegate:self queue:captureQueue];
    if ([_session canAddOutput:audioOut]) {
        [_session addOutput:audioOut];
    }
    _audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
    
    // 静态图片输出
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
    imageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    if ([_session canAddOutput:imageOutput]) {
        [_session addOutput:imageOutput];
    }
    _imageOutput = imageOutput;
}

#pragma mark - -会话控制
// 开启捕捉
- (void)startCaptureSession {
    
    if (!_session.isRunning) {
        [_session startRunning];
    }
}

// 停止捕捉
- (void)stopCaptureSession {
    
    if (_session.isRunning) {
        [_session stopRunning];
    }
}

#pragma mark - -操作相机
// 缩放
- (void)zoomAction:(FJCameraView *)cameraView factor:(CGFloat)factor {
    
    NSError *error = [_cameraManager zoom:[self activeCamera] factor:factor];
    if (error) MFLog(@"%@", error);
}

// 聚焦
- (void)focusAction:(FJCameraView *)cameraView point:(CGPoint)point handle:(void (^)(NSError *))handle {
    
    NSError *error = [_cameraManager focus:[self activeCamera] point:point];
    handle(error);
    MFLog(@"%f", [self activeCamera].activeFormat.videoMaxZoomFactor);
}

// 曝光
- (void)exposAction:(FJCameraView *)cameraView point:(CGPoint)point handle:(void (^)(NSError *))handle {
    
    NSError *error = [_cameraManager expose:[self activeCamera] point:point];
    handle(error);
}

// 自动聚焦、曝光
- (void)autoFocusAndExposureAction:(FJCameraView *)cameraView handle:(void (^)(NSError *))handle {
    
    NSError *error = [_cameraManager resetFocusAndExposure:[self activeCamera]];
    handle(error);
}

// 闪光灯
- (void)flashLightAction:(FJCameraView *)cameraView handle:(void (^)(NSError *))handle {
    
    BOOL on = [_cameraManager flashMode:[self activeCamera]] == AVCaptureFlashModeOn;
    AVCaptureFlashMode mode = on ? AVCaptureFlashModeOff : AVCaptureFlashModeOn;
    NSError *error = [_cameraManager changeFlash:[self activeCamera] mode: mode];
    handle(error);
}

// 手电筒
- (void)torchLightAction:(FJCameraView *)cameraView handle:(void (^)(NSError *))handle {
    
    BOOL on = [_cameraManager torchMode:[self activeCamera]] == AVCaptureTorchModeOn;
    AVCaptureTorchMode mode = on ? AVCaptureTorchModeOff : AVCaptureTorchModeOn;
    NSError *error = [_cameraManager changeTorch:[self activeCamera] model:mode];
    handle(error);
}

// 转换摄像头
- (void)swicthCameraAction:(FJCameraView *)cameraView handle:(void (^)(NSError *))handle {
    
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (videoInput) {
        // 动画效果
        CATransition *animation = [CATransition animation];
        animation.type = @"oglFlip";
        animation.subtype = kCATransitionFromLeft;
        animation.duration = 0.5;
        [self.cameraView.previewView.layer addAnimation:animation forKey:@"flip"];
        
        // 当前闪光灯状态
        AVCaptureFlashMode mode = [_cameraManager flashMode:[self activeCamera]];
        
        // 转换摄像头
        _deviceInput = [_cameraManager switchCamera:_session old:_deviceInput new:videoInput];
        
        // 重新设置视频输出链接
        _videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
        
        // 如果后置转前置，系统会自动关闭手电筒(如果之前打开的，需要更新UI)
        if (videoDevice.position == AVCaptureDevicePositionFront) {
            [self.cameraView changeTorch:NO];
        }
        
        // 前后摄像头的闪光灯不是同步的，所以在转换摄像头后需要重新设置闪光灯
        [_cameraManager changeFlash:[self activeCamera] mode:mode];
    }
    handle(error);
}

#pragma mark - -拍摄照片
// 拍照
- (void)takePhotoAction:(FJCameraView *)cameraView {
    
    AVCaptureConnection *connection = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection.isVideoOrientationSupported) {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    MF_WEAK_SELF
    [_imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        if (error) {
            [weakSelf.view showError:error];
            return;
        }
        __block NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        __block UIImage *image = [[UIImage alloc] initWithData:imageData];
        if (weakSelf.config.enableConfirmPreview) {
            FJMediaObject *media = [FJMediaObject new];
            media.image = image;
            media.imageData = imageData;
            FJImagePreviewController *previewVC = [[FJImagePreviewController alloc] initWithMedia:media callback:^(BOOL saved, FJMediaObject *media) {
                
                if (weakSelf.config.enablePreviewAll) {
                    if (saved) {
                        [weakSelf.medias addObject:media];
                        [weakSelf.cameraView updateMedias:weakSelf.medias];
                    }
                }else {
                    weakSelf.mediasTakenBlock == nil ? : weakSelf.mediasTakenBlock(MF_WRAP_ARRAY(media));
                }
            }];
            if (weakSelf.config.enablePreviewAll == NO) {
                [previewVC dismissToRoot];
            }
            [weakSelf.navigationController pushViewController:previewVC animated:YES];
        }else {
            
            [FJSaveMedia savePhotoToPhotoLibrary:image completionBlock:^(UIImage *image, NSURL *imageURL, NSError *error) {
                
                if (error) {
                    [weakSelf.view showError:error];
                    return;
                }
                FJMediaObject *media = [FJMediaObject new];
                media.image = image;
                media.imageURL = imageURL;
                if (weakSelf.config.enablePreviewAll) {
                    [weakSelf.medias addObject:media];
                    [weakSelf.cameraView updateMedias:weakSelf.medias];
                }else {
                    weakSelf.mediasTakenBlock == nil ? : weakSelf.mediasTakenBlock(MF_WRAP_ARRAY(media));
                    [weakSelf fj_dismiss];
                }
            }];
        }
    }];
}

// 取消拍照
- (void)cancelAction:(FJCameraView *)cameraView {
    
    [self fj_dismiss];
}

#pragma mark - -录制视频
// 开始录像
- (void)startRecordVideoAction:(FJCameraView *)cameraView {
    
    _recording = YES;
    _movieManager.currentDevice = [self activeCamera];
    _movieManager.currentOrientation = [self currentVideoOrientation];
    MF_WEAK_SELF
    [_movieManager start:^(NSError * _Nonnull error) {
        if (error) [weakSelf.view showError:error];
    }];
}

// 停止录像
- (void)stopRecordVideoAction:(FJCameraView *)cameraView {
    
    _recording = NO;
    MF_WEAK_SELF
    [_movieManager stop:^(NSURL * _Nonnull url, NSError * _Nonnull error) {
        if (error) {
            [weakSelf.view showError:error];
        } else {
            if (weakSelf.config.enableConfirmPreview) {
                FJMediaObject *media = [FJMediaObject new];
                media.isVideo = YES;
                media.videoURL = url;
                FJImagePreviewController *previewVC = [[FJImagePreviewController alloc] initWithMedia:media callback:^(BOOL saved, FJMediaObject *media) {

                    if (weakSelf.config.enablePreviewAll) {
                        if (saved) {
                            [weakSelf.medias addObject:media];
                            [weakSelf.cameraView updateMedias:weakSelf.medias];
                        }
                    }else {
                        weakSelf.mediasTakenBlock == nil ? : weakSelf.mediasTakenBlock(MF_WRAP_ARRAY(media));
                    }
                }];
                if (weakSelf.config.enablePreviewAll == NO) {
                    [previewVC dismissToRoot];
                }
                [weakSelf.navigationController pushViewController:previewVC animated:YES];
            }else {
                
                [FJSaveMedia saveMovieToCameraRoll:url completionBlock:^(NSURL *mediaURL, NSError *error) {
                    if (error) {
                        [weakSelf.view showError:error];
                        return;
                    }
                    FJMediaObject *media = [FJMediaObject new];
                    media.videoURL = mediaURL;
                    media.image = [mediaURL previewImage];
                    media.isVideo = YES;
                    if (weakSelf.config.enablePreviewAll) {
                        [weakSelf.medias addObject:media];
                        [weakSelf.cameraView updateMedias:weakSelf.medias];
                    }else {
                        weakSelf.mediasTakenBlock == nil ? : weakSelf.mediasTakenBlock(MF_WRAP_ARRAY(media));
                        [weakSelf fj_dismiss];
                    }
                }];
            }
        }
    }];
}

// Preview 预览
- (void)previewAction:(FJCameraView *)cameraView {
    
    if (self.medias == nil || self.medias.count == 0) {
        return;
    }
    FJAllMediaPreviewViewController *allMediaPreviewVC = [[FJAllMediaPreviewViewController alloc] init];
    allMediaPreviewVC.medias = self.medias;
    [self.navigationController pushViewController:allMediaPreviewVC animated:YES];
}

// 完成预览
- (void)doneAction:(FJCameraView *)cameraView {
    
    self.mediasTakenBlock == nil ? : self.mediasTakenBlock(self.medias);
    [self fj_dismiss];
}

#pragma mark - -输出代理
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (_recording) {
        [_movieManager writeData:connection video:_videoConnection audio:_audioConnection buffer:sampleBuffer];
    }
}

#pragma mark - -其它方法
// 当前设备取向
- (AVCaptureVideoOrientation)currentVideoOrientation {
    
    AVCaptureVideoOrientation orientation;
    switch (self.motionManager.deviceOrientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    return orientation;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
