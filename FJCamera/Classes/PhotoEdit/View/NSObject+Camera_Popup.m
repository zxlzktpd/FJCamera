//
//  NSObject+Camera_Popup.m
//  FJCamera
//
//  Created by Fu Jie on 2019/4/11.
//  Copyright © 2019 Fu Jie. All rights reserved.
//

#import "NSObject+Camera_Popup.h"
#import "FJPhotoDraftEditPopupView.h"
#import <FJKit_OC/Macro.h>
#import <FJKit_OC/FJPopupManager.h>

@implementation NSObject (Camera_Popup)

// 弹出编辑窗口
+ (void)popupDraftEditTool:(void(^)(void))editBlock {
    
    FJPhotoDraftEditPopupView *view = MF_LOAD_NIB(@"FJPhotoDraftEditPopupView");
    view.tapOKBlock = ^{
        [FJPopupManager fj_dismissPopup:FJPopupDismissTapTypeOpen ext:nil];
    };
    view.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, 48.0);
    [FJPopupManager fj_showPopup:view blur:YES spring:NO appear:FJPopupAnimationPopBottom dismiss:FJPopupAnimationNone dismissCompletion:^(FJPopupDismissTapType type, id ext) {
        if (type == FJPopupDismissTapTypeOpen) {
            editBlock == nil ? : editBlock();
        }
    }];
    
}

@end
