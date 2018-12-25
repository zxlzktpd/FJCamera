//
//  FJCropperView.m
//  FJCamera
//
//  Created by Fu Jie on 2018/11/13.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJCropperView.h"
#import "PHAsset+QuickEdit.h"
#import <FJKit_OC/Macro.h>
#import <FJKit_OC/UIImage+Utility_FJ.h>

@interface FJImageScrollView()

@end

@implementation FJImageScrollView

- (instancetype)init {
    self = [super init];
    if (self) {
        NSAssert(NO, @"FJImageScrollView : Please Use - initWithFrame:");
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _buildUI];
    }
    return self;
}

- (void)_buildUI {
    
    self.clipsToBounds = NO;
    self.layer.masksToBounds = NO;
    self.maximumZoomScale = 1.0;
    self.minimumZoomScale = 1.0;
    self.zoomScale = 1.0;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.bounces = YES;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [self addSubview:imageView];
    self.imageView = imageView;
}

@end

@interface FJCropperView () <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *scrollViews;
@property (nonatomic, strong) FJImageScrollView *currentScrollView;
@property (nonatomic, weak) IBOutlet UIView *toolView;
@property (nonatomic, weak) IBOutlet UIImageView *expandImageView;
@property (nonatomic, weak) IBOutlet UIImageView *updownImageView;
@property (nonatomic, weak) IBOutlet UIButton *expandButton;
@property (nonatomic, weak) IBOutlet UIButton *updownButton;

@property (nonatomic, assign) CGFloat horizontalExtemeRatio;
@property (nonatomic, assign) CGFloat verticalExtemeRatio;

// 1：扁长（超比例）  2：扁长（范围内） 3：窄长（超比例） 4：窄长（范围内）
@property (nonatomic, assign) int type;
@property (nonatomic, assign) CGFloat base;
@property (nonatomic, assign) BOOL inCrop;
@property (nonatomic, assign) BOOL isFirst;
@property (nonatomic, assign) BOOL isDebug;

@property (nonatomic, copy) void(^croppedBlock)(FJPhotoModel *photoModel, CGRect frame);
@property (nonatomic, copy) void(^updownBlock)(BOOL up);

@end

@implementation FJCropperView

- (NSMutableArray *)scrollViews {
    
    if (_scrollViews == nil) {
        _scrollViews = [[NSMutableArray alloc] init];
    }
    return _scrollViews;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
}

+ (FJCropperView *)create:(CGFloat)horizontalExtemeRatio verticalExtemeRatio:(CGFloat)verticalExtemeRatio debug:(BOOL)debug croppedBlock:(void(^)(FJPhotoModel *photoModel, CGRect frame))croppedBlock updownBlock:(void(^)(BOOL up))updownBlock {
    
    FJCropperView *view = MF_LOAD_NIB(@"FJCropperView");
    view.clipsToBounds = YES;
    view.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_WIDTH);
    view.horizontalExtemeRatio = horizontalExtemeRatio;
    view.verticalExtemeRatio = verticalExtemeRatio;
    view.croppedBlock = croppedBlock;
    view.updownBlock = updownBlock;
    view.inCrop = NO;
    view.isFirst = YES;
    view.isDebug = debug;
    // Setup UI
    [view _buildNewImageScrollView];
    return view;
}

// 新建
- (void)_buildNewImageScrollView {
    
    // ScrollView
    self.currentScrollView = [[FJImageScrollView alloc] initWithFrame:self.bounds];
    [self.scrollViews addObject:self.currentScrollView];
    self.currentScrollView.delegate = self;
    [self addSubview:self.currentScrollView];
    if (self.isDebug) {
        self.backgroundColor = [UIColor redColor];
        self.currentScrollView.backgroundColor = [UIColor grayColor];
    }else {
        self.backgroundColor = @"#F5F5F5".fj_color;
        self.currentScrollView.backgroundColor = @"#F5F5F5".fj_color;
    }
    
    [self bringSubviewToFront:self.currentScrollView];
    [self bringSubviewToFront:self.toolView];
}

