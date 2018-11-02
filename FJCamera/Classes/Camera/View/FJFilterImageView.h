//
//  FJFilterImageView.h
//  FJCamera
//
//  Created by Fu Jie on 2018/11/1.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FJKit_OC/Macro.h>
#import <CoreImage/CoreImage.h>
#import "FJPhotoManager.h"
#import "FJFilterManager.h"

@interface FJFilterImageView : UIView

+ (FJFilterImageView *)create:(CGRect)frame;

- (void)updateImage:(UIImage *)image;

- (UIImage *)getFilterImage;

- (void)updateBrightness:(float)brightness contrast:(float)contrast saturation:(float)saturation;

- (void)updateTemperature:(float)temperature;

- (void)updateVignette:(float)vignette;

@end
