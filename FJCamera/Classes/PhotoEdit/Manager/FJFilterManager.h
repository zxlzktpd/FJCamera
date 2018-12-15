//
//  FJFilterManager.h
//  FJCamera
//
//  Created by Fu Jie on 2018/11/2.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import "FJPhotoManager.h"

@interface FJFilterManager : NSObject

@property (nonatomic, strong, readonly) CIImage *originalCIImage;

// 控制Brightness, contrast, saturation的滤镜
@property (nonatomic, strong, readonly) CIFilter *colorControlFilter;
// 控制色温滤镜
@property (nonatomic, strong, readonly) CIFilter *temperatureFilter;
// 暗角滤镜
@property (nonatomic, strong, readonly) CIFilter *vignetteFilter;

+ (FJFilterManager *)shared;

- (void)updateImage:(UIImage *)image;

- (void)setFilter:(CIFilter *)filter inputImage:(CIImage *)ciImage;

- ( CIFilter * _Nonnull )filterApplyTo:(CIImage *)ciImage brightness:(float)brightness contrast:(float)contrast saturation:(float)saturation;

- ( CIFilter * _Nonnull )filterApplyTo:(CIImage *)ciImage brightness:(float)brightness;

- ( CIFilter * _Nonnull )filterApplyTo:(CIImage *)ciImage contrast:(float)contrast;

- ( CIFilter * _Nonnull )filterApplyTo:(CIImage *)ciImage saturation:(float)saturation;

- ( CIFilter * _Nonnull )filterApplyTo:(CIImage *)ciImage temperature:(float)temperature;

- ( CIFilter * _Nonnull )filterApplyTo:(CIImage *)ciImage vignette:(float)vignette;

- ( UIImage * _Nonnull )getImage:(UIImage *)image filterType:(FJFilterType)filterType;

- (void)getImageCombine:(NSArray<CIFilter *> *)filters result:(void(^)(UIImage *image))result;

- ( UIImage * _Nonnull )getImageCombine:(NSArray<CIFilter *> *)filters;

- ( UIImage * _Nonnull )getImage:(UIImage *)image tuningObject:(FJTuningObject *)tuningObject appendFilterType:(FJFilterType)filterType;

- ( UIImage * _Nonnull )getImageAsset:(PHAsset *)asset tuningObject:(FJTuningObject *)tuningObject appendFilterType:(FJFilterType)filterType;

- ( CIFilter * _Nonnull )filterBy:(FJFilterType)type;

@end
