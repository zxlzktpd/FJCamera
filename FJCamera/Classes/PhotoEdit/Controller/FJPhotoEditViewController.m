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
#import "FJPhotoUserTagBaseViewController.h"
#import "FJPhotoImageTagView.h"
#import "FJPhotoTagAlertView.h"
#import "FJImageTagModel.h"
#import <FJKit_OC/NSString+Image_FJ.h>
#import <FJKit_OC/UIImage+Utility_FJ.h>

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
// Tag Deletion ImageView
@property (nonatomic, strong) UIImageView *deletionImageView;
// Current ImageView on ScrollView
@property (nonatomic, strong) UIImageView *currentImageView;

// Edit Controller Block
@property (nonatomic, copy) __kindof FJPhotoUserTagBaseViewController * (^editController)(FJPhotoEditViewController *controller);

// Index
@property (nonatomic, assign) NSUInteger index;

@end

@implementation FJPhotoEditViewController

- (UIImageView *)deletionImageView {
    
    if (_deletionImageView == nil) {
        _deletionImageView = [[UIImageView alloc] init];
        _deletionImageView.image = @"FJPhotoEditViewController.ic_tag_garbage".fj_image;
        [self.view addSubview:_deletionImageView];
    }
    return _deletionImageView;
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
        _filterView = [FJFilterImageView create:_scrollView.frame];
        [self.view addSubview:_filterView];
        [self.view bringSubviewToFront:_filterView];
    }
    return _filterView;
}

- (void)dealloc {
    
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.mode = FJPhotoEditModeFilter | FJPhotoEditModeCropprer | FJPhotoEditModeTuning | FJPhotoEditModeTag;
    }
    return self;
}

