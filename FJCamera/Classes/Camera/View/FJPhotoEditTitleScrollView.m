//
//  FJPhotoEditTitleScrollView.m
//  FJCamera
//
//  Created by Fu Jie on 2018/10/30.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJPhotoEditTitleScrollView.h"
#import "FJCameraCommonHeader.h"
#import <SMPageControl/SMPageControl.h>

@interface FJPhotoEditTitleScrollView ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) SMPageControl *pageControl;

@end

@implementation FJPhotoEditTitleScrollView

- (void)awakeFromNib {
    
    [super awakeFromNib];
    SMPageControl *pageControl = [[SMPageControl alloc] init];
    pageControl.numberOfPages = 9;
    pageControl.pageIndicatorImage = [UIImage imageNamed:@"ic_pagecontrol_unselected"];
    pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"ic_pagecontrol_selected"];
    [self addSubview:pageControl];
    MF_WEAK_SELF
    [pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(weakSelf);
        make.top.equalTo(weakSelf.titleLabel.mas_bottom);
    }];
    [pageControl sizeToFit];
    self.pageControl = pageControl;
}

- (void)updateTitle:(NSString *)title {
    
    self.titleLabel.text = title;
}

- (void)updateCount:(NSUInteger)count {
    
    self.pageControl.numberOfPages = count;
}

- (void)updateIndex:(NSUInteger)index {
    
    self.pageControl.currentPage = index;
}

+ (FJPhotoEditTitleScrollView *)create:(NSUInteger)count {
    
    FJPhotoEditTitleScrollView *view = MF_LOAD_NIB(@"FJPhotoEditTitleScrollView");
    [view updateTitle:@"编辑图片"];
    view.pageControl.numberOfPages = count;
    return view;
}

- (CGSize)intrinsicContentSize {
    
    return CGSizeMake(240, 48);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
