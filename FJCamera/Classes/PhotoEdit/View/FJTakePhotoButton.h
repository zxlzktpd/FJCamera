//
//  FJTakePhotoButton.h
//  FJCamera
//
//  Created by Fu Jie on 2018/12/24.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FJTakePhotoButton : UIView

+ (FJTakePhotoButton *)create:(void(^)(void))takePhotoBlock;

@end
