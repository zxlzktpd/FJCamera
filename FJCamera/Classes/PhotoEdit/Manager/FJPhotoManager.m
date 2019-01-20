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
#import <FJKit_OC/NSArray+JSON_FJ.h>
#import <FJKit_OC/NSDate+Utility_FJ.h>
#import <FJKit_OC/NSString+Image_FJ.h>

#pragma mark - Photo Saving Model
@implementation FJPhotoPostSavingModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"tuningObject" : FJTuningObject.class , @"imageTags" : FJImageTagModel.class};
}

@end

#pragma mark - Post Object Saving Model
@implementation FJPhotoPostDraftSavingModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.photos = (NSMutableArray<FJPhotoPostSavingModel *> *)[[NSMutableArray alloc] init];
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"photos" : FJPhotoPostSavingModel.class};
}

@end

#pragma mark - Post Object List Saving Model
@implementation FJPhotoPostDraftListSavingModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.drafts = (NSMutableArray<FJPhotoPostDraftSavingModel *> *)[[NSMutableArray alloc] init];
    }
    return self;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"drafts" : FJPhotoPostDraftSavingModel.class};
}

@end

#pragma mark - Photo Model
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
            if (_smallOriginalImage == nil) {
                if (_croppedImage != nil) {
                    _smallOriginalImage = _croppedImage;
                }else {
                    _smallOriginalImage = _originalImage;
                }
            }
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
    return self.originalImage;
}

