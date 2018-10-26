//
//  FJPhotoCollectionViewCell.h
//  FJCamera
//
//  Created by Fu Jie on 2018/10/26.
//  Copyright © 2018年 Fu Jie. All rights reserved.
//

#import "FJCameraCommonHeader.h"
#import <Photos/Photos.h>

@interface FJPhotoCollectionViewCell : FJClCell

@end

@interface FJPhotoCollectionViewCellDataSource : FJClCellDataSource

@property (nonatomic, assign) BOOL isCameraPlaceholer;
@property (nonatomic, assign) BOOL isMultiSelection;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) PHAsset *photoAsset;

@end
