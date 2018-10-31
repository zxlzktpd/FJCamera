//
//  FJPhotoEditViewController.h
//  FJCamera
//
//  Created by Fu Jie on 2018/10/30.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FJCameraCommonHeader.h"

typedef NS_ENUM(NSInteger, FJPhotoEditMode) {
    FJPhotoEditModeFilter     = 0x0001,
    FJPhotoEditModeCropprer   = 0x0002,
    FJPhotoEditModeTuning     = 0x0004,
    FJPhotoEditModeTag        = 0x0008,
    FJPhotoEditModeAll        = FJPhotoEditModeFilter | FJPhotoEditModeCropprer | FJPhotoEditModeTuning | FJPhotoEditModeTag
};

@interface FJPhotoEditViewController : UIViewController

// 已选相片
@property (nonatomic, strong) NSMutableArray<PHAsset *> *selectedPhotoAssets;
@property (nonatomic, assign) FJPhotoEditMode mode;

@end
