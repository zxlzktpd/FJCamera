//
//  FJCameraView.m
//  FJCamera
//
//  Created by Fu Jie on 2018/11/19.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJCameraView.h"
#import "FJAVCatpureCommonHeader.h"
#import "UIView+FJHUD.h"
#import "FJTakePhotoView.h"

@implementation FJCameraViewConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 支持前后置摄像头切换
        self.enableSwitch = YES;
        // 支持补光
        self.enableLightSupplement = YES;
        // 支持闪光灯
        self.enableFlashLight = YES;
        // 支持自动聚焦和曝光
        self.enableAutoFocusAndExposure = YES;
        // 支持缩放
        self.enableZoom = YES;
        // 支持缩放显示条
        self.enableZoomIndicator = YES;
        // 支持手动聚焦/曝光
        self.enableManualTapFocusAndExposure = YES;
        // 支持拍摄模式
        self.captureType = FJCaptureTypeAll;
        // Preview全屏
        self.capturePreviewFullScreen = YES;
        // Top Bar 背景颜色
        self.topBarTintColor = [UIColor clearColor];
        // Bottom Bar 背景颜色
        self.bottomBarTintColor = [UIColor clearColor];
        // Top Bar 高度
        self.topBarHeight = 64.0;
        // Bottom Bar 高度
        self.bottomBarHeight = 220.0;
        // 聚焦框颜色
        self.focusBorderColor = [UIColor whiteColor];
        // 聚焦框边长
        self.focusSideLength = 160.0;
        // 聚焦框厚度
        self.focusBorderWidth = 2.0;
        // 曝光框颜色
        self.exposureBorderColor = [UIColor whiteColor];
        // 曝光框边长
        self.exposureSideLength = 180.0;
        // 曝光框厚度
        self.exposureBorderWidth = 5.0;
        // 缩放显示条 maximumTrackTintColor
        self.zoomIndicatorMaximumTrackTintColor = [UIColor whiteColor];
        // 缩放显示条 minimumTrackTintColor
        self.zoomIndicatorMinimumTrackTintColor = [UIColor whiteColor];
        // 缩放显示条 thumbTintColor
        self.zoomIndicatorThumbTintColor = [UIColor whiteColor];
        // 缩放显示条 OffsetTop
        self.zoomIndicatorOffsetTop = 104.0;
        // 缩放显示条 OffsetRight
        self.zoomIndicatorOffsetRight = 30.0;
        // 缩放显示条 Width
        self.zoomIndicatorWidth = 10.0;
        // 缩放显示条 Height
        self.zoomIndicatorHeight = 200.0;
        // 控件使用图标 Top View (Cancel Button除外)
        self.widgetUsingImageTopView = NO;
        // 控件使用图标 Cancel Button
        self.widgetUsingImageCancel = NO;
        // 控件使用图标 Bottom Button
        self.widgetUsingImageBottomView = NO;
        // Take View Size
        self.takeViewSize = CGSizeMake(90.0, 90.0);
        // Take Button Size
        self.takeButtonSize = CGSizeMake(70.0, 70.0);
        // Take Button Stroke Color
        self.takeButtonStrokeColor = @"#00D76E".fj_color;
        // Take Button Stroke Width
        self.takeButtonStrokeWidth = 10.0;
        // Take Button Stroke Long Press Duration
        self.takeButtonLongTapPressDuration = 0.5;
        // Take Button Stroke Circle Duration
        self.takeButtonCircleDuration = 15.0;
        // Hint Height
        self.hintHeight = 27.0;
    }
    return self;
}

@end

@interface FJCameraView()

// 1：拍照 2：视频
@property(nonatomic, assign) FJCaptureType captureType;
@property(nonatomic, strong) FJVideoPreview *previewView;
@property(nonatomic, strong) UIView *topView;      // 上面的bar
@property(nonatomic, strong) UIView *bottomView;   // 下面的bar
@property(nonatomic, strong) UIView *focusView;    // 聚焦动画view
@property(nonatomic, strong) UIView *exposureView; // 曝光动画view

