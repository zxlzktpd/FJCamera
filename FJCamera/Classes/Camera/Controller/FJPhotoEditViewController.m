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

@end

@implementation FJPhotoEditViewController

- (UIButton *)nextBtn {
    
    if (_nextBtn == nil) {
        _nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
        [_nextBtn fj_setTitle:@"下一步"];
        [_nextBtn fj_setTitleFont:[UIFont systemFontOfSize:14.0]];
        [_nextBtn fj_setTitleColor:@"#FF7725".fj_color];
        [_nextBtn setUserInteractionEnabled:NO];
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
            }else {
                weakSelf.scrollView.hidden = NO;
                weakSelf.cropperView.hidden = YES;
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
                [weakSelf.cropperView updateImage:[FJPhotoManager shared].currentPhotoImage ratio:r];
            }
        } tuneBlock:^(FJTuningType type, float value, BOOL confirm) {
            NSLog(@"Tune Type : %d Value : %f Confirm : %@", (int)type, value, confirm ? @"YES" : @"NO");
            [[FJPhotoManager shared] setCurrentTuningObject:type value:value];
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