- (NSMutableArray<UIImage *> *)filterThumbImages {
    
    if (_filterThumbImages == nil || _filterThumbImages.count == 0) {
        if (_filterThumbImages == nil) {
            _filterThumbImages = (NSMutableArray<UIImage *> *)[[NSMutableArray alloc] init];
        }
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

#pragma mark - Photo

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
                if ([model.asset isEqual:photoModel.asset] && [model.uuid isEqualToString:photoModel.uuid]) {
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

#pragma mark - Draft

// 判断存在（用于退出保存）
- (BOOL)isDraftExist {
    
    FJPhotoPostDraftListSavingModel *objectListModel = [FJStorage valueAnyObject:[FJPhotoPostDraftListSavingModel class]];
    return objectListModel != nil && objectListModel.drafts != nil && objectListModel.drafts.count > 0;
}

// 保存（用于退出保存）
- (void)saveDraftCache:(BOOL)overwrite extraType:(int)extraType extras:(NSDictionary *)extras {
    
    // 判断是否是已经存在已保存的draft中
    // 如果存在，先删除老的draft，再保存新的draft
    FJPhotoPostDraftListSavingModel *objectListModel = [FJStorage valueAnyObject:[FJPhotoPostDraftListSavingModel class]];
    if (overwrite && objectListModel.drafts.count > 0) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (int i = (int)objectListModel.drafts.count - 1; i >= 0; i--) {
            FJPhotoPostDraftSavingModel *draft = [objectListModel.drafts fj_arrayObjectAtIndex:i];
            [arr removeAllObjects];
            for (FJPhotoPostSavingModel *photo in draft.photos) {
                [arr addObject:photo.assetIdentifier];
            }
            for (int j = 0; j < self.allPhotos.count; j++) {
                FJPhotoModel *model = [self.allPhotos fj_arrayObjectAtIndex:j];
                if ([arr containsObject:model.asset.localIdentifier]) {
                    if (j == self.allPhotos.count - 1) {
                        // 存在重复
                        [objectListModel.drafts fj_arrayRemoveObjectAtIndex:i];
                    }
                }else {
                    break;
                }
            }
        }
    }
    
    if (objectListModel == nil) {
        objectListModel = [[FJPhotoPostDraftListSavingModel alloc] init];
    }
    
    FJPhotoPostDraftSavingModel *objectModel = [[FJPhotoPostDraftSavingModel alloc] init];
    objectModel.extraType = extraType;
    objectModel.extra0 = [extras objectForKey:@"extra0"];
    objectModel.extra1 = [extras objectForKey:@"extra1"];
    objectModel.extra2 = [extras objectForKey:@"extra2"];
    objectModel.extra3 = [extras objectForKey:@"extra3"];
    objectModel.extra4 = [extras objectForKey:@"extra4"];
    objectModel.extra5 = [extras objectForKey:@"extra5"];
    for (FJPhotoModel *model in self.allPhotos) {
        FJPhotoPostSavingModel *postPhotoModel = [[FJPhotoPostSavingModel alloc] init];
        postPhotoModel.uuid = model.uuid;
        postPhotoModel.assetIdentifier = [model.asset localIdentifier];
        postPhotoModel.tuningObject = model.tuningObject;
        postPhotoModel.imageTags = model.imageTags;
        postPhotoModel.compressed = model.compressed;
        postPhotoModel.beginCropPointX = model.beginCropPoint.x;
        postPhotoModel.beginCropPointY = model.beginCropPoint.y;
        postPhotoModel.endCropPointX = model.endCropPoint.x;
        postPhotoModel.endCropPointY = model.endCropPoint.y;
        [objectModel.photos addObject:postPhotoModel];
    }
    objectModel.savingDate = [NSDate fj_dateTimeStampSince1970];
    [objectListModel.drafts addObject:objectModel];
    [FJStorage saveAnyObject:objectListModel];
}

// 加载（用于退出保存）
- (FJPhotoPostDraftListSavingModel *)loadDraftCache {
    
    FJPhotoPostDraftListSavingModel *objectListModel = [FJStorage valueAnyObject:[FJPhotoPostDraftListSavingModel class]];
    return objectListModel;
}

// 加载到allPhoto（用于退出保存）
- (void)loadDraftPhotosToAllPhotos:(FJPhotoPostDraftSavingModel *)draft {
    
    [self clean];
    for (FJPhotoPostSavingModel *savingPhotoModel in draft.photos) {
        
        FJPhotoModel *photoModel = [[FJPhotoModel alloc] init];
        // 赋值照片属性
        photoModel.uuid = savingPhotoModel.uuid;
        photoModel.tuningObject = savingPhotoModel.tuningObject;
        photoModel.imageTags = savingPhotoModel.imageTags;
        photoModel.compressed = savingPhotoModel.compressed;
        photoModel.beginCropPoint = CGPointMake(savingPhotoModel.beginCropPointX, savingPhotoModel.beginCropPointY);
        photoModel.endCropPoint = CGPointMake(savingPhotoModel.endCropPointX, savingPhotoModel.endCropPointY);
        // 查找相册并赋值PHAsset
        PHAsset *findedAsset = [self findByIdentifier:savingPhotoModel.assetIdentifier];
        if (findedAsset == nil) {
            photoModel.croppedImage = @"FJPhotoManager.ic_photo_no_found".fj_image;
        }else {
            photoModel.asset = findedAsset;
            UIImage *originalImage = [findedAsset getGeneralTargetImage];
            photoModel.croppedImage = [originalImage fj_imageCropBeginPointRatio:photoModel.beginCropPoint endPointRatio:photoModel.endCropPoint];
        }
        [self.allPhotos addObject:photoModel];
    }
}

// 删除（用于退出保存）
- (void)cleanDraftCache {
    
    [FJStorage clearObject:@"FJPhotoPostDraftListSavingModel"];
}

// 删除某个Draft（用于退出保存）
- (void)removeDraft:(FJPhotoPostDraftSavingModel *)draft {
    
    FJPhotoPostDraftListSavingModel *draftList = [self loadDraftCache];
    for (int i = (int)draftList.drafts.count - 1; i >= 0; i--) {
        FJPhotoPostDraftSavingModel *d = [draftList.drafts fj_arrayObjectAtIndex:i];
        if (d.savingDate == draft.savingDate) {
            [draftList.drafts fj_arrayRemoveObjectAtIndex:i];
            break;
        }
    }
    if (draftList.drafts.count == 0) {
        [self cleanDraftCache];
    }else {
        [FJStorage saveAnyObject:draftList];
    }
}


// 根据Asset Identifier查找PHAsset
- (PHAsset *)findByIdentifier:(NSString *)assetIdentifier {
    
    // 系统相机查找
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    for (PHAssetCollection *collection in collections) {
        if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeAlbumMyPhotoStream || collection.assetCollectionSubtype == PHAssetCollectionSubtypeAlbumCloudShared) {
            // 屏蔽 iCloud 照片流
        }else {
            PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
            for (PHAsset *asset in assets) {
                if ([[asset localIdentifier] isEqualToString:assetIdentifier]) {
                    return asset;
                }
            }
        }
    }
    // 自定义相册查找
    PHFetchResult<PHAssetCollection *> *customCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in customCollections) {
        PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        for (PHAsset *asset in assets) {
            if ([[asset localIdentifier] isEqualToString:assetIdentifier]) {
                return asset;
            }
        }
    }
    return nil;
}

@end
