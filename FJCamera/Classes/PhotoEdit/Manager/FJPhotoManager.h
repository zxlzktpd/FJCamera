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

#define KeyFJCameraLocalTag @"LOCAL#"

#pragma mark - Photo Saving Model 草稿保存对象
@interface FJPhotoPostSavingModel : NSObject

// Photo 信息
@property (nonatomic, copy) NSString *uuid;  // 打开相册时间戳，相同的assetIdentifier在不同时间戳打开属于不同的照片
// 照片的local asset id（TODO：当保存的时候，以assetIdentifier为名保存到文件中，以便在相册中搜寻无果时候可以在文件系统中恢复）
@property (nonatomic, copy) NSString *assetIdentifier;
@property (nonatomic, copy) NSString *photoUrl;  // 照片的URL（下载照片存放在文件系统中，以photoUrl的hash值为文件名）
@property (nonatomic, strong) FJTuningObject *tuningObject;  // 照片的调整参数
@property (nonatomic, strong) NSMutableArray<FJImageTagModel *> *imageTags;  // 照片的图上标签信息
@property (nonatomic, assign) BOOL compressed;  // 照片是否撑满或适中
@property (nonatomic, assign) CGFloat beginCropPointX;  // 照片的左上角裁切点X值
@property (nonatomic, assign) CGFloat beginCropPointY;  // 照片的左上角裁切点Y值
@property (nonatomic, assign) CGFloat endCropPointX;    // 照片的右下角裁切点X值
@property (nonatomic, assign) CGFloat endCropPointY;    // 照片的右下角裁切点Y值

@end

#pragma mark - Post Object Saving Model 包含草稿保存对象列表的对象
@interface FJPhotoPostDraftSavingModel : NSObject

// Photo 列表
@property (nonatomic, strong) NSMutableArray<FJPhotoPostSavingModel *> *photos;
// Extra 信息
@property (nonatomic, assign) int extraType;   // extra参数类型，比如0表示某功能的晒单扩展参数，1表示其他模块的文档扩展参数
// 为用户预留的保存参数
@property (nonatomic, copy) NSString *extra0;
@property (nonatomic, copy) NSString *extra1;
@property (nonatomic, copy) NSString *extra2;
@property (nonatomic, copy) NSString *extra3;
@property (nonatomic, copy) NSString *extra4;
@property (nonatomic, copy) NSString *extra5;
// 唯一码(可以去晒单ID，可以取创建时间)
@property (nonatomic, copy) NSString *identifier;
// 最后保存时间
@property (nonatomic, assign) long long updatingTimestamp;

@end

#pragma mark - Post Object List Saving Model
@interface FJPhotoPostDraftListSavingModel : NSObject

@property (nonatomic, strong) NSMutableArray<FJPhotoPostDraftSavingModel *> *drafts;

@end

#pragma mark - Photo Model
@interface FJPhotoModel : NSObject

@property (nonatomic, copy) NSString *uuid;  // 打开相册时间戳，相同的assetIdentifier在不同时间戳打开属于不同的照片
@property (nonatomic, strong) PHAsset *asset;  // 照片的local asset对象，包含local asset id
@property (nonatomic, copy) NSString *photoUrl;  // 照片的URL（下载照片存放在文件系统中，以photoUrl的hash值为文件名）
@property (nonatomic, strong) UIImage *croppedImage;  // 压缩图片
@property (nonatomic, strong) UIImage *originalImage;  // 原始图片
@property (nonatomic, strong) UIImage *smallOriginalImage;  // 缩略图片
@property (nonatomic, strong) UIImage *currentImage;   // 当前图片
@property (nonatomic, strong) FJTuningObject *tuningObject;  // 调整图片的参数
@property (nonatomic, strong) NSMutableArray<FJImageTagModel *> *imageTags;  // 图上标签
@property (nonatomic, strong) NSMutableArray<UIImage *> *filterThumbImages;  // 滤镜参数

// Extra
@property (nonatomic, assign) BOOL needCrop;  // 是否需要裁切
// 留白和充满标记
// YES -> 留白    NO  -> 充满
@property (nonatomic, assign) BOOL compressed;
// 裁切的起始（左上角）结束（右下角）的参数
@property (nonatomic, assign) CGPoint beginCropPoint;
@property (nonatomic, assign) CGPoint endCropPoint;

// 初始化
- (instancetype)initWithAsset:(PHAsset *)asset;

// 滤镜标题列表
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
- (NSString *)saveDraftCache:(BOOL)overwrite extraType:(int)extraType extras:(NSDictionary *)extras identifier:(NSString *)identifier;

// 加载（用于退出保存）
- (FJPhotoPostDraftListSavingModel *)loadDraftCache;

// 加载到allPhoto（用于退出保存）
- (void)loadDraftPhotosToAllPhotos:(FJPhotoPostDraftSavingModel *)draft completion:(void(^)(void))completion;

// 删除（用于退出保存）
- (void)cleanDraftCache;

// 删除某个Draft（用于退出保存）
- (void)removeDraft:(FJPhotoPostDraftSavingModel *)draft;

// 删除某个Draft（用于退出保存）
- (void)removeDraftByIdentifier:(NSString *)identifier;

// 根据Asset Identifier查找PHAsset
- (PHAsset *)findByIdentifier:(NSString *)assetIdentifier;

// 根据PhotoUrl查找NSData、UIImage
- (void)findByPhotoUrl:(NSString *)photoUrl completion:(void(^)(NSData *imageData, UIImage *image, NSString *url))completion;

// 打开草稿箱
+ (void)presentDraftController:(UIViewController *)controller userSelectDraftBlock:(void(^)(FJPhotoPostDraftSavingModel *draft, BOOL pictureRemoved))userSelectDraftBlock;

@end
