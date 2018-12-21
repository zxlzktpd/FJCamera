//
//  FJPhotoManager.m
//  FJCamera
//
//  Created by Fu Jie on 2018/10/31.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJPhotoManager.h"
#import "PHAsset+QuickEdit.h"
#import "FJFilterManager.h"
#import <FJKit_OC/UIImage+Utility_FJ.h>

@implementation FJPhotoModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tuningObject = [[FJTuningObject alloc] init];
        self.imageTags = (NSMutableArray<FJImageTagModel *> *)[[NSMutableArray alloc] init];
        self.beginCropPoint = CGPointZero;
        self.endCropPoint = CGPointZero;
    }
    return self;
}

- (instancetype)initWithAsset:(PHAsset *)asset {
    
    self = [self init];
    self.asset = asset;
    return self;
}

- (UIImage *)originalImage {
    
    if (_originalImage == nil) {
        _originalImage = [self.asset getGeneralTargetImage];
    }
    return _originalImage;
}

- (UIImage *)smallOriginalImage {
    
    
    if (self.needCrop == NO) {
        if (_smallOriginalImage == nil) {
            _smallOriginalImage = [self.asset getSmallTargetImage];
        }
    }else {
        static CGPoint lastBeginPoint;
        if (_smallOriginalImage == nil || !CGPointEqualToPoint(lastBeginPoint, self.beginCropPoint)) {
            _smallOriginalImage = [[self.asset getSmallTargetImage] fj_imageCropBeginPointRatio:self.beginCropPoint endPointRatio:self.endCropPoint];
        }
        lastBeginPoint = self.beginCropPoint;
    }
    return _smallOriginalImage;
}

- (UIImage *)currentImage {
    
    if (_croppedImage != nil) {
        return _croppedImage;
    }
    return _originalImage;
}

- (NSMutableArray<UIImage *> *)filterThumbImages {
    
    if (_filterThumbImages == nil) {
        _filterThumbImages = (NSMutableArray<UIImage *> *)[[NSMutableArray alloc] init];
        for (int i = 0; i < [FJPhotoModel filterTypes].count; i++ ) {
            FJFilterType type = [[[FJPhotoModel filterTypes] objectAtIndex:i] integerValue];
            UIImage *filteredSmallImage = [[FJFilterManager shared] getImage:self.smallOriginalImage filterType:type];
            [_filterThumbImages addObject:filteredSmallImage];
        }
    }
    return _filterThumbImages;
}

+ (NSArray *)filterTypes {
    
    return @[@(FJFilterTypeOriginal),
             @(FJFilterTypePhotoEffectChrome),
             @(FJFilterTypePhotoEffectFade),
             @(FJFilterTypePhotoEffectInstant),
             @(FJFilterTypePhotoEffectMono),
             @(FJFilterTypePhotoEffectNoir),
             @(FJFilterTypePhotoEffectProcess),
             @(FJFilterTypePhotoEffectTonal),
             @(FJFilterTypePhotoEffectTransfer)];
}

+ (NSArray *)filterTitles {
    
    return @[@"原图",@"铬黄",@"褪色",@"怀旧",@"单色",@"黑白",@"冲印",@"色调",@"岁月"];
}

@end

@interface FJPhotoManager ()

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
    return self;
}

- (NSMutableArray<FJPhotoModel *> *)allPhotos {
    
    if (_allPhotos == nil) {
        _allPhotos = (NSMutableArray<FJPhotoModel *> *)[[NSMutableArray alloc] init];
    }
    return _allPhotos;
}

// 获取
- (FJPhotoModel *)get:(PHAsset *)asset {
    
    for (FJPhotoModel *model in self.allPhotos) {
        if ([model.asset isEqual:asset]) {
            return model;
        }
    }
    return [[FJPhotoModel alloc] initWithAsset:asset];
}

// 新增
- (FJPhotoModel *)add:(PHAsset *)asset {
    
    if (asset != nil) {
        FJPhotoModel *model = [[FJPhotoModel alloc] initWithAsset:asset];
        [self.allPhotos addObject:model];
        return model;
    }
    return nil;
}

// 新增，Distinct
- (FJPhotoModel *)addDistinct:(id)object {
    
    if (object != nil) {
        if ([object isKindOfClass:[PHAsset class]]) {
            
            PHAsset *asset = object;
            for (FJPhotoModel *model in self.allPhotos) {
                if ([model.asset isEqual:asset]) {
                    return model;
                }
            }
            FJPhotoModel *model = [[FJPhotoModel alloc] initWithAsset:asset];
            [self.allPhotos addObject:model];
            return model;
        }else if ([object isKindOfClass:[FJPhotoModel class]]) {
            
            FJPhotoModel *photoModel = object;
            for (int i = 0; i < self.allPhotos.count; i++) {
                FJPhotoModel *model = [self.allPhotos objectAtIndex:i];
                if ([model.asset isEqual:photoModel.asset]) {
                    [self.allPhotos fj_arrayReplaceObjectAtIndex:i withObject:photoModel];
                    return photoModel;
                }
            }
            [self.allPhotos addObject:photoModel];
            return photoModel;
        }
    }
    return nil;
}

// 删除
- (void)remove:(PHAsset *)asset {
    
    if (asset != nil) {
        for (int i = (int)self.allPhotos.count - 1; i >= 0; i-- ) {
            FJPhotoModel *model = [self.allPhotos objectAtIndex:i];
            if ([model.asset isEqual:asset]) {
                [self.allPhotos removeObjectAtIndex:i];
                break;
            }
        }
    }
}

// 删除（Index）
- (void)removeByIndex:(NSUInteger)index {
    
    [self.allPhotos removeObjectAtIndex:index];
}

// 交换
- (void)switchPosition:(NSUInteger)one another:(NSUInteger)another {
    
    [self.allPhotos exchangeObjectAtIndex:one withObjectAtIndex:another];
}

// 插入首部
- (void)setTopPosition:(NSUInteger)index {
    
    if (index == 0) {
        return;
    }
    [self.allPhotos insertObject:[self.allPhotos objectAtIndex:index] atIndex:0];
    [self.allPhotos removeObjectAtIndex:(index+1)];
}

// 清空
- (void)clean {
    
    [self.allPhotos removeAllObjects];
}


@end
