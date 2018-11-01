//
//  FJPhotoEditViewController.m
//  FJCamera
//
//  Created by Fu Jie on 2018/10/30.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJPhotoEditViewController.h"
#import "FJPhotoEditTitleScrollView.h"
#import "FJPhotoEditToolbarView.h"
#import "FJPhotoManager.h"
#import "StaticScaleCropView.h"
#import "FJFilterImageView.h"
#import <CoreImage/CoreImage.h>
#import <CoreImage/CIFilter.h>

@interface FJPhotoEditViewController () <UIScrollViewDelegate>

// Custome TitleView
@property (nonatomic, strong) FJPhotoEditTitleScrollView *customTitleView;
// Next Button
@property (nonatomic, strong) UIButton *nextBtn;
// Tool Bar
@property (nonatomic, strong) FJPhotoEditToolbarView *toolbar;
// ScrollView
@property (nonatomic, strong) UIScrollView *scrollView;
// Cropper View
@property (nonatomic, strong) StaticScaleCropView *cropperView;
// Filter View
@property (nonatomic, strong) FJFilterImageView *filterView;

@end

@implementation FJPhotoEditViewController

- (void)_test {
    
    /* 滤镜分类Categories */
    /*
    CORE_IMAGE_EXPORT NSString * const kCICategoryDistortionEffect;
    CORE_IMAGE_EXPORT NSString * const kCICategoryGeometryAdjustment;
    CORE_IMAGE_EXPORT NSString * const kCICategoryCompositeOperation;
    CORE_IMAGE_EXPORT NSString * const kCICategoryHalftoneEffect;
    CORE_IMAGE_EXPORT NSString * const kCICategoryColorAdjustment;
    CORE_IMAGE_EXPORT NSString * const kCICategoryColorEffect;
    CORE_IMAGE_EXPORT NSString * const kCICategoryTransition;
    CORE_IMAGE_EXPORT NSString * const kCICategoryTileEffect;
    CORE_IMAGE_EXPORT NSString * const kCICategoryGenerator;
    CORE_IMAGE_EXPORT NSString * const kCICategoryReduction NS_AVAILABLE(10_5, 5_0);
    CORE_IMAGE_EXPORT NSString * const kCICategoryGradient;
    CORE_IMAGE_EXPORT NSString * const kCICategoryStylize;
    CORE_IMAGE_EXPORT NSString * const kCICategorySharpen;
    CORE_IMAGE_EXPORT NSString * const kCICategoryBlur;
    CORE_IMAGE_EXPORT NSString * const kCICategoryVideo;
    CORE_IMAGE_EXPORT NSString * const kCICategoryStillImage;
    CORE_IMAGE_EXPORT NSString * const kCICategoryInterlaced;
    CORE_IMAGE_EXPORT NSString * const kCICategoryNonSquarePixels;
    CORE_IMAGE_EXPORT NSString * const kCICategoryHighDynamicRange;
    CORE_IMAGE_EXPORT NSString * const kCICategoryBuiltIn;
    CORE_IMAGE_EXPORT NSString * const kCICategoryFilterGenerator NS_AVAILABLE(10_5, 9_0);
    */
    
    NSArray *filterNames = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
    NSLog(@"总共有%ld种滤镜效果:%@",filterNames.count,filterNames);
    
    
    NSArray* filters = [CIFilter filterNamesInCategory:kCICategoryDistortionEffect];
    for (NSString* filterName in filters) {
        NSLog(@"filter name:%@",filterName);
        // 我们可以通过filterName创建对应的滤镜对象
        CIFilter* filter = [CIFilter filterWithName:filterName];
        NSDictionary* attributes = [filter attributes];
        // 获取属性键/值对(在这个字典中我们可以看到滤镜的属性以及对应的key)
        NSLog(@"filter attributes:%@",attributes);
    }
    
    // CIColorControls --> 亮度、饱和度、对比度控制 kCIInputBrightnessKey kCIInputSaturationKey kCIInputContrastKey
    // CITemperatureAndTint --> 色温 kCIInputNeutralTemperatureKey kCIInputNeutralTintKey
    // CIVignette CIVignetteEffect --> 暗角  inputIntensity inputRadius
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
    NSDictionary* attributes = [filter attributes];
    NSLog(@"filter attributes:%@",attributes);
    
    filter = [CIFilter filterWithName:@"CITemperatureAndTint"];
    attributes = [filter attributes];
    NSLog(@"filter attributes:%@",attributes);
    
    filter = [CIFilter filterWithName:@"CIVignette"];
    attributes = [filter attributes];
    NSLog(@"filter attributes:%@",attributes);
    
    filter = [CIFilter filterWithName:@"CIVignetteEffect"];
    attributes = [filter attributes];
    NSLog(@"filter attributes:%@",attributes);
    
}

