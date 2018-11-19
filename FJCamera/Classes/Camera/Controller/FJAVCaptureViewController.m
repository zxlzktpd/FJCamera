//
//  FJAVCaptureViewController.m
//  FJCamera
//
//  Created by Fu Jie on 2018/11/19.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJAVCaptureViewController.h"

@interface FJAVCaptureViewController ()

@end

@implementation FJAVCaptureViewController

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.enablePhoto = YES;
        self.enableVideo = YES;
        self.videoMaxDuration = 15.0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
