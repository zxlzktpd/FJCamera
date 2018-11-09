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

@interface FJPhotoModel : NSObject

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) UIImage *croppedImage;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImage *smallOriginalImage;
@property (nonatomic, strong) UIImage *currentImage;
@property (nonatomic, strong) FJTuningObject *tuningObject;
@property (nonatomic, strong) NSMutableArray<FJImageTagModel *> *imageTags;

- (instancetype)initWithAsset:(PHAsset *)asset;

@end

@interface FJPhotoManager : NSObject

@property (nonatomic, strong) NSMutableArray<FJPhotoModel *> *allPhotos;

@property (nonatomic, strong) FJPhotoModel *currentEditPhoto;

+ (FJPhotoManager *)shared;

// 新增
- (FJPhotoModel *)add:(PHAsset *)asset;

// 删除
- (void)remove:(PHAsset *)asset;

// 删除（Index）
- (void)removeByIndex:(NSUInteger)index;

// 交换
- (void)switchPosition:(NSUInteger)one another:(NSUInteger)another;

// 插入首部
- (void)setTopPosition:(NSUInteger)index;

// 清空
- (void)clean;

@end
