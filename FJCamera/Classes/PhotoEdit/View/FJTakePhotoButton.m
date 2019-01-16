//
//  FJTakePhotoButton.m
//  FJCamera
//
//  Created by Fu Jie on 2018/12/24.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJTakePhotoButton.h"
#import <FJKit_OC/Macro.h>
#import <Masonry/Masonry.h>

@interface FJTakePhotoButton ()


@property (nonatomic, weak) IBOutlet UIView *takePhotoView;
@property (nonatomic, weak) IBOutlet UIView *draftView;
@property (nonatomic, copy) void(^takePhotoBlock)(void);
@property (nonatomic, copy) void(^draftBlock)(void);

@end

@implementation FJTakePhotoButton

+ (FJTakePhotoButton *)create:(BOOL)withDraft draftBlock:(void(^)(void))draftBlock takePhotoBlock:(void(^)(void))takePhotoBlock {
    
    FJTakePhotoButton *button = MF_LOAD_NIB(@"FJTakePhotoButton");
    if (withDraft) {
        button.draftBlock = draftBlock;
    }else {
        button.draftView.hidden = YES;
        MF_WEAK_OBJECT(button)
        [button.takePhotoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakbutton);
        }];
    }
    button.takePhotoBlock = takePhotoBlock;
    return button;
}

- (IBAction)_tap:(UIButton *)sender {
    
    if (sender.tag == 0) {
        self.takePhotoBlock == nil ? : self.takePhotoBlock();
    }else if (sender.tag == 1) {
        self.draftBlock == nil ? : self.draftBlock();
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
