//
//  FJPhotoEditTitleScrollView.h
//  FJCamera
//
//  Created by Fu Jie on 2018/10/30.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FJPhotoEditTitleScrollView : UIView

- (void)updateTitle:(NSString *)title;

- (void)updateCount:(NSUInteger)count;

- (void)updateIndex:(NSUInteger)index;

+ (FJPhotoEditTitleScrollView *)create:(NSUInteger)count;

@end
