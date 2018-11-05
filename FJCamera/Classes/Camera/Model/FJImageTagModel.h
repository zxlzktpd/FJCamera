//
//  FJImageTagModel.h
//  FJCamera
//
//  Created by Fu Jie on 2018/10/31.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FJImageTagModel <NSObject>
@end

@interface FJImageTagModel : NSObject

// Tag的名称
@property (nonatomic, copy) NSString *name;
// 图片上的x偏移比例
@property (nonatomic, assign) float xPercent;
// 图片上的y偏移比例
@property (nonatomic, assign) float yPercent;
// 图片Index
@property (nonatomic, assign) NSUInteger photoIndex;
// Tag方向
@property (nonatomic, assign) int direction;
// Tag创建时间
@property (nonatomic, assign) long long createdTime;

@end
