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
        self.lightValue = 0;
        self.contrastValue = 0;
        self.saturationValue = 0;
        self.warmValue = 0;
        self.halationValue = 0;
    }
    return self;
}

@end
