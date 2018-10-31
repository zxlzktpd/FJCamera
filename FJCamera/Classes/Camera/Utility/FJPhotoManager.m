//
//  FJPhotoManager.m
//  FJCamera
//
//  Created by Fu Jie on 2018/10/31.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJPhotoManager.h"

@implementation FJPhotoManager

static FJPhotoManager *SINGLETON = nil;
static bool isFirstAccess = YES;

+ (FJPhotoManager *)shared {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];
    });
    
    return SINGLETON;
}

#pragma mark - Life Cycle
+ (id)allocWithZone:(NSZone *)zone {
    return [self shared];
}

- (id)copy {
    return [[FJPhotoManager alloc] init];
}

- (id)mutableCopy {
    return [[FJPhotoManager alloc] init];
}

- (id)init {
    
    if(SINGLETON){
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    self.selectedPhotoAssets = (NSMutableArray<PHAsset *> *)[NSMutableArray new];
    self.selectedPhotoAssetsCroppedImages = (NSMutableDictionary<PHAsset *, UIImage *> *)[NSMutableDictionary new];
    self.selectedPhotoAssetsTuningValues = (NSMutableDictionary<PHAsset *, FJTuningObject *> *)[NSMutableDictionary new];
    self.selectedPhotoAssetsImageTags = (NSMutableDictionary<PHAsset *, NSMutableArray<FJImageTagModel *> *> *)[NSMutableDictionary new];
    return self;
}

// 初始化
- (void)initial:(NSMutableArray<PHAsset *> *)selectedPhotoAssets {
    
    if (selectedPhotoAssets == nil || selectedPhotoAssets.count == 0) {
        return;
    }
    
    self.currentPhotoAsset = [selectedPhotoAssets firstObject];
    [self.selectedPhotoAssets addObjectsFromArray:selectedPhotoAssets];
    for (PHAsset *asset in self.selectedPhotoAssets) {
        [self.selectedPhotoAssetsTuningValues setObject:[FJTuningObject new] forKey:asset];
    }
}

// 清空参数
- (void)clean {
    
    [self.selectedPhotoAssets removeAllObjects];
    [self.selectedPhotoAssetsCroppedImages removeAllObjects];
    [self.selectedPhotoAssetsTuningValues removeAllObjects];
    [self.selectedPhotoAssetsImageTags removeAllObjects];
}

// 获取当前照片的TuningObject
- (FJTuningObject *)currentTuningObject {
    
    return [self tuningObject:self.currentPhotoAsset];
}

// 获取TuningObject
- (FJTuningObject *)tuningObject:(PHAsset *)asset {
    
    FJTuningObject *object = [self.selectedPhotoAssetsTuningValues objectForKey:asset];
    return object;
}

// 设置当前照片的Tuning参数
- (void)setCurrentTuningObject:(FJTuningType)type value:(float)value {
    
    [self setTuningObject:type value:value forAsset:self.currentPhotoAsset];
}

// 设置照片的Tuning参数
- (void)setTuningObject:(FJTuningType)type value:(float)value forAsset:(PHAsset *)asset {
    
    FJTuningObject *tuningObject = [self currentTuningObject];
    switch (type) {
        case FJTuningTypeLight:
        {
            tuningObject.lightValue = value;
            break;
        }
        case FJTuningTypeContrast:
        {
            tuningObject.contrastValue = value;
            break;
        }
        case FJTuningTypeSaturation:
        {
            tuningObject.saturationValue = value;
            break;
        }
        case FJTuningTypeWarm:
        {
            tuningObject.warmValue = value;
            break;
        }
        case FJTuningTypeHalation:
        {
            tuningObject.halationValue = value;
            break;
        }
        default:
            break;
    }
}

@end
