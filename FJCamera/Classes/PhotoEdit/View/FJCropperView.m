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
#import <FJKit_OC/NSString+Image_FJ.h>

#define K_HEIGHT      100.0
#define K_PDD_WIDTH   20.0

@interface FJGridLabel : UILabel

@end

@implementation FJGridLabel

- (void)drawRect:(CGRect)rect {
    // MFLog(@"rect : %f %f %f %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    //获得处理的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //指定直线样式
    CGContextSetLineCap(context, kCGLineCapSquare);
    //直线宽度
    CGContextSetLineWidth(context, 0.5);
    //设置颜色
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    //开始绘制
    CGContextBeginPath(context);
    // 直线
    CGContextMoveToPoint(context, 0, rect.size.height / 3.0);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height / 3.0);
    
    CGContextMoveToPoint(context, 0, rect.size.height * 2.0 / 3.0);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height * 2.0 / 3.0);
    
    CGContextMoveToPoint(context, rect.size.width / 3.0, 0);
    CGContextAddLineToPoint(context, rect.size.width / 3.0, rect.size.height);
    
    CGContextMoveToPoint(context, rect.size.width * 2.0 / 3.0, 0);
    CGContextAddLineToPoint(context, rect.size.width * 2.0 / 3.0, rect.size.height);
    
    //绘制完成
    CGContextStrokePath(context);
}

@end

@interface FJImageScrollView : UIScrollView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) FJPhotoModel *photoModel;

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
@property (nonatomic, strong) FJGridLabel *gridView;

@property (nonatomic, assign) CGFloat horizontalExtemeRatio;
@property (nonatomic, assign) CGFloat verticalExtemeRatio;

// 是否显示网格线
@property (nonatomic, assign) BOOL isGrid;

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

- (FJGridLabel *)gridView {
    
    if (_gridView == nil) {
        _gridView = [[FJGridLabel alloc] init];
        [self addSubview:_gridView];
        if (self.isDebug) {
            _gridView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
        }
    }
    [self bringSubviewToFront:_gridView];
    return _gridView;
}

- (NSMutableArray *)scrollViews {
    
    if (_scrollViews == nil) {
        _scrollViews = [[NSMutableArray alloc] init];
    }
    return _scrollViews;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
}

+ (FJCropperView *)create:(BOOL)debug grid:(BOOL)grid horizontalExtemeRatio:(CGFloat)horizontalExtemeRatio verticalExtemeRatio:(CGFloat)verticalExtemeRatio croppedBlock:(void(^)(FJPhotoModel *photoModel, CGRect frame))croppedBlock updownBlock:(void(^)(BOOL up))updownBlock {
    
    FJCropperView *view = MF_LOAD_NIB(@"FJCropperView");
    view.clipsToBounds = YES;
    view.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_WIDTH);
    view.horizontalExtemeRatio = horizontalExtemeRatio;
    view.verticalExtemeRatio = verticalExtemeRatio;
    view.croppedBlock = croppedBlock;
    view.updownBlock = updownBlock;
    view.inCrop = NO;
    view.isFirst = YES;
    view.isGrid = grid;
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
        self.backgroundColor = [UIColor blueColor];
        self.currentScrollView.backgroundColor = [UIColor blackColor];
    }else {
        self.backgroundColor = @"#F5F5F5".fj_color;
        self.currentScrollView.backgroundColor = @"#F5F5F5".fj_color;
    }
    
    [self bringSubviewToFront:self.currentScrollView];
    [self bringSubviewToFront:self.toolView];
    
    // Hint
    NSString *lastVersion = [FJStorage valueNSObject:@"FJCameraUpdateVersion"];
    NSString *version = MF_APP_VERSION;
    if (lastVersion == nil || ![lastVersion isEqualToString:version]) {
        
        [FJStorage saveNSObject:version key:@"FJCameraUpdateVersion"];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = 1000;
        [imageView setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapHint:)];
        [imageView addGestureRecognizer:tap];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = @"FJCropperView.ic_pop_left".fj_image;
        [self addSubview:imageView];
        __weak typeof(self) weakSelf = self;
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@170.0);
            make.height.equalTo(@36.0);
            make.left.equalTo(weakSelf).offset(10.0);
            make.bottom.equalTo(weakSelf).offset(-48.0);
        }];
        
        imageView = [[UIImageView alloc] init];
        imageView.tag = 2000;
        [imageView setUserInteractionEnabled:YES];
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapHint:)];
        [imageView addGestureRecognizer:tap];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = @"FJCropperView.ic_pop_right".fj_image;
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@124.0);
            make.height.equalTo(@36.0);
            make.right.equalTo(weakSelf).offset(-10.0);
            make.bottom.equalTo(weakSelf).offset(-48.0);
        }];
    }
}

- (void)_tapHint:(UITapGestureRecognizer *)tap {
    
    [tap.view removeFromSuperview];
}

// 更新图片(返回NO表示iCoud图片下载中)
- (BOOL)updateModel:(FJPhotoModel *)model {
    
    FJImageScrollView *imageScrollView = nil;
    UIImage *image = [model.asset getGeneralTargetImage];
    if (image == nil) {
        [self fj_toast:FJToastImageTypeNone message:@"iCloud照片正在下载中"];
        return NO;
    }
    for (FJImageScrollView *scrollView in self.scrollViews) {
        if (scrollView.photoModel == nil) {
            // ScrollView的photoModel为空，第一次渲染照片
            scrollView.hidden = NO;
            imageScrollView = scrollView;
            self.currentScrollView = scrollView;
            self.currentScrollView.photoModel = model;
            [self _updateImageView:NO image:image];
        }else if ([scrollView.photoModel isEqual:model]) {
            // 在scrollViews数组中寻找已经渲染过的对象
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
            // 将渲染过并未不是当前显示的对象隐藏
            scrollView.hidden = YES;
        }
    }
    if (imageScrollView == nil) {
        // 当照片未被渲染过
        [self _buildNewImageScrollView];
        self.currentScrollView.photoModel = model;
        [self _updateImageView:NO image:image];
        
        // 加载新图片，删除Hint
        for (UIImageView *imageView in self.subviews) {
            if (imageView.tag == 1000 || imageView.tag == 2000) {
                [imageView removeFromSuperview];
            }
        }
    }
    return YES;
}

