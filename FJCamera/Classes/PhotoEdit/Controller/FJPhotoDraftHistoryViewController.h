//
//  FJPhotoDraftHistoryViewController.h
//  FJCamera
//
//  Created by Fu Jie on 2019/1/16.
//  Copyright © 2019 Fu Jie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FJPhotoEditCommonHeader.h"
#import "FJPhotoManager.h"

@interface FJPhotoDraftHistoryViewController : UIViewController

@property (nonatomic, copy) void(^userSelectDraftBlock)(FJPhotoPostDraftSavingModel *draft);

@end