- (void)_testFilter {
    
    // Do any additional setup after loading the view, typically from a nib.
    // 滤镜效果
    NSArray *operations = @[@"CILinearToSRGBToneCurve",
                            @"CIPhotoEffectChrome",
                            @"CIPhotoEffectFade",
                            @"CIPhotoEffectInstant",
                            @"CIPhotoEffectMono",
                            @"CIPhotoEffectNoir",
                            @"CIPhotoEffectProcess",
                            @"CIPhotoEffectTonal",
                            @"CIPhotoEffectTransfer",
                            @"CISRGBToneCurveToLinear",
                            @"CIVignetteEffect"];
    CGFloat width = self.view.frame.size.width / 3;
    CGFloat height = self.view.frame.size.height / 4;
    NSMutableArray *imageViews = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < [operations count]; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame: CGRectMake(i%3*width, i/3*height, width, height)];
        imageView.image = [UIImage imageNamed:@"timg.jpeg"];
        [imageViews addObject:imageView];
        [self.view addSubview:imageView];
        
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0),^{
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < [operations count]; i++) {
            UIImage *image = [UIImage imageNamed:@"timg.jpeg"];
            CIImage *cImage = [[CIImage alloc]initWithImage:image];
            //使用资源
            CIFilter *filter = [CIFilter filterWithName:operations[i] keysAndValues:kCIInputImageKey,cImage, nil];
            //使用默认参数
            [filter setDefaults];
            //生成上下文
            CIContext*context = [CIContext contextWithOptions:nil];
            //滤镜生成器输出图片
            CIImage *outputimage = [filter outputImage];
            //转换为UIImage
            CGImageRef ref = [context createCGImage:outputimage fromRect:[outputimage extent]];
            UIImage *temp = [UIImage imageWithCGImage:ref];
            [images addObject:temp];
            //释放
            CGImageRelease(ref);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            for (int x = 0; x < [images count]; x++) {
                UIImageView *imageView = imageViews[x];
                imageView.image = images[x];
            }
        });
        
    });
}

- (UIButton *)nextBtn {
    
    if (_nextBtn == nil) {
        _nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
        [_nextBtn fj_setTitle:@"下一步"];
        [_nextBtn fj_setTitleFont:[UIFont systemFontOfSize:14.0]];
        [_nextBtn fj_setTitleColor:@"#FF7725".fj_color];
        [_nextBtn setUserInteractionEnabled:YES];
        [_nextBtn addTarget:self action:@selector(_tapNext) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

- (StaticScaleCropView *)cropperView {
    
    if (_cropperView == nil) {
        _cropperView = [[StaticScaleCropView alloc] initWithFrame:_scrollView.frame];
        [self.view addSubview:_cropperView];
        [self.view bringSubviewToFront:_cropperView];
    }
    return _cropperView;
}

- (FJFilterImageView *)filterView {
    
    if (_filterView == nil) {
        
        UIImage *image = [FJPhotoManager shared].currentCroppedImage;
        if (!image) {
            image = [FJPhotoManager shared].currentPhotoImage;
        }
        _filterView = [FJFilterImageView create:_scrollView.frame image:image];
        [self.view addSubview:_filterView];
        [self.view bringSubviewToFront:_filterView];
    }
    return _filterView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mode = FJPhotoEditModeFilter | FJPhotoEditModeCropprer | FJPhotoEditModeTuning | FJPhotoEditModeTag;
    }
    return self;
}

- (void)dealloc {
    
    [self _cleanPhotoManager];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 初始化Manager
    [[FJPhotoManager shared] initial:self.selectedPhotoAssets];
    
    // 初始化UI
    [self _buildUI];
    
    // 刷新
    [self _refreshScrollView];
    
    // [self _test];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_cleanPhotoManager {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[FJPhotoManager shared] clean];
    });
}

