//
//  FJCropperView.m
//  FJCamera
//
//  Created by Fu Jie on 2018/11/13.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJCropperView.h"

@interface FJCropperView () <UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UIView *expandView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *scrollViewTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *scrollViewBottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *scrollViewLeftConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *scrollViewRightConstraint;
@property (nonatomic, strong) UIImageView *imageView;

// 留白和充满标记
// YES -> 留白
// NO  -> 充满
@property (nonatomic, assign) BOOL compressed;

@end

@implementation FJCropperView

- (void)awakeFromNib {
    
    [super awakeFromNib];
}

+ (FJCropperView *)create {
    
    FJCropperView *view = MF_LOAD_NIB(@"FJCropperView");
    view.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_WIDTH);
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
    return view;
}

// 更新图片
- (void)updateImage:(UIImage *)image {
    
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.tag = 100;
        [self.scrollView addSubview:_imageView];
    }
    _imageView.image = image;
    [self updateCompressed:NO];
}

// 更新留白和充满状态
- (void)updateCompressed:(BOOL)compressed {
    
    self.compressed = compressed;
    compressed  = YES;
    
    CGRect scrollViewFrame = CGRectZero;
    CGRect imageViewFrame = CGRectZero;
    CGSize scrollViewContentSize = CGSizeZero;
    CGFloat maxScale = 3.0;
    CGFloat minScale = 1.0;
    CGPoint scrollViewOffset = CGPointZero;
    
    self.scrollView.contentOffset = CGPointZero;
    UIImage *image = self.imageView.image;
    // 初始化计算
    if (image.size.width / image.size.height >= 1.0) {
        // 水平扁长图片或同等比例
        if (compressed) {
            // 留白 (垂直缩小)
            if (image.size.width / image.size.height >= 5.0 / 3.0) {
                // 宽高比大于等于5/3 (固定)
                scrollViewFrame = CGRectMake(0, UI_SCREEN_WIDTH / 5.0, UI_SCREEN_WIDTH, UI_SCREEN_WIDTH * 3.0 / 5.0);
                imageViewFrame = CGRectMake(0, 0, (UI_SCREEN_WIDTH * 3.0 / 5.0) * image.size.width / image.size.height, UI_SCREEN_WIDTH * 3.0 / 5.0);
                scrollViewContentSize = CGSizeMake(imageViewFrame.size.width, imageViewFrame.size.height);
                maxScale = 3.0;
                scrollViewOffset = CGPointMake((imageViewFrame.size.width - scrollViewFrame.size.width) / 2.0, 0);
            }else {
                // 宽高比小于5/3 (固定超出两边10，倒推比例)
                CGFloat imageFrameWidth = UI_SCREEN_WIDTH + 20.0;
                CGFloat imageFrameHeight = imageFrameWidth * (image.size.height / image.size.width);
                scrollViewFrame = CGRectMake(0, (UI_SCREEN_WIDTH - imageFrameHeight) / 2.0, UI_SCREEN_WIDTH, imageFrameHeight);
                imageViewFrame = CGRectMake(0, 0, imageFrameWidth, imageFrameHeight);
                scrollViewContentSize = CGSizeMake(imageFrameWidth, imageFrameHeight);
                maxScale = 3.0;
                scrollViewOffset = CGPointMake(10, 0);
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
            if (image.size.height / image.size.width > 5.0 / 3.0) {
                // 高宽比大于等于5/3（固定）
                scrollViewFrame = CGRectMake(UI_SCREEN_WIDTH / 5.0, 0, UI_SCREEN_WIDTH * 3.0 / 5.0, UI_SCREEN_WIDTH);
                imageViewFrame = CGRectMake(0, 0, UI_SCREEN_WIDTH * 3.0 / 5.0, (UI_SCREEN_WIDTH * 3.0 / 5.0) * image.size.height / image.size.width);
                scrollViewContentSize = CGSizeMake(imageViewFrame.size.width, imageViewFrame.size.height);
                maxScale = 3.0;
                scrollViewOffset = CGPointMake(0, (imageViewFrame.size.height - scrollViewFrame.size.height) / 2.0);
            }else {
                // 高宽比小于5/3
                CGFloat imageFrameHeight = UI_SCREEN_WIDTH + 20.0;
                CGFloat imageFrameWidth = imageFrameHeight * (image.size.width / image.size.height);
                scrollViewFrame = CGRectMake((UI_SCREEN_WIDTH - imageFrameWidth) / 2.0, 0, imageFrameWidth, UI_SCREEN_WIDTH);
                imageViewFrame = CGRectMake(0, 0, imageFrameWidth, imageFrameHeight);
                scrollViewContentSize = CGSizeMake(imageFrameWidth, imageFrameHeight);
                maxScale = 3.0;
                scrollViewOffset = CGPointMake(0, 10);
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
    self.scrollView.frame = scrollViewFrame;
    self.scrollView.contentSize = scrollViewContentSize;
    self.imageView.frame = imageViewFrame;
    self.scrollView.maximumZoomScale = maxScale;
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.zoomScale = minScale;
    self.scrollView.contentOffset = scrollViewOffset;
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
