//
//  FJPhotoEditFilterGenreView.m
//  FJCamera
//
//  Created by Fu Jie on 2018/11/8.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJPhotoEditFilterGenreView.h"

@interface FJPhotoEditFilterGenreView ()

@property (nonatomic, strong) UIImageView *filterImageView;
// @property (nonatomic, strong) UIView *filterCoverView;
@property (nonatomic, strong) UIView *filterTextBackgroundView;
@property (nonatomic, strong) UILabel *filterTextLabel;
@property (nonatomic, strong) UIButton *button;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) BOOL selected;

@end

@implementation FJPhotoEditFilterGenreView

+ (FJPhotoEditFilterGenreView *)create:(CGRect)frame image:(UIImage *)image title:(NSString *)title selected:(BOOL)selected {
    
    FJPhotoEditFilterGenreView *view = [[FJPhotoEditFilterGenreView alloc] initWithFrame:frame];
    view.image = image;
    view.title = title;
    view.selected = selected;
    [view _buildUI];
    return view;
}

- (void)_buildUI {
    
    if (_filterImageView == nil) {
        _filterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        _filterImageView.contentMode = UIViewContentModeScaleAspectFill;
        _filterImageView.clipsToBounds = YES;
        _filterImageView.image = self.image;
        [self addSubview:_filterImageView];
    }
    
    /*
    if (_filterCoverView == nil) {
        _filterCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        _filterCoverView.backgroundColor = [@"#FF7725".fj_color colorWithAlphaComponent:0.5];
        [self addSubview:_filterCoverView];
    }
    */
    
    if (_filterTextBackgroundView == nil) {
        _filterTextBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, 80, 20)];
        _filterTextBackgroundView.backgroundColor = @"#FF7725".fj_color;
        [self addSubview:_filterTextBackgroundView];
    }
    
    if (_filterTextLabel == nil) {
        _filterTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, 80, 20)];
        _filterTextLabel.font = [UIFont systemFontOfSize:12];
        _filterTextLabel.textAlignment = NSTextAlignmentCenter;
        _filterTextLabel.text = self.title;
        [self addSubview:_filterTextLabel];
    }
    
    if (_button == nil) {
        _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 100)];
        [self addSubview:_button];
    }
    
    [self fj_cornerRadius:2.0];
    [self updateSelected:self.selected];
}

- (void)updateFilterImage:(UIImage *)filterImage {
    
    self.filterImageView.image = filterImage;
}

- (void)updateSelected:(BOOL)selected {
    
    self.selected = selected;
    // self.filterCoverView.hidden = !selected;
    self.filterTextBackgroundView.hidden = !selected;
    if (selected) {
        self.filterTextLabel.textColor = [UIColor whiteColor];
    }else {
        self.filterTextLabel.textColor = @"#78787D".fj_color;
    }
}

- (CGSize)intrinsicContentSize {
    
    return CGSizeMake(80.0, 100.0);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
