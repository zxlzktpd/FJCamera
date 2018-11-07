//
//  FJTuningObject.h
//  FJCamera
//
//  Created by Fu Jie on 2018/10/31.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FJTuningType) {
    FJTuningTypeBrightness,
    FJTuningTypeContrast,
    FJTuningTypeSaturation,
    FJTuningTypeTemperature,
    FJTuningTypeVignette
};

@protocol FJTuningObject <NSObject>
@end

@interface FJTuningObject : NSObject

// 亮度 [-100, 100] 默认 0
@property (nonatomic, assign) float brightnessValue;
// 对比度 [-100, 100] 默认 0
@property (nonatomic, assign) float contrastValue;
// 暖色调 [-100, 100] 默认 0
@property (nonatomic, assign) float saturationValue;
// 饱和度 [-100, 100] 默认 0
@property (nonatomic, assign) float temperatureValue;
// 晕影 [-100, 100] 默认 0
@property (nonatomic, assign) float vignetteValue;

- (void)setType:(FJTuningType)type value:(float)value;

@end
