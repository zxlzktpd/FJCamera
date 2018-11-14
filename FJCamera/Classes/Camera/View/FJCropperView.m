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
    view.scrollView.minimumZoomScale = 1.0;
    view.scrollView.zoomScale = 1.0;
    view.scrollView.maximumZoomScale = 3.0;
    view.scrollView.delegate = view;
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
    // 初始化计算
    UIImage *image = self.imageView.image;
    if (image.size.width / image.size.height >= self.scrollView.bounds.size.width / self.scrollView.bounds.size.height) {
        // 水平扁长图片或同等比例
        // max scale = image.size.height / scrollView.size.height (至少为1.0)
        
        // 充满
        
        // 留白 (垂直缩小)
        
    }else {
        // 垂直扁长图片
        // max scale = image.size.width / scrollView.size.width (至少为1.0)
        
        // 充满
        
        // 留白（水平缩小）
    }
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
