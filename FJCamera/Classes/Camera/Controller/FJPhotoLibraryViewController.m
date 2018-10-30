//
//  FJPhotoLibraryViewController.m
//  FJCamera
//
//  Created by Fu Jie on 2018/10/26.
//  Copyright © 2018年 Fu Jie. All rights reserved.
//

#import "FJPhotoLibraryViewController.h"
#import <LBXPermission/LBXPermission.h>
#import "FJCameraCommonHeader.h"
#import "FJPhotoLibrarySelectionView.h"
#import "FJPhotoLibraryAlbumSelectionView.h"
#import "FJPhotoCollectionViewCell.h"

@interface FJPhotoLibraryViewController ()

// CollectionView
@property (nonatomic, strong) FJCollectionView *collectionView;
// Navigation TitleView
@property (nonatomic, strong) FJPhotoLibrarySelectionView *customTitleView;
// Next Button
@property (nonatomic, strong) UIButton *nextBtn;
// 选择相册组件
@property (nonatomic, strong) FJPhotoLibraryAlbumSelectionView *albumSelectionView;
// 所有相册
@property (nonatomic, strong) NSMutableArray<PHAssetCollection *> *photoAssetCollections;
// 当前相册
@property (nonatomic, strong) PHAssetCollection *currentPhotoAssetColletion;
// 已选中的照片
@property (nonatomic, strong) NSMutableArray<PHAsset *> *selectedPhotoAssets;

@end

@implementation FJPhotoLibraryViewController

