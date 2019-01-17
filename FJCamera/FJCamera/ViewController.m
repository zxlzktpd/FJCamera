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
#import <FJKit_OC/NSString+Image_FJ.h>

@interface ViewController ()


@property (nonatomic, weak) IBOutlet UIImageView *leftImageView;
@property (nonatomic, weak) IBOutlet UIImageView *middleImageView;
@property (nonatomic, weak) IBOutlet UIImageView *rightImageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.leftImageView.image = [@"ic_tag_up_left".fj_image stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0];
    self.middleImageView.image = @"ic_tag_up_middle".fj_image;
    self.rightImageView.image = [@"ic_tag_up_right".fj_image stretchableImageWithLeftCapWidth:10.0 topCapHeight:10.0];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)tapPhotoLibrary:(id)sender {
    
    FJPhotoLibraryViewController *photoLibVC = [[FJPhotoLibraryViewController alloc] initWithMode:FJPhotoEditModeAll editController:^__kindof FJPhotoUserTagBaseViewController *(FJPhotoEditViewController *controller) {
        return nil;
    }];
    [self.navigationController pushViewController:photoLibVC animated:YES];
}

- (IBAction)tapINSPhotoLibrary:(id)sender {
    
    FJPhotoLibraryCropperViewController *photoLibVC = [[FJPhotoLibraryCropperViewController alloc] initWithMode:FJPhotoEditModeFilter | FJPhotoEditModeTag editController:^__kindof FJPhotoUserTagBaseViewController *(FJPhotoEditViewController *controller) {
        return nil;
    }];
    photoLibVC.maxSelectionCount = 3;
    photoLibVC.photoListColumn = 5;
    photoLibVC.takeButtonPosition = FJTakePhotoButtonPositionBottomWithDraft;
    [self.navigationController pushViewController:photoLibVC animated:YES];
}

- (IBAction)tapAVCapture:(id)sender {
    
    FJAVInputSettingConfig *inputConfig = [[FJAVInputSettingConfig alloc] init];
    FJAVCaptureViewController *avCaptureVC = [[FJAVCaptureViewController alloc] initWithAVInputSettingConfig:inputConfig outputExtension:FJAVFileTypeMP4];
    FJCaptureConfig *config = [[FJCaptureConfig alloc] init];
    config.enableSwitch = YES;
    config.enableLightSupplement = YES;
    config.enableFlashLight = YES;
    config.enableAutoFocusAndExposure = YES;
    config.widgetUsingImageTopView = YES;
    config.widgetUsingImageBottomView = YES;
    config.enablePreviewAll = YES;
    config.enableConfirmPreview = NO;
    config.captureType = FJCaptureTypeAll;
    avCaptureVC.config = config;
    avCaptureVC.mediasTakenBlock = ^(NSArray *medias) {
        NSLog(@"mediasTakenBlock callback");
        NSLog(@"%@", medias);
    };
    [self.navigationController pushViewController:avCaptureVC animated:YES];
}

@end