// 更新图片
- (void)updateModel:(FJPhotoModel *)model {
    
    FJImageScrollView *imageScrollView = nil;
    UIImage *image = [model.asset getGeneralTargetImage];
    if (image == nil) {
        [self fj_toast:FJToastImageTypeNone message:@"iCloud照片正在下载中"];
        return;
    }
    for (FJImageScrollView *scrollView in self.scrollViews) {
        if (scrollView.photoModel == nil) {
            scrollView.hidden = NO;
            imageScrollView = scrollView;
            self.currentScrollView = scrollView;
            self.currentScrollView.photoModel = model;
            [self _updateImageView:NO image:image];
        }else if ([scrollView.photoModel isEqual:model]) {
            scrollView.hidden = NO;
            imageScrollView = scrollView;
            self.currentScrollView = scrollView;
            if ([scrollView isEqual:[self.subviews fj_arrayObjectAtIndex:self.subviews.count - 2]]) {
                [self _cropImage];
            }else {
                [self bringSubviewToFront:scrollView];
                [self bringSubviewToFront:self.toolView];
            }
        }else {
            scrollView.hidden = YES;
        }
    }
    if (imageScrollView == nil) {
        [self _buildNewImageScrollView];
        self.currentScrollView.photoModel = model;
        [self _updateImageView:NO image:image];
    }
}

// 更新向上和向下的状态
- (void)updateUp:(BOOL)up {
    
    [self.updownImageView setHighlighted:up];
}

// 获取向上和向下的状态
- (BOOL)getUp {
    
    return self.updownImageView.highlighted;
}

// 是否在裁切图片
- (BOOL)inCroppingImage {
    
    return self.currentScrollView.photoModel.needCrop && self.inCrop;
}

