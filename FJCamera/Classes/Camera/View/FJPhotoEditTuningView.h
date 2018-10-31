//
//  FJPhotoEditTuningView.h
//  FJCamera
//
//  Created by Fu Jie on 2018/10/30.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FJPhotoEditTuningView : UIView

@property (nonatomic, copy) void(^editingBlock)(BOOL inEditing);

+ (FJPhotoEditTuningView *)create:(CGRect)frame editingBlock:(void(^)(BOOL inEditing))editingBlock;

@end
