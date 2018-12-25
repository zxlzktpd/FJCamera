//
//  PHAsset+Utility.h
//  AFNetworking
//
//  Created by Fu Jie on 2018/11/7.
//

#import <Photos/Photos.h>
#import <FJKit_OC/Macro.h>

@interface PHAsset (Utility)

/**
 * 同步获取固定尺寸的图片
 */
- (UIImage *)fj_imageSyncTargetSize:(CGSize)size fast:(BOOL)fast iCloudAsyncDownload:(BOOL)iCloudAsyncDownload;

/**
 * 异步获取固定尺寸的图片
 */
- (void)fj_imageAsyncTargetSize:(CGSize)size fast:(BOOL)fast iCloud:(BOOL)iCloud progress:(PHAssetImageProgressHandler)progress result:(void(^)(UIImage * image))result;

/**
 * 同步获取固定倍数尺寸的图片
 */
- (UIImage *)fj_imageSyncTargetSize:(CGSize)size multiples:(CGFloat)multiples fast:(BOOL)fast;

/**
 * 异步获取固定倍数尺寸的图片
 */
- (void)fj_imageASyncTargetSize:(CGSize)size multiples:(CGFloat)multiples fast:(BOOL)fast result:(void(^)(UIImage * image))result;

/**
 *  是否是iCloud图片
 */
- (BOOL)fj_isCloudImage;

- (PHImageRequestID)requestImageDataCompletion:(void (^)(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info))completion progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler;

@end
