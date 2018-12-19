//
//  PHAsset+QuickEdit.h
//  FJCamera
//
//  Created by Fu Jie on 2018/12/19.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <Photos/Photos.h>
#import "PHAsset+Utility.h"

// 用于FJPhotoEditViewController
#define FJCAMERA_IMAGE_WIDTH  (UI_SCREEN_WIDTH)
#define FJCAMERA_IMAGE_HEIGHT (UI_SCREEN_HEIGHT - UI_TOP_HEIGHT - 167.0)

@interface PHAsset (QuickEdit)

/**
 *  同步获取小尺寸的图片
 */
- (UIImage *)getSmallTargetImage;

/**
 *  同步获取一般尺寸的图片
 */
- (UIImage *)getGeneralTargetImage;

/**
 *  同步获取一般尺寸的图片
 */
- (UIImage *)getLargeTargetImage;

@end