// 更新留白和充满状态
- (void)_updateImageView:(BOOL)compressChange image:(UIImage *)image {
    
    FJPhotoModel *model = self.currentScrollView.photoModel;
    if (image != nil) {
        self.currentScrollView.imageView.image = image;
    }else {
        self.currentScrollView.imageView.image = [model.asset getGeneralTargetImage];
    }
    if (self.currentScrollView.imageView.image == nil) {
        [self fj_toast:FJToastImageTypeNone message:@"iCloud照片正在下载中"];
        return;
    }
    
    // 图像处理
    CGRect scrollViewFrame = CGRectZero;
    CGRect imageViewFrame = CGRectZero;
    CGSize scrollViewContentSize = CGSizeZero;
    CGFloat maxScale = 3.0;
    CGFloat minScale = 1.0;
    CGPoint scrollViewOffset = CGPointZero;
    image = self.currentScrollView.imageView.image;
    // 初始化计算
    self.type = 0;
    self.base = 0;
    if (image.size.width / image.size.height >= 1.0) {
        // 水平扁长图片或同等比例
        if (model.compressed) {
            // Instagram风格，留白
            CGFloat ratio = image.size.height / image.size.width;
            if (ratio < self.horizontalExtemeRatio) {
                // 小于极限值
                self.type = 1;
                self.base = UI_SCREEN_WIDTH * self.horizontalExtemeRatio;
                scrollViewContentSize = CGSizeMake(UI_SCREEN_WIDTH, UI_SCREEN_WIDTH);
                imageViewFrame = CGRectMake(0, 0, self.base * (image.size.width / image.size.height), self.base);
                scrollViewFrame = CGRectMake(0, (UI_SCREEN_WIDTH - self.base) / 2.0, UI_SCREEN_WIDTH, self.base);
                maxScale = UI_SCREEN_WIDTH / self.base * 2.0;
                minScale = 1.0;
                if (CGPointEqualToPoint(self.currentScrollView.photoModel.beginCropPoint, CGPointZero) && CGPointEqualToPoint(self.currentScrollView.photoModel.endCropPoint, CGPointZero)) {
                    scrollViewOffset = CGPointMake( (imageViewFrame.size.width - UI_SCREEN_WIDTH) / 2.0, 0);
                }else if (compressChange) {
                    scrollViewOffset = CGPointMake(imageViewFrame.size.width * model.beginCropPoint.x, imageViewFrame.size.height * model.beginCropPoint.y);
                }
            }else {
                self.type = 2;
                self.base = UI_SCREEN_WIDTH * image.size.height / image.size.width;
                scrollViewContentSize = CGSizeMake(UI_SCREEN_WIDTH, UI_SCREEN_WIDTH);
                imageViewFrame = CGRectMake(0, 0, UI_SCREEN_WIDTH, self.base);
                scrollViewFrame = CGRectMake(0, (UI_SCREEN_WIDTH - self.base) / 2.0, UI_SCREEN_WIDTH, self.base);
                maxScale = UI_SCREEN_WIDTH / self.base * 2.0;
                minScale = 1.0;
                if (CGPointEqualToPoint(self.currentScrollView.photoModel.beginCropPoint, CGPointZero) && CGPointEqualToPoint(self.currentScrollView.photoModel.endCropPoint, CGPointZero)) {
                    scrollViewOffset = CGPointMake(0, 0);
                }else if (compressChange) {
                    scrollViewOffset = CGPointMake(imageViewFrame.size.width * model.beginCropPoint.x, imageViewFrame.size.height * model.beginCropPoint.y);
                }
            }
        }else {
            // 充满
            scrollViewFrame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_WIDTH);
            imageViewFrame = CGRectMake(0, 0, UI_SCREEN_WIDTH * (image.size.width / image.size.height), UI_SCREEN_WIDTH);
            scrollViewContentSize = CGSizeMake(imageViewFrame.size.width, imageViewFrame.size.height);
            maxScale = 3.0;
            if (CGPointEqualToPoint(self.currentScrollView.photoModel.beginCropPoint, CGPointZero) && CGPointEqualToPoint(self.currentScrollView.photoModel.endCropPoint, CGPointZero)) {
                scrollViewOffset = CGPointMake((imageViewFrame.size.width - scrollViewFrame.size.width) / 2.0, 0);
            }else if (compressChange) {
                scrollViewOffset = CGPointMake(imageViewFrame.size.width * model.beginCropPoint.x, imageViewFrame.size.height * model.beginCropPoint.y);
            }
        }
    }else {
        // 垂直扁长图片
        if (model.compressed) {
            // Instagram风格，留白
            CGFloat ratio = image.size.width / image.size.height;
            if (ratio < self.verticalExtemeRatio) {
                // 小于极限值
                self.type = 3;
                self.base = UI_SCREEN_WIDTH * self.verticalExtemeRatio;
                scrollViewContentSize = CGSizeMake(UI_SCREEN_WIDTH, UI_SCREEN_WIDTH);
                imageViewFrame = CGRectMake(0, 0, self.base, self.base * (image.size.height / image.size.width));
                scrollViewFrame = CGRectMake( (UI_SCREEN_WIDTH - self.base) / 2.0, 0, self.base, UI_SCREEN_WIDTH);
                maxScale = UI_SCREEN_WIDTH / self.base * 2.0;
                minScale = 1.0;
                if (CGPointEqualToPoint(self.currentScrollView.photoModel.beginCropPoint, CGPointZero) && CGPointEqualToPoint(self.currentScrollView.photoModel.endCropPoint, CGPointZero)) {
                    scrollViewOffset = CGPointMake(0, (imageViewFrame.size.height - UI_SCREEN_WIDTH) / 2.0);
                }else if (compressChange) {
                    scrollViewOffset = CGPointMake(imageViewFrame.size.width * model.beginCropPoint.x, imageViewFrame.size.height * model.beginCropPoint.y);
                }
            }else {
                self.type = 4;
                self.base = UI_SCREEN_WIDTH * image.size.width / image.size.height;
                scrollViewContentSize = CGSizeMake(UI_SCREEN_WIDTH, UI_SCREEN_WIDTH);
                imageViewFrame = CGRectMake(0, 0, self.base, UI_SCREEN_WIDTH);
                scrollViewFrame = CGRectMake( (UI_SCREEN_WIDTH - self.base) / 2.0, 0, self.base, UI_SCREEN_WIDTH);
                maxScale = UI_SCREEN_WIDTH / self.base * 2.0;
                minScale = 1.0;
                if (CGPointEqualToPoint(self.currentScrollView.photoModel.beginCropPoint, CGPointZero) && CGPointEqualToPoint(self.currentScrollView.photoModel.endCropPoint, CGPointZero)) {
                    scrollViewOffset = CGPointMake(0, 0);
                }else if (compressChange) {
                    scrollViewOffset = CGPointMake(imageViewFrame.size.width * model.beginCropPoint.x, imageViewFrame.size.height * model.beginCropPoint.y);
                }
            }
        }else {
            // 充满
            scrollViewFrame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_WIDTH);
            imageViewFrame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_WIDTH * (image.size.height / image.size.width));
            scrollViewContentSize = CGSizeMake(imageViewFrame.size.width, imageViewFrame.size.height);
            maxScale = 3.0;
            if (CGPointEqualToPoint(self.currentScrollView.photoModel.beginCropPoint, CGPointZero) && CGPointEqualToPoint(self.currentScrollView.photoModel.endCropPoint, CGPointZero)) {
                scrollViewOffset = CGPointMake(0 , (imageViewFrame.size.height - scrollViewFrame.size.height) / 2.0);
            }else if (compressChange) {
                scrollViewOffset = CGPointMake(imageViewFrame.size.width * model.beginCropPoint.x, imageViewFrame.size.height * model.beginCropPoint.y);
            }
        }
    }
    // 设置参数
    MF_WEAK_SELF
    [self.expandButton setUserInteractionEnabled:NO];
    
    self.currentScrollView.frame = scrollViewFrame;
    self.currentScrollView.zoomScale = minScale;
    self.currentScrollView.contentSize = scrollViewContentSize;
    self.currentScrollView.imageView.frame = imageViewFrame;
    self.currentScrollView.maximumZoomScale = maxScale;
    self.currentScrollView.minimumZoomScale = minScale;
    self.currentScrollView.contentOffset = scrollViewOffset;
    self.currentScrollView.zoomScale = minScale;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.expandButton setUserInteractionEnabled:YES];
    });
    
    [self _cropImage];
    self.inCrop = NO;
}

