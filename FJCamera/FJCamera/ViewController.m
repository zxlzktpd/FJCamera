//
//  ViewController.m
//  FJCamera
//
//  Created by Fu Jie on 2018/10/26.
//  Copyright © 2018年 Fu Jie. All rights reserved.
//

#import "ViewController.h"
#import "FJPhotoLibraryViewController.h"

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
    
    FJPhotoLibraryViewController *photoLibVC = [[FJPhotoLibraryViewController alloc] init];
    [self.navigationController pushViewController:photoLibVC animated:YES];
}

@end
