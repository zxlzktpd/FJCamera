//
//  FJPhotoImageTagView.m
//  FJCamera
//
//  Created by Fu Jie on 2018/11/5.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJPhotoImageTagView.h"
#import <FJKit_OC/Macro.h>
#import <FJKit_OC/UIView+Utility_FJ.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import "FJPhotoImageTagPointView.h"
#import <FJKit_OC/NSString+Image_FJ.h>

@interface FJPhotoImageTagView ()

@property (nonatomic, weak) IBOutlet UIView *tagBackgroundView;
@property (nonatomic, weak) IBOutlet UIImageView *tagImageView;
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet FJPhotoImageTagPointView *tagPointUpView;
@property (nonatomic, weak) IBOutlet FJPhotoImageTagPointView *tagPointDownView;
@property (nonatomic, weak) IBOutlet UIView *tagLineUpView;
@property (nonatomic, weak) IBOutlet UIView *tagLineDownView;
@property (nonatomic, weak) IBOutlet UIButton *reverseUpButton;
@property (nonatomic, weak) IBOutlet UIButton *reverseDownButton;
@property (nonatomic, strong) FJImageTagModel *model;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, copy) void(^tapBlock)(FJPhotoImageTagView *photoImageTagView);
@property (nonatomic, copy) void(^movingBlock)(UIGestureRecognizerState state, CGPoint point, FJPhotoImageTagView *imageTagView);

@end

@implementation FJPhotoImageTagView

-(void)dealloc {
    
}

// 创建FJPhotoImageTagView
+ (FJPhotoImageTagView *)create:(CGPoint)point containerSize:(CGSize)containerSize model:(FJImageTagModel *)model tapBlock:(void(^)(__weak FJPhotoImageTagView *photoImageTagView))tapBlock movingBlock:(void(^)(UIGestureRecognizerState state, CGPoint point, FJPhotoImageTagView *imageTagView))movingBlock {
    
    return [self create:point containerSize:containerSize model:model scale:1.0 tapBlock:tapBlock movingBlock:movingBlock];
}

// 创建FJPhotoImageTagView（Scale）
+ (FJPhotoImageTagView *)create:(CGPoint)point containerSize:(CGSize)containerSize model:(FJImageTagModel *)model scale:(CGFloat)scale tapBlock:(void(^)(__weak FJPhotoImageTagView *photoImageTagView))tapBlock movingBlock:(void(^)(UIGestureRecognizerState state, CGPoint point, FJPhotoImageTagView *imageTagView))movingBlock {
    
    FJPhotoImageTagView *view = MF_LOAD_NIB(@"FJPhotoImageTagView");
    view.model = model;
    view.textLabel.text = model.name;
    view.tapBlock = tapBlock;
    view.movingBlock = movingBlock;
    CGFloat w;
    if (@available(iOS 8.2, *)) {
        w = [model.name fj_width:[UIFont systemFontOfSize:12.0 weight:UIFontWeightMedium] enableCeil:YES];
    } else {
        w = [model.name fj_width:[UIFont systemFontOfSize:12.0] enableCeil:YES] + 0.2 * model.name.length;
    }
    view.frame = CGRectMake(point.x, point.y, w + 24.0 + 8.0 + 6.0 + 6.0, FJPhotoImageTagViewHeight);
    [view.tagBackgroundView fj_cornerRadius:2.0];
    switch (model.type) {
        case 0:
        {
            // 话题
            view.tagImageView.image = @"ic_logo_tag_topic".fj_image;
            break;
        }
        case 1:
        {
            // 品牌
            view.tagImageView.image = @"ic_logo_tag_brand".fj_image;
            break;
        }
        case 20:
        {
            // 人民币
            view.tagImageView.image = @"ic_logo_tag_rmb".fj_image;
            break;
        }
        case 21:
        {
            // 美元
            view.tagImageView.image = @"ic_logo_tag_dollar".fj_image;
            break;
        }
        case 22:
        {
            // 欧元
            view.tagImageView.image = @"ic_logo_tag_euro".fj_image;
            break;
        }
        default:
            break;
    }
    
    if (model.direction == 0) {
        [view.tagPointDownView stopAnimation];
        view.tagPointDownView.hidden = YES;
        view.tagLineDownView.hidden = YES;
        view.tagPointUpView.hidden = NO;
        view.tagLineUpView.hidden = NO;
        [view.tagPointUpView startAnimation];
    }else {
        [view.tagPointUpView stopAnimation];
        view.tagPointUpView.hidden = YES;
        view.tagLineUpView.hidden = YES;
        view.tagPointDownView.hidden = NO;
        view.tagLineDownView.hidden = NO;
        [view.tagPointDownView startAnimation];
    }
    // 修正view使得view在ContainerSize内
    if (view.frame.origin.x + view.bounds.size.width > containerSize.width && view.frame.origin.y + view.bounds.size.height > containerSize.height) {
        view.frame = CGRectMake(containerSize.width - view.bounds.size.width, containerSize.height - view.bounds.size.height, view.bounds.size.width, view.bounds.size.height);
        model.xPercent = view.frame.origin.x / containerSize.width;
        model.yPercent = view.frame.origin.y / containerSize.height;
    }else if (view.frame.origin.x + view.bounds.size.width > containerSize.width) {
        view.frame = CGRectMake(containerSize.width - view.bounds.size.width, view.frame.origin.y, view.bounds.size.width, view.bounds.size.height);
        model.xPercent = view.frame.origin.x / containerSize.width;
    }else if (view.frame.origin.y + view.bounds.size.height > containerSize.height) {
        view.frame = CGRectMake(view.frame.origin.x, containerSize.height - view.bounds.size.height, view.bounds.size.width, view.bounds.size.height);
        model.yPercent = view.frame.origin.y / containerSize.height;
    }
    
    // 调整后的frame
    model.adjustedFrame = view.frame;
    
    // 圆角修饰
    [view.tagBackgroundView fj_cornerRadius:12.0 borderWidth:1.0 boderColor:[UIColor whiteColor]];
    
    if (model.isHint == YES) {
        
        [view setUserInteractionEnabled:NO];
        [view.reverseUpButton setHidden:YES];
        [view.reverseDownButton setHidden:YES];
    }else {
        
        if (movingBlock != nil) {
            [view addGestureRecognizer:view.panGesture];
            [view.reverseUpButton setHidden:NO];
            [view.reverseDownButton setHidden:NO];
        }else {
            [view.reverseUpButton setHidden:YES];
            [view.reverseDownButton setHidden:YES];
        }
        
        if (tapBlock != nil) {
            [view addGestureRecognizer:view.tapGesture];
        }
    }
    return view;
}

