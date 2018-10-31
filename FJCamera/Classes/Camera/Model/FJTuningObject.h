//
//  FJTuningObject.h
//  FJCamera
//
//  Created by Fu Jie on 2018/10/31.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FJTuningType) {
    FJTuningTypeLight,
    FJTuningTypeContrast,
    FJTuningTypeSaturation,
    FJTuningTypeWarm,
    FJTuningTypeHalation
};

@protocol FJTuningObject <NSObject>
@end

@interface FJTuningObject : NSObject

// 亮度 [-100, 100] 默认 0
@property (nonatomic, assign) float lightValue;
// 对比度 [-100, 100] 默认 0
@property (nonatomic, assign) float contrastValue;
// 暖色调 [-100, 100] 默认 0
@property (nonatomic, assign) float saturationValue;
// 饱和度 [-100, 100] 默认 0
@property (nonatomic, assign) float warmValue;
// 晕影 [-100, 100] 默认 0
@property (nonatomic, assign) float halationValue;

@end
