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
#import "PHAsset+Utility.h"

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

// 固定滤镜
// 预制滤镜Photo 8款 
@property (nonatomic, strong) CIFilter *photoEffectChromeFilter;
@property (nonatomic, strong) CIFilter *photoEffectFadeFilter;
@property (nonatomic, strong) CIFilter *photoEffectInstantFilter;
@property (nonatomic, strong) CIFilter *photoEffectMonoFilter;
@property (nonatomic, strong) CIFilter *photoEffectNoirFilter;
@property (nonatomic, strong) CIFilter *photoEffectProcessFilter;
@property (nonatomic, strong) CIFilter *photoEffectTonalFilter;
@property (nonatomic, strong) CIFilter *photoEffectTransferFilter;

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

#pragma mark - Photo Effect Filters

- (CIFilter *)photoEffectChromeFilter {
    
    if (_photoEffectChromeFilter == nil) {
        _photoEffectChromeFilter = [CIFilter filterWithName:@"CIPhotoEffectChrome"];
    }
    return _photoEffectChromeFilter;
}

- (CIFilter *)photoEffectFadeFilter {
    
    if (_photoEffectFadeFilter == nil) {
        _photoEffectFadeFilter = [CIFilter filterWithName:@"CIPhotoEffectFade"];
    }
    return _photoEffectFadeFilter;
}

- (CIFilter *)photoEffectInstantFilter {
    
    if (_photoEffectInstantFilter == nil) {
        _photoEffectInstantFilter = [CIFilter filterWithName:@"CIPhotoEffectInstant"];
    }
    return _photoEffectInstantFilter;
}

- (CIFilter *)photoEffectMonoFilter {
    
    if (_photoEffectMonoFilter == nil) {
        _photoEffectMonoFilter = [CIFilter filterWithName:@"CIPhotoEffectMono"];
    }
    return _photoEffectMonoFilter;
}

- (CIFilter *)photoEffectNoirFilter {
    
    if (_photoEffectNoirFilter == nil) {
        _photoEffectNoirFilter = [CIFilter filterWithName:@"CIPhotoEffectNoir"];
    }
    return _photoEffectNoirFilter;
}

- (CIFilter *)photoEffectProcessFilter {
    
    if (_photoEffectProcessFilter == nil) {
        _photoEffectProcessFilter = [CIFilter filterWithName:@"CIPhotoEffectProcess"];
    }
    return _photoEffectProcessFilter;
}

- (CIFilter *)photoEffectTonalFilter {
    
    if (_photoEffectTonalFilter == nil) {
        _photoEffectTonalFilter = [CIFilter filterWithName:@"CIPhotoEffectTonal"];
    }
    return _photoEffectTonalFilter;
}

- (CIFilter *)photoEffectTransferFilter {
    
    if (_photoEffectTransferFilter == nil) {
        _photoEffectTransferFilter = [CIFilter filterWithName:@"CIPhotoEffectTransfer"];
    }
    return _photoEffectTransferFilter;
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

- (UIImage *)getImage:(UIImage *)image filterType:(FJFilterType)filterType {
    
    CIFilter *filter = [self filterBy:filterType];
    if (filter == nil) {
        return image;
    }
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    [filter setValue:ciImage forKey:kCIInputImageKey];
    CGImageRef ref = [self.context createCGImage:filter.outputImage fromRect:filter.outputImage.extent];
    UIImage *filterImage = [UIImage imageWithCGImage:ref];
    //释放
    CGImageRelease(ref);
    return filterImage;
}

- (void)getImageCombine:(NSArray<CIFilter *> *)filters result:(void(^)(UIImage *image))result {
    
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        
        // 去重
        NSArray *uniqueArray = [filters fj_arrayRemoveDuplicateObjects];
        
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

- (UIImage *)getImageCombine:(NSArray<CIFilter *> *)filters {
    
    // 去重
    NSArray *uniqueArray = [filters fj_arrayRemoveDuplicateObjects];
    
    // 合成Filter
    // 第一个Filter必须有CIImage输入源
    for (int i = 1; i < uniqueArray.count; i++) {
        CIFilter *filter = [uniqueArray objectAtIndex:i];
        CIFilter *preFilter = [uniqueArray objectAtIndex:i-1];
        [filter setValue:preFilter.outputImage forKey:kCIInputImageKey];
    }
    CIFilter *lastFilter = [uniqueArray lastObject];
    CGImageRef ref = [self.context createCGImage:lastFilter.outputImage fromRect:lastFilter.outputImage.extent];
    UIImage *filterImage = [UIImage imageWithCGImage:ref];
    //释放
    CGImageRelease(ref);
    return filterImage;
}

- (UIImage *)getImage:(UIImage *)image tuningObject:(FJTuningObject *)tuningObject appendFilterType:(FJFilterType)filterType {
    
    if (image == nil || ![image isKindOfClass:[UIImage class]]) {
        return nil;
    }
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter1 = [[FJFilterManager shared] filterApplyTo:ciImage brightness:tuningObject.brightnessValue contrast:tuningObject.contrastValue saturation:tuningObject.saturationValue];
    CIFilter *filter2 = [[FJFilterManager shared] filterApplyTo:nil temperature:tuningObject.temperatureValue];
    CIFilter *filter3 = [[FJFilterManager shared] filterApplyTo:nil vignette:tuningObject.vignetteValue];
    CIFilter *filter4 = [self filterBy:filterType];
    if (filter4 != nil) {
        return [self getImageCombine:@[filter1, filter2, filter3, filter4]];
    }
    return [self getImageCombine:@[filter1, filter2, filter3]];
}

- (UIImage *)getImageAsset:(PHAsset *)asset tuningObject:(FJTuningObject *)tuningObject appendFilterType:(FJFilterType)filterType {
    
    UIImage *image = [asset getStaticTargetImage];
    return [self getImage:image tuningObject:tuningObject appendFilterType:filterType];
}

- (CIFilter *)filterBy:(FJFilterType)type {
    
    switch (type) {
        case FJFilterTypePhotoEffectChrome:
        {
            return self.photoEffectChromeFilter;
        }
        case FJFilterTypePhotoEffectFade:
        {
            return self.photoEffectFadeFilter;
        }
        case FJFilterTypePhotoEffectInstant:
        {
            return self.photoEffectInstantFilter;
        }
        case FJFilterTypePhotoEffectMono:
        {
            return self.photoEffectMonoFilter;
        }
        case FJFilterTypePhotoEffectNoir:
        {
            return self.photoEffectNoirFilter;
        }
        case FJFilterTypePhotoEffectProcess:
        {
            return self.photoEffectProcessFilter;
        }
        case FJFilterTypePhotoEffectTonal:
        {
            return self.photoEffectTonalFilter;
        }
        case FJFilterTypePhotoEffectTransfer:
        {
            return self.photoEffectTransferFilter;
        }
        case FJFilterTypeOriginal:
        default:
            return nil;
    }
}

@end
