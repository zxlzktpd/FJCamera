//
//  FJFilterManager.m
//  FJCamera
//
//  Created by Fu Jie on 2018/11/2.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJFilterManager.h"
#import <FJKit_OC/NSMutableArray+Utility_FJ.h>
#import <FJKit_OC/NSArray+Utility_FJ.h>

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

@interface FJFilterManager ()

// 上下文
@property (nonatomic, strong) CIContext *context;
// 当前设置的UIImage输入源（加上滤镜效果不改变原值）
@property (nonatomic, strong) UIImage *originalImage;
// image -> ciImage
@property (nonatomic, strong) CIImage *originalCIImage;

// 控制Brightness, contrast, saturation的滤镜
@property (nonatomic, strong) CIFilter *colorControlFilter;
// 控制色温滤镜
@property (nonatomic, strong) CIFilter *temperatureFilter;
// 暗角滤镜
@property (nonatomic, strong) CIFilter *vignetteFilter;

@end

@implementation FJFilterManager

static FJFilterManager *SINGLETON = nil;
static bool isFirstAccess = YES;

+ (FJFilterManager *)shared {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];
    });
    
    return SINGLETON;
}

#pragma mark - Life Cycle
+ (id)allocWithZone:(NSZone *)zone {
    return [self shared];
}

- (id)copy {
    return [[FJFilterManager alloc] init];
}

- (id)mutableCopy {
    return [[FJFilterManager alloc] init];
}

