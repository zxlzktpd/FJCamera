//
//  FJPhotoEditTuningValueView.h
//  FJCamera
//
//  Created by Fu Jie on 2018/10/31.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FJCameraCommonHeader.h"

@interface FJPhotoEditTuningValueView : UIView

@property (nonatomic, copy) void(^okBlock)(float value);
@property (nonatomic, copy) void(^editingBlock)(BOOL inEditing);

- (void)updateTitle:(NSString *)title;

- (void)updateValue:(float)value;

+ (FJPhotoEditTuningValueView *)create:(CGRect)frame title:(NSString *)title value:(float)value editingBlock:(void(^)(BOOL inEditing))editingBlock okBlock:(void(^)(float value))okBlock;

@end
