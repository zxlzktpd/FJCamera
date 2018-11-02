//
//  FJTuningObject.m
//  FJCamera
//
//  Created by Fu Jie on 2018/10/31.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJTuningObject.h"

@implementation FJTuningObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.brightnessValue = 0;
        self.contrastValue = 1.0;
        self.saturationValue = 1.0;
        self.temperatureValue = 6500.0;
        self.vignetteValue = 0;
    }
    return self;
}

@end