// 裁切照片
- (void)_cropImage {
    
    UIImage *cropImage = nil;
    UIImageView *imageView = self.currentScrollView.imageView;
    CGRect imageRect = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height);
    CGPoint contentOffset = self.currentScrollView.contentOffset;
    CGPoint beginPointRatio = CGPointZero;
    CGPoint endPointRatio = CGPointZero;
    if (imageRect.size.height / imageRect.size.width <= 1.0) {
        // 扁长
        if (imageRect.size.height > UI_SCREEN_WIDTH) {
            imageRect = [self.currentScrollView convertRect:imageRect toView:self];
            beginPointRatio = CGPointMake(fabs(imageRect.origin.x) / imageRect.size.width, fabs(imageRect.origin.y) / imageRect.size.height);
            endPointRatio = CGPointMake((fabs(imageRect.origin.x) + UI_SCREEN_WIDTH ) / imageRect.size.width, (fabs(imageRect.origin.y) + UI_SCREEN_WIDTH ) / imageRect.size.height);
        }else {
            beginPointRatio = CGPointMake(contentOffset.x / imageRect.size.width, 0);
            endPointRatio = CGPointMake((contentOffset.x + UI_SCREEN_WIDTH) / imageRect.size.width, 1.0);
        }
    }else {
        // 窄长
        if (imageRect.size.width > UI_SCREEN_WIDTH) {
            imageRect = [self.currentScrollView convertRect:imageRect toView:self];
            beginPointRatio = CGPointMake(fabs(imageRect.origin.x) / imageRect.size.width, fabs(imageRect.origin.y) / imageRect.size.height);
            endPointRatio = CGPointMake((fabs(imageRect.origin.x) + UI_SCREEN_WIDTH ) / imageRect.size.width, (fabs(imageRect.origin.y) + UI_SCREEN_WIDTH ) / imageRect.size.height);
        }else {
            beginPointRatio = CGPointMake(0, contentOffset.y / imageRect.size.height);
            endPointRatio = CGPointMake(1.0, (contentOffset.y + UI_SCREEN_WIDTH) / imageRect.size.height);
        }
    }
    self.currentScrollView.photoModel.beginCropPoint = beginPointRatio;
    self.currentScrollView.photoModel.endCropPoint = endPointRatio;
    
    if (self.currentScrollView.photoModel.needCrop) {
        cropImage = [imageView.image fj_imageCropBeginPointRatio:beginPointRatio endPointRatio:endPointRatio];
        self.currentScrollView.photoModel.croppedImage = cropImage;
        [self.currentScrollView.photoModel.filterThumbImages removeAllObjects];
    }
    
    if (self.isDebug) {
        UIImageView *imageView = [MF_KEY_WINDOW viewWithTag:1000];
        if (imageView == nil) {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(64.0, 0, 64.0, 64.0)];
            imageView.backgroundColor = [UIColor redColor];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.image = cropImage;
        }
        [MF_KEY_WINDOW addSubview:imageView];
    }
}