// 更新向上和向下的状态
- (void)updateUp:(BOOL)up {
    
    [self.updownImageView setHighlighted:up];
    self.blurLabel.hidden = !up;
}

// 获取向上和向下的状态
- (BOOL)getUp {
    
    return self.updownImageView.highlighted;
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
                scrollViewOffset = CGPointMake(imageViewFrame.size.width * model.beginCropPoint.x, 0);
                if (scrollViewOffset.x < 0) {
                    scrollViewOffset = CGPointMake(0 , 0);
                }else if (scrollViewOffset.x > imageViewFrame.size.width - scrollViewFrame.size.width) {
                    scrollViewOffset = CGPointMake(imageViewFrame.size.width - scrollViewFrame.size.width , 0);
                }
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
                scrollViewOffset = CGPointMake(0, imageViewFrame.size.height * model.beginCropPoint.y);
                if (scrollViewOffset.y < 0) {
                    scrollViewOffset = CGPointMake(0 , 0);
                }else if (scrollViewOffset.y > imageViewFrame.size.height - scrollViewFrame.size.height) {
                    scrollViewOffset = CGPointMake(0 , imageViewFrame.size.height - scrollViewFrame.size.height);
                }
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
            imageView.backgroundColor = [UIColor darkGrayColor];
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

// 更新网格
- (void)_updateGrid:(UIScrollView *)scrollView {
    
    if (self.isGrid == NO) {
        return;
    }
    self.gridView.hidden = NO;
    self.gridView.alpha = 1;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = 0;
    CGFloat h = 0;
    if (scrollView.contentOffset.x >=0) {
        x = scrollView.frame.origin.x - scrollView.contentOffset.x;
        if (x <= 0) {
            x = 0;
            w = scrollView.contentSize.width - scrollView.contentOffset.x;
        }else {
            w = scrollView.contentSize.width;
        }
        
        if (w >= scrollView.frame.size.width) {
            w = scrollView.frame.size.width;
        }
    }else {
        x = scrollView.frame.origin.x + (- scrollView.contentOffset.x);
        w = scrollView.contentSize.width;
        if (w >= self.frame.size.width - x) {
            w = self.frame.size.width - x;
        }
    }
    if (scrollView.contentOffset.y >= 0) {
        y = scrollView.frame.origin.y - scrollView.contentOffset.y;
        if (y <= 0 ) {
            y = 0;
            h = scrollView.contentSize.height - scrollView.contentOffset.y;
        }else {
            h = scrollView.contentSize.height;
        }
        if (h >= self.frame.size.height) {
            h = self.frame.size.height;
        }
        
    }else {
        y = scrollView.frame.origin.y + (- scrollView.contentOffset.y);
        h = scrollView.contentSize.height;
        if (h >= self.frame.size.height - y) {
            h = self.frame.size.height - y;
        }
    }
    if (self.isDebug) {
        self.gridView.frame = CGRectMake(x + 4.0, y + 4.0, w - 8.0, h - 8.0);
    }else {
        self.gridView.frame = CGRectMake(x, y , w, h);
    }
}

// 停止网格
- (void)_removeGrid {
    
    if (self.isGrid == NO) {
        return;
    }
    MF_WEAK_SELF
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.gridView.alpha = 0;
    } completion:^(BOOL finished) {
        weakSelf.gridView.alpha = 1;
        weakSelf.gridView.hidden = YES;
    }];
}

#pragma mark - UISCrollView Delegate
// 缩放对象
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.currentScrollView.imageView;
}

// 缩放开始
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view {
    
    MFLog(@"### 缩放开始");
}

// 缩放进行
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    MFLog(@"### 缩放进行");
    
    self.inCrop = YES;
    // 可以实时监测缩放比例
    // MFLog(@"......scale is %f",scrollView.zoomScale);
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
    
    [self _updateGrid:scrollView];
}

// 缩放完毕
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
    MFLog(@"### 缩放完毕");
    // 把当前的缩放比例设进ZoomScale，以便下次缩放时实在现有的比例的基础上
    // MFLog(@"scale is %f",scale);
    [self.currentScrollView setZoomScale:scale animated:NO];
    
    [self _cropImage];
    self.inCrop = NO;
    [self _removeGrid];
}

// 移动进行
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    MFLog(@"### 移动进行");
    if (self.isFirst) {
        self.isFirst = NO;
        return;
    }
    self.inCrop = YES;
    [self _updateGrid:scrollView];
}

// 移动停止（非人为拖拽后停止）
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    MFLog(@"### 移动停止（非人为拖拽后停止）");
    self.inCrop = NO;
}

// 移动停止（人为拖拽后停止）
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    MFLog(@"### 移动停止（人为拖拽后停止）");
    [self _cropImage];
    self.inCrop = NO;
    [self _removeGrid];
}

// 拖拽停止
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    MFLog(@"### 拖拽停止");
    [self _cropImage];
    self.inCrop = NO;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.inCrop == NO) {
            [weakSelf _removeGrid];
        }
    });
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
