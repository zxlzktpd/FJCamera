//
//  FJPhotoCollectionViewCell.m
//  FJCamera
//
//  Created by Fu Jie on 2018/10/26.
//  Copyright © 2018年 Fu Jie. All rights reserved.
//

#import "FJPhotoCollectionViewCell.h"
#import <Photos/Photos.h>

@interface FJPhotoCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *iv_camera;

@property (nonatomic, weak) IBOutlet UIView *v_content;
@property (nonatomic, weak) IBOutlet UIImageView *iv_cover;
@property (nonatomic, weak) IBOutlet UIImageView *iv_select;

@end

@implementation FJPhotoCollectionViewCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self layoutIfNeeded];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.iv_cover.contentMode = UIViewContentModeScaleAspectFill;
    self.iv_cover.clipsToBounds = YES;
}

- (void)fj_setData:(__kindof FJClCellDataSource *)data {
    
    FJPhotoCollectionViewCellDataSource *ds = data;
    self.iv_camera.hidden = !ds.isCameraPlaceholer;
    self.v_content.hidden = ds.isCameraPlaceholer;
    if (ds.isCameraPlaceholer) {
        return;
    }
    self.iv_select.hidden = !ds.isMultiSelection;
    [self.iv_cover setImage:nil];
    
    // PHAsset
    MF_WEAK_SELF
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        PHAsset *asset = ds.photoAsset;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(150.0, 150.0) contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.iv_cover setImage:result];
            });
        }];
    });
    
    if (ds.isSelected) {
        [self.iv_select setImage:[UIImage imageNamed:@"ic_photo_selected"]];
    }else {
        [self.iv_select setImage:[UIImage imageNamed:@"ic_photo_unselected"]];
    }
}

@end

@implementation FJPhotoCollectionViewCellDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.fj_size = CGSizeMake((UI_SCREEN_WIDTH - 5 * 4) / 4.0, (UI_SCREEN_WIDTH - 5 * 4) / 4.0);
    }
    return self;
}

@end
