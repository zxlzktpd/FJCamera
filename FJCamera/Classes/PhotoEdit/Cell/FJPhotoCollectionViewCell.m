//
//  FJPhotoCollectionViewCell.m
//  FJCamera
//
//  Created by Fu Jie on 2018/10/26.
//  Copyright © 2018年 Fu Jie. All rights reserved.
//

#import "FJPhotoCollectionViewCell.h"
#import "PHAsset+QuickEdit.h"

@interface FJPhotoCollectionViewCell ()

@property (nonatomic, weak) IBOutlet UIImageView *iv_camera;
@property (nonatomic, weak) IBOutlet UIView *v_content;
@property (nonatomic, weak) IBOutlet UIImageView *iv_cover;
@property (nonatomic, weak) IBOutlet UIImageView *iv_select;

@end

@implementation FJPhotoCollectionViewCell

- (void)dealloc {
    self.iv_camera = nil;
    self.v_content = nil;
    self.iv_cover = nil;
    self.iv_select = nil;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self layoutIfNeeded];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.iv_cover.contentMode = UIViewContentModeScaleAspectFill;
    self.iv_cover.clipsToBounds = YES;
}

- (void)fj_setData:(__kindof FJClCellDataSource *)data {
    
    [super fj_setData:data];
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
    [ds.photoAsset fj_imageAsyncTargetSize:CGSizeMake(UI_SCREEN_WIDTH * 2.0 / (CGFloat)ds.photoListColumn, UI_SCREEN_WIDTH * 2.0 / (CGFloat)ds.photoListColumn) fast:YES iCloud:YES progress:nil result:^(UIImage *image) {
        [weakSelf.iv_cover setImage:image];
    }];
    if (ds.isSelected) {
        [self.iv_select setImage:[FJStorage podImage:@"ic_photo_selected" class:[self class]]];
    }else {
        [self.iv_select setImage:[FJStorage podImage:@"ic_photo_unselected" class:[self class]]];
    }
}

- (IBAction)_tapSelect:(id)sender {
    
    [self fj_tapCell:self.fj_data];
}

@end

@implementation FJPhotoCollectionViewCellDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.photoListColumn = 4.0;
        self.fj_size = CGSizeMake((UI_SCREEN_WIDTH - 5.0 * (CGFloat)self.photoListColumn) / (CGFloat)self.photoListColumn, (UI_SCREEN_WIDTH - 5.0 * (CGFloat)self.photoListColumn) / (CGFloat)self.photoListColumn);
    }
    return self;
}

- (void)setPhotoListColumn:(NSUInteger)photoListColumn {
    
    _photoListColumn = photoListColumn;
    self.fj_size = CGSizeMake((UI_SCREEN_WIDTH - 5.0 * (CGFloat)photoListColumn) / (CGFloat)photoListColumn, (UI_SCREEN_WIDTH - 5.0 * (CGFloat)photoListColumn) / (CGFloat)photoListColumn);
}

@end
