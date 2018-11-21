//
//  FJAVCaptureViewController.h
//  FJCamera
//
//  Created by Fu Jie on 2018/11/19.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FJCameraView.h"
#import "FJMediaObject.h"

@interface FJAVCaptureViewController : UIViewController

@property (nonatomic, strong, readonly) NSMutableArray *medias;

// FJCameraViewConfig参数
@property (nonatomic, strong) FJCameraViewConfig *cameraViewConfig;

// 每次拍照、录像完成确认界面
@property (nonatomic, assign) BOOL enableConfirmPreview;

// 支持浏览和编辑所有照片、录像
@property (nonatomic, assign) BOOL enablePreviewAll;

// 单张图片/单个视频的回调
@property (nonatomic, copy) void(^oneMediaTakenBlock)(FJMediaObject *media);

@end
