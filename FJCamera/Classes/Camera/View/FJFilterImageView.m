//
//  FJFilterImageView.m
//  FJCamera
//
//  Created by Fu Jie on 2018/11/1.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJFilterImageView.h"

@interface FJFilterImageView ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, assign) BOOL updated;

@end

@implementation FJFilterImageView

- (void)setHidden:(BOOL)hidden {
    
    if (hidden == YES) {
        self.updated = NO;
    }
    [super setHidden:hidden];
}

+ (FJFilterImageView *)create:(CGRect)frame {
    
    FJFilterImageView *view = MF_LOAD_NIB(@"FJFilterImageView");
    view.frame = frame;
    return view;
}

- (void)updateImage:(UIImage *)image {
    
    if (self.updated) {
        return;
    }
    [[FJFilterManager shared] updateImage:image];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = image;
    self.updated = YES;
}

- (UIImage *)getFilterImage {
    
    return self.imageView.image;
}

- (void)updateBrightness:(float)brightness contrast:(float)contrast saturation:(float)saturation {

    FJTuningObject *tuneObject = [FJPhotoManager shared].currentTuningObject;
    CIFilter *filter1 =  [[FJFilterManager shared] filterApplyTo:[FJFilterManager shared].originalCIImage brightness:brightness contrast:contrast saturation:saturation];
    CIFilter *filter2 = [[FJFilterManager shared] filterApplyTo:nil temperature:tuneObject.temperatureValue];
    CIFilter *filter3 = [[FJFilterManager shared] filterApplyTo:nil vignette:tuneObject.vignetteValue];
    MF_WEAK_SELF
    [[FJFilterManager shared] getImageCombine:@[filter1, filter2, filter3] result:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.imageView.image = image;
        });
    }];
}

- (void)updateTemperature:(float)temperature {

    FJTuningObject *tuneObject = [FJPhotoManager shared].currentTuningObject;
    CIFilter *filter1 = [[FJFilterManager shared] filterApplyTo:[FJFilterManager shared].originalCIImage brightness:tuneObject.brightnessValue contrast:tuneObject.contrastValue saturation:tuneObject.saturationValue];
    CIFilter *filter2 = [[FJFilterManager shared] filterApplyTo:nil temperature:temperature];
    CIFilter *filter3 = [[FJFilterManager shared] filterApplyTo:nil vignette:tuneObject.vignetteValue];
    
    MF_WEAK_SELF
    [[FJFilterManager shared] getImageCombine:@[filter1, filter2, filter3] result:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.imageView.image = image;
        });
    }];
}

- (void)updateVignette:(float)vignette {

    FJTuningObject *tuneObject = [FJPhotoManager shared].currentTuningObject;
    CIFilter *filter1 = [[FJFilterManager shared] filterApplyTo:[FJFilterManager shared].originalCIImage brightness:tuneObject.brightnessValue contrast:tuneObject.contrastValue saturation:tuneObject.saturationValue];
    CIFilter *filter2 = [[FJFilterManager shared] filterApplyTo:nil temperature:tuneObject.temperatureValue];
    CIFilter *filter3 = [[FJFilterManager shared] filterApplyTo:nil vignette:vignette];
    
    MF_WEAK_SELF
    [[FJFilterManager shared] getImageCombine:@[filter1, filter2, filter3] result:^(UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.imageView.image = image;
        });
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
