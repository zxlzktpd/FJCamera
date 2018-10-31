//
//  FJPhotoEditTuningView.m
//  FJCamera
//
//  Created by Fu Jie on 2018/10/30.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJPhotoEditTuningView.h"

@interface FJPhotoEditTuningView ()

@end

@implementation FJPhotoEditTuningView

+ (FJPhotoEditTuningView *)create:(CGRect)frame editingBlock:(void(^)(BOOL inEditing))editingBlock tuneBlock:(void(^)(FJTuningType type, float value, BOOL confirm))tuneBlock {
    
    FJPhotoEditTuningView *view = MF_LOAD_NIB(@"FJPhotoEditTuningView");
    view.frame = frame;
    view.editingBlock = editingBlock;
    view.tuneBlock = tuneBlock;
    return view;
}

- (IBAction)_tapLight:(id)sender {
    
    MF_WEAK_SELF
    self.editingBlock == nil ? : self.editingBlock(YES);
    FJTuningObject *object = [[FJPhotoManager shared] currentTuningObject];
    FJPhotoEditTuningValueView *view = [FJPhotoEditTuningValueView create:self.bounds title:@"亮度" value:object.lightValue editingBlock:self.editingBlock okBlock:^(float value) {
        weakSelf.tuneBlock == nil ? : weakSelf.tuneBlock(FJTuningTypeLight, value, YES);
    }];
    [self addSubview:view];
}

- (IBAction)_tapContrast:(id)sender {

    MF_WEAK_SELF
    self.editingBlock == nil ? : self.editingBlock(YES);
    FJTuningObject *object = [[FJPhotoManager shared] currentTuningObject];
    FJPhotoEditTuningValueView *view = [FJPhotoEditTuningValueView create:self.bounds title:@"对比度" value:object.contrastValue editingBlock:self.editingBlock okBlock:^(float value) {
        weakSelf.tuneBlock == nil ? : weakSelf.tuneBlock(FJTuningTypeContrast, value, YES);
    }];
    [self addSubview:view];
}

- (IBAction)_tapSaturation:(id)sender {
    
    MF_WEAK_SELF
    self.editingBlock == nil ? : self.editingBlock(YES);
    FJTuningObject *object = [[FJPhotoManager shared] currentTuningObject];
    FJPhotoEditTuningValueView *view = [FJPhotoEditTuningValueView create:self.bounds title:@"饱和度" value:object.saturationValue editingBlock:self.editingBlock okBlock:^(float value) {
        weakSelf.tuneBlock == nil ? : weakSelf.tuneBlock(FJTuningTypeSaturation, value, YES);
    }];
    [self addSubview:view];
}

- (IBAction)_tapWarm:(id)sender {
    
    MF_WEAK_SELF
    self.editingBlock == nil ? : self.editingBlock(YES);
    FJTuningObject *object = [[FJPhotoManager shared] currentTuningObject];
    FJPhotoEditTuningValueView *view = [FJPhotoEditTuningValueView create:self.bounds title:@"暖色调" value:object.warmValue editingBlock:self.editingBlock okBlock:^(float value) {
        weakSelf.tuneBlock == nil ? : weakSelf.tuneBlock(FJTuningTypeWarm, value, YES);
    }];
    [self addSubview:view];
}

- (IBAction)_tapHalation:(id)sender {
    
    MF_WEAK_SELF
    self.editingBlock == nil ? : self.editingBlock(YES);
    FJTuningObject *object = [[FJPhotoManager shared] currentTuningObject];
    FJPhotoEditTuningValueView *view = [FJPhotoEditTuningValueView create:self.bounds title:@"晕影" value:object.halationValue editingBlock:self.editingBlock okBlock:^(float value) {
        weakSelf.tuneBlock == nil ? : weakSelf.tuneBlock(FJTuningTypeHalation, value, YES);
    }];
    [self addSubview:view];
}

- (IBAction)_tapBack:(id)sender {
    
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
