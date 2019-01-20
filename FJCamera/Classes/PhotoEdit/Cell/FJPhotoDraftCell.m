//
//  FJPhotoDraftCell.m
//  FJCamera
//
//  Created by Fu Jie on 2019/1/16.
//  Copyright © 2019 Fu Jie. All rights reserved.
//

#import "FJPhotoDraftCell.h"
#import "PHAsset+QuickEdit.h"
#import <FJKit_OC/UIImage+Utility_FJ.h>
#import <FJKit_OC/NSString+Image_FJ.h>

@interface FJPhotoDraftCell()

@property (nonatomic, weak) IBOutlet UIImageView *draftImageView;
@property (nonatomic, weak) IBOutlet UILabel *draftLabel;
@property (nonatomic, weak) IBOutlet UILabel *draftAssetsCntLabel;

@end

@implementation FJPhotoDraftCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)fj_setData:(__kindof FJCellDataSource *)data {
    
    [super fj_setData:data];
    FJPhotoDraftCellDataSource *ds = data;
    
    FJPhotoPostSavingModel *pModel = [ds.data.photos fj_arrayObjectAtIndex:0];
    PHAsset *asset = [[FJPhotoManager shared] findByIdentifier:pModel.assetIdentifier];
    if (asset == nil) {
        self.draftImageView.image = @"FJPhotoDraftCell.ic_photo_no_found".fj_image;
        ds.pictureRemoved = YES;
    }else {
        ds.pictureRemoved = NO;
        UIImage *image = [asset getSmallTargetImage];
        image = [image fj_imageCropBeginPointRatio:CGPointMake(pModel.beginCropPointX, pModel.beginCropPointY) endPointRatio:CGPointMake(pModel.endCropPointX, pModel.endCropPointY)];
        image = [[FJFilterManager shared] getImage:image tuningObject:pModel.tuningObject appendFilterType:pModel.tuningObject.filterType];
        self.draftImageView.image = image;
    }
    if (ds.data.extra0 != nil && [ds.data.extra0 isKindOfClass:[NSString class]]) {
        NSString *txt = ds.data.extra0;
        self.draftLabel.attributedText = txt.typeset.font([UIFont systemFontOfSize:14.0].fontName, 14.0).minimumLineHeight(22.0).color(@"#3C3C3C".fj_color).string;
    }else {
        self.draftLabel.attributedText = @"暂无晒单文字".typeset.font([UIFont systemFontOfSize:14.0].fontName, 14.0).minimumLineHeight(22.0).color(@"#3C3C3C".fj_color).string;
    }
    self.draftAssetsCntLabel.text = [NSString stringWithFormat:@"%d张照片", (int)ds.data.photos.count];
    
}

@end

@implementation FJPhotoDraftCellDataSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.fj_height = 98.0;
    }
    return self;
}

@end
