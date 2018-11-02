//
//  FJPhotoManager.m
//  FJCamera
//
//  Created by Fu Jie on 2018/10/31.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJPhotoManager.h"

@interface FJPhotoManager ()

@property (nonatomic, assign) BOOL currentPhotoChanged;

@end

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

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    
    if (_currentIndex != currentIndex) {
        _currentIndex = currentIndex;
        self.currentPhotoAsset = [self.selectedPhotoAssets fj_safeObjectAtIndex:_currentIndex];
    }
}

- (void)setCurrentPhotoAsset:(PHAsset *)currentPhotoAsset {
    
    if ([_currentPhotoAsset isEqual:currentPhotoAsset]) {
        _currentPhotoChanged = NO;
    }else {
        _currentPhotoAsset = currentPhotoAsset;
        _currentPhotoChanged = YES;
        _currentPhotoImage = nil;
        MF_WEAK_SELF
        [FJPhotoManager getStaticTargetImage:self.currentPhotoAsset result:^(UIImage *image) {
            weakSelf.currentPhotoImage = image;
        }];
    }
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
        case FJTuningTypeBrightness:
        {
            tuningObject.brightnessValue = value;
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
        case FJTuningTypeTemperature:
        {
            tuningObject.temperatureValue = value;
            break;
        }
        case FJTuningTypeVignette:
        {
            tuningObject.vignetteValue = value;
            break;
        }
        default:
            break;
    }
}

// 获取当前Cropped Image
- (UIImage *)currentCroppedImage {
    
    return [self croppedImage:self.currentPhotoAsset];
}

// 获取Cropped Image
- (UIImage *)croppedImage:(PHAsset *)asset {
    
    if (asset == nil) {
        return nil;
    }
    return [self.selectedPhotoAssetsCroppedImages objectForKey:asset];
}

// 设置当前照片的Cropped Image
- (void)setCurrentCroppedImage:(UIImage *)image {
    
    [self setCroppedImage:image forAsset:self.currentPhotoAsset];
}

// 设置照片的Cropped Image
- (void)setCroppedImage:(UIImage *)image forAsset:(PHAsset *)asset {
    
    if (image == nil) {
        [self.selectedPhotoAssetsCroppedImages removeObjectForKey:asset];
    }else {
        [self.selectedPhotoAssetsCroppedImages setObject:image forKey:asset];
    }
}

// 同步获取固定尺寸的图片
+ (void)getStaticTargetImage:(PHAsset *)asset result:(void(^)(UIImage * image))result {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        // 同步获得图片, 只会返回1张图片
        options.synchronous = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT - UI_TOP_HEIGHT - 167.0) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                result == nil ? : result(image);
            });
        }];
    });
}

@end
