//
//  FJPhotoCollectionViewCell.h
//  FJCamera
//
//  Created by Fu Jie on 2018/10/26.
//  Copyright © 2018年 Fu Jie. All rights reserved.
//

#import "FJPhotoEditCommonHeader.h"
#import <Photos/Photos.h>

@interface FJPhotoCollectionViewCell : FJClCell

- (void)updateHighlighted:(BOOL)isHighlighted;

@end

@interface FJPhotoCollectionViewCellDataSource : FJClCellDataSource

@property (nonatomic, assign) BOOL isCameraPlaceholer;
@property (nonatomic, assign) BOOL isMultiSelection;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isHighlighted;
@property (nonatomic, strong) PHAsset *photoAsset;
@property (nonatomic, assign) NSUInteger photoListColumn;

@end
