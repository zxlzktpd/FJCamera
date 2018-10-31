//
//  FJPhotoEditTuningView.m
//  FJCamera
//
//  Created by Fu Jie on 2018/10/30.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJPhotoEditTuningView.h"
#import "FJPhotoEditTuningValueView.h"

@interface FJPhotoEditTuningView ()

@end

@implementation FJPhotoEditTuningView

+ (FJPhotoEditTuningView *)create:(CGRect)frame editingBlock:(void(^)(BOOL inEditing))editingBlock {
    
    FJPhotoEditTuningView *view = MF_LOAD_NIB(@"FJPhotoEditTuningView");
    view.frame = frame;
    view.editingBlock = editingBlock;
    return view;
}

- (IBAction)_tapLight:(id)sender {
    
    self.editingBlock == nil ? : self.editingBlock(YES);
    FJTuningObject *object = [[FJPhotoManager shared] currentTuningObject];
    FJPhotoEditTuningValueView *view = [FJPhotoEditTuningValueView create:self.bounds title:@"亮度" value:object.lightValue editingBlock:self.editingBlock okBlock:^(float value) {
        [[FJPhotoManager shared] setCurrentTuningObject:FJTuningTypeLight value:value];
    }];
    [self addSubview:view];
}

- (IBAction)_tapContrast:(id)sender {

    self.editingBlock == nil ? : self.editingBlock(YES);
    FJTuningObject *object = [[FJPhotoManager shared] currentTuningObject];
    FJPhotoEditTuningValueView *view = [FJPhotoEditTuningValueView create:self.bounds title:@"对比度" value:object.contrastValue editingBlock:self.editingBlock okBlock:^(float value) {
        [[FJPhotoManager shared] setCurrentTuningObject:FJTuningTypeContrast value:value];
    }];
    [self addSubview:view];
}

- (IBAction)_tapSaturation:(id)sender {
    
    self.editingBlock == nil ? : self.editingBlock(YES);
    FJTuningObject *object = [[FJPhotoManager shared] currentTuningObject];
    FJPhotoEditTuningValueView *view = [FJPhotoEditTuningValueView create:self.bounds title:@"饱和度" value:object.saturationValue editingBlock:self.editingBlock okBlock:^(float value) {
        [[FJPhotoManager shared] setCurrentTuningObject:FJTuningTypeSaturation value:value];
    }];
    [self addSubview:view];
}

- (IBAction)_tapWarm:(id)sender {
    
    self.editingBlock == nil ? : self.editingBlock(YES);
    FJTuningObject *object = [[FJPhotoManager shared] currentTuningObject];
    FJPhotoEditTuningValueView *view = [FJPhotoEditTuningValueView create:self.bounds title:@"暖色调" value:object.warmValue editingBlock:self.editingBlock okBlock:^(float value) {
        [[FJPhotoManager shared] setCurrentTuningObject:FJTuningTypeWarm value:value];
    }];
    [self addSubview:view];
}

- (IBAction)_tapHalation:(id)sender {
    
    self.editingBlock == nil ? : self.editingBlock(YES);
    FJTuningObject *object = [[FJPhotoManager shared] currentTuningObject];
    FJPhotoEditTuningValueView *view = [FJPhotoEditTuningValueView create:self.bounds title:@"晕影" value:object.halationValue editingBlock:self.editingBlock okBlock:^(float value) {
        [[FJPhotoManager shared] setCurrentTuningObject:FJTuningTypeHalation value:value];
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