@property(nonatomic, strong) UISlider *slider;
@property(nonatomic, strong) UIButton *torchBtn;
@property(nonatomic, strong) UIButton *flashBtn;
@property(nonatomic, strong) UIButton *photoBtn;

@end

@implementation FJCameraView

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSAssert(NO, @"FJCameraView Init 异常");
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSAssert(NO, @"FJCameraView Init 异常");
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame config:(FJCameraViewConfig *)config {
    
    // NSAssert(frame.size.height > 164 || frame.size.width > 374, @"相机视图的高不小于164，宽不小于375");
    self = [super initWithFrame:frame];
    if (self) {
        _captureType = FJCaptureTypePhoto;
        [self _buildUI:config];
    }
    return self;
}

-(UIView *)topView {
    
    if (_topView == nil) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.config.topBarHeight)];
        _topView.backgroundColor = self.config.topBarTintColor;
    }
    return _topView;
}

-(UIView *)bottomView {
    
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - self.config.bottomBarHeight, self.width, self.config.bottomBarHeight)];
        _bottomView.backgroundColor = self.config.bottomBarTintColor;
    }
    return _bottomView;
}

-(UIView *)focusView {
    
    if (_focusView == nil) {
        _focusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.config.focusSideLength, self.config.focusSideLength)];
        _focusView.backgroundColor = [UIColor clearColor];
        _focusView.layer.borderColor = self.config.focusBorderColor.CGColor;
        _focusView.layer.borderWidth = self.config.focusBorderWidth;
        _focusView.hidden = YES;
    }
    return _focusView;
}

-(UIView *)exposureView {
    
    if (_exposureView == nil) {
        _exposureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.config.exposureSideLength, self.config.exposureSideLength)];
        _exposureView.backgroundColor = [UIColor clearColor];
        _exposureView.layer.borderColor = self.config.exposureBorderColor.CGColor;
        _exposureView.layer.borderWidth = self.config.exposureBorderWidth;
        _exposureView.hidden = YES;
    }
    return _exposureView;
}

-(UISlider *)slider {
    
    if (_slider == nil) {
        _slider = [[UISlider alloc] init];
        _slider.minimumValue = 0;
        _slider.maximumValue = 1;
        _slider.maximumTrackTintColor = self.config.zoomIndicatorMaximumTrackTintColor;
        _slider.minimumTrackTintColor = self.config.zoomIndicatorMinimumTrackTintColor;
        _slider.thumbTintColor = self.config.zoomIndicatorThumbTintColor;
        _slider.alpha = 0.0;
    }
    return _slider;
}

#pragma mark - Public
-(void)changeTorch:(BOOL)on {
    
    _torchBtn.selected = on;
}

-(void)changeFlash:(BOOL)on {
    
    _flashBtn.selected = on;
}

