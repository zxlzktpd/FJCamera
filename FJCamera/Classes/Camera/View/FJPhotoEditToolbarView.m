//
//  FJPhotoEditToolbarView.m
//  FJCamera
//
//  Created by Fu Jie on 2018/10/30.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJPhotoEditToolbarView.h"

@interface FJPhotoEditToolbarView ()

@property (nonatomic, weak) IBOutlet UIView *filterView;
@property (nonatomic, weak) IBOutlet UIView *cropperView;
@property (nonatomic, weak) IBOutlet UIView *tuningView;
@property (nonatomic, weak) IBOutlet UIView *tagView;

@end

@implementation FJPhotoEditToolbarView

+ (FJPhotoEditToolbarView *)create:(FJPhotoEditMode)mode {
    
    FJPhotoEditToolbarView *view = [[FJPhotoEditToolbarView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_WIDTH, 167.0)];
    return view;
}

- (void)_buildUI:(FJPhotoEditMode)mode {
    
    BOOL visible = mode & FJPhotoEditModeFilter;
    self.filterView.hidden = !visible;
    visible = mode & FJPhotoEditModeCropprer;
    self.cropperView.hidden = !visible;
    visible = mode & FJPhotoEditModeTuning;
    self.tuningView.hidden = !visible;
    visible = mode & FJPhotoEditModeTag;
    self.tagView.hidden = !visible;
}

- (IBAction)_tapFilter:(id)sender {
    
    self.filterBlock == nil ? : self.filterBlock();
}

- (IBAction)_tapCropper:(id)sender {
    
}

- (IBAction)_tapTuning:(id)sender {
    
}

- (IBAction)_tapTag:(id)sender {
    
    self.tagBlock == nil ? : self.tagBlock();
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
