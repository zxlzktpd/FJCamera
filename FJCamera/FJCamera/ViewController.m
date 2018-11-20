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
    FJCameraViewConfig *config = [[FJCameraViewConfig alloc] init];
    config.enableSwitch = NO;
    config.enableLightSupplement = NO;
    config.enableFlashLight = NO;
    config.enableAutoFocusAndExposure = NO;
    config.widgetUsingImageBottomView = NO;
    avCaptureVC.cameraViewConfig = config;
    [self.navigationController pushViewController:avCaptureVC animated:YES];
}

@end