#pragma mark - Private
-(void)_buildUI:(FJCameraViewConfig *)config {
    
    __weak typeof(self) weakSelf = self;
    if (config == nil) {
        self.config = [[FJCameraViewConfig alloc] init];
    }else {
        self.config = config;
    }
    
    if (self.config.capturePreviewFullScreen) {
        self.previewView = [[FJVideoPreview alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    }else {
        self.previewView = [[FJVideoPreview alloc] initWithFrame:CGRectMake(0, self.config.topBarHeight, self.width, self.height - self.config.topBarHeight - self.config.bottomBarHeight)];
    }    
    [self addSubview:self.previewView];
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    if (self.config.enableManualTapFocusAndExposure) {
        [self.previewView addSubview:self.focusView];
        [self.previewView addSubview:self.exposureView];
    }
    if (self.config.enableZoom && self.config.enableZoomIndicator) {
        [self.previewView addSubview:self.slider];
    }
    // ----------------------- 手势
    if (self.config.enableManualTapFocusAndExposure) {
        // 点击-->聚焦
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapAction:)];
        [self.previewView addGestureRecognizer:tap];
        // 双击-->曝光
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_doubleTapAction:)];
        doubleTap.numberOfTapsRequired = 2;
        [self.previewView addGestureRecognizer:doubleTap];
        [tap requireGestureRecognizerToFail:doubleTap];
    }
    
    if (self.config.enableZoom) {
        // 捏合-->缩放
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action: @selector(_pinchAction:)];
        [self.previewView addGestureRecognizer:pinch];
        if (self.config.enableZoomIndicator) {
            // 缩放 UI 条
            self.slider.transform = CGAffineTransformMakeRotation(M_PI_2);
            self.slider.frame = CGRectMake(self.width - self.config.zoomIndicatorOffsetRight, self.config.zoomIndicatorOffsetTop, self.config.zoomIndicatorWidth, self.config.zoomIndicatorHeight);
        }
    }

    // Bottom Bar
    if (self.config.widgetUsingImageBottomView) {
        
        UILabel *labelHint = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bottomView.size.width, self.config.hintHeight)];
        NSString *hint = nil;
        int type = 0;
        if (self.config.captureType == FJCaptureTypeAll) {
            hint = @"轻触拍照，长按摄像";
            type = 3;
        }else if (self.config.captureType == FJCaptureTypePhoto) {
            hint = @"轻触拍照";
            type = 1;
        }else if (self.config.captureType == FJCaptureTypeVidio) {
            hint = @"长按摄像";
            type = 2;
        }
        labelHint.text = hint;
        labelHint.textAlignment = NSTextAlignmentCenter;
        labelHint.textColor = [UIColor whiteColor];
        labelHint.font = [UIFont systemFontOfSize:14.0];
        [self.bottomView addSubview:labelHint];
       
        
        FJTakePhotoView *takeView = [FJTakePhotoView create:CGRectMake((self.bottomView.size.width - self.config.takeViewSize.width) / 2.0, (self.bottomView.size.height - self.config.takeViewSize.height) / 2.0, self.config.takeViewSize.width, self.config.takeViewSize.height) takeButtonSize:self.config.takeButtonSize strokeColor:self.config.takeButtonStrokeColor strokeWidth:self.config.takeButtonStrokeWidth longTapPressDuration:self.config.takeButtonLongTapPressDuration circleDuration:self.config.takeButtonCircleDuration type:type tapBlock:^{
            // 拍照
            if ([weakSelf.delegate respondsToSelector:@selector(takePhotoAction:)]) {
                [weakSelf.delegate takePhotoAction:self];
            }
            
        } longPressBlock:^(BOOL begin) {
            // 拍摄
            if (begin) {
                if ([weakSelf.delegate respondsToSelector:@selector(startRecordVideoAction:)]) {
                    [weakSelf.delegate startRecordVideoAction:self];
                }
            }else {
                if ([weakSelf.delegate respondsToSelector:@selector(stopRecordVideoAction:)]) {
                    [weakSelf.delegate stopRecordVideoAction:self];
                }
            }
        }];
        [self.bottomView addSubview:takeView];
        
    }else {
        // 拍照
        UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [photoButton setTitle:@"拍照" forState:UIControlStateNormal];
        [photoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [photoButton addTarget:self action:@selector(_takePicture:) forControlEvents:UIControlEventTouchUpInside];
        photoButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        photoButton.frame = CGRectMake(self.bottomView.bounds.size.width / 2.0 - 30.0, self.bottomView.bounds.size.height / 2.0 - 30.0, 60.0, 60.0);
        [self.bottomView addSubview:photoButton];
        _photoBtn = photoButton;
        
        // 照片类型
        UIButton *typeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [typeButton setTitle:@"照片" forState:UIControlStateNormal];
        [typeButton setTitle:@"视频" forState:UIControlStateSelected];
        [typeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [typeButton addTarget:self action:@selector(_changeType:) forControlEvents:UIControlEventTouchUpInside];
        typeButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        typeButton.frame = CGRectMake(self.bottomView.bounds.size.width - 100.0, self.bottomView.bounds.size.height / 2.0 - 20.0, 80.0, 40.0);
        [self.bottomView addSubview:typeButton];
    }
    
    // Top Bar
    int w = 0;
    if (self.config.enableSwitch) {
        w++;
    }
    if (self.config.enableLightSupplement) {
        w++;
    }
    if (self.config.enableFlashLight) {
        w++;
    }
    if (self.config.enableAutoFocusAndExposure) {
        w++;
    }
    // 取消
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(_cancel:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
    cancelButton.frame = CGRectMake(0, 0, self.topView.width / 5.0, self.topView.bounds.size.height);
    [self.topView addSubview:cancelButton];
    
    // 转换前后摄像头
    UIButton *switchCameraButton = nil;
    if (self.config.enableSwitch) {
        switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [switchCameraButton addTarget:self action:@selector(_switchCameraClick:) forControlEvents:UIControlEventTouchUpInside];
        switchCameraButton.frame = CGRectMake(cancelButton.width, 0, (self.topView.width - cancelButton.width) / (float)w , self.topView.height);
        [self.topView addSubview:switchCameraButton];
        if (self.config.widgetUsingImageTopView) {
            // TODO ICON
        }else {
            [switchCameraButton setTitle:@"转换" forState:UIControlStateNormal];
            [switchCameraButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            switchCameraButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        }
    }
    
    // 补光
    UIButton *lightButton = nil;
    if (self.config.enableLightSupplement) {
        lightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [lightButton addTarget:self action:@selector(_torchClick:) forControlEvents:UIControlEventTouchUpInside];
        CGRect frame = CGRectZero;
        if (switchCameraButton != nil ) {
            frame = CGRectMake(switchCameraButton.frame.origin.x + switchCameraButton.frame.size.width, 0, (self.topView.width - cancelButton.width) / (float)w, self.topView.height);
        }else {
            frame = CGRectMake(cancelButton.width, 0, (self.topView.width - cancelButton.width) / (float)w , self.topView.height);
        }
        lightButton.frame = frame;
        [self.topView addSubview:lightButton];
        _torchBtn = lightButton;
        if (self.config.widgetUsingImageTopView) {
            // TODO ICON
        }else {
            [lightButton setTitle:@"补光" forState:UIControlStateNormal];
            [lightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [lightButton setTitleColor:[UIColor yellowColor] forState:UIControlStateSelected];
            lightButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        }
    }
    
    // 闪光灯
    UIButton *flashButton = nil;
    if (self.config.enableFlashLight) {
        flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [flashButton addTarget:self action:@selector(_flashClick:) forControlEvents:UIControlEventTouchUpInside];
        CGRect frame = CGRectZero;
        if (lightButton != nil ) {
            frame = CGRectMake(lightButton.frame.origin.x + lightButton.frame.size.width, 0, (self.topView.width - cancelButton.width) / (float)w, self.topView.height);
        }else if (switchCameraButton != nil ) {
            frame = CGRectMake(switchCameraButton.frame.origin.x + switchCameraButton.frame.size.width, 0, (self.topView.width - cancelButton.width) / (float)w, self.topView.height);
        }else {
            frame = CGRectMake(cancelButton.width, 0, (self.topView.width - cancelButton.width) / (float)w , self.topView.height);
        }
        flashButton.frame = frame;
        [self.topView addSubview:flashButton];
        _flashBtn = flashButton;
        if (self.config.widgetUsingImageTopView) {
            // TODO ICON
        }else {
            [flashButton setTitle:@"闪光灯" forState:UIControlStateNormal];
            [flashButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [flashButton setTitleColor:[UIColor yellowColor] forState:UIControlStateSelected];
            flashButton.titleLabel.font = [UIFont systemFontOfSize:16.0];
        }
    }
    
    // 重置对焦、曝光
    UIButton *focusAndExposureButton = nil;
    if (self.config.enableAutoFocusAndExposure) {
        focusAndExposureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [focusAndExposureButton addTarget:self action:@selector(_focusAndExposureClick:) forControlEvents:UIControlEventTouchUpInside];
        CGRect frame = CGRectZero;
        if (flashButton != nil ) {
            frame = CGRectMake(flashButton.frame.origin.x + flashButton.frame.size.width, 0, (self.topView.width - cancelButton.width) / (float)w, self.topView.height);
        }else if (lightButton != nil ) {
            frame = CGRectMake(lightButton.frame.origin.x + lightButton.frame.size.width, 0, (self.topView.width - cancelButton.width) / (float)w, self.topView.height);
        }else if (switchCameraButton != nil ) {
            frame = CGRectMake(switchCameraButton.frame.origin.x + switchCameraButton.frame.size.width, 0, (self.topView.width - cancelButton.width) / (float)w, self.topView.height);
        }else {
            frame = CGRectMake(cancelButton.width, 0, (self.topView.width - cancelButton.width) / (float)w , self.topView.height);
        }
        focusAndExposureButton.frame = frame;
        [self.topView addSubview:focusAndExposureButton];
        if (self.config.widgetUsingImageTopView) {
            // TODO ICON
        }else {
            [focusAndExposureButton setTitle:@"自动聚焦/曝光" forState:UIControlStateNormal];
            [focusAndExposureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            focusAndExposureButton.titleLabel.font = [UIFont systemFontOfSize:14.0 - w];
        }
    }
}

-(void)_pinchAction:(UIPinchGestureRecognizer *)pinch {
    
    @weakify(self)
    if ([_delegate respondsToSelector:@selector(zoomAction:factor:)]) {
        if (pinch.state == UIGestureRecognizerStateBegan) {
            [UIView animateWithDuration:0.1 animations:^{
                @strongify(self)
                self.slider.alpha = 1;
            }];
        } else if (pinch.state == UIGestureRecognizerStateChanged) {
            if (pinch.velocity > 0) {
                _slider.value += pinch.velocity/100;
            } else {
                _slider.value += pinch.velocity/20;
            }
            [_delegate zoomAction:self factor: powf(5, _slider.value)];
        } else {
            [UIView animateWithDuration:0.1 animations:^{
                @strongify(self)
                self.slider.alpha = 0.0;
            }];
        }
    }
}

// 聚焦
-(void)_tapAction:(UIGestureRecognizer *)tap {
    
    if ([_delegate respondsToSelector:@selector(focusAction:point:handle:)]) {
        CGPoint point = [tap locationInView:self.previewView];
        [self _runFocusAnimation:self.focusView point:point];
        @weakify(self)
        [_delegate focusAction:self point:[self.previewView captureDevicePointForPoint:point] handle:^(NSError *error) {
            @strongify(self)
            if (error) [self showError:error];
        }];
    }
}

// 曝光
-(void)_doubleTapAction:(UIGestureRecognizer *)tap {
    
    if ([_delegate respondsToSelector:@selector(exposAction:point:handle:)]) {
        CGPoint point = [tap locationInView:self.previewView];
        [self _runFocusAnimation:self.exposureView point:point];
        @weakify(self)
        [_delegate exposAction:self point:[self.previewView captureDevicePointForPoint:point] handle:^(NSError *error) {
            @strongify(self)
            if (error) [self showError:error];
        }];
    }
}

// 自动聚焦和曝光
-(void)_focusAndExposureClick:(UIButton *)button {
    
    if ([_delegate respondsToSelector:@selector(autoFocusAndExposureAction:handle:)]) {
        [self _runResetAnimation];
        @weakify(self)
        [_delegate autoFocusAndExposureAction:self handle:^(NSError *error) {
            @strongify(self)
            if (error) [self showError:error];
        }];
    }
}

// 拍照、视频
-(void)_takePicture:(UIButton *)btn {
    
    if (self.captureType == FJCaptureTypePhoto) {
        if ([_delegate respondsToSelector:@selector(takePhotoAction:)]) {
            [_delegate takePhotoAction:self];
        }
    } else if(self.captureType == FJCaptureTypeVidio) {
        if (btn.selected == YES) {
            // 结束
            btn.selected = NO;
            [_photoBtn setTitle:@"开始" forState:UIControlStateNormal];
            if ([_delegate respondsToSelector:@selector(stopRecordVideoAction:)]) {
                [_delegate stopRecordVideoAction:self];
            }
        } else {
            // 开始
            btn.selected = YES;
            [_photoBtn setTitle:@"结束" forState:UIControlStateNormal];
            if ([_delegate respondsToSelector:@selector(startRecordVideoAction:)]) {
                [_delegate startRecordVideoAction:self];
            }
        }
    }
}

// 取消
-(void)_cancel:(UIButton *)btn {
    
    if ([_delegate respondsToSelector:@selector(cancelAction:)]) {
        [_delegate cancelAction:self];
    }
}

// 转换拍摄类型
-(void)_changeType:(UIButton *)btn {
    
    btn.selected = !btn.selected;
    if (self.captureType == FJCaptureTypePhoto) {
        self.captureType = FJCaptureTypeVidio;
        [_photoBtn setTitle:@"开始" forState:UIControlStateNormal];
    }else if (self.captureType == FJCaptureTypeVidio) {
        self.captureType = FJCaptureTypePhoto;
        [_photoBtn setTitle:@"拍照" forState:UIControlStateNormal];
    }
}

// 转换摄像头
-(void)_switchCameraClick:(UIButton *)btn {
    
    if ([_delegate respondsToSelector:@selector(swicthCameraAction:handle:)]) {
        [_delegate swicthCameraAction:self handle:^(NSError *error) {
            if (error) [self showError:error];
        }];
    }
}

// 手电筒
-(void)_torchClick:(UIButton *)btn {
    
    @weakify(self)
    if ([_delegate respondsToSelector:@selector(torchLightAction:handle:)]) {
        [_delegate torchLightAction:self handle:^(NSError *error) {
            @strongify(self)
            if (error) {
                [self showError:error];
            } else {
                self.flashBtn.selected = NO;
                self.torchBtn.selected = !self.torchBtn.selected;
            }
        }];
    }
}

// 闪光灯
-(void)_flashClick:(UIButton *)btn {
    
    @weakify(self)
    if ([_delegate respondsToSelector:@selector(flashLightAction:handle:)]) {
        [_delegate flashLightAction:self handle:^(NSError *error) {
            @strongify(self)
            if (error) {
                [self showError:error];
            } else {
                self.flashBtn.selected = !self.flashBtn.selected;
                self.torchBtn.selected = NO;
            }
        }];
    }
}

#pragma mark - Private methods
// 聚焦、曝光动画
-(void)_runFocusAnimation:(UIView *)view point:(CGPoint)point {
    
    view.center = point;
    view.hidden = NO;
    [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
    } completion:^(BOOL complete) {
        double delayInSeconds = 0.5f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            view.hidden = YES;
            view.transform = CGAffineTransformIdentity;
        });
    }];
}

// 自动聚焦、曝光动画
- (void)_runResetAnimation {
    
    self.focusView.center = CGPointMake(self.previewView.width/2, self.previewView.height/2);
    self.exposureView.center = CGPointMake(self.previewView.width/2, self.previewView.height/2);;
    self.exposureView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    self.focusView.hidden = NO;
    self.focusView.hidden = NO;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.focusView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
        weakSelf.exposureView.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1.0);
    } completion:^(BOOL complete) {
        double delayInSeconds = 0.5f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            weakSelf.focusView.hidden = YES;
            weakSelf.exposureView.hidden = YES;
            weakSelf.focusView.transform = CGAffineTransformIdentity;
            weakSelf.exposureView.transform = CGAffineTransformIdentity;
        });
    }];
}

@end
