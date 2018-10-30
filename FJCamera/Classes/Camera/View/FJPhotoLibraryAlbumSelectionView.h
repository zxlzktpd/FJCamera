//
//  FJPhotoLibraryAlbumSelectionView.h
//  FJCamera
//
//  Created by Fu Jie on 2018/10/26.
//  Copyright © 2018年 Fu Jie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FJCameraCommonHeader.h"

@interface FJPhotoLibraryAlbumSelectionView : UIView

- (void)setAssetCollectionChangedBlock:(void(^)(PHAssetCollection *currentCollection))block;

+ (FJPhotoLibraryAlbumSelectionView *)create:(CGPoint)point photoAssetCollections:(NSArray<PHAssetCollection *> *)photoAssetCollections selectedPhotoAssetCollection:(PHAssetCollection *)selectedPhotoAssetCollection assetCollectionChangedBlock:(void(^)(PHAssetCollection *currentCollection))block;

@end