- (UIPanGestureRecognizer *)panGesture {
    
    if (_panGesture == nil) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panAction:)];
    }
    return _panGesture;
}

- (UITapGestureRecognizer *)tapGesture {
    
    if (_tapGesture == nil) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapAction:)];
        _tapGesture.numberOfTapsRequired = 1;
        _tapGesture.numberOfTouchesRequired = 1;
    }
    return _tapGesture;
}

- (void)_panAction:(UIPanGestureRecognizer *)panGesture {
    
    UIGestureRecognizerState state = panGesture.state;
    CGPoint locationPoint = [panGesture locationInView:panGesture.view.superview.superview.superview];
    CGPoint point = [panGesture translationInView:panGesture.view];
    BOOL isContain = CGRectContainsRect(self.superview.bounds, self.frame);
    if (isContain) {
        self.center = CGPointMake(self.center.x + point.x, self.center.y + point.y);
    }else {
        // 超出(包括贴边)情况
        CGSize supSize = self.superview.frame.size;
        if (CGRectGetMinY(self.frame) < 0) {
            // 靠上
            self.frame = CGRectMake(self.frame.origin.x, 0, self.frame.size.width, self.frame.size.height);
        }else if (CGRectGetMinX(self.frame) < 0) {
            // 靠左
            self.frame = CGRectMake(0, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        }else if (CGRectGetMaxY(self.frame) > supSize.height) {
            // 靠下
            self.frame = CGRectMake(self.frame.origin.x, self.superview.bounds.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
        }else if (CGRectGetMaxX(self.frame) > supSize.width) {
            // 靠右
            self.frame = CGRectMake(self.superview.bounds.size.width - self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        }
    }
    [panGesture setTranslation:CGPointZero inView:panGesture.view];
    self.model.xPercent = self.frame.origin.x / self.superview.bounds.size.width;
    self.model.yPercent = self.frame.origin.y / self.superview.bounds.size.height;
    self.movingBlock == nil ? : self.movingBlock(state, locationPoint, self);
}

- (void)_tapAction:(UITapGestureRecognizer *)tapGesture {
    
    self.tapBlock == nil ? : self.tapBlock(self);
}

- (IBAction)_tapReverse:(UIButton *)button {
    
    [self reverseDirection];
    self.tapBlock == nil ? : self.tapBlock(self);
}

- (void)reverseDirection {
    
    if (self.model.direction == 0) {
        self.model.direction = 1;
        [self.tagPointUpView stopAnimation];
        self.tagPointUpView.hidden = YES;
        self.tagLineUpView.hidden = YES;
        self.tagPointDownView.hidden = NO;
        self.tagLineDownView.hidden = NO;
        [self.tagPointDownView startAnimation];
    }else if (self.model.direction == 1) {
        self.model.direction = 0;
        [self.tagPointDownView stopAnimation];
        self.tagPointDownView.hidden = YES;
        self.tagLineDownView.hidden = YES;
        self.tagPointUpView.hidden = NO;
        self.tagLineUpView.hidden = NO;
        [self.tagPointUpView startAnimation];
    }
}

- (FJImageTagModel *)getTagModel {
    
    return self.model;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
