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

typedef NS_ENUM(NSInteger, FJFilterType) {
    FJFilterTypeNull,
    FJFilterType0,
    FJFilterType1,
    FJFilterType2,
    FJFilterType3,
    FJFilterType4,
    FJFilterType5,
    FJFilterType6,
    FJFilterType7
};

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

- (CIFilter *)filterApplyTo:(CIImage *)ciImage brightness:(float)brightness contrast:(float)contrast saturation:(float)saturation;

- (CIFilter *)filterApplyTo:(CIImage *)ciImage brightness:(float)brightness;

- (CIFilter *)filterApplyTo:(CIImage *)ciImage contrast:(float)contrast;

- (CIFilter *)filterApplyTo:(CIImage *)ciImage saturation:(float)saturation;

- (CIFilter *)filterApplyTo:(CIImage *)ciImage temperature:(float)temperature;

- (CIFilter *)filterApplyTo:(CIImage *)ciImage vignette:(float)vignette;

- (void)getImage:(CIFilter *)filter result:(void(^)(UIImage *image))result;

- (void)getImageCombine:(NSArray<CIFilter *> *)filters result:(void(^)(UIImage *image))result;

- (void)getImage:(UIImage *)image tuningObject:(FJTuningObject *)tuningObject appendFilterType:(FJFilterType)filterType result:(void(^)(UIImage *image))result;

@end