- (id)init {
    
    if(SINGLETON){
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    // 初始化工作
    if (_context == nil) {
        _context = [CIContext contextWithOptions:nil];
    }
    return self;
}

#pragma mark - Test

- (void)_test1 {
    
    /* 滤镜分类Categories */
    /*
     CORE_IMAGE_EXPORT NSString * const kCICategoryDistortionEffect;
     CORE_IMAGE_EXPORT NSString * const kCICategoryGeometryAdjustment;
     CORE_IMAGE_EXPORT NSString * const kCICategoryCompositeOperation;
     CORE_IMAGE_EXPORT NSString * const kCICategoryHalftoneEffect;
     CORE_IMAGE_EXPORT NSString * const kCICategoryColorAdjustment;
     CORE_IMAGE_EXPORT NSString * const kCICategoryColorEffect;
     CORE_IMAGE_EXPORT NSString * const kCICategoryTransition;
     CORE_IMAGE_EXPORT NSString * const kCICategoryTileEffect;
     CORE_IMAGE_EXPORT NSString * const kCICategoryGenerator;
     CORE_IMAGE_EXPORT NSString * const kCICategoryReduction NS_AVAILABLE(10_5, 5_0);
     CORE_IMAGE_EXPORT NSString * const kCICategoryGradient;
     CORE_IMAGE_EXPORT NSString * const kCICategoryStylize;
     CORE_IMAGE_EXPORT NSString * const kCICategorySharpen;
     CORE_IMAGE_EXPORT NSString * const kCICategoryBlur;
     CORE_IMAGE_EXPORT NSString * const kCICategoryVideo;
     CORE_IMAGE_EXPORT NSString * const kCICategoryStillImage;
     CORE_IMAGE_EXPORT NSString * const kCICategoryInterlaced;
     CORE_IMAGE_EXPORT NSString * const kCICategoryNonSquarePixels;
     CORE_IMAGE_EXPORT NSString * const kCICategoryHighDynamicRange;
     CORE_IMAGE_EXPORT NSString * const kCICategoryBuiltIn;
     CORE_IMAGE_EXPORT NSString * const kCICategoryFilterGenerator NS_AVAILABLE(10_5, 9_0);
     */
    
    /*
    NSArray *filterNames = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
    NSLog(@"总共有%ld种滤镜效果:%@",filterNames.count,filterNames);
    
    
    NSArray* filters = [CIFilter filterNamesInCategory:kCICategoryDistortionEffect];
    for (NSString* filterName in filters) {
        NSLog(@"filter name:%@",filterName);
        // 我们可以通过filterName创建对应的滤镜对象
        CIFilter* filter = [CIFilter filterWithName:filterName];
        NSDictionary* attributes = [filter attributes];
        // 获取属性键/值对(在这个字典中我们可以看到滤镜的属性以及对应的key)
        NSLog(@"filter attributes:%@",attributes);
    }
    
    // CIColorControls --> 亮度、饱和度、对比度控制 kCIInputBrightnessKey kCIInputSaturationKey kCIInputContrastKey
    // CITemperatureAndTint --> 色温 kCIInputNeutralTemperatureKey kCIInputNeutralTintKey
    // CIVignette CIVignetteEffect --> 暗角  inputIntensity inputRadius
    
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"];
    NSDictionary* attributes = [filter attributes];
    NSLog(@"filter attributes:%@",attributes);
    
    filter = [CIFilter filterWithName:@"CITemperatureAndTint"];
    attributes = [filter attributes];
    NSLog(@"filter attributes:%@",attributes);
    
    filter = [CIFilter filterWithName:@"CIVignette"];
    attributes = [filter attributes];
    NSLog(@"filter attributes:%@",attributes);
    
    filter = [CIFilter filterWithName:@"CIVignetteEffect"];
    attributes = [filter attributes];
    NSLog(@"filter attributes:%@",attributes);
    */
}

- (void)_test2 {
    
    // Do any additional setup after loading the view, typically from a nib.
    // 滤镜效果
    /*
    NSArray *operations = @[@"CILinearToSRGBToneCurve",
                            @"CIPhotoEffectChrome",
                            @"CIPhotoEffectFade",
                            @"CIPhotoEffectInstant",
                            @"CIPhotoEffectMono",
                            @"CIPhotoEffectNoir",
                            @"CIPhotoEffectProcess",
                            @"CIPhotoEffectTonal",
                            @"CIPhotoEffectTransfer",
                            @"CISRGBToneCurveToLinear",
                            @"CIVignetteEffect"];
    CGFloat width = self.view.frame.size.width / 3;
    CGFloat height = self.view.frame.size.height / 4;
    NSMutableArray *imageViews = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < [operations count]; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame: CGRectMake(i%3*width, i/3*height, width, height)];
        imageView.image = [UIImage imageNamed:@"timg.jpeg"];
        [imageViews addObject:imageView];
        [self.view addSubview:imageView];
    }
    dispatch_async(dispatch_get_global_queue(0, 0),^{
        NSMutableArray *images = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < [operations count]; i++) {
            UIImage *image = [UIImage imageNamed:@"timg.jpeg"];
            CIImage *cImage = [[CIImage alloc]initWithImage:image];
            //使用资源
            CIFilter *filter = [CIFilter filterWithName:operations[i] keysAndValues:kCIInputImageKey,cImage, nil];
            //使用默认参数
            [filter setDefaults];
            //生成上下文
            CIContext*context = [CIContext contextWithOptions:nil];
            //滤镜生成器输出图片
            CIImage *outputimage = [filter outputImage];
            //转换为UIImage
            CGImageRef ref = [context createCGImage:outputimage fromRect:[outputimage extent]];
            UIImage *temp = [UIImage imageWithCGImage:ref];
            [images addObject:temp];
            //释放
            CGImageRelease(ref);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            for (int x = 0; x < [images count]; x++) {
                UIImageView *imageView = imageViews[x];
                imageView.image = images[x];
            }
        });
    });
    */
}

#pragma mark - Filter
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

#pragma mark - Public

- (void)updateImage:(UIImage *)image {
    
    self.originalImage = image;
    self.originalCIImage = [[CIImage alloc] initWithImage:image];
}

- (void)setFilter:(CIFilter *)filter inputImage:(CIImage *)ciImage {
    
    [filter setValue:ciImage forKey:kCIInputImageKey];
}

- (CIFilter *)filterApplyTo:(CIImage *)ciImage brightness:(float)brightness contrast:(float)contrast saturation:(float)saturation {
    
    if (ciImage != nil) {
        [self.colorControlFilter setValue:ciImage forKey:kCIInputImageKey];
    }
    [self.colorControlFilter setValue:@(brightness) forKey:kCIInputBrightnessKey];
    [self.colorControlFilter setValue:@(contrast) forKey:kCIInputContrastKey];
    [self.colorControlFilter setValue:@(saturation) forKey:kCIInputSaturationKey];
    return self.colorControlFilter;
}

- (CIFilter *)filterApplyTo:(CIImage *)ciImage brightness:(float)brightness {
    
    if (ciImage != nil) {
        [self.colorControlFilter setValue:ciImage forKey:kCIInputImageKey];
    }
    [self.colorControlFilter setValue:@(brightness) forKey:kCIInputBrightnessKey];
    return self.colorControlFilter;
}

- (CIFilter *)filterApplyTo:(CIImage *)ciImage contrast:(float)contrast {
    
    if (ciImage != nil) {
        [self.colorControlFilter setValue:ciImage forKey:kCIInputImageKey];
    }
    [self.colorControlFilter setValue:@(contrast) forKey:kCIInputContrastKey];
    return self.colorControlFilter;
}

- (CIFilter *)filterApplyTo:(CIImage *)ciImage saturation:(float)saturation {
    
    if (ciImage != nil) {
        [self.colorControlFilter setValue:ciImage forKey:kCIInputImageKey];
    }
    [self.colorControlFilter setValue:@(saturation) forKey:kCIInputSaturationKey];
    return self.colorControlFilter;
}

- (CIFilter *)filterApplyTo:(CIImage *)ciImage temperature:(float)temperature {

    if (ciImage != nil) {
        [self.temperatureFilter setValue:ciImage forKey:kCIInputImageKey];
    }
    [self.temperatureFilter setValue:[CIVector vectorWithX:temperature Y:0] forKey:@"inputTargetNeutral"];
    return self.temperatureFilter;
}

- (CIFilter *)filterApplyTo:(CIImage *)ciImage vignette:(float)vignette {
    
    if (ciImage != nil) {
        [self.vignetteFilter setValue:ciImage forKey:kCIInputImageKey];
    }
    [self.vignetteFilter setValue:@(vignette) forKey:kCIInputIntensityKey];
    [self.vignetteFilter setValue:@(vignette + 1.0) forKey:kCIInputRadiusKey];
    return self.vignetteFilter;
}

- (void)getImage:(CIFilter *)filter result:(void(^)(UIImage *image))result {
    
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
       
        CGImageRef ref = [weakSelf.context createCGImage:filter.outputImage fromRect:filter.outputImage.extent];
        __block UIImage *filterImage = [UIImage imageWithCGImage:ref];
        //释放
        CGImageRelease(ref);
        dispatch_async(dispatch_get_main_queue(), ^{
            result == nil ? : result(filterImage);
        });
    });
}