- (UIButton *)nextBtn {
    
    if (_nextBtn == nil) {
        _nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
        [_nextBtn fj_setTitle:@"下一步"];
        [_nextBtn fj_setTitleFont:[UIFont systemFontOfSize:14.0]];
        [_nextBtn fj_setTitleColor:@"#78787D".fj_color];
        [_nextBtn setUserInteractionEnabled:NO];
        [_nextBtn addTarget:self action:@selector(_tapNext) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

- (NSMutableArray<PHAssetCollection *> *)photoAssetCollections {
    
    if (_photoAssetCollections == nil) {
        _photoAssetCollections = (NSMutableArray<PHAssetCollection *> *)[NSMutableArray new];
    }
    return _photoAssetCollections;
}

- (NSMutableArray<PHAsset *> *)selectedPhotoAssets {
    
    if (_selectedPhotoAssets == nil) {
        _selectedPhotoAssets = (NSMutableArray<PHAsset *> *)[NSMutableArray new];
    }
    return _selectedPhotoAssets;
}

// 设置已选的照片Asset数组
- (void)updateSelectedPhotoAssets:(NSArray<PHAsset *> *)selectedPhotoAssets {
    
    [self.selectedPhotoAssets removeAllObjects];
    [self.selectedPhotoAssets addObjectsFromArray:selectedPhotoAssets];
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.maxSelectionCount = 9;
        self.photoListColumn = 4;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self _buildUI];
    // 获取权限
    // 加载相册
    MF_WEAK_SELF
    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    // 如果用户还没有做出选择，会自动弹框，用户对弹框做出选择后才会调用block
    // 如果之前做过选择，会直接执行调用block
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusDenied) {
                //用户拒绝当前APP访问相册
                if (oldStatus != PHAuthorizationStatusNotDetermined) {
                    //提醒用户打开开关
                    MF_WEAK_SELF
                    FJAlertModel *goSettingAlertModel = [FJAlertModel alertModel:@"前往设置" action:^{
                        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                        if ([[UIApplication sharedApplication] canOpenURL:url]) {
                            [[UIApplication sharedApplication] openURL:url];
                        }
                    }];
                    FJAlertModel *cancelAlertModel = [FJAlertModel alertModelDefaultCancel:^{
                        [weakSelf fj_dismiss];
                    }];
                    [weakSelf fj_alertView:nil message:@"系统设置禁止App访问相册" cancel:NO item:goSettingAlertModel,cancelAlertModel, nil];
                }
            }else if (status == PHAuthorizationStatusAuthorized) {
                // 用户允许当前APP访问相册
                [weakSelf _reloadPhotoAssetCollections];
            }else if (status == PHAuthorizationStatusRestricted) {
                // (系统原因)无法访问相册
                [weakSelf fj_dismiss];
            }
        });
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.userInitBlock == nil ? : weakSelf.userInitBlock();
    });
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)_buildUI {
    
    MF_WEAK_SELF
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    [self fj_navigationBarHidden:NO];
    [self fj_navigationBarStyle:[UIColor whiteColor] translucent:NO bottomLineColor:@"#E6E6E6".fj_color];
    [self fj_addLeftBarButton:[FJStorage podImage:@"ic_back" class:[self class]] action:^{
        [weakSelf fj_dismiss];
    }];
    [self fj_addRightBarCustomView:self.nextBtn action:nil];
    
    if (_customTitleView == nil) {
        self.customTitleView = [FJPhotoLibrarySelectionView create:@"手机相册"];
        self.navigationItem.titleView = self.customTitleView;
        [self.customTitleView setExtendBlock:^{
            [weakSelf _setAblumSelectionViewHidden:NO animation:YES];
        }];
        [self.customTitleView setCollapseBlock:^{
            [weakSelf _setAblumSelectionViewHidden:YES animation:YES];
        }];
    }
    
    if (_collectionView == nil) {
        self.collectionView = [FJCollectionView fj_createCollectionView:CGRectZero backgroundColor:[UIColor whiteColor] collectionViewBackgroundColor:[UIColor whiteColor] sectionInset:UIEdgeInsetsMake(5, 5, 5, 5) minimumLineSpace:5.0 minimumInteritemSpace:5.0 headerHeight:0 footerHeight:0 registerClasses:@[[FJPhotoCollectionViewCell class]] waterfallColumns:self.photoListColumn stickyHeader:NO];
        [self.view addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf.view);
        }];
    }
    
    _collectionView.fj_actionBlock = ^(FJCollectionView *collectionView, FJClActionBlockType type, NSInteger section, NSInteger item, __kindof NSObject *cellData, __kindof UIView *cell) {
        if (type == FJClActionBlockTypeTapped) {
            if ([cellData isKindOfClass:[FJPhotoCollectionViewCellDataSource class]]) {
                __block FJPhotoCollectionViewCellDataSource *ds = (FJPhotoCollectionViewCellDataSource *)cellData;
                if (ds.isCameraPlaceholer) {
                    // 打开相机
                    [weakSelf _openCamera];
                }else {
                    // 选择照片
                    if (weakSelf.singleSelection) {
                        // 单图
                        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
                        //option.synchronous = YES;
                        //option.resizeMode = PHImageRequestOptionsResizeModeExact;
                        option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            
                            [[PHImageManager defaultManager] requestImageForAsset:ds.photoAsset targetSize:CGSizeMake(UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT) contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                
                                BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                                if (downloadFinined) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [weakSelf _openEditingController:result];
                                    });
                                }
                            }];
                        });
                    }else {
                        // 多图
                        
                        if (ds.isSelected) {
                            // 移除
                            ds.isSelected = NO;
                            [weakSelf.selectedPhotoAssets removeObject:ds.photoAsset];
                        }else {
                            // 判断是否超出最大选择数量
                            if (weakSelf.selectedPhotoAssets.count == weakSelf.maxSelectionCount) {
                                if (weakSelf.userOverLimitationBlock != nil) {
                                    weakSelf.userOverLimitationBlock();
                                }else {
                                    [weakSelf.view fj_toast:FJToastImageTypeWarning message:[NSString stringWithFormat:@"最多可以选择 %lu 张图片", (unsigned long)weakSelf.maxSelectionCount]];
                                }
                                return;
                            }
                            // 选择
                            ds.isSelected = YES;
                            [weakSelf.selectedPhotoAssets fj_safeAddObject:ds.photoAsset];
                        }
                        [weakSelf.collectionView.fj_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:item inSection:section]]];
                        [weakSelf _checkNextState];
                    }
                }
            }
        }
    };
}

