//
//  FJPhotoEditToolbarView.m
//  FJCamera
//
//  Created by Fu Jie on 2018/10/30.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJPhotoEditToolbarView.h"
#import "FJPhotoEditCropperView.h"
#import "FJPhotoEditTuningView.h"

@interface FJPhotoEditToolbarView ()

@property (nonatomic, weak) IBOutlet UIView *filterView;
@property (nonatomic, weak) IBOutlet UIView *cropperView;
@property (nonatomic, weak) IBOutlet UIView *tuningView;
@property (nonatomic, weak) IBOutlet UIView *tagView;

@end

@implementation FJPhotoEditToolbarView

+ (FJPhotoEditToolbarView *)create:(FJPhotoEditMode)mode {
    
    FJPhotoEditToolbarView *view = MF_LOAD_NIB(@"FJPhotoEditToolbarView");
    view.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, 167.0);
    [view _buildUI:mode];
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
    
    FJPhotoEditCropperView *view = [FJPhotoEditCropperView create:self.bounds editingBlock:^(BOOL inEditing) {
        NSLog(@"In Editing : %@", inEditing ? @"YES" : @"NO");
    } crop1to1:^{
        NSLog(@"1:1");
    } crop3to4:^{
        NSLog(@"3:4");
    } crop4to3:^{
        NSLog(@"4:3");
    } crop4to5:^{
        NSLog(@"4:5");
    } crop5to4:^{
        NSLog(@"5:4");
    } okBlock:^(NSString *ratio) {
        NSLog(@"Ratio : %@", ratio);
    }];
    [self addSubview:view];
}

- (IBAction)_tapTuning:(id)sender {
    
    FJPhotoEditTuningView *view = [FJPhotoEditTuningView create:self.bounds editingBlock:^(BOOL inEditing) {
        NSLog(@"In Editing Tuning : %@", inEditing ? @"YES" : @"NO");
    }];
    [self addSubview:view];
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
