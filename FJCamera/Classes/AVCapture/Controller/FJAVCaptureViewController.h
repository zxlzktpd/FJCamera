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
#import "FJCaptureConfig.h"

@interface FJAVCaptureViewController : UIViewController

@property (nonatomic, strong, readonly) NSMutableArray *medias;

// FJCaptureConfig参数
@property (nonatomic, strong) FJCaptureConfig *config;

// 单张图片/单个视频的回调
@property (nonatomic, copy) void(^oneMediaTakenBlock)(FJMediaObject *media);

// 多张图片/多个视频的回调
@property (nonatomic, copy) void(^allMediasTakenBlock)(NSArray *medias);

@end
