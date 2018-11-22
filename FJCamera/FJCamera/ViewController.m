//
//  ViewController.m
//  FJCamera
//
//  Created by Fu Jie on 2018/10/26.
//  Copyright © 2018年 Fu Jie. All rights reserved.
//

#import "ViewController.h"
#import "FJPhotoLibraryViewController.h"
#import "FJPhotoLibraryCropperViewController.h"
#import "FJAVCaptureViewController.h"

#import "FJTakePhotoView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)tapPhotoLibrary:(id)sender {
    
    FJPhotoLibraryCropperViewController *photoLibVC = [[FJPhotoLibraryCropperViewController alloc] init];
    [self.navigationController pushViewController:photoLibVC animated:YES];
}

- (IBAction)tapAVCapture:(id)sender {
    
    FJAVCaptureViewController *avCaptureVC = [[FJAVCaptureViewController alloc] init];
    FJCaptureConfig *config = [[FJCaptureConfig alloc] init];
    config.enableSwitch = YES;
    config.enableLightSupplement = YES;
    config.enableFlashLight = YES;
    config.enableAutoFocusAndExposure = YES;
    config.widgetUsingImageTopView = YES;
    config.widgetUsingImageBottomView = YES;
    config.enablePreviewAll = NO;
    config.enableConfirmPreview = YES;
    config.captureType = FJCaptureTypeAll;
    avCaptureVC.config = config;
    
    avCaptureVC.oneMediaTakenBlock = ^(FJMediaObject *media) {
        NSLog(@"oneMediaTakenBlock callback");
        NSLog(@"%@", media);
    };
    
    avCaptureVC.allMediasTakenBlock = ^(NSArray *medias) {
        NSLog(@"allMediasTakenBlock callback");
        NSLog(@"%@", medias);
    };
    [self.navigationController pushViewController:avCaptureVC animated:YES];
}

@end
