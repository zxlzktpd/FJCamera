//
//  FJPhotoLibraryNoAlbumView.m
//  FJCamera
//
//  Created by Fu Jie on 2019/1/23.
//  Copyright © 2019 Fu Jie. All rights reserved.
//

#import "FJPhotoLibraryNoAlbumView.h"
#import <FJKit_OC/Macro.h>

@implementation FJPhotoLibraryNoAlbumView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (FJPhotoLibraryNoAlbumView *)create {
    
    FJPhotoLibraryNoAlbumView *view = MF_LOAD_NIB(@"FJPhotoLibraryNoAlbumView");
    return view;
}

@end
