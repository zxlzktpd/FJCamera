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
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) CIImage *ciImage;
@property (nonatomic, strong) CIContext *context;
@property (nonatomic, strong) CIFilter *colorControlFilter;
@property (nonatomic, strong) CIFilter *temperatureFilter;
@property (nonatomic, strong) CIFilter *vignetteFilter;

@end

@implementation FJFilterImageView

// CIColorControls --> 亮度、饱和度、对比度控制 kCIInputBrightnessKey kCIInputSaturationKey kCIInputContrastKey
// CITemperatureAndTint --> 色温 kCIInputNeutralTemperatureKey kCIInputNeutralTintKey
// CIVignette CIVignetteEffect --> 暗角  inputIntensity inputRadius

//CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
//NSDictionary* attributes = [filter attributes];
//NSLog(@"filter attributes:%@",attributes);
//
//filter = [CIFilter filterWithName:@"CITemperatureAndTint"];
//attributes = [filter attributes];
//NSLog(@"filter attributes:%@",attributes);
//
//filter = [CIFilter filterWithName:@"CIVignette"];
//attributes = [filter attributes];
//NSLog(@"filter attributes:%@",attributes);
//
//filter = [CIFilter filterWithName:@"CIVignetteEffect"];
//attributes = [filter attributes];
//NSLog(@"filter attributes:%@",attributes);

- (CIContext *)context {
    
    if (_context == nil) {
        _context = [CIContext contextWithOptions:nil];
    }
    return _context;
}

- (CIImage *)ciImage {
    
    if (_ciImage == nil) {
        _ciImage = [[CIImage alloc] initWithImage:self.image];
    }
    return _ciImage;
}

- (CIFilter *)colorControlFilter {

    if (_colorControlFilter == nil) {
        _colorControlFilter = [CIFilter filterWithName:@"CIColorControls"];
    }
    return _colorControlFilter;
}

- (CIFilter *)temperatureFilter {
    
    if (_temperatureFilter == nil) {
        _temperatureFilter = [CIFilter filterWithName:@"CITemperatureAndTint"];
    }
    return _temperatureFilter;
}

- (CIFilter *)vignetteFilter {
    
    if (_vignetteFilter == nil) {
        _vignetteFilter = [CIFilter filterWithName:@"CIVignette"];
    }
    return _vignetteFilter;
}

+ (FJFilterImageView *)create:(CGRect)frame image:(UIImage *)image {
    
    FJFilterImageView *view = MF_LOAD_NIB(@"FJFilterImageView");
    view.frame = frame;
    view.image = image;
    view.imageView.image = image;
    view.imageView.contentMode = UIViewContentModeScaleAspectFit;
    return view;
}

- (void)updateImage:(UIImage *)image {
    
    self.image = image;
    self.imageView.image = image;
}

- (void)updateBrightness:(float)brightness {
    
    MF_WEAK_SELF
    dispatch_async(dispatch_get_global_queue(0, 0),^{
   
        //使用资源
        if ([weakSelf.colorControlFilter valueForKey:kCIInputImageKey] == nil) {
             [weakSelf.colorControlFilter setValue:weakSelf.ciImage forKey:kCIInputImageKey];
        }
        [weakSelf.colorControlFilter setValue:@(brightness) forKey:kCIInputBrightnessKey];
        //滤镜生成器输出图片
        //转换为UIImage
        CGImageRef ref = [weakSelf.context createCGImage:weakSelf.colorControlFilter.outputImage fromRect:weakSelf.colorControlFilter.outputImage.extent];
        __block UIImage *temp = [UIImage imageWithCGImage:ref];
        //释放
        CGImageRelease(ref);
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.imageView.image = temp;
        });
    });
}

- (void)updateContrast:(float)contrast {
    
    MF_WEAK_SELF
    dispatch_async(dispatch_get_global_queue(0, 0),^{

        //使用资源
        if ([weakSelf.colorControlFilter valueForKey:kCIInputImageKey] == nil) {
            [weakSelf.colorControlFilter setValue:weakSelf.ciImage forKey:kCIInputImageKey];
        }
        [weakSelf.colorControlFilter setValue:@(contrast) forKey:kCIInputContrastKey];
        //滤镜生成器输出图片
        //转换为UIImage
        CGImageRef ref = [weakSelf.context createCGImage:weakSelf.colorControlFilter.outputImage fromRect:weakSelf.colorControlFilter.outputImage.extent];
        __block UIImage *temp = [UIImage imageWithCGImage:ref];
        //释放
        CGImageRelease(ref);
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.imageView.image = temp;
        });
    });
}

- (void)updateSaturation:(float)saturation {
    
    MF_WEAK_SELF
    dispatch_async(dispatch_get_global_queue(0, 0),^{
        
        //使用资源
        if ([weakSelf.colorControlFilter valueForKey:kCIInputImageKey] == nil) {
            [weakSelf.colorControlFilter setValue:weakSelf.ciImage forKey:kCIInputImageKey];
        }
        [weakSelf.colorControlFilter setValue:@(saturation) forKey:kCIInputSaturationKey];
        //滤镜生成器输出图片
        //转换为UIImage
        CGImageRef ref = [weakSelf.context createCGImage:weakSelf.colorControlFilter.outputImage fromRect:weakSelf.colorControlFilter.outputImage.extent];
        __block UIImage *temp = [UIImage imageWithCGImage:ref];
        //释放
        CGImageRelease(ref);
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.imageView.image = temp;
        });
    });
}

- (void)updateTemperature:(float)temperature {
    
    MF_WEAK_SELF
    dispatch_async(dispatch_get_global_queue(0, 0),^{
        
        //使用资源
        if ([weakSelf.temperatureFilter valueForKey:kCIInputImageKey] == nil) {
            [weakSelf.temperatureFilter setValue:weakSelf.ciImage forKey:kCIInputImageKey];
        }
        [weakSelf.temperatureFilter setValue:[CIVector vectorWithX:temperature Y:0] forKey:@"inputTargetNeutral"];
        //滤镜生成器输出图片
        //转换为UIImage
        CGImageRef ref = [weakSelf.context createCGImage:weakSelf.temperatureFilter.outputImage fromRect:weakSelf.temperatureFilter.outputImage.extent];
        __block UIImage *temp = [UIImage imageWithCGImage:ref];
        //释放
        CGImageRelease(ref);
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.imageView.image = temp;
        });
    });
}

- (void)updateVignette:(float)vignette {
    
    MF_WEAK_SELF
    dispatch_async(dispatch_get_global_queue(0, 0),^{
        
        //使用资源
        if ([weakSelf.vignetteFilter valueForKey:kCIInputImageKey] == nil) {
            [weakSelf.vignetteFilter setValue:weakSelf.ciImage forKey:kCIInputImageKey];
        }
        [weakSelf.vignetteFilter setValue:@(vignette) forKey:kCIInputIntensityKey];
        [weakSelf.vignetteFilter setValue:@(vignette + 1.0) forKey:kCIInputRadiusKey];
        //滤镜生成器输出图片
        //转换为UIImage
        CGImageRef ref = [weakSelf.context createCGImage:weakSelf.vignetteFilter.outputImage fromRect:weakSelf.vignetteFilter.outputImage.extent];
        __block UIImage *temp = [UIImage imageWithCGImage:ref];
        //释放
        CGImageRelease(ref);
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.imageView.image = temp;
        });
    });
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
