//
//  FJPhotoDraftCell.h
//  FJCamera
//
//  Created by Fu Jie on 2019/1/16.
//  Copyright © 2019 Fu Jie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FJPhotoEditCommonHeader.h"
#import "FJPhotoManager.h"
#import "FJFilterManager.h"

@interface FJPhotoDraftCell : FJCell

@end

@interface FJPhotoDraftCellDataSource : FJCellDataSource

@property (nonatomic, strong) FJPhotoPostDraftSavingModel *data;
@property (nonatomic, assign) BOOL pictureRemoved;

@end
