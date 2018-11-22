//
//  FJCropperView.m
//  FJCamera
//
//  Created by Fu Jie on 2018/11/13.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJCropperView.h"
#import "PHAsset+Utility.h"

@interface FJCropperView () <UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *expandView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIButton *expandButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *scrollViewTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *scrollViewLeftConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *scrollViewRightConstraint;
@property (nonatomic, strong) UIImageView *imageView;

// 留白和充满标记
// YES -> 留白
// NO  -> 充满
@property (nonatomic, assign) BOOL compressed;

@property (nonatomic, strong) FJPhotoModel *photoModel;

@property (nonatomic, copy) void(^croppedBlock)(FJPhotoModel *photoModel, CGRect frame);

@end

@implementation FJCropperView

- (void)awakeFromNib {
    
    [super awakeFromNib];
}

- (IBAction)_tapCompress:(id)sender {
    
    [self updateCompressed:!_compressed];
}

+ (FJCropperView *)create:(void(^)(FJPhotoModel *photoModel, CGRect frame))croppedBlock {
    
    FJCropperView *view = MF_LOAD_NIB(@"FJCropperView");
    view.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_WIDTH);
    view.croppedBlock = croppedBlock;
    // Setup UI
    [view.expandView fj_cornerRadius:6.0 borderWidth:1.0 boderColor:[UIColor whiteColor]];
    // ScrollView
    view.scrollView.clipsToBounds = NO;
    view.scrollView.maximumZoomScale = 1.0;
    view.scrollView.minimumZoomScale = 1.0;
    view.scrollView.zoomScale = 1.0;
    view.scrollView.delegate = view;
    view.scrollView.showsVerticalScrollIndicator = NO;
    view.scrollView.showsHorizontalScrollIndicator = NO;
    view.scrollView.bounces = YES;
    view.scrollView.layer.masksToBounds = YES;
    return view;
}

// 更新图片
- (void)updateModel:(FJPhotoModel *)model {
    
    self.photoModel = model;
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.tag = 100;
        [self.scrollView addSubview:_imageView];
    }
    _imageView.image = [model.asset getStaticTargetImage];
    [self updateCompressed:NO];
}

