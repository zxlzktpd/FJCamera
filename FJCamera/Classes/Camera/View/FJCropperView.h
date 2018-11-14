//
//  FJCropperView.h
//  FJCamera
//
//  Created by Fu Jie on 2018/11/13.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FJCameraCommonHeader.h"

@interface FJCropperView : UIView

+ (FJCropperView *)create;

// 更新图片
- (void)updateImage:(UIImage *)image;

// 更新留白和充满状态
- (void)updateCompressed:(BOOL)compressed;

@end
