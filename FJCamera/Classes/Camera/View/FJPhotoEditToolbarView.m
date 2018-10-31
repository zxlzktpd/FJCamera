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

+ (FJPhotoEditToolbarView *)create:(FJPhotoEditMode)mode editingBlock:(void (^)(BOOL inEditing))editingBlock cropBlock:(void (^)(NSString *ratio, BOOL confirm))cropBlock tuneBlock:(void(^)(FJTuningType type, float value, BOOL confirm))tuneBlock {
    
    FJPhotoEditToolbarView *view = MF_LOAD_NIB(@"FJPhotoEditToolbarView");
    view.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, 167.0);
    view.editingBlock = editingBlock;
    view.cropBlock = cropBlock;
    view.tuneBlock = tuneBlock;
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
    
    MF_WEAK_SELF
    FJPhotoEditCropperView *view = [FJPhotoEditCropperView create:self.bounds editingBlock:self.editingBlock crop1to1:^{
        weakSelf.cropBlock == nil ? : weakSelf.cropBlock(@"1:1", NO);
    } crop3to4:^{
        weakSelf.cropBlock == nil ? : weakSelf.cropBlock(@"3:4", NO);
    } crop4to3:^{
        weakSelf.cropBlock == nil ? : weakSelf.cropBlock(@"4:3", NO);
    } crop4to5:^{
        weakSelf.cropBlock == nil ? : weakSelf.cropBlock(@"4:5", NO);
    } crop5to4:^{
        weakSelf.cropBlock == nil ? : weakSelf.cropBlock(@"5:4", NO);
    } okBlock:^(NSString *ratio) {
        weakSelf.cropBlock == nil ? : weakSelf.cropBlock(ratio, YES);
    }];
    [self addSubview:view];
}

- (IBAction)_tapTuning:(id)sender {
    
    FJPhotoEditTuningView *view = [FJPhotoEditTuningView create:self.bounds editingBlock:self.editingBlock tuneBlock:self.tuneBlock];
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
