//
//  FJPhotoLibraryAlbumCell.m
//  FJCamera
//
//  Created by Fu Jie on 2018/10/26.
//  Copyright © 2018年 Fu Jie. All rights reserved.
//

#import "FJPhotoLibraryAlbumCell.h"

@interface FJPhotoLibraryAlbumCell()

@property (nonatomic, weak) IBOutlet UIImageView *albumImage;
@property (nonatomic, weak) IBOutlet UILabel *albumLabel;
@property (nonatomic, weak) IBOutlet UILabel *countLabel;
@property (nonatomic, weak) IBOutlet UIImageView *selectImage;

@end

@implementation FJPhotoLibraryAlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)fj_setData:(__kindof FJCellDataSource *)data {
    
    [super fj_setData:data];
    FJPhotoLibraryAlbumCellDataSource *ds = data;
    // 获取当前相册 所有照片对象
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:ds.assetCollection options:nil];
    __block PHAsset *firstAsset = assets.lastObject;
    
    MF_WEAK_SELF
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[PHImageManager defaultManager] requestImageForAsset:firstAsset targetSize:CGSizeMake(150.0, 150.0) contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.albumImage setImage:result];
            });
        }];
    });
    self.albumLabel.text = ds.assetCollection.localizedTitle;
    self.countLabel.text = MF_STR(assets.count);
}

@end

@implementation FJPhotoLibraryAlbumCellDataSource

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.fj_height = 80.0;
    }
    return self;
}

@end