- (void)getImageCombine:(NSArray<CIFilter *> *)filters result:(void(^)(UIImage *image))result {
    
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        
        // 去重
        NSArray *uniqueArray = [filters fj_uniqueObjects];
        
        // 合成Filter
        // 第一个Filter必须有CIImage输入源
        for (int i = 1; i < uniqueArray.count; i++) {
            CIFilter *filter = [uniqueArray objectAtIndex:i];
            CIFilter *preFilter = [uniqueArray objectAtIndex:i-1];
            [filter setValue:preFilter.outputImage forKey:kCIInputImageKey];
        }
        CIFilter *lastFilter = [uniqueArray lastObject];
        CGImageRef ref = [weakSelf.context createCGImage:lastFilter.outputImage fromRect:lastFilter.outputImage.extent];
        __block UIImage *filterImage = [UIImage imageWithCGImage:ref];
        //释放
        CGImageRelease(ref);
        dispatch_async(dispatch_get_main_queue(), ^{
            result == nil ? : result(filterImage);
        });
    });
}

- (void)getImage:(UIImage *)image tuningObject:(FJTuningObject *)tuningObject appendFilterType:(FJFilterType)filterType result:(void(^)(UIImage *image))result {
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter1 = [[FJFilterManager shared] filterApplyTo:ciImage brightness:tuningObject.brightnessValue contrast:tuningObject.contrastValue saturation:tuningObject.saturationValue];
    CIFilter *filter2 = [[FJFilterManager shared] filterApplyTo:nil temperature:tuningObject.temperatureValue];
    CIFilter *filter3 = [[FJFilterManager shared] filterApplyTo:nil vignette:tuningObject.vignetteValue];
    [self getImageCombine:@[filter1, filter2, filter3] result:result];
}

@end
