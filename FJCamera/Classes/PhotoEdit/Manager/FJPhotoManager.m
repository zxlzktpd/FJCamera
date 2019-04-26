//
//  FJPhotoManager.m
//  FJCamera
//
//  Created by Fu Jie on 2018/10/31.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJPhotoManager.h"
#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <FJKit_OC/UIImage+Utility_FJ.h>
#import <FJKit_OC/NSArray+JSON_FJ.h>
#import <FJKit_OC/NSDate+Utility_FJ.h>
#import <FJKit_OC/NSString+Image_FJ.h>
#import <FJKit_OC/FJNavigationController.h>
#import "FJPhotoDraftHistoryViewController.h"
#import "PHAsset+QuickEdit.h"
#import "FJFilterManager.h"

#pragma mark - Photo Saving Model
@implementation FJPhotoPostSavingModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imageTags = (NSMutableArray<FJImageTagModel *> *)[[NSMutableArray alloc] init];
    }
    return self;
}

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
- (long long)saveDraftCache:(BOOL)overwrite extraType:(int)extraType extras:(NSDictionary *)extras identifier:(long long)identifier {
    
    long long now = (long long)[NSDate fj_dateTimeStampSince1970];
    // 判断是否是已经存在已保存的draft中
    // 如果存在，先删除老的draft，再保存新的draft
    FJPhotoPostDraftListSavingModel *objectListModel = [FJStorage valueAnyObject:[FJPhotoPostDraftListSavingModel class]];
    if (objectListModel.drafts.count > 0) {
        for (int i = (int)objectListModel.drafts.count - 1; i >= 0; i--) {
            FJPhotoPostDraftSavingModel *draft = [objectListModel.drafts fj_arrayObjectAtIndex:i];
            if (identifier > 0 && draft.identifier == identifier) {
                if (overwrite) {
                    // 覆盖
                    [objectListModel.drafts removeObjectAtIndex:i];
                }else {
                    // 不覆盖
                    identifier = now;
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
        postPhotoModel.photoUrl = model.photoUrl;
        postPhotoModel.tuningObject = model.tuningObject;
        postPhotoModel.imageTags = model.imageTags;
        postPhotoModel.compressed = model.compressed;
        postPhotoModel.beginCropPointX = model.beginCropPoint.x;
        postPhotoModel.beginCropPointY = model.beginCropPoint.y;
        postPhotoModel.endCropPointX = model.endCropPoint.x;
        postPhotoModel.endCropPointY = model.endCropPoint.y;
        [objectModel.photos addObject:postPhotoModel];
    }
    if (identifier > 0) {
        objectModel.identifier = identifier;
    }else {
        objectModel.identifier = now;
    }
    objectModel.updatingTimestamp = now;
    [objectListModel.drafts addObject:objectModel];
    [FJStorage saveAnyObject:objectListModel];
    return objectModel.identifier;
}

// 加载（用于退出保存）
- (FJPhotoPostDraftListSavingModel *)loadDraftCache {
    
    FJPhotoPostDraftListSavingModel *objectListModel = [FJStorage valueAnyObject:[FJPhotoPostDraftListSavingModel class]];
    return objectListModel;
}

// 加载到allPhoto（用于退出保存）
- (void)loadDraftPhotosToAllPhotos:(FJPhotoPostDraftSavingModel *)draft completion:(void(^)(void))completion {
    
    [self clean];
    for (int i = 0; i < draft.photos.count; i++) {
        FJPhotoPostSavingModel *savingPhotoModel = [draft.photos fj_arrayObjectAtIndex:i];
        // 查找相册并赋值PHAsset（本地）
        if (savingPhotoModel.assetIdentifier.length > 0) {
            PHAsset *findedAsset = [self findByIdentifier:savingPhotoModel.assetIdentifier];
            UIImage *originalImage = [findedAsset getGeneralTargetImage];
            [self _addToAllPhotos:draft assetIdentifier:savingPhotoModel.assetIdentifier photoUrl:savingPhotoModel.photoUrl image:originalImage asset:findedAsset completion:completion];
        }
        // 查找SD库(网络图片,异步加载)
        else if (savingPhotoModel.photoUrl.length > 0) {
            MF_WEAK_SELF
            [self findByPhotoUrl:savingPhotoModel.photoUrl completion:^(NSData *imageData, UIImage *image, NSString *url) {
                [weakSelf _addToAllPhotos:draft assetIdentifier:nil photoUrl:url image:image asset:nil completion:completion];
            }];
        }
        // 失败
        else {
            [self _addToAllPhotos:draft assetIdentifier:nil photoUrl:nil image:nil asset:nil completion:completion];
        }
    }
}

- (void)_addToAllPhotos:(FJPhotoPostDraftSavingModel *)draft assetIdentifier:(NSString *)assetIdentifier photoUrl:(NSString *)photoUrl image:(UIImage *)image asset:(PHAsset *)asset completion:(void(^)(void))completion {
    
    FJPhotoPostSavingModel *savingPhotoModel = nil;
    for (int i = 0; i < draft.photos.count; i++) {
        savingPhotoModel = [draft.photos fj_arrayObjectAtIndex:i];
        if (assetIdentifier.length > 0) {
            if ([savingPhotoModel.assetIdentifier isEqualToString:assetIdentifier]) {
                break;
            }
        }else if (photoUrl.length > 0) {
            if ([savingPhotoModel.photoUrl isEqualToString:photoUrl]) {
                break;
            }
        }
    }
    
    FJPhotoModel *photoModel = [[FJPhotoModel alloc] init];
    if (assetIdentifier == nil && photoUrl == nil && savingPhotoModel == nil) {
        // 加载照片失败
        photoModel.croppedImage = @"FJPhotoManager.ic_photo_no_found".fj_image;
    }
    // 赋值照片属性
    photoModel.uuid = savingPhotoModel.uuid;
    photoModel.asset = asset;
    photoModel.croppedImage = image;
    photoModel.photoUrl = savingPhotoModel.photoUrl;
    photoModel.tuningObject = savingPhotoModel.tuningObject;
    photoModel.imageTags = savingPhotoModel.imageTags;
    photoModel.compressed = savingPhotoModel.compressed;
    photoModel.beginCropPoint = CGPointMake(savingPhotoModel.beginCropPointX, savingPhotoModel.beginCropPointY);
    photoModel.endCropPoint = CGPointMake(savingPhotoModel.endCropPointX, savingPhotoModel.endCropPointY);
    UIImage *croppedImage = [image fj_imageCropBeginPointRatio:photoModel.beginCropPoint endPointRatio:CGPointMake(savingPhotoModel.endCropPointX, savingPhotoModel.endCropPointY)];
    photoModel.croppedImage = croppedImage;
    [self.allPhotos addObject:photoModel];
    
    if (self.allPhotos.count == draft.photos.count) {
        // 调整顺序
        for (int i = 0; i < draft.photos.count; i++) {
            savingPhotoModel = [draft.photos fj_arrayObjectAtIndex:i];
            FJPhotoModel *photoModel = [self.allPhotos fj_arrayObjectAtIndex:i];
            if (savingPhotoModel.assetIdentifier.length > 0) {
                if (![savingPhotoModel.assetIdentifier isEqualToString:[photoModel.asset localIdentifier]]) {
                    for (int j = i + 1; j < self.allPhotos.count; j++) {
                        FJPhotoModel *pModel = [self.allPhotos fj_arrayObjectAtIndex:j];
                        if ([savingPhotoModel.assetIdentifier isEqualToString:[pModel.asset localIdentifier]]) {
                            [self.allPhotos exchangeObjectAtIndex:j withObjectAtIndex:i];
                            break;
                        }
                    }
                }
            }else if (savingPhotoModel.photoUrl.length > 0) {
                if (![savingPhotoModel.photoUrl isEqualToString:photoModel.photoUrl]) {
                    for (int j = i + 1; j < self.allPhotos.count; j++) {
                        FJPhotoModel *pModel = [self.allPhotos fj_arrayObjectAtIndex:j];
                        if ([savingPhotoModel.photoUrl isEqualToString:pModel.photoUrl]) {
                            [self.allPhotos exchangeObjectAtIndex:j withObjectAtIndex:i];
                            break;
                        }
                    }
                }
            }
        }
        // 完成回调
        completion == nil ? : completion();
    }
}

// 删除（用于退出保存）
- (void)cleanDraftCache {
    
    [FJStorage clearObject:@"FJPhotoPostDraftListSavingModel"];
}

// 删除某个Draft（用于退出保存）
- (void)removeDraft:(FJPhotoPostDraftSavingModel *)draft {
    
    [self removeDraftByIdentifier:draft.identifier];
}

// 删除某个Draft（用于退出保存）
- (void)removeDraftByIdentifier:(long long)identifier {
    
    FJPhotoPostDraftListSavingModel *draftList = [self loadDraftCache];
    for (int i = (int)draftList.drafts.count - 1; i >= 0; i--) {
        FJPhotoPostDraftSavingModel *d = [draftList.drafts fj_arrayObjectAtIndex:i];
        if (d.identifier == identifier) {
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

// 根据PhotoUrl查找NSData、UIImage
- (void)findByPhotoUrl:(NSString *)photoUrl completion:(void(^)(NSData *imageData, UIImage *image, NSString *url))completion {
    
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[photoUrl fjNSURL] options:SDWebImageDownloaderHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
        completion == nil ? : completion(data, image, photoUrl);
    }];
}

// 打开草稿箱
+ (void)presentDraftController:(UIViewController *)controller userSelectDraftBlock:(void(^)(FJPhotoPostDraftSavingModel *draft, BOOL pictureRemoved))userSelectDraftBlock {
    
    FJPhotoDraftHistoryViewController *draftVC = [[FJPhotoDraftHistoryViewController alloc] init];
    draftVC.userSelectDraftBlock = userSelectDraftBlock;
    FJNavigationController *nav = [[FJNavigationController alloc] initWithRootViewController:draftVC];
    [controller presentViewController:nav animated:YES completion:nil];
}


@end