- (IBAction)_tapCompress:(id)sender {
    
    FJPhotoModel *model = self.currentScrollView.photoModel;
    model.compressed = !model.compressed;
    
    // Expand View UI
    if (model.compressed == YES) {
        [self.expandImageView setHighlighted:YES];
    }else {
        [self.expandImageView setHighlighted:NO];
    }
    
    [self _updateImageView:YES image:self.currentScrollView.imageView.image];
}

- (IBAction)_tapUpdown:(UIButton *)sender {
    
    BOOL up = ![self getUp];
    [self updateUp:up];
    self.updownBlock == nil ? : self.updownBlock(up);
}

#pragma mark - UISCrollView Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.currentScrollView.imageView;
}

// called before the scroll view begins zooming its content缩放开始的时候调用
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view {
    
    // NSLog(@"%s",__func__);
}

// scale between minimum and maximum. called after any 'bounce' animations缩放完毕的时候调用。
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
    //把当前的缩放比例设进ZoomScale，以便下次缩放时实在现有的比例的基础上
    // NSLog(@"scale is %f",scale);
    [self.currentScrollView setZoomScale:scale animated:NO];
    
    [self _cropImage];
    self.inCrop = NO;
}

// 缩放时调用
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    self.inCrop = YES;
    // 可以实时监测缩放比例
    // NSLog(@"......scale is %f",scrollView.zoomScale);
    if (self.type == 1 || self.type == 2) {
        if (self.base * scrollView.zoomScale >= UI_SCREEN_WIDTH) {
            self.currentScrollView.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_WIDTH);
        }else {
            self.currentScrollView.frame = CGRectMake(0, (UI_SCREEN_WIDTH - self.base * scrollView.zoomScale) / 2.0, UI_SCREEN_WIDTH, self.base * scrollView.zoomScale);
        }
    }else if (self.type == 3 || self.type == 4) {
        if (self.base * scrollView.zoomScale >= UI_SCREEN_WIDTH) {
            self.currentScrollView.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_WIDTH);
        }else {
            self.currentScrollView.frame = CGRectMake((UI_SCREEN_WIDTH - self.base * scrollView.zoomScale) / 2.0, 0, self.base * scrollView.zoomScale, UI_SCREEN_WIDTH);
        }
    }
}

// 移动图像
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.isFirst) {
        self.isFirst = NO;
        return;
    }
    self.inCrop = YES;
    // NSLog(@"--- scrollViewDidScroll YES");
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    self.inCrop = NO;
    // NSLog(@"--- scrollViewDidEndScrollingAnimation NO");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self _cropImage];
    self.inCrop = NO;
    // NSLog(@"--- scrollViewDidEndDecelerating NO");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [self _cropImage];
    self.inCrop = NO;
    // NSLog(@"--- scrollViewDidEndDragging NO");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
