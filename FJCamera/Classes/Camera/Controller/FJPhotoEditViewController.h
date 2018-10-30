//
//  FJPhotoEditViewController.h
//  FJCamera
//
//  Created by Fu Jie on 2018/10/30.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface FJPhotoEditViewController : UIViewController

@property (nonatomic, strong) NSMutableArray<PHAsset *> *selectedPhotoAssets;

@end
