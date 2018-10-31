//
//  FJPhotoManager.h
//  FJCamera
//
//  Created by Fu Jie on 2018/10/31.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FJCameraCommonHeader.h"
#import "FJTuningObject.h"
#import "FJImageTagModel.h"

@interface FJPhotoManager : NSObject

@property (nonatomic, strong) PHAsset *currentPhotoAsset;
@property (nonatomic, strong) UIImage *currentPhotoImage;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, assign, readonly) BOOL currentPhotoChanged;

@property (nonatomic, strong) NSMutableArray<PHAsset *> *selectedPhotoAssets;
@property (nonatomic, strong) NSMutableDictionary<PHAsset *, UIImage *> *selectedPhotoAssetsCroppedImages;
@property (nonatomic, strong) NSMutableDictionary<PHAsset *, FJTuningObject *> *selectedPhotoAssetsTuningValues;
@property (nonatomic, strong) NSMutableDictionary<PHAsset *, NSMutableArray<FJImageTagModel *> *> *selectedPhotoAssetsImageTags;

+ (FJPhotoManager *)shared;

// 初始化
- (void)initial:(NSMutableArray<PHAsset *> *)selectedPhotoAssets;

// 清空参数
- (void)clean;

// 获取当前照片的TuningObject
- (FJTuningObject *)currentTuningObject;

// 获取TuningObject
- (FJTuningObject *)tuningObject:(PHAsset *)asset;

// 设置当前照片的Tuning参数
- (void)setCurrentTuningObject:(FJTuningType)type value:(float)value;

// 设置照片的Tuning参数
- (void)setTuningObject:(FJTuningType)type value:(float)value forAsset:(PHAsset *)asset;

// 获取当前Cropped Image
- (UIImage *)currentCroppedImage;

// 获取Cropped Image
- (UIImage *)croppedImage:(PHAsset *)asset;

// 设置当前照片的Cropped Image
- (void)setCurrentCroppedImage:(UIImage *)image;

// 设置照片的Cropped Image
- (void)setCroppedImage:(UIImage *)image forAsset:(PHAsset *)asset;

// 同步获取固定尺寸的图片
+ (void)getStaticTargetImage:(PHAsset *)asset result:(void(^)(UIImage * image))result;

@end
