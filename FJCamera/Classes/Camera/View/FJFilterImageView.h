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

@interface FJFilterImageView : UIView

+ (FJFilterImageView *)create:(CGRect)frame image:(UIImage *)image;

- (void)updateImage:(UIImage *)image;

- (void)updateBrightness:(float)brightness;

- (void)updateContrast:(float)contrast;

- (void)updateSaturation:(float)saturation;

- (void)updateTemperature:(float)temperature;

- (void)updateVignette:(float)vignette;

@end