- (instancetype)initWithMode:(FJPhotoEditMode)mode editController:(__kindof FJPhotoUserTagBaseViewController * (^)(FJPhotoEditViewController *controller))editController {
    
    self = [self init];
    if (self) {
        self.mode = mode;
        if (editController != nil) {
            self.editController = editController;
            __kindof FJPhotoUserTagBaseViewController *userTagAddVC = self.editController(self);
            userTagAddVC.delegate = self;
            self.userTagController = userTagAddVC;
        }
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // 初始化UI
    [self _buildUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_buildUI {
    
    MF_WEAK_SELF
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    [self fj_navigationBarHidden:NO];
    [self fj_navigationBarStyle:[UIColor whiteColor] translucent:NO bottomLineColor:@"#E6E6E6".fj_color];
    if (self.editPhotoIndex == nil) {
        [self fj_addLeftBarButton:[FJStorage podImage:@"ic_back" class:[self class]] action:^{
            [weakSelf fj_dismiss];
        }];
    }
    [self fj_addRightBarCustomView:self.nextBtn action:nil];
    
    // 定位当前Photo Index
    if (self.editPhotoIndex != nil) {
        self.index = [self.editPhotoIndex intValue];
        // 当从编辑进来的，相册数量同步FJPhotoManager
        [FJPhotoManager shared].currentEditPhoto = [self.selectedPhotos objectAtIndex:self.index];
    }else {
        self.index = 0;
        [FJPhotoManager shared].currentEditPhoto = [self.selectedPhotos objectAtIndex:0];
    }
    
    // Title View
    if (_customTitleView == nil) {
        _customTitleView = [FJPhotoEditTitleScrollView create:self.selectedPhotos.count];
        self.navigationItem.titleView = _customTitleView;
    }
    
    // Tool Bar
    if (_toolbar == nil) {
        static NSString *_ratio = nil;
        static BOOL _confirm = NO;
        _toolbar = [FJPhotoEditToolbarView create:self.mode editingBlock:^(BOOL inEditing) {
            
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
                FJPhotoModel *currentPhoto = [FJPhotoManager shared].currentEditPhoto;
                if (currentPhoto.imageTags.count > 0 && weakSelf.currentImageView.subviews.count == 0) {
                    // 裁剪界面返回完成后恢复TagView
                    for (FJImageTagModel *tagModel in currentPhoto.imageTags) {
                        CGPoint p = CGPointMake(weakSelf.currentImageView.bounds.size.width * tagModel.xPercent, weakSelf.currentImageView.bounds.size.height * tagModel.yPercent);
                        [weakSelf _addImageTagOnImageView:weakSelf.currentImageView tag:tagModel point:p];
                    }
                }
            }
        } filterBlock:^(FJFilterType filterType) {
            
            FJPhotoModel *currentPhoto = [FJPhotoManager shared].currentEditPhoto;
            currentPhoto.tuningObject.filterType = filterType;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf _refreshCurrentImageViewToScrollView:nil];
            });
        } cropBlock:^(NSString *ratio, BOOL confirm) {
            
            // 暂时删除当前ImageView视图的所有TagView
            for (FJPhotoImageTagView *tagView in weakSelf.currentImageView.subviews) {
                if ([tagView isKindOfClass:[FJPhotoImageTagView class]]) {
                    [tagView removeFromSuperview];
                }
            }
            
            if ([ratio isEqualToString:_ratio] && confirm == _confirm) {
                return;
            }else {
                _ratio = ratio;
                _confirm = confirm;
            }
            if (confirm) {
                UIImage *croppedImage = [weakSelf.cropperView croppedImage];
                FJPhotoModel *currentPhoto = [FJPhotoManager shared].currentEditPhoto;
                [FJPhotoManager shared].currentEditPhoto.croppedImage = croppedImage;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf _refreshCurrentImageViewToScrollView:nil];
                });
                // 裁剪完成后恢复TagView
                for (FJImageTagModel *tagModel in currentPhoto.imageTags) {
                    CGPoint p = CGPointMake(weakSelf.currentImageView.bounds.size.width * tagModel.xPercent, weakSelf.currentImageView.bounds.size.height * tagModel.yPercent);
                    [weakSelf _addImageTagOnImageView:weakSelf.currentImageView tag:tagModel point:p];
                }
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
                weakSelf.cropperView.hidden = NO;
                [weakSelf.view bringSubviewToFront:weakSelf.cropperView];
                // 效果图
                FJPhotoModel *currentPhoto = [FJPhotoManager shared].currentEditPhoto;
                [weakSelf.cropperView updateImage:currentPhoto.currentImage ratio:r];
                [weakSelf.cropperView updateCurrentTuning:currentPhoto.tuningObject];
            }
        } tuneBlock:^(FJTuningType type, float value, BOOL confirm) {
            
            FJPhotoModel *currentPhoto = [FJPhotoManager shared].currentEditPhoto;
            if (confirm) {
                [currentPhoto.tuningObject setType:type value:value];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf _refreshCurrentImageViewToScrollView:nil];
                });
            }else {
                [weakSelf.view bringSubviewToFront:weakSelf.filterView];
                weakSelf.filterView.hidden = NO;
                
                // 当点击调整Tab时候，默认会进来一次
                // 当tuningObject值和value相等表示是第一次进来
                // 否则，非第一次进来，不设置效果图，提高性能
                BOOL isFirst = NO;
                switch (type) {
                    case FJTuningTypeBrightness:
                    {
                        if (currentPhoto.tuningObject.brightnessValue == value) {
                            isFirst = YES;
                        }
                        break;
                    }
                    case FJTuningTypeContrast:
                    {
                        if (currentPhoto.tuningObject.contrastValue == value) {
                            isFirst = YES;
                        }
                        break;
                    }
                    case FJTuningTypeSaturation:
                    {
                        if (currentPhoto.tuningObject.saturationValue == value) {
                            isFirst = YES;
                        }
                        break;
                    }
                    case FJTuningTypeTemperature:
                    {
                        if (currentPhoto.tuningObject.temperatureValue == value) {
                            isFirst = YES;
                        }
                        break;
                    }
                    case FJTuningTypeVignette:
                    {
                        if (currentPhoto.tuningObject.vignetteValue == value) {
                            isFirst = YES;
                        }
                        break;
                    }
                }
                if (isFirst) {
                    // 效果图
                    [weakSelf.filterView updateImage:currentPhoto.currentImage];
                    [weakSelf.filterView updateCurrentTuning:currentPhoto.tuningObject];
                }
                switch (type) {
                    case FJTuningTypeBrightness:
                    {
                        [weakSelf.filterView updatePhoto:currentPhoto brightness:value contrast:currentPhoto.tuningObject.contrastValue saturation:currentPhoto.tuningObject.saturationValue];
                        break;
                    }
                    case FJTuningTypeContrast:
                    {
                        [weakSelf.filterView updatePhoto:currentPhoto brightness:currentPhoto.tuningObject.brightnessValue contrast:value saturation:currentPhoto.tuningObject.saturationValue];
                        break;
                    }
                    case FJTuningTypeSaturation:
                    {
                        [weakSelf.filterView updatePhoto:currentPhoto brightness:currentPhoto.tuningObject.brightnessValue contrast:currentPhoto.tuningObject.contrastValue saturation:value];
                        break;
                    }
                    case FJTuningTypeTemperature:
                    {
                        [weakSelf.filterView updatePhoto:currentPhoto temperature:value];
                        break;
                    }
                    case FJTuningTypeVignette:
                    {
                        [weakSelf.filterView updatePhoto:currentPhoto vignette:value];
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
        
        _toolbar.tagBlock = ^{
            
            if ([weakSelf.userTagController isKindOfClass:[FJPhotoUserTagBaseViewController class]]) {
                ((FJPhotoUserTagBaseViewController *)weakSelf.userTagController).point = CGPointMake(weakSelf.currentImageView.bounds.size.width / 2.0 - 50.0, weakSelf.currentImageView.bounds.size.height / 2.0 - 24.0);
                [weakSelf.navigationController pushViewController:weakSelf.userTagController animated:YES];
            }
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
        for (NSUInteger index = 0; index < self.selectedPhotos.count; index++) {
            
            FJPhotoModel *model = [self.selectedPhotos objectAtIndex:index];
            UIImage *image = model.croppedImage;
            if (image == nil) {
                if (model.needCrop) {
                    model.croppedImage = [model.originalImage fj_imageCropBeginPointRatio:model.beginCropPoint endPointRatio:model.endCropPoint];
                    image = model.croppedImage;
                }
                if (image == nil) {
                    image = model.originalImage;
                }
            }
            
            // 加调整和滤镜效果
            image = [[FJFilterManager shared] getImage:image tuningObject:model.tuningObject appendFilterType:model.tuningObject.filterType];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            if (image.size.width / image.size.height >= _scrollView.bounds.size.width / _scrollView.bounds.size.height) {
                CGFloat h = image.size.height / image.size.width * _scrollView.bounds.size.width;
                CGFloat y = (_scrollView.bounds.size.height - h) / 2.0;
                imageView.frame = CGRectMake(_scrollView.bounds.size.width * index, y, _scrollView.bounds.size.width, h);
            }else {
                CGFloat w = image.size.width / image.size.height * _scrollView.bounds.size.height;
                CGFloat x = (_scrollView.bounds.size.width - w) / 2.0;
                imageView.frame = CGRectMake(_scrollView.bounds.size.width * index + x, 0, w, _scrollView.bounds.size.height);
            }
            [_scrollView addSubview:imageView];
            if (model.asset != nil) {
                imageView.tag = [model.asset hash];
            }else if(model.photoUrl != nil) {
                imageView.tag = [model.photoUrl hash];
            }
            
            // 添加TagView
            if (model.imageTags.count == 0) {
                // 添加提示标签语：添加说明标签可以被更多人看见
                FJImageTagModel *hintTagModel = [[FJImageTagModel alloc] init];
                hintTagModel.isHint = YES;
                hintTagModel.name = @"添加说明标签可以被更多人看见";
                hintTagModel.xPercent = (UI_SCREEN_WIDTH) / 2.0 / UI_SCREEN_WIDTH;
                hintTagModel.yPercent = (imageView.bounds.size.height - 50.0) / imageView.bounds.size.height;
                hintTagModel.direction = 0;
                hintTagModel.v = @"1";
                CGPoint p = CGPointMake(imageView.bounds.size.width * hintTagModel.xPercent, imageView.bounds.size.height * hintTagModel.yPercent);
                [weakSelf _addImageTagOnImageView:imageView tag:hintTagModel point:p];
            }else {
                for (FJImageTagModel *tagModel in model.imageTags) {
                    CGPoint p = CGPointMake(imageView.bounds.size.width * tagModel.xPercent, imageView.bounds.size.height * tagModel.yPercent);
                    [weakSelf _addImageTagOnImageView:imageView tag:tagModel point:p];
                }
            }
            // 打Tag手势
            [imageView setUserInteractionEnabled:YES];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapAddTag:)];
            [imageView addGestureRecognizer:tap];
            
        }
        _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width * self.selectedPhotos.count, _scrollView.bounds.size.height);
    }
    
    // 滚动到当前相片
    [_scrollView setContentOffset:CGPointMake(UI_SCREEN_WIDTH * self.index, 0)];
    [self.customTitleView updateIndex:self.index];
}

