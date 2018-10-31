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

@property (nonatomic, copy) NSString *tagName;
@property (nonatomic, assign) float xPercent;
@property (nonatomic, assign) float yPercent;
@property (nonatomic, assign) int direction;
@property (nonatomic, assign) long long createdTime;

@end
