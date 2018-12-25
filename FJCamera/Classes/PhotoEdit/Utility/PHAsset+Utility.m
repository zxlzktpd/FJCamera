//
//  PHAsset+Utility.m
//  AFNetworking
//
//  Created by Fu Jie on 2018/11/7.
//

#import "PHAsset+Utility.h"

@implementation PHAsset (Utility)

/**
 * 同步获取固定尺寸的图片
 */
- (UIImage *)fj_imageSyncTargetSize:(CGSize)size fast:(BOOL)fast {
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    if (fast) {
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    }else {
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    }
    __block UIImage *ret = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[PHImageManager defaultManager] requestImageForAsset:self targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        ret = image;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return ret;
}

/**
 * 异步获取固定尺寸的图片
 */
- (void)fj_imageAsyncTargetSize:(CGSize)size fast:(BOOL)fast result:(void(^)(UIImage * image))result {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        // 同步获得图片, 只会返回1张图片
        options.synchronous = YES;
        if (fast) {
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        }else{
            options.resizeMode = PHImageRequestOptionsResizeModeExact;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        }
        [[PHImageManager defaultManager] requestImageForAsset:self targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                result == nil ? : result(image);
            });
        }];
    });
}

/**
 * 同步获取固定倍数尺寸的图片
 */
- (UIImage *)fj_imageSyncTargetSize:(CGSize)size multiples:(CGFloat)multiples fast:(BOOL)fast {
    
    CGSize targetSize = CGSizeZero;
    if (self.pixelHeight / self.pixelWidth > size.height / size.width) {
        targetSize = CGSizeMake(size.height * ((CGFloat)self.pixelWidth / (CGFloat)self.pixelHeight) * multiples, size.height * multiples);
    }else {
        targetSize = CGSizeMake(size.width * multiples, size.width * ((CGFloat)self.pixelHeight / (CGFloat)self.pixelWidth) * multiples);
    }
    return [self fj_imageSyncTargetSize:targetSize fast:fast];
}

/**
 * 异步获取固定倍数尺寸的图片
 */
- (void)fj_imageSyncTargetSize:(CGSize)size multiples:(CGFloat)multiples fast:(BOOL)fast result:(void(^)(UIImage * image))result {
    
    CGSize targetSize = CGSizeZero;
    if (self.pixelHeight / self.pixelWidth > size.height / size.width) {
        targetSize = CGSizeMake(size.height * ((CGFloat)self.pixelWidth / (CGFloat)self.pixelHeight) * multiples, size.height * multiples);
    }else {
        targetSize = CGSizeMake(size.width * multiples, size.width * ((CGFloat)self.pixelHeight / (CGFloat)self.pixelWidth) * multiples);
    }
    [self fj_imageAsyncTargetSize:targetSize fast:fast result:result];
}

/**
 *  是否是iCloud图片
 */
- (BOOL)fj_isCloudImage {
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.synchronous = YES;
    __block BOOL isICloudAsset = NO;
    [[PHImageManager defaultManager] requestImageForAsset:self targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        //根据请求会调中的参数重 NSDictionary *info 是否有cloudKey 来判断是否是  iCloud
        if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue])
        {
            isICloudAsset = YES;
        }
    }];
    return !isICloudAsset;
}

@end
