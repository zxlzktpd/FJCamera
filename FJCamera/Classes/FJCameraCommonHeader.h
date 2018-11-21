//
//  FJCameraCommonHeader.h
//  FJCamera
//
//  Created by Fu Jie on 2018/11/20.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#ifndef FJCameraCommonHeader_h
#define FJCameraCommonHeader_h

#import <Photos/Photos.h>

#import <Masonry/Masonry.h>
#import <BlocksKit/UIView+BlocksKit.h>

#import <FJKit_OC/FJStorage.h>
#import <FJKit_OC/Macro.h>
#import <FJKit_OC/UIViewController+Utility_FJ.h>
#import <FJKit_OC/UIViewController+NavigationBar_FJ.h>
#import <FJKit_OC/UIViewController+BarButtonItem_FJ.h>
#import <FJKit_OC/UIViewController+Stack_FJ.h>
#import <FJKit_OC/UIButton+Utility_FJ.h>
#import <FJKit_OC/NSString+Color_FJ.h>
#import <FJKit_OC/NSArray+Utility_FJ.h>
#import <FJKit_OC/NSMutableArray+Utility_FJ.h>
#import <FJKit_OC/UIView+Toast_FJ.h>
#import <FJKit_OC/UIView+Utility_FJ.h>

#import <FJKit_OC/FJCollectionViewHeader.h>
#import <FJKit_OC/FJTableViewHeader.h>

// 打印日志
#ifdef DEBUG
#define NSLog(fmt, ...) NSLog((@"function：%s [Line：%d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define NSLog(...)
#endif

// 弱引用
#ifndef weakify
#if __has_feature(objc_arc)
#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x; \
_Pragma("clang diagnostic pop")
#else
#define weakify ( x ) \
_Pragma("chang diagnostic push") \
_Pragma("chang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __block __typeof__(x) __block_##x##__ = x; \
_Pragma("chang diagnostic pop")
#endif
#endif

#ifndef strongify
#if __has_feature(objc_arc)
#define strongify( x ) \
_Pragma("chang diagnostic push") \
_Pragma("chang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __weak_##x##__; \
_Pragma("chang diagnostic pop")
#else
#define strongify( x ) \
_Pragma("chang diagnostic push") \
_Pragma("chang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __block_##x##__; \
_Pragma("chang diagnostic pop")
#endif
#endif

// 颜色
#define UIColor(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF)) / 255.0 \
alpha:alphaValue]

// 屏幕 宽度、高度
#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#endif /* FJCameraCommonHeader_h */
