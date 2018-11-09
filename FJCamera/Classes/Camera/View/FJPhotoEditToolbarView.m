//
//  FJPhotoEditToolbarView.m
//  FJCamera
//
//  Created by Fu Jie on 2018/10/30.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJPhotoEditToolbarView.h"
#import "FJPhotoEditFilterView.h"
#import "FJPhotoEditCropperView.h"
#import "FJPhotoEditTuningView.h"

@interface FJPhotoEditToolbarView ()

@property (nonatomic, weak) IBOutlet UIView *filterView;
@property (nonatomic, weak) IBOutlet UIView *cropperView;
@property (nonatomic, weak) IBOutlet UIView *tuningView;
@property (nonatomic, weak) IBOutlet UIView *tagView;

@property (nonatomic, weak) IBOutlet UIImageView *filterImageView;
@property (nonatomic, weak) IBOutlet UIImageView *cropperImageView;
@property (nonatomic, weak) IBOutlet UIImageView *tuningImageView;
@property (nonatomic, weak) IBOutlet UIImageView *tagImageView;
@property (nonatomic, weak) IBOutlet UILabel *filterLabel;
@property (nonatomic, weak) IBOutlet UILabel *cropperLabel;
@property (nonatomic, weak) IBOutlet UILabel *tuningLabel;
@property (nonatomic, weak) IBOutlet UILabel *tagLabel;

@property (nonatomic, strong) FJPhotoEditFilterView *editFilterView;

@end

@implementation FJPhotoEditToolbarView

- (FJPhotoEditFilterView *)editFilterView {
    
    if (_editFilterView == nil) {
        NSMutableArray *filterImages = [[NSMutableArray alloc] init];
        FJPhotoModel *currentPhotoModel = [FJPhotoManager shared].currentEditPhoto;
        [filterImages addObject:currentPhotoModel.smallOriginalImage];
        [filterImages addObject:currentPhotoModel.smallOriginalImage];
        [filterImages addObject:currentPhotoModel.smallOriginalImage];
        [filterImages addObject:currentPhotoModel.smallOriginalImage];
        [filterImages addObject:currentPhotoModel.smallOriginalImage];
        [filterImages addObject:currentPhotoModel.smallOriginalImage];
        [filterImages addObject:currentPhotoModel.smallOriginalImage];
        [filterImages addObject:currentPhotoModel.smallOriginalImage];
        [filterImages addObject:currentPhotoModel.smallOriginalImage];
        _editFilterView = [FJPhotoEditFilterView create:CGRectMake(0, 0, UI_SCREEN_WIDTH, 118.0) filterImages:filterImages filterNames:@[@"原图",@"滤镜1",@"滤镜2",@"滤镜3",@"滤镜4",@"滤镜5",@"滤镜6",@"滤镜7",@"滤镜8"] selectedBlock:^(NSUInteger index) {
            NSLog(@"select %d", index);
        }];
        [self addSubview:_editFilterView];
    }
    return _editFilterView;
}

+ (FJPhotoEditToolbarView *)create:(FJPhotoEditMode)mode editingBlock:(void (^)(BOOL inEditing))editingBlock cropBlock:(void (^)(NSString *ratio, BOOL confirm))cropBlock tuneBlock:(void(^)(FJTuningType type, float value, BOOL confirm))tuneBlock {
    
    FJPhotoEditToolbarView *view = MF_LOAD_NIB(@"FJPhotoEditToolbarView");
    view.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, 167.0);
    view.editingBlock = editingBlock;
    view.cropBlock = cropBlock;
    view.tuneBlock = tuneBlock;
    [view _buildUI:mode];
    [view _setHighlighted:0];
    view.editFilterView.hidden = NO;
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
    
    self.editFilterView.hidden = NO;
    [self _setHighlighted:0];
}

- (IBAction)_tapCropper:(id)sender {
    
    _editFilterView.hidden = YES;
    [self _setHighlighted:1];
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
    
    _editFilterView.hidden = YES;
    [self _setHighlighted:2];
    FJPhotoEditTuningView *view = [FJPhotoEditTuningView create:self.bounds editingBlock:self.editingBlock tuneBlock:self.tuneBlock];
    [self addSubview:view];
}

- (IBAction)_tapTag:(id)sender {
    
    _editFilterView.hidden = YES;
    [self _setHighlighted:3];
    self.tagBlock == nil ? : self.tagBlock();
}

- (void)_setHighlighted:(NSUInteger)index {
    
    switch (index) {
        case 0:
        {
            [self.filterImageView setHighlighted:YES];
            [self.cropperImageView setHighlighted:NO];
            [self.tuningImageView setHighlighted:NO];
            [self.tagImageView setHighlighted:NO];
            self.filterLabel.textColor = @"#FF7725".fj_color;
            self.cropperLabel.textColor = @"#4F4F53".fj_color;
            self.tuningLabel.textColor = @"#4F4F53".fj_color;
            self.tagLabel.textColor = @"#4F4F53".fj_color;
            break;
        }
        case 1:
        {
            [self.filterImageView setHighlighted:NO];
            [self.cropperImageView setHighlighted:YES];
            [self.tuningImageView setHighlighted:NO];
            [self.tagImageView setHighlighted:NO];
            self.filterLabel.textColor = @"#4F4F53".fj_color;
            self.cropperLabel.textColor = @"#FF7725".fj_color;
            self.tuningLabel.textColor = @"#4F4F53".fj_color;
            self.tagLabel.textColor = @"#4F4F53".fj_color;
            break;
        }
        case 2:
        {
            [self.filterImageView setHighlighted:NO];
            [self.cropperImageView setHighlighted:NO];
            [self.tuningImageView setHighlighted:YES];
            [self.tagImageView setHighlighted:NO];
            self.filterLabel.textColor = @"#4F4F53".fj_color;
            self.cropperLabel.textColor = @"#4F4F53".fj_color;
            self.tuningLabel.textColor = @"#FF7725".fj_color;
            self.tagLabel.textColor = @"#4F4F53".fj_color;
            break;
        }
        case 3:
        {
            [self.filterImageView setHighlighted:NO];
            [self.cropperImageView setHighlighted:NO];
            [self.tuningImageView setHighlighted:NO];
            [self.tagImageView setHighlighted:YES];
            self.filterLabel.textColor = @"#4F4F53".fj_color;
            self.cropperLabel.textColor = @"#4F4F53".fj_color;
            self.tuningLabel.textColor = @"#4F4F53".fj_color;
            self.tagLabel.textColor = @"#FF7725".fj_color;
            break;
        }
        default:
            break;
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
