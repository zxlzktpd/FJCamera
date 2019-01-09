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

// Tag的ID
@property (nonatomic, copy) NSString *tagId;
// Tag的名称
@property (nonatomic, copy) NSString *name;
// 图片上的x偏移比例
@property (nonatomic, assign) float xPercent;
// 图片上的y偏移比例
@property (nonatomic, assign) float yPercent;
// 图片Index
@property (nonatomic, assign) NSUInteger photoHash;
// Tag方向
@property (nonatomic, assign) int direction;
// Tag创建时间
@property (nonatomic, assign) long long createdTime;
// Tag View Frame (计算后填入，用于页面滑动刷新)
@property (nonatomic, assign) CGRect adjustedFrame;
// isHint
@property (nonatomic, assign) BOOL isHint;

@end
