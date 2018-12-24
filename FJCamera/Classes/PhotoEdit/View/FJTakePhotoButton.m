//
//  FJTakePhotoButton.m
//  FJCamera
//
//  Created by Fu Jie on 2018/12/24.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJTakePhotoButton.h"
#import <FJKit_OC/Macro.h>

@interface FJTakePhotoButton ()

@property (nonatomic, copy) void(^takePhotoBlock)(void);

@end

@implementation FJTakePhotoButton

+ (FJTakePhotoButton *)create:(void(^)(void))takePhotoBlock {
    
    FJTakePhotoButton *button = MF_LOAD_NIB(@"FJTakePhotoButton");
    button.takePhotoBlock = takePhotoBlock;
    return button;
}

- (IBAction)_tap:(id)sender {
    
    self.takePhotoBlock == nil ? : self.takePhotoBlock();
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
