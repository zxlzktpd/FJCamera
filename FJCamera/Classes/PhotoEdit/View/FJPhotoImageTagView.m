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

@interface FJPhotoImageTagView ()

@property (nonatomic, weak) IBOutlet UIView *tagBackgroundView;
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) IBOutlet UIImageView *triangleUpImageView;
@property (nonatomic, weak) IBOutlet UIImageView *triangleDownImageView;
@property (nonatomic, weak) IBOutlet FJPhotoImageTagPointView *tagPointUpView;
@property (nonatomic, weak) IBOutlet FJPhotoImageTagPointView *tagPointDownView;

@property (nonatomic, strong) FJImageTagModel *model;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, copy) void(^tapBlock)(FJPhotoImageTagView *photoImageTagView);
@property (nonatomic, copy) void(^movingBlock)(void);

@end

@implementation FJPhotoImageTagView

-(void)dealloc {
    
}

+ (FJPhotoImageTagView *)create:(CGPoint)point model:(FJImageTagModel *)model canmove:(BOOL)canmove tapBlock:(void(^)(__weak FJPhotoImageTagView *photoImageTagView))tapBlock movingBlock:(void(^)(void))movingBlock {
    
    FJPhotoImageTagView *view = MF_LOAD_NIB(@"FJPhotoImageTagView");
    view.model = model;
    view.textLabel.text = model.name;
    view.tapBlock = tapBlock;
    view.movingBlock = movingBlock;
    CGFloat w;
    if (@available(iOS 8.2, *)) {
        w = [model.name fj_width:[UIFont systemFontOfSize:14.0 weight:UIFontWeightMedium] enableCeil:YES];
    } else {
        w = [model.name fj_width:[UIFont systemFontOfSize:14.0] enableCeil:YES] + 0.2 * model.name.length;
    }
    view.frame = CGRectMake(point.x, point.y, w + 12.0 + 12.0, FJPhotoImageTagViewHeight);
    [view.tagBackgroundView fj_cornerRadius:2.0];
    if (canmove) {
        [view addGestureRecognizer:view.panGesture];
        [view addGestureRecognizer:view.tapGesture];
    }
    if (model.direction == 0) {
        view.triangleUpImageView.hidden = NO;
        view.triangleDownImageView.hidden = YES;
    }else if (model.direction == 1) {
        view.triangleUpImageView.hidden = YES;
        view.triangleDownImageView.hidden = NO;
    }
    if (model.direction == 0) {
        [view.tagPointDownView stopAnimation];
        view.tagPointDownView.hidden = YES;
        view.tagPointUpView.hidden = NO;
        [view.tagPointUpView startAnimation];
    }else {
        [view.tagPointUpView stopAnimation];
        view.tagPointUpView.hidden = YES;
        view.tagPointDownView.hidden = NO;
        [view.tagPointDownView startAnimation];
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
    }
    return _tapGesture;
}

- (void)_panAction:(UIPanGestureRecognizer *)panGesture {
    
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
    self.movingBlock == nil ? : self.movingBlock();
}

- (void)_tapAction:(UITapGestureRecognizer *)tapGesture {
    
    self.tapBlock == nil ? : self.tapBlock(self);
}

- (void)reverseDirection {
    
    if (self.model.direction == 0) {
        self.model.direction = 1;
        self.triangleUpImageView.hidden = YES;
        self.triangleDownImageView.hidden = NO;
        [self.tagPointUpView stopAnimation];
        self.tagPointUpView.hidden = YES;
        self.tagPointDownView.hidden = NO;
        [self.tagPointDownView startAnimation];
    }else if (self.model.direction == 1) {
        self.model.direction = 0;
        self.triangleUpImageView.hidden = NO;
        self.triangleDownImageView.hidden = YES;
        [self.tagPointDownView stopAnimation];
        self.tagPointDownView.hidden = YES;
        self.tagPointUpView.hidden = NO;
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
