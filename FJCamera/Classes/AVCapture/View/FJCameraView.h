//
//  FJCameraView.h
//  FJCamera
//
//  Created by Fu Jie on 2018/11/19.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FJVideoPreview.h"

typedef NS_ENUM(NSInteger, FJCaptureType) {
    FJCaptureTypePhoto = 0x0001,
    FJCaptureTypeVidio = 0x0002,
    FJCaptureTypeAll   = FJCaptureTypePhoto | FJCaptureTypeVidio
};

@class FJCameraView;

@protocol FJCameraViewDelegate <NSObject>
@optional;

/// 闪光灯
-(void)flashLightAction:(FJCameraView *)cameraView handle:(void(^)(NSError *error))handle;

/// 补光
-(void)torchLightAction:(FJCameraView *)cameraView handle:(void(^)(NSError *error))handle;

/// 转换摄像头
-(void)swicthCameraAction:(FJCameraView *)cameraView handle:(void(^)(NSError *error))handle;

/// 自动聚焦曝光
-(void)autoFocusAndExposureAction:(FJCameraView *)cameraView handle:(void(^)(NSError *error))handle;

/// 聚焦
-(void)focusAction:(FJCameraView *)cameraView point:(CGPoint)point handle:(void(^)(NSError *error))handle;

/// 曝光
-(void)exposAction:(FJCameraView *)cameraView point:(CGPoint)point handle:(void(^)(NSError *error))handle;

/// 缩放
-(void)zoomAction:(FJCameraView *)cameraView factor:(CGFloat)factor;

/// 取消
-(void)cancelAction:(FJCameraView *)cameraView;

/// 拍照
-(void)takePhotoAction:(FJCameraView *)cameraView;

/// 停止录制视频
-(void)stopRecordVideoAction:(FJCameraView *)cameraView;

/// 开始录制视频
-(void)startRecordVideoAction:(FJCameraView *)cameraView;

@end

@interface FJCameraViewConfig : NSObject

// 支持前后置摄像头切换
@property (nonatomic, assign) BOOL enableSwitch;
// 支持补光
@property (nonatomic, assign) BOOL enableLightSupplement;
// 支持闪光灯
@property (nonatomic, assign) BOOL enableFlashLight;
// 支持自动聚焦和曝光
@property (nonatomic, assign) BOOL enableAutoFocusAndExposure;
// 支持缩放
@property (nonatomic, assign) BOOL enableZoom;
// 支持缩放显示条
@property (nonatomic, assign) BOOL enableZoomIndicator;
// 支持拍摄模式
@property (nonatomic, assign) FJCaptureType captureType;
// Preview全屏
@property (nonatomic, assign) BOOL capturePreviewFullScreen;
// Top Bar 背景颜色
@property (nonatomic, strong) UIColor *topBarTintColor;
// Bottom Bar 背景颜色
@property (nonatomic, strong) UIColor *bottomBarTintColor;
// Top Bar 高度
@property (nonatomic, assign) CGFloat topBarHeight;
// Bottom Bar 高度
@property (nonatomic, assign) CGFloat bottomBarHeight;
// 聚焦框颜色
@property (nonatomic, strong) UIColor *focusBorderColor;
// 聚焦框边长
@property (nonatomic, assign) CGFloat focusSideLength;
// 聚焦框厚度
@property (nonatomic, assign) CGFloat focusBorderWidth;
// 曝光框颜色
@property (nonatomic, strong) UIColor *exposureBorderColor;
// 曝光框边长
@property (nonatomic, assign) CGFloat exposureSideLength;
// 曝光框厚度
@property (nonatomic, assign) CGFloat exposureBorderWidth;
// 缩放显示条 maximumTrackTintColor
@property (nonatomic, strong) UIColor *zoomIndicatorMaximumTrackTintColor;
// 缩放显示条 minimumTrackTintColor
@property (nonatomic, strong) UIColor *zoomIndicatorMinimumTrackTintColor;
// 缩放显示条 thumbTintColor
@property (nonatomic, strong) UIColor *zoomIndicatorThumbTintColor;
// 缩放显示条 OffsetTop
@property (nonatomic, assign) CGFloat zoomIndicatorOffsetTop;
// 缩放显示条 OffsetRight
@property (nonatomic, assign) CGFloat zoomIndicatorOffsetRight;
// 缩放显示条 Width
@property (nonatomic, assign) CGFloat zoomIndicatorWidth;
// 缩放显示条 Height
@property (nonatomic, assign) CGFloat zoomIndicatorHeight;
// 控件使用图标 Top View (Cancel Button除外)
@property (nonatomic, assign) BOOL widgetUsingImageTopView;
// 控件使用图标 Cancel Button
@property (nonatomic, assign) BOOL widgetUsingImageCancel;
// 控件使用图标 Bottom View
@property (nonatomic, assign) BOOL widgetUsingImageBottomView;

@end

@interface FJCameraView : UIView

@property (nonatomic, weak) id <FJCameraViewDelegate> delegate;

@property (nonatomic, strong, readonly) FJVideoPreview *previewView;

@property (nonatomic, assign, readonly) FJCaptureType captureType;

@property (nonatomic, strong) FJCameraViewConfig *config;

-(instancetype)initWithFrame:(CGRect)frame config:(FJCameraViewConfig *)config;

-(void)changeTorch:(BOOL)on;

-(void)changeFlash:(BOOL)on;

@end
