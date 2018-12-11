//
//  FJPhotoImageTagView.h
//  FJCamera
//
//  Created by Fu Jie on 2018/11/5.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FJImageTagModel.h"

#define FJPhotoImageTagViewHeight (60.0)

@interface FJPhotoImageTagView : UIView

+ (FJPhotoImageTagView *)create:(CGPoint)point model:(FJImageTagModel *)model canmove:(BOOL)canmove tapBlock:(void(^)(__weak FJPhotoImageTagView *photoImageTagView))tapBlock movingBlock:(void(^)(void))movingBlock;

- (void)reverseDirection;

- (FJImageTagModel *)getTagModel;

@end
