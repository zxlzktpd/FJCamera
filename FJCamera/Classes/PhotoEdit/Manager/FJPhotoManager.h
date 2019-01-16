//
//  FJPhotoManager.h
//  FJCamera
//
//  Created by Fu Jie on 2018/10/31.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FJPhotoEditCommonHeader.h"
#import "FJTuningObject.h"
#import "FJImageTagModel.h"

#pragma mark - Photo Saving Model
@interface FJPhotoPostSavingModel : NSObject

// Photo 信息
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, copy) NSString *assetIdentifier;
@property (nonatomic, strong) FJTuningObject *tuningObject;
@property (nonatomic, strong) NSMutableArray<FJImageTagModel *> *imageTags;
@property (nonatomic, assign) BOOL compressed;
@property (nonatomic, assign) CGFloat beginCropPointX;
@property (nonatomic, assign) CGFloat beginCropPointY;
@property (nonatomic, assign) CGFloat endCropPointX;
@property (nonatomic, assign) CGFloat endCropPointY;

@end

#pragma mark - Post Object Saving Model
@interface FJPhotoPostDraftSavingModel : NSObject

// Photo 列表
@property (nonatomic, strong) NSMutableArray<FJPhotoPostSavingModel *> *photos;
// Extra 信息
@property (nonatomic, assign) int extraType;
@property (nonatomic, copy) NSString *extra0;
@property (nonatomic, copy) NSString *extra1;
@property (nonatomic, copy) NSString *extra2;
@property (nonatomic, copy) NSString *extra3;
@property (nonatomic, copy) NSString *extra4;
@property (nonatomic, copy) NSString *extra5;
@property (nonatomic, copy) NSString *extra6;
@property (nonatomic, copy) NSString *extra7;
@property (nonatomic, copy) NSString *extra8;
@property (nonatomic, copy) NSString *extra9;
// 保存时间
@property (nonatomic, assign) long long savingDate;

@end

#pragma mark - Post Object List Saving Model
@interface FJPhotoPostDraftListSavingModel : NSObject

@property (nonatomic, strong) NSMutableArray<FJPhotoPostDraftSavingModel *> *drafts;

@end

#pragma mark - Photo Model
@interface FJPhotoModel : NSObject

@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) UIImage *croppedImage;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImage *smallOriginalImage;
@property (nonatomic, strong) UIImage *currentImage;
@property (nonatomic, strong) FJTuningObject *tuningObject;
@property (nonatomic, strong) NSMutableArray<FJImageTagModel *> *imageTags;
@property (nonatomic, strong) NSMutableArray<UIImage *> *filterThumbImages;

// Extra
@property (nonatomic, assign) BOOL needCrop;
// 留白和充满标记
// YES -> 留白    NO  -> 充满
@property (nonatomic, assign) BOOL compressed;
@property (nonatomic, assign) CGPoint beginCropPoint;
@property (nonatomic, assign) CGPoint endCropPoint;

- (instancetype)initWithAsset:(PHAsset *)asset;

+ (NSArray *)filterTitles;

@end

@interface FJPhotoManager : NSObject

@property (nonatomic, strong) NSMutableArray<FJPhotoModel *> *allPhotos;

@property (nonatomic, strong) FJPhotoModel *currentEditPhoto;

+ (FJPhotoManager *)shared;

#pragma mark - Photo

// 获取
- (FJPhotoModel *)get:(PHAsset *)asset;

// 新增
- (FJPhotoModel *)add:(PHAsset *)asset;

// 新增，Distinct
- (FJPhotoModel *)addDistinct:(id)object;

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

#pragma mark - Draft

// 判断存在（用于退出保存）
- (BOOL)isDraftExist;

// 保存（用于退出保存）
- (void)saveDraftCache:(BOOL)overwrite extraType:(int)extraType extras:(NSDictionary *)extras;

// 加载（用于退出保存）
- (FJPhotoPostDraftListSavingModel *)loadDraftCache;

// 加载到allPhoto（用于退出保存）
- (void)loadDraftPhotosToAllPhotos:(FJPhotoPostDraftSavingModel *)draft;

// 删除（用于退出保存）
- (void)cleanDraftCache;

// 删除某个Draft（用于退出保存）
- (void)removeDraft:(FJPhotoPostDraftSavingModel *)draft;

// 根据Asset Identifier查找PHAsset
- (PHAsset *)findByIdentifier:(NSString *)assetIdentifier;

@end
