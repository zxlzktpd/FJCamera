//
//  FJPhotoEditToolbarView.h
//  FJCamera
//
//  Created by Fu Jie on 2018/10/30.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FJCameraCommonHeader.h"
#import "FJPhotoEditViewController.h"

@interface FJPhotoEditToolbarView : UIView

@property (nonatomic, copy) void(^filterBlock)(void);
@property (nonatomic, copy) void(^tagBlock)(void);

+ (FJPhotoEditToolbarView *)create:(FJPhotoEditMode)mode;

@end
