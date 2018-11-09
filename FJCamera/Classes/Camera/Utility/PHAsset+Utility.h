//
//  PHAsset+Utility.h
//  AFNetworking
//
//  Created by Fu Jie on 2018/11/7.
//

#import <Photos/Photos.h>
#import <FJKit_OC/Macro.h>

#define FJCAMERA_IMAGE_WIDTH  (UI_SCREEN_WIDTH)
#define FJCAMERA_IMAGE_HEIGHT (UI_SCREEN_HEIGHT - UI_TOP_HEIGHT - 167.0)

@interface PHAsset (Utility)

// 同步获取固定小尺寸的图片
- (UIImage *)getStaticSmallTargetImage;

// 同步获取固定尺寸的图片
- (UIImage *)getStaticTargetImage;

// 获取固定尺寸的图片
- (void)getStaticTargetImage:(void(^)(UIImage * image))result;

@end