// 更新留白和充满状态
- (void)updateCompressed:(BOOL)compressed {
    
    self.compressed = compressed;
    CGRect scrollViewFrame = CGRectZero;
    CGRect imageViewFrame = CGRectZero;
    CGSize scrollViewContentSize = CGSizeZero;
    CGFloat maxScale = 3.0;
    CGFloat minScale = 1.0;
    CGPoint scrollViewOffset = CGPointZero;
    // 固定临界点数值
    CGFloat ratioLong = 5.0;
    CGFloat rationShort = 4.0;
    CGFloat expandSide = 20.0;
    CGFloat minGapSide = 10.0;
    
    self.scrollView.contentOffset = CGPointZero;
    UIImage *image = self.imageView.image;
    // 初始化计算
    if (image.size.width / image.size.height >= 1.0) {
        // 水平扁长图片或同等比例
        if (compressed) {
            // 留白 (垂直缩小)
            if (image.size.width / image.size.height > (ratioLong / rationShort)) {
                // 宽高比大于等于比例 (留白空间固定)
                scrollViewFrame = CGRectMake(0, UI_SCREEN_WIDTH * ((1.0 - rationShort / ratioLong) / 2.0), UI_SCREEN_WIDTH, UI_SCREEN_WIDTH * (rationShort / ratioLong));
                imageViewFrame = CGRectMake(0, 0, (UI_SCREEN_WIDTH * (rationShort / ratioLong)) * image.size.width / image.size.height, UI_SCREEN_WIDTH * (rationShort / ratioLong));
                scrollViewContentSize = CGSizeMake(imageViewFrame.size.width, imageViewFrame.size.height);
                maxScale = 3.0;
                scrollViewOffset = CGPointMake((imageViewFrame.size.width - scrollViewFrame.size.width) / 2.0, 0);
            }else {
                // 宽高比小于比例 (固定超出两边20，倒推比例)
                CGFloat imageFrameWidth = UI_SCREEN_WIDTH + expandSide * 2;
                CGFloat imageFrameHeight = imageFrameWidth * (image.size.height / image.size.width);
                CGFloat scrollViewHeight = (imageFrameHeight > UI_SCREEN_WIDTH - minGapSide * 2) ? (UI_SCREEN_WIDTH - minGapSide * 2 ) : imageFrameHeight;
                scrollViewFrame = CGRectMake(0, (UI_SCREEN_WIDTH - scrollViewHeight) / 2.0, UI_SCREEN_WIDTH, scrollViewHeight);
                imageViewFrame = CGRectMake(0, 0, imageFrameWidth, imageFrameHeight);
                scrollViewContentSize = CGSizeMake(imageFrameWidth, imageFrameHeight);
                maxScale = 3.0;
                scrollViewOffset = CGPointMake(expandSide, fabs(imageFrameHeight - scrollViewHeight) / 2.0);
            }
        }else {
            // 充满
            scrollViewFrame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_WIDTH);
            imageViewFrame = CGRectMake(0, 0, UI_SCREEN_WIDTH * (image.size.width / image.size.height), UI_SCREEN_WIDTH);
            scrollViewContentSize = CGSizeMake(imageViewFrame.size.width, imageViewFrame.size.height);
            maxScale = 3.0;
            scrollViewOffset = CGPointMake((imageViewFrame.size.width - scrollViewFrame.size.width) / 2.0, 0);
        }
    }else {
        // 垂直扁长图片
        if (compressed) {
            // 留白（水平缩小）
            if (image.size.height / image.size.width > (ratioLong / rationShort)) {
                // 高宽比大于等于比例（留白空间固定）
                scrollViewFrame = CGRectMake(UI_SCREEN_WIDTH * ((1.0 - rationShort / ratioLong) / 2.0), 0, UI_SCREEN_WIDTH * (rationShort / ratioLong), UI_SCREEN_WIDTH);
                imageViewFrame = CGRectMake(0, 0, UI_SCREEN_WIDTH * (rationShort / ratioLong), (UI_SCREEN_WIDTH * (rationShort / ratioLong)) * image.size.height / image.size.width);
                scrollViewContentSize = CGSizeMake(imageViewFrame.size.width, imageViewFrame.size.height);
                maxScale = 3.0;
                scrollViewOffset = CGPointMake(0, (imageViewFrame.size.height - scrollViewFrame.size.height) / 2.0);
            }else {
                // 高宽比小于比例
                CGFloat imageFrameHeight = UI_SCREEN_WIDTH + expandSide * 2;
                CGFloat imageFrameWidth = imageFrameHeight * (image.size.width / image.size.height);
                CGFloat scrollViewWidth = (imageFrameWidth > UI_SCREEN_WIDTH - minGapSide * 2) ? (UI_SCREEN_WIDTH - minGapSide * 2 ) : imageFrameWidth;
                scrollViewFrame = CGRectMake((UI_SCREEN_WIDTH - imageFrameWidth) / 2.0, 0, scrollViewWidth, UI_SCREEN_WIDTH);
                imageViewFrame = CGRectMake(0, 0, imageFrameWidth, imageFrameHeight);
                scrollViewContentSize = CGSizeMake(imageFrameWidth, imageFrameHeight);
                maxScale = 3.0;
                scrollViewOffset = CGPointMake(fabs(imageFrameWidth - scrollViewWidth) / 2.0, expandSide);
            }
        }else {
            // 充满
            scrollViewFrame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_WIDTH);
            imageViewFrame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_WIDTH * (image.size.height / image.size.width));
            scrollViewContentSize = CGSizeMake(imageViewFrame.size.width, imageViewFrame.size.height);
            maxScale = 3.0;
            scrollViewOffset = CGPointMake(0 , (imageViewFrame.size.height - scrollViewFrame.size.height) / 2.0);
        }
    }
    // 设置参数
    MF_WEAK_SELF
    [self.expandButton setUserInteractionEnabled:NO];
    self.scrollView.frame = scrollViewFrame;
    self.scrollView.contentSize = scrollViewContentSize;
    self.imageView.frame = imageViewFrame;
    self.scrollView.maximumZoomScale = maxScale;
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.zoomScale = minScale;
    self.scrollView.contentOffset = scrollViewOffset;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.expandButton setUserInteractionEnabled:YES];
    });
    
    // Expand View UI
    UILabel *label = [self.expandView viewWithTag:100];
    UIImageView *imageView = [self.expandView viewWithTag:200];
    if (_compressed == YES) {
        label.text = @"充满";
        [imageView setHighlighted:YES];
    }else {
        label.text = @"留白";
        [imageView setHighlighted:NO];
    }
    
    CGRect frame = [self.scrollView convertRect:self.imageView.frame toView:self];
    frame = CGRectMake(self.scrollView.frame.origin.x - frame.origin.x, self.scrollView.frame.origin.y - frame.origin.y, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
}

#pragma mark - UISCrollView Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return [self.scrollView viewWithTag:100];
}


// called before the scroll view begins zooming its content缩放开始的时候调用
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view {
    
    NSLog(@"%s",__func__);
}

// scale between minimum and maximum. called after any 'bounce' animations缩放完毕的时候调用。
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
    //把当前的缩放比例设进ZoomScale，以便下次缩放时实在现有的比例的基础上
    NSLog(@"scale is %f",scale);
    [_scrollView setZoomScale:scale animated:NO];
}

// 缩放时调用
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    // 可以实时监测缩放比例
    NSLog(@"......scale is %f",scrollView.zoomScale);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end