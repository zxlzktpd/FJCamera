//
//  FJPhotoLibraryViewController.h
//  FJCamera
//
//  Created by Fu Jie on 2018/10/26.
//  Copyright © 2018年 Fu Jie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FJCameraCommonHeader.h"
#import "FJPhotoEditViewController.h"
#import "FJImageTagModel.h"
#import "FJPhotoUserTagBaseViewController.h"

@interface FJPhotoLibraryViewController : UIViewController

// 是否选择单张/多张照片
@property (nonatomic, assign) BOOL singleSelection;

// 多张照片选择最多选择张数（默认为9）
@property (nonatomic, assign) NSUInteger maxSelectionCount;

// 照片瀑布流的列数（默认为4）
@property (nonatomic, assign) NSUInteger photoListColumn;

// 启动时的Block
@property (nonatomic, copy) void(^userInitBlock)(void);

// 超出最多选择张数后的Block
@property (nonatomic, copy) void(^userOverLimitationBlock)(void);

// Next Block
@property (nonatomic, copy) void(^userNextBlock)(NSMutableArray<PHAsset *> *selectedPhotoAssets);

// Mode (Edit Controller)
@property (nonatomic, assign) FJPhotoEditMode mode;

// 相片和Tag输出Block (Edit Controller)
@property (nonatomic, copy) void(^outputBlock)(NSArray<UIImage *> *images, NSArray<FJImageTagModel *> *tags);

// 初始化
- (instancetype)initWithMode:(FJPhotoEditMode)mode editController:(__kindof FJPhotoUserTagBaseViewController * (^)(FJPhotoEditViewController *controller))editController;

// 设置已选的照片Asset数组
- (void)updateSelectedPhotoAssets:(NSArray<PHAsset *> *)selectedPhotoAssets;

@end
