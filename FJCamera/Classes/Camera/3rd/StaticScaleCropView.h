//
//  StaticScaleCropView.h
//  TagTest
//
//  Created by mark meng on 16/9/22.
//  Copyright © 2016年 mark meng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StaticScaleCropView : UIView

- (void)updateImage:(UIImage*)image ratio:(CGFloat)ratio;

- (UIImage *)croppedImage;

@end