// 当前操作的Image视图
- (UIImageView *)currentImageView {
    
    FJPhotoModel *currentModel = [FJPhotoManager shared].currentEditPhoto;
    for (UIImageView *imageView in self.scrollView.subviews) {
        if (currentModel.asset != nil) {
            if (imageView.tag == [currentModel.asset hash]) {
                return imageView;
            }
        }else if (currentModel.photoUrl != nil) {
            if (imageView.tag == [currentModel.photoUrl hash]) {
                return imageView;
            }
        }
    }
    return nil;
}

- (void)_refreshCurrentImageViewToScrollView:(void(^)(UIImage *image))result {
    
    // 裁切
    MF_WEAK_SELF
    FJPhotoModel *currentModel = [FJPhotoManager shared].currentEditPhoto;
    UIImage *image = currentModel.croppedImage;
    BOOL cropped = NO;
    if (image == nil) {
        // 原图
        image = currentModel.originalImage;
    }else {
        // 裁切
        cropped = YES;
    }
    // 加调整和滤镜效果
    // TODO TEST
    // UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    // imageView.frame = CGRectMake(100, 50, 50, 50);
    // [MF_KEY_WINDOW addSubview:imageView];
    image = [[FJFilterManager shared] getImage:image tuningObject:currentModel.tuningObject appendFilterType:currentModel.tuningObject.filterType];
    // imageView = [[UIImageView alloc] initWithImage:image];
    // imageView.frame = CGRectMake(180, 50, 50, 50);
    // [MF_KEY_WINDOW addSubview:imageView];
    
    self.currentImageView.image = image;
    if (cropped) {
        if (image.size.width /
            image.size.height >= weakSelf.scrollView.bounds.size.width / weakSelf.scrollView.bounds.size.height) {
            CGFloat h = image.size.height / image.size.width * weakSelf.scrollView.bounds.size.width;
            CGFloat y = (weakSelf.scrollView.bounds.size.height - h) / 2.0;
            self.currentImageView.frame = CGRectMake(weakSelf.scrollView.bounds.size.width * weakSelf.index, y, weakSelf.scrollView.bounds.size.width, h);
        }else {
            CGFloat w = image.size.width / image.size.height * weakSelf.scrollView.bounds.size.height;
            CGFloat x = (weakSelf.scrollView.bounds.size.width - w) / 2.0;
            self.currentImageView.frame = CGRectMake(weakSelf.scrollView.bounds.size.width * weakSelf.index + x, 0, w, weakSelf.scrollView.bounds.size.height);
        }
    }
    result == nil ? : result(image);
}

