//
//  FJPhotoEditTuningValueView.m
//  FJCamera
//
//  Created by Fu Jie on 2018/10/31.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJPhotoEditTuningValueView.h"

@interface FJPhotoEditTuningValueView ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;
@property (nonatomic, weak) IBOutlet UISlider *valueSlider;
@property (nonatomic, assign) CGFloat value;

@end

@implementation FJPhotoEditTuningValueView

+ (FJPhotoEditTuningValueView *)create:(CGRect)frame title:(NSString *)title value:(float)value editingBlock:(void(^)(BOOL inEditing))editingBlock okBlock:(void(^)(float value))okBlock {
    
    FJPhotoEditTuningValueView *view = MF_LOAD_NIB(@"FJPhotoEditTuningValueView");
    view.frame = frame;
    [view updateTitle:title];
    [view updateValue:value];
    view.editingBlock = editingBlock;
    view.okBlock = okBlock;
    [view.valueSlider addTarget:view action:@selector(_sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    return view;
}

- (void)updateTitle:(NSString *)title {
    
    self.titleLabel.text = title;
}

- (void)updateValue:(float)value {
    
    self.value = value;
    self.valueLabel.text = [NSString stringWithFormat:@"%d", (int)value];
    self.valueSlider.value = value;
}

- (IBAction)_tapBack:(id)sender {
    
    self.editingBlock == nil ? : self.editingBlock(NO);
    [self removeFromSuperview];
}

- (IBAction)_tapOK:(id)sender {
    
    self.editingBlock == nil ? : self.editingBlock(NO);
    self.okBlock == nil ? : self.okBlock(self.value);
    [self removeFromSuperview];
}

- (void)_sliderValueChanged:(UISlider *)slider {
    
    [self updateValue:slider.value];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
