//
//  FJPhotoEditFilterView.m
//  FJCamera
//
//  Created by Fu Jie on 2018/11/8.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJPhotoEditFilterView.h"
#import "FJPhotoEditFilterGenreView.h"

@interface FJPhotoEditFilterView ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, copy) void(^selectedBlock)(NSUInteger index);

@end

@implementation FJPhotoEditFilterView

+ (FJPhotoEditFilterView *)create:(CGRect)frame filterImages:(NSArray *)filterImages filterNames:(NSArray *)filterNames selectedBlock:(void(^)(NSUInteger index))selectedBlock {
    
    if (filterImages == nil || filterImages.count == 0 || filterNames == nil || filterNames.count == 0 || filterImages.count != filterNames.count) {
        return nil;
    }
    FJPhotoEditFilterView *view = MF_LOAD_NIB(@"FJPhotoEditFilterView");
    view.frame = frame;
    view.selectedBlock = selectedBlock;
    for (int i = 0; i < filterImages.count; i++) {
        UIImage *filterImage = [filterImages objectAtIndex:i];
        NSString *filterName = [filterNames objectAtIndex:i];
        FJPhotoEditFilterGenreView *genreView = [FJPhotoEditFilterGenreView create:CGRectMake(4.0 + i * (80.0 + 4.0), 0, 80.0, 100.0) image:filterImage title:filterName selected:NO];
        genreView.button.tag = i;
        [genreView.button addTarget:view action:@selector(_tap:) forControlEvents:UIControlEventTouchUpInside];
        [view.scrollView addSubview:genreView];
    }
    view.scrollView.showsVerticalScrollIndicator = NO;
    view.scrollView.showsHorizontalScrollIndicator = NO;
    view.scrollView.contentSize = CGSizeMake(filterImages.count * (80.0 + 4.0) + 4.0, 100.0);
    return view;
}

- (void)_tap:(UIButton *)button {
    
    self.selectedBlock == nil ? : self.selectedBlock(button.tag);
    for (int i = 0; i < self.scrollView.subviews.count; i++) {
        FJPhotoEditFilterGenreView *view = [self.scrollView.subviews objectAtIndex:i];
        if (view.button.tag == button.tag) {
            [view updateSelected:YES];
        }else {
            [view updateSelected:NO];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
