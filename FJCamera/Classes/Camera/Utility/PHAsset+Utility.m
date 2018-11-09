//
//  PHAsset+Utility.m
//  AFNetworking
//
//  Created by Fu Jie on 2018/11/7.
//

#import "PHAsset+Utility.h"

@implementation PHAsset (Utility)

// 同步获取固定小尺寸的图片
- (UIImage *)getStaticSmallTargetImage {
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    __block UIImage *ret = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[PHImageManager defaultManager] requestImageForAsset:self targetSize:CGSizeMake(FJCAMERA_IMAGE_WIDTH / 4.0, FJCAMERA_IMAGE_HEIGHT / 4.0) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        ret = image;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return ret;
}

// 同步获取固定尺寸的图片
- (UIImage *)getStaticTargetImage {
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    __block UIImage *ret = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[PHImageManager defaultManager] requestImageForAsset:self targetSize:CGSizeMake(FJCAMERA_IMAGE_WIDTH, FJCAMERA_IMAGE_HEIGHT) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        ret = image;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return ret;
}

// 获取固定尺寸的图片
- (void)getStaticTargetImage:(void(^)(UIImage * image))result {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        // 同步获得图片, 只会返回1张图片
        options.synchronous = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        [[PHImageManager defaultManager] requestImageForAsset:self targetSize:CGSizeMake(FJCAMERA_IMAGE_WIDTH, FJCAMERA_IMAGE_HEIGHT) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                result == nil ? : result(image);
            });
        }];
    });
}

@end