- (void)_setAblumSelectionViewHidden:(BOOL)hidden animation:(BOOL)animation {
    
    UIView *view = nil;
    MF_WEAK_SELF
    if (_albumSelectionView == nil) {
        
        view = [[UIView alloc] init];
        view.tag = 1000;
        view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        [self.collectionView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf.collectionView);
        }];
        
        UIButton *btn = [[UIButton alloc] init];
        [view addSubview:btn];
        MF_WEAK_OBJECT(view)
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakview);
        }];
        [btn addTarget:self action:@selector(_tapBlurView) forControlEvents:UIControlEventTouchUpInside];
        
        CGPoint point = CGPointZero;
        _albumSelectionView = [FJPhotoLibraryAlbumSelectionView create:point photoAssetCollections:self.photoAssetCollections selectedPhotoAssetCollection:self.currentPhotoAssetColletion assetCollectionChangedBlock:^(PHAssetCollection *currentCollection) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf _setAblumSelectionViewHidden:YES animation:YES];
                [weakSelf.customTitleView collapse];
                if ([weakSelf.currentPhotoAssetColletion isEqual:currentCollection]) {
                    return;
                }
                weakSelf.currentPhotoAssetColletion = currentCollection;
                [weakSelf.customTitleView updateAlbumTitle:currentCollection.localizedTitle];
                [weakSelf _render];
            });
            
        }];
        
        _albumSelectionView.frame = CGRectMake(0, - _albumSelectionView.bounds.size.height, UI_SCREEN_WIDTH, _albumSelectionView.bounds.size.height);
        [view addSubview:_albumSelectionView];
        
    }else {
        for (UIView *v in self.collectionView.subviews) {
            if ([v isMemberOfClass:[UIView class]] && v.tag == 1000) {
                view = v;
                break;
            }
        }
    }
    
    if (animation) {
        MF_WEAK_OBJECT(view)
        if (hidden == YES) {
            view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
            [UIView animateWithDuration:0.25 animations:^{
                weakSelf.albumSelectionView.frame = CGRectMake(0, - weakSelf.albumSelectionView.bounds.size.height, weakSelf.albumSelectionView.bounds.size.width, weakSelf.albumSelectionView.bounds.size.height);
                weakview.backgroundColor = [UIColor clearColor];
            } completion:^(BOOL finished) {
                weakview.hidden = YES;
            }];
            
        }else {
            view.hidden = NO;
            view.backgroundColor = [UIColor clearColor];
            [UIView animateWithDuration:0.2 animations:^{
                weakSelf.albumSelectionView.frame = CGRectMake(0, 0, weakSelf.albumSelectionView.bounds.size.width, weakSelf.albumSelectionView.bounds.size.height);
                weakview.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
            } completion:^(BOOL finished) {
            }];
        }
    }else {
        if (hidden == YES) {
            view.hidden = YES;
            _albumSelectionView.frame = CGRectMake(0, - _albumSelectionView.bounds.size.height, _albumSelectionView.bounds.size.width, _albumSelectionView.bounds.size.height);
        }else {
            view.hidden = NO;
            view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
            _albumSelectionView.frame = CGRectMake(0, 0, _albumSelectionView.bounds.size.width, _albumSelectionView.bounds.size.height);
        }
    }
}

- (void)_tapBlurView {
    
    [self _setAblumSelectionViewHidden:YES animation:YES];
    [self.customTitleView collapse];
}

- (void)_tapNext {
    
    if (self.userNextBlock != nil) {
        self.userNextBlock(self.selectedPhotoAssets);
    }else {
        
    }
}

- (void)_openCamera {
    
}

- (void)_openEditingController:(UIImage *)image {
    
}

- (void)_checkNextState {
    
    if (self.selectedPhotoAssets.count > 0) {
        [self.nextBtn fj_setTitleColor:@"#FF7725".fj_color];
        [self.nextBtn setUserInteractionEnabled:YES];
    }else {
        [self.nextBtn fj_setTitleColor:@"#78787D".fj_color];
        [self.nextBtn setUserInteractionEnabled:NO];
    }
}

- (void)_reloadPhotoAssetCollections {
    
    [self.photoAssetCollections removeAllObjects];
    
    // 系统相机
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    for (PHAssetCollection *collection in collections) {
        if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeAlbumMyPhotoStream || collection.assetCollectionSubtype == PHAssetCollectionSubtypeAlbumCloudShared) {
            // 屏蔽 iCloud 照片流
        }else {
            [self.photoAssetCollections fj_safeAddObject:collection];
        }
    }
    
    // 自定义相册
    PHFetchResult<PHAssetCollection *> *customCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in customCollections) {
        [self.photoAssetCollections fj_safeAddObject:collection];
    }
    
    // 默认选择 系统相册
    self.currentPhotoAssetColletion = self.photoAssetCollections.firstObject;
    
    [self.customTitleView updateAlbumTitle:self.currentPhotoAssetColletion.localizedTitle];
    [self _render];
}

- (void)_render {
    
    [self.collectionView.fj_dataSource removeAllObjects];
    
    // 相机Placeholder
    FJPhotoCollectionViewCellDataSource *placeholer = [[FJPhotoCollectionViewCellDataSource alloc] init];
    placeholer.isCameraPlaceholer = YES;
    [self.collectionView.fj_dataSource fj_safeAddObject:placeholer];
    
    // 当前选中相册的照片流
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    // 排序（最新排的在前面）
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:self.currentPhotoAssetColletion options:option];
    for (PHAsset *asset in assets) {
        BOOL isSelected = NO;
        for (PHAsset *selectedPhotoAsset in self.selectedPhotoAssets) {
            if ([selectedPhotoAsset.localIdentifier isEqualToString:asset.localIdentifier]) {
                isSelected = YES;
                break;
            }
        }
        
        FJPhotoCollectionViewCellDataSource *ds = [[FJPhotoCollectionViewCellDataSource alloc] init];
        ds.isMultiSelection = YES;
        ds.isSelected = isSelected;
        ds.photoAsset = asset;
        
        [self.collectionView.fj_dataSource addObject:ds];
        [self.collectionView fj_refresh];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