- (void)_tapAddTag:(UITapGestureRecognizer *)tapGesuture {
    
    // 把Hint Tag View删除
    for (FJPhotoImageTagView *tagView in self.currentImageView.subviews) {
        if ([tagView isKindOfClass:[FJPhotoImageTagView class]]) {
            if ([tagView getTagModel].isHint == YES) {
                [tagView removeFromSuperview];
            }
        }
    }
    
    // 跳转用户的标签选择页面
    UIImageView *imageView = (UIImageView *)tapGesuture.view;
    if ([imageView isKindOfClass:[UIImageView class]]) {
        CGPoint p = [tapGesuture locationInView:imageView];
        if ([self.userTagController isKindOfClass:[FJPhotoUserTagBaseViewController class]]) {
            ((FJPhotoUserTagBaseViewController *)self.userTagController).point = p;
            [self.navigationController pushViewController:self.userTagController animated:YES];
        }
    }
}

- (void)_addImageTagOnImageView:(UIImageView *)imageView tag:(FJImageTagModel *)tag point:(CGPoint)point {
    
    MF_WEAK_SELF
    tag.createdTime = [[NSDate date] timeIntervalSince1970];
    tag.xPercent = point.x / imageView.bounds.size.width;
    tag.yPercent = point.y / imageView.bounds.size.height;
    // 切换方向的Hint
    __block NSNumber *shownImageTagHint = [[NSUserDefaults standardUserDefaults] valueForKey:@"shownImageTagHint"];
    if (shownImageTagHint == nil && tag.isHint == NO) {
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"shownImageTagHint"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    FJPhotoImageTagView *tagView = [FJPhotoImageTagView create:point containerSize:imageView.bounds.size model:tag tapBlock:^(__weak FJPhotoImageTagView * photoImageTagView) {
        
        if (shownImageTagHint == nil && tag.isHint == NO) {
            for (UILabel *hintLabel in imageView.subviews) {
                if ([hintLabel isKindOfClass:[UILabel class]] && hintLabel.tag == 1001) {
                    [hintLabel removeFromSuperview];
                    break;
                }
            }
        }
    } movingBlock:^(UIGestureRecognizerState state, CGPoint point, FJPhotoImageTagView *imageTagView) {
        
        static BOOL isDeletion;
        switch (state) {
            case UIGestureRecognizerStateBegan:
            {
                weakSelf.deletionImageView.hidden = NO;
                weakSelf.deletionImageView.frame = CGRectMake((weakSelf.scrollView.frame.size.width - 48.0) / 2.0, weakSelf.currentImageView.frame.origin.y + weakSelf.currentImageView.frame.size.height - 48.0 - 20.0 , 48.0, 48.0);
                [self.view bringSubviewToFront:weakSelf.deletionImageView];
                if (shownImageTagHint == nil && tag.isHint == NO) {
                    for (UILabel *hintLabel in imageView.subviews) {
                        if ([hintLabel isKindOfClass:[UILabel class]] && hintLabel.tag == 1001) {
                            [hintLabel removeFromSuperview];
                            break;
                        }
                    }
                }
                break;
            }
            case UIGestureRecognizerStateChanged:
            {
                if (point.x >= weakSelf.deletionImageView.frame.origin.x &&
                    point.x <= weakSelf.deletionImageView.frame.origin.x + weakSelf.deletionImageView.frame.size.width &&
                    point.y >= weakSelf.deletionImageView.frame.origin.y &&
                    point.y <= weakSelf.deletionImageView.frame.origin.y + weakSelf.deletionImageView.frame.size.height) {
                    if (isDeletion == NO) {
                        [UIView animateWithDuration:0.3 animations:^{
                            weakSelf.deletionImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
                        }];
                    }
                    imageTagView.hidden = YES;
                    isDeletion = YES;
                }else {
                    if (isDeletion == YES) {
                        weakSelf.deletionImageView.transform = CGAffineTransformIdentity;
                    }
                    imageTagView.hidden = NO;
                    isDeletion = NO;
                }
                break;
            }
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateEnded:
            {
                weakSelf.deletionImageView.hidden = YES;
                if (isDeletion && state == UIGestureRecognizerStateEnded) {
                    FJPhotoModel *photoModel = [FJPhotoManager shared].currentEditPhoto;
                    [photoModel.imageTags removeObject:[imageTagView getTagModel]];
                    [imageTagView removeFromSuperview];
                }
                isDeletion = NO;
                weakSelf.deletionImageView.transform = CGAffineTransformIdentity;
                break;
            }
            default:
                break;
        }
    }];
    [imageView addSubview:tagView];
    
    if (shownImageTagHint == nil && tag.isHint == NO) {
        UILabel *hintTapReverseLabel = [[UILabel alloc] init];
        hintTapReverseLabel.tag = 1001;
        hintTapReverseLabel.frame = CGRectMake(tagView.frame.origin.x + tagView.frame.size.width / 2.0 + 8.0, tagView.frame.origin.y - 2.0, 120.0, 18.0);
        if (hintTapReverseLabel.frame.origin.x + hintTapReverseLabel.frame.size.width >= UI_SCREEN_WIDTH) {
            hintTapReverseLabel.frame = CGRectMake(hintTapReverseLabel.frame.origin.x - hintTapReverseLabel.frame.size.width - 8.0 * 2.0, hintTapReverseLabel.frame.origin.y, hintTapReverseLabel.frame.size.width, hintTapReverseLabel.frame.size.height);
        }
        hintTapReverseLabel.backgroundColor = @"#FF7A00".fj_color;
        hintTapReverseLabel.attributedText = @"轻触圆点切换方向".typeset.font([UIFont systemFontOfSize:12.0].fontName, 12.0).color([UIColor whiteColor]).textAlignment(NSTextAlignmentCenter).string;
        [hintTapReverseLabel fj_cornerRadius:hintTapReverseLabel.frame.size.height / 2.0];
        [imageView addSubview:hintTapReverseLabel];
        /*
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            for (UILabel *hintLabel in imageView.subviews) {
                if ([hintLabel isKindOfClass:[UILabel class]] && hintLabel.tag == 1001) {
                    [hintLabel removeFromSuperview];
                    break;
                }
            }
        }); */
    }
}

- (void)_tapNext {
    
    self.userEditNextBlock == nil ? : self.userEditNextBlock();
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSUInteger page = (NSUInteger)(scrollView.contentOffset.x / UI_SCREEN_WIDTH);
    self.index = page;
    [self.customTitleView updateIndex:page];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [FJPhotoManager shared].currentEditPhoto = [self.selectedPhotos objectAtIndex:self.index];
    if ([_toolbar getIndex] == 0) {
        [self.toolbar refreshFilterToolbar];
    }
}

#pragma mark - FJPhotoEditTagDelegate
- (void)fj_photoEditAddTag:(FJImageTagModel *)model point:(CGPoint)point {
    
    FJPhotoModel *photoModel = [FJPhotoManager shared].currentEditPhoto;
    [photoModel.imageTags addObject:model];
    [self _addImageTagOnImageView:self.currentImageView tag:model point:point];
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
