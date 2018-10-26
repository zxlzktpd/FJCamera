//
//  FJPhotoLibraryAlbumSelectionView.m
//  FJCamera
//
//  Created by Fu Jie on 2018/10/26.
//  Copyright © 2018年 Fu Jie. All rights reserved.
//

#import "FJPhotoLibraryAlbumSelectionView.h"
#import "FJPhotoLibraryAlbumCell.h"

@interface FJPhotoLibraryAlbumSelectionView()

@property (nonatomic, strong) FJTableView *tableView;
@property (nonatomic, strong) NSArray<PHAssetCollection *> *photoAssetCollections;
@property (nonatomic, strong) PHAssetCollection *selectedPhotoAssetCollection;
@property (nonatomic, copy) void(^assetCollectionChangedBlock)(PHAssetCollection *currentCollection);

@end

@implementation FJPhotoLibraryAlbumSelectionView

- (void)setAssetCollectionChangedBlock:(void(^)(PHAssetCollection *currentCollection))block {
    
    self.assetCollectionChangedBlock = block;
}

+ (FJPhotoLibraryAlbumSelectionView *)create:(CGPoint)point photoAssetCollections:(NSArray<PHAssetCollection *> *)photoAssetCollections selectedPhotoAssetCollection:(PHAssetCollection *)selectedPhotoAssetCollection assetCollectionChangedBlock:(void(^)(PHAssetCollection *currentCollection))block {
    
    CGFloat h = photoAssetCollections.count > 5 ? 5 * 80.0 : photoAssetCollections.count * 80.0;
    FJPhotoLibraryAlbumSelectionView *view = [[FJPhotoLibraryAlbumSelectionView alloc] initWithFrame:CGRectMake(point.x, point.y, UIScreen.mainScreen.bounds.size.width, h)];
    view.photoAssetCollections = photoAssetCollections;
    view.selectedPhotoAssetCollection = selectedPhotoAssetCollection;
    [view setAssetCollectionChangedBlock:block];
    [view _render];
    return view;
}

- (FJTableView *)tableView {
    
    if (_tableView == nil) {
        _tableView = [FJTableView fj_createDefaultTableView];
        [self addSubview:_tableView];
        MF_WEAK_SELF
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf);
        }];
        _tableView.fj_actionBlock = ^(FJTableView *__weak tableView, FJActionBlockType type, NSInteger section, NSInteger row, __kindof FJCellDataSource *cellData, __kindof FJCell *cell, __kindof FJTableHeaderFooterViewDataSource *headerFooterData, __kindof FJTableHeaderFooterView *headerFooter) {
            if (type == FJActionBlockTypeTapped) {
                if ([cellData isKindOfClass:[FJPhotoLibraryAlbumCellDataSource class]]) {
                    FJPhotoLibraryAlbumCellDataSource *ds = cellData;
                    for (FJPhotoLibraryAlbumCellDataSource *data in weakSelf.tableView.fj_dataSource) {
                        data.isSelected = NO;
                        if ([data isEqual:ds]) {
                            data.isSelected = YES;
                            weakSelf.assetCollectionChangedBlock == nil ? : weakSelf.assetCollectionChangedBlock(data.assetCollection);
                        }
                    }
                    [weakSelf.tableView fj_refresh];
                }
            }
        };
    }
    return _tableView;
}

- (void)_render {
    
    [self.tableView.fj_dataSource removeAllObjects];
    // 获取当前相册 所有照片对象
    for (PHAssetCollection *collection in self.photoAssetCollections) {
        FJPhotoLibraryAlbumCellDataSource *ds = [[FJPhotoLibraryAlbumCellDataSource alloc] init];
        ds.assetCollection = collection;
        if ([collection isEqual:self.selectedPhotoAssetCollection]) {
            ds.isSelected = YES;
        }else {
            ds.isSelected = NO;
        }
    }
    [self.tableView fj_refresh];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
