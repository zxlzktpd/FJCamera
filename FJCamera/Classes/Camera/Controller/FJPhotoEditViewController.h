//
//  FJPhotoEditViewController.h
//  FJCamera
//
//  Created by Fu Jie on 2018/10/30.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FJCameraCommonHeader.h"

@protocol FJPhotoEditTagDelegate <NSObject>

@optional

- (void)fj_photoEditAddTag:(FJImageTagModel *)model point:(CGPoint)point;

@end


typedef NS_ENUM(NSInteger, FJPhotoEditMode) {
    FJPhotoEditModeNotSet     = 0x0000,   // 默认的，无效值
    FJPhotoEditModeFilter     = 0x0001,
    FJPhotoEditModeCropprer   = 0x0002,
    FJPhotoEditModeTuning     = 0x0004,
    FJPhotoEditModeTag        = 0x0008,
    FJPhotoEditModeAll        = FJPhotoEditModeFilter | FJPhotoEditModeCropprer | FJPhotoEditModeTuning | FJPhotoEditModeTag
};

@interface FJPhotoEditViewController : UIViewController <FJPhotoEditTagDelegate>

// Mode
@property (nonatomic, assign) FJPhotoEditMode mode;


@property (nonatomic, strong) UIViewController *userTagController;

// 已选相片
@property (nonatomic, strong) NSMutableArray<PHAsset *> *selectedPhotoAssets;

@end
