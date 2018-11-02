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
        _filterView = [FJFilterImageView create:_scrollView.frame];
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
    // [self _refreshScrollView];
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
                [weakSelf.customTitleView setPageControllHidden:NO];
                [weakSelf.nextBtn fj_setTitleColor:@"#FF7725".fj_color];
                [weakSelf.nextBtn setUserInteractionEnabled:YES];
                weakSelf.cropperView.hidden = YES;
                weakSelf.filterView.hidden = YES;
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
                UIImage *croppedImage = [weakSelf.cropperView croppedImage];
                [[FJPhotoManager shared] setCurrentCroppedImage:croppedImage];
                [weakSelf _refreshCurrentImageViewToScrollView:YES result:nil];
            }else {
                __block float r = 1.0;
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
                weakSelf.cropperView.hidden = NO;
                [weakSelf.view bringSubviewToFront:weakSelf.cropperView];
                // 效果图
                UIImage *image = [[FJPhotoManager shared] currentCroppedImage];
                if (image == nil) {
                    // 原图
                    image = [FJPhotoManager shared].currentPhotoImage;
                }
                [weakSelf.cropperView updateImage:image ratio:r];
                [weakSelf.cropperView updateCurrentTuning:[FJPhotoManager shared].currentTuningObject];
            }
        } tuneBlock:^(FJTuningType type, float value, BOOL confirm) {
            NSLog(@"Tune Type : %d Value : %f Confirm : %@", (int)type, value, confirm ? @"YES" : @"NO");
            if (confirm) {
                [[FJPhotoManager shared] setCurrentTuningObject:type value:value];
                [weakSelf _refreshCurrentImageViewToScrollView:YES result:nil];
            }else {
                [weakSelf.view bringSubviewToFront:weakSelf.filterView];
                weakSelf.filterView.hidden = NO;
                // 效果图
                UIImage *image = [[FJPhotoManager shared] currentCroppedImage];
                if (image == nil) {
                    // 原图
                    image = [FJPhotoManager shared].currentPhotoImage;
                }
                [weakSelf.filterView updateImage:image];
                switch (type) {
                    case FJTuningTypeBrightness:
                    {
                        FJTuningObject *tuneObject = [FJPhotoManager shared].currentTuningObject;
                        [weakSelf.filterView updateBrightness:value contrast:tuneObject.contrastValue saturation:tuneObject.saturationValue];
                        break;
                    }
                    case FJTuningTypeContrast:
                    {
                        FJTuningObject *tuneObject = [FJPhotoManager shared].currentTuningObject;
                        [weakSelf.filterView updateBrightness:tuneObject.brightnessValue contrast:value saturation:tuneObject.saturationValue];
                        break;
                    }
                    case FJTuningTypeSaturation:
                    {
                        FJTuningObject *tuneObject = [FJPhotoManager shared].currentTuningObject;
                        [weakSelf.filterView updateBrightness:tuneObject.brightnessValue contrast:tuneObject.contrastValue saturation:value];
                        break;
                    }
                    case FJTuningTypeTemperature:
                    {
                        [weakSelf.filterView updateTemperature:value];
                        break;
                    }
                    case FJTuningTypeVignette:
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

- (void)_refreshCurrentImageViewToScrollView:(BOOL)refresh result:(void(^)(UIImage *image))result {
    
    // 裁切
    MF_WEAK_SELF
    FJTuningObject *tuningObject = [FJPhotoManager shared].currentTuningObject;
    __block PHAsset *asset = [FJPhotoManager shared].currentPhotoAsset;
    UIImage *image = [FJPhotoManager shared].currentCroppedImage;
    if (image == nil) {
        // 原图
        image = [FJPhotoManager shared].currentPhotoImage;
    }else {
        // 裁切
    }
    // 加调整和滤镜效果
    [[FJFilterManager shared] getImage:image tuningObject:tuningObject appendFilterType:FJFilterTypeNull result:^(UIImage *image) {
        
        if (refresh) {
            for (UIImageView *imageView in weakSelf.scrollView.subviews) {
                if (imageView.tag == [asset hash]) {
                    imageView.image = image;
                    break;
                }
            }
        }
        result == nil ? : result(image);
    }];
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