- (void)_buildUI {
    
    MF_WEAK_SELF
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    [self fj_navigationBarHidden:NO];
    [self fj_navigationBarStyle:[UIColor whiteColor] translucent:NO bottomLineColor:@"#E6E6E6".fj_color];
    [self fj_addLeftBarButton:[FJStorage podImage:@"ic_back" class:[self class]] action:^{
        [weakSelf _cleanPhotoManager];
        [weakSelf fj_dismiss];
    }];
    [self fj_addRightBarCustomView:self.nextBtn action:nil];
    
    // Title View
    if (_customTitleView == nil) {
        _customTitleView = [FJPhotoEditTitleScrollView create:self.selectedPhotoAssets.count];
        self.navigationItem.titleView = _customTitleView;
    }
    
    // Tool Bar
    if (_toolbar == nil) {
        static NSString *_ratio = nil;
        static BOOL _confirm = NO;
        _toolbar = [FJPhotoEditToolbarView create:FJPhotoEditModeAll editingBlock:^(BOOL inEditing) {
            NSLog(@"In Editing : %@", inEditing ? @"YES" : @"NO");
            if (inEditing) {
                weakSelf.scrollView.hidden = YES;
                [weakSelf.customTitleView setPageControllHidden:YES];
                [weakSelf.nextBtn fj_setTitleColor:@"#78787D".fj_color];
                [weakSelf.nextBtn setUserInteractionEnabled:NO];
            }else {
                weakSelf.scrollView.hidden = NO;
                weakSelf.cropperView.hidden = YES;
                weakSelf.filterView.hidden = YES;
                [weakSelf.customTitleView setPageControllHidden:NO];
                [weakSelf.nextBtn fj_setTitleColor:@"#FF7725".fj_color];
                [weakSelf.nextBtn setUserInteractionEnabled:YES];
                _ratio = nil;
            }
        } cropBlock:^(NSString *ratio, BOOL confirm) {
            
            if ([ratio isEqualToString:_ratio] && confirm == _confirm) {
                return;
            }else {
                _ratio = ratio;
                _confirm = confirm;
            }
            NSLog(@"Ration : %@ Confirm : %@", ratio, confirm ? @"YES" : @"NO");
            if (confirm) {
                weakSelf.cropperView.hidden = YES;
                UIImage *croppedImage = [weakSelf.cropperView croppedImage];
                [[FJPhotoManager shared] setCurrentCroppedImage:croppedImage];
                [weakSelf _refreshScrollView];
            }else {
                float r = 1.0;
                if ([ratio isEqualToString:@"1:1"]) {
                    r = 1.0;
                }else if ([ratio isEqualToString:@"3:4"]) {
                    r = 3.0 / 4.0;
                }else if ([ratio isEqualToString:@"4:3"]) {
                    r = 4.0 / 3.0;
                }else if ([ratio isEqualToString:@"4:5"]) {
                    r = 4.0 / 5.0;
                }else if ([ratio isEqualToString:@"5:4"]) {
                    r = 5.0 / 4.0;
                }
                weakSelf.scrollView.hidden = YES;
                weakSelf.cropperView.hidden = NO;
                [weakSelf.view bringSubviewToFront:weakSelf.cropperView];
                [weakSelf.cropperView updateImage:[FJPhotoManager shared].currentPhotoImage ratio:r];
            }
        } tuneBlock:^(FJTuningType type, float value, BOOL confirm) {
            NSLog(@"Tune Type : %d Value : %f Confirm : %@", (int)type, value, confirm ? @"YES" : @"NO");
            if (confirm) {
                weakSelf.filterView.hidden = YES;
                [[FJPhotoManager shared] setCurrentTuningObject:type value:value];
            }else {
                [weakSelf.view bringSubviewToFront:weakSelf.filterView];
                weakSelf.filterView.hidden = NO;
                switch (type) {
                    case FJTuningTypeLight:
                    {
                        [weakSelf.filterView updateBrightness:value];
                        break;
                    }
                    case FJTuningTypeContrast:
                    {
                        [weakSelf.filterView updateContrast:value];
                        break;
                    }
                    case FJTuningTypeSaturation:
                    {
                        [weakSelf.filterView updateSaturation:value];
                        break;
                    }
                    case FJTuningTypeWarm:
                    {
                        [weakSelf.filterView updateTemperature:value];
                        break;
                    }
                    case FJTuningTypeHalation:
                    {
                        [weakSelf.filterView updateVignette:value];
                        break;
                    }
                    default:
                        break;
                }
            }
        }];
        [self.view addSubview:_toolbar];
        [_toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(weakSelf.view);
            make.height.equalTo(@167.0);
        }];
        
        _toolbar.filterBlock = ^{
            NSLog(@"tap filter");
        };
        
        _toolbar.tagBlock = ^{
            NSLog(@"tap tag");
        };
    }
    
    // ScrollView
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT - UI_TOP_HEIGHT - _toolbar.bounds.size.height)];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:_scrollView];
        
        __weak typeof(_scrollView) weakScrollView = _scrollView;
        
        for (PHAsset *asset in self.selectedPhotoAssets) {
            [FJPhotoManager getStaticTargetImage:asset result:^(UIImage *image) {
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                NSUInteger index = [weakSelf.selectedPhotoAssets indexOfObject:asset];
                imageView.frame = CGRectMake(weakScrollView.bounds.size.width * index, 0, weakScrollView.bounds.size.width, weakScrollView.bounds.size.height);
                [weakScrollView addSubview:imageView];
                imageView.tag = [asset hash];
            }];
        }
        _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width * self.selectedPhotoAssets.count, _scrollView.bounds.size.height);
    }
}

- (void)_refreshScrollView {
    
    for (int i = 0; i < [self.scrollView.subviews count]; i++) {
        PHAsset *asset = [[FJPhotoManager shared].selectedPhotoAssets fj_safeObjectAtIndex:i];
        UIImage *croppedImage = [[FJPhotoManager shared] croppedImage:asset];
        if (croppedImage != nil) {
            for (UIImageView *imageView in self.scrollView.subviews) {
                if (imageView.tag == [asset hash]) {
                    imageView.image = croppedImage;
                    break;
                }
            }
        }
    }
}

- (void)_tapNext {
    
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSUInteger page = (NSUInteger)(scrollView.contentOffset.x / UI_SCREEN_WIDTH);
    [FJPhotoManager shared].currentIndex = page;
    [self.customTitleView updateIndex:page];
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
