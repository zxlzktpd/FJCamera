//
//  FJCropperView.h
//  FJCamera
//
//  Created by Fu Jie on 2018/11/13.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FJPhotoEditCommonHeader.h"
#import "FJPhotoManager.h"

@interface FJCropperView : UIView

+ (FJCropperView *)create:(CGFloat)horizontalExtemeRatio verticalExtemeRatio:(CGFloat)verticalExtemeRatio ins:(BOOL)ins debug:(BOOL)debug croppedBlock:(void(^)(FJPhotoModel *photoModel, CGRect frame))croppedBlock updownBlock:(void(^)(BOOL up))updownBlock;

// 更新图片
- (void)updateModel:(FJPhotoModel *)model;

// 更新留白和充满状态
- (void)updateCompressed:(BOOL)compressed;

// 是否在裁切图片
- (BOOL)inCroppingImage;

@end
