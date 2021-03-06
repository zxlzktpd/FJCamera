//
//  FJPhotoLibraryViewController.m
//  FJCamera
//
//  Created by Fu Jie on 2018/10/26.
//  Copyright © 2018年 Fu Jie. All rights reserved.
//

#import "FJPhotoLibraryViewController.h"
#import "FJPhotoLibrarySelectionView.h"
#import "FJPhotoLibraryAlbumSelectionView.h"
#import "FJPhotoCollectionViewCell.h"

@interface FJPhotoLibraryViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

// CollectionView
@property (nonatomic, strong) FJCollectionView *collectionView;
// Navigation TitleView
@property (nonatomic, strong) FJPhotoLibrarySelectionView *customTitleView;
// Image Picker Controller
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
// Next Button
@property (nonatomic, strong) UIButton *nextBtn;
// 选择相册组件
@property (nonatomic, strong) FJPhotoLibraryAlbumSelectionView *albumSelectionView;
// 所有相册
@property (nonatomic, strong) NSMutableArray<PHAssetCollection *> *photoAssetCollections;
// 当前相册
@property (nonatomic, strong) PHAssetCollection *currentPhotoAssetColletion;
// 已选中的照片
@property (nonatomic, strong) NSMutableArray<FJPhotoModel *> *selectedPhotos;

// Edit Controller Block
@property (nonatomic, copy) __kindof FJPhotoUserTagBaseViewController * (^editController)(__kindof __weak FJPhotoEditViewController *controller);

// First Picture Auto Selected (拍照后刷新自动选择)
@property (nonatomic, assign) BOOL firstPhotoAutoSelected;

@end

@implementation FJPhotoLibraryViewController

- (UIImagePickerController *)imagePickerController {
    
    if (_imagePickerController == nil) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imagePickerController.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
        _imagePickerController.allowsEditing = NO;
    }
    return _imagePickerController;
}

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

- (NSMutableArray<FJPhotoModel *> *)selectedPhotos {
    
    if (_selectedPhotos == nil) {
        _selectedPhotos = (NSMutableArray<FJPhotoModel *> *)[NSMutableArray new];
    }
    return _selectedPhotos;
}

- (void)dealloc {
    
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        self.maxSelectionCount = 9;
        self.photoListColumn = 4;
    }
    return self;
}

- (instancetype)initWithMode:(FJPhotoEditMode)mode editController:(__kindof __weak FJPhotoUserTagBaseViewController * (^)(FJPhotoEditViewController *controller))editController {
    
    self = [self init];
    if (self) {
        self.mode = mode;
        self.editController = nil;
        self.editController = editController;
    }
    return self;
}

- (void)viewDidLoad {
    
    MF_WEAK_SELF
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = @"#F5F5F5".fj_color;
    [self fj_navigationBarHidden:NO];
    [self fj_navigationBarStyle:[UIColor whiteColor] translucent:NO bottomLineColor:@"#E6E6E6".fj_color];
    [self fj_addLeftBarButton:[FJStorage podImage:@"ic_back" class:[self class]] action:^{
        [weakSelf fj_dismiss];
    }];
    
    // 获取权限
    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    if (oldStatus == PHAuthorizationStatusDenied || oldStatus == PHAuthorizationStatusRestricted) {
        if (self.userNoPhotoLibraryPermissionBlock != nil) {
            self.userNoPhotoLibraryPermissionBlock();
        }else {
            FJAlertModel *alert = [FJAlertModel alertModel:@"去开启" action:^{
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@""} completionHandler:^(BOOL success){}];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }];
            FJAlertModel *cancel = [FJAlertModel alertModel:@"取消" action:^{
                [weakSelf fj_dismiss];
            }];
            [weakSelf fj_alertView:@"打开相册权限" message:@"打开相册权限后，才能浏览相册哦" cancel:NO item:alert,cancel, nil];
        }
        return;
    }
    // 如果用户还没有做出选择，会自动弹框，用户对弹框做出选择后才会调用block
    // 如果之前做过选择，会直接执行调用block
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusDenied) {
                //用户拒绝当前APP访问相册
                if (oldStatus != PHAuthorizationStatusNotDetermined) {
                    //提醒用户打开开关
                    FJAlertModel *goSettingAlertModel = [FJAlertModel alertModel:@"去开启" action:^{
                        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                        if ([[UIApplication sharedApplication] canOpenURL:url]) {
                            [[UIApplication sharedApplication] openURL:url];
                        }
                    }];
                    FJAlertModel *cancelAlertModel = [FJAlertModel alertModelDefaultCancel:^{
                        [weakSelf fj_dismiss];
                    }];
                    [weakSelf fj_alertView:@"打开相册权限" message:@"打开相册权限后，才能浏览相册哦" cancel:NO item:goSettingAlertModel,cancelAlertModel, nil];
                }else {
                    [weakSelf fj_dismiss];
                }
            }else if (status == PHAuthorizationStatusRestricted) {
                // (系统原因)无法访问相册
                [weakSelf fj_dismiss];
            }else if (status == PHAuthorizationStatusAuthorized) {
                // 用户允许当前APP访问相册
                // 加载相册
                [weakSelf _buildUI];
                [weakSelf _reloadPhotoAssetCollections];
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
        _collectionView = [FJCollectionView fj_createCollectionView:CGRectZero backgroundColor:[UIColor whiteColor] collectionViewBackgroundColor:[UIColor whiteColor] sectionInset:UIEdgeInsetsMake(5, 5, 5, 5) minimumLineSpace:5.0 minimumInteritemSpace:5.0 headerHeight:0 footerHeight:0 registerClasses:@[[FJPhotoCollectionViewCell class]] waterfallColumns:self.photoListColumn stickyHeader:NO];
        [self.view addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf.view);
        }];
    }
    
    _collectionView.fj_actionBlock = ^(FJCollectionView *collectionView, FJClActionBlockType type, NSInteger section, NSInteger item, __kindof NSObject *cellData, __kindof UIView *cell) {
        
        if ([cellData isKindOfClass:[FJPhotoCollectionViewCellDataSource class]]) {
            __block FJPhotoCollectionViewCellDataSource *ds = (FJPhotoCollectionViewCellDataSource *)cellData;
            if (ds.isCameraPlaceholer) {
                // 打开相机
                [weakSelf _openCamera];
            }else {
                // 选择照片
                if (ds.isSelected) {
                    // 移除
                    ds.isSelected = NO;
                    [[FJPhotoManager shared] remove:ds.photoAsset];
                    for (int i = (int)weakSelf.selectedPhotos.count - 1; i >= 0; i--) {
                        FJPhotoModel *photoModel = [weakSelf.selectedPhotos objectAtIndex:i];
                        if ([photoModel.asset isEqual:ds.photoAsset]) {
                            [weakSelf.selectedPhotos removeObjectAtIndex:i];
                            break;
                        }
                    }
                }else {
                    // 判断是否超出最大选择数量
                    if (weakSelf.selectedPhotos.count == weakSelf.maxSelectionCount) {
                        if (weakSelf.userOverLimitationBlock != nil) {
                            weakSelf.userOverLimitationBlock();
                        }else {
                            [weakSelf.view fj_toast:FJToastImageTypeWarning message:[NSString stringWithFormat:@"最多可以选择 %lu 张图片", (unsigned long)weakSelf.maxSelectionCount]];
                        }
                        return;
                    }
                    // 选择
                    ds.isSelected = YES;
                    FJPhotoModel *model = [[FJPhotoManager shared] add:ds.photoAsset];
                    [weakSelf.selectedPhotos fj_arrayAddObject:model];
                }
                [weakSelf.collectionView.fj_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:item inSection:section]]];
                [weakSelf _checkNextState];
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
        [self.view addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf.view);
        }];
        
        UIButton *btn = [[UIButton alloc] init];
        [view addSubview:btn];
        MF_WEAK_OBJECT(view)
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakview);
        }];
        [btn addTarget:self action:@selector(_tapBlurView) forControlEvents:UIControlEventTouchUpInside];
        
        CGPoint point = CGPointZero;
        _albumSelectionView = [FJPhotoLibraryAlbumSelectionView create:point maxColumn:5 photoAssetCollections:self.photoAssetCollections selectedPhotoAssetCollection:self.currentPhotoAssetColletion assetCollectionChangedBlock:^(PHAssetCollection *currentCollection) {
            
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
        for (UIView *v in self.view.subviews) {
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
        self.userNextBlock(self.selectedPhotos);
    }else {
        // 推出 FJPhotoEditViewController
        FJPhotoEditViewController *editVC = [[FJPhotoEditViewController alloc] initWithMode:self.mode editController:self.editController];
        editVC.selectedPhotos = self.selectedPhotos;
        editVC.userEditNextBlock = self.userEditNextBlock;
        editVC.mode = self.mode;
        [self.navigationController pushViewController:editVC animated:YES];
    }
}

- (void)_openCamera {
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
        if (self.userNoCameraPermissionBlock != nil) {
            self.userNoCameraPermissionBlock();
        }else {
            FJAlertModel *alert = [FJAlertModel alertModel:@"去开启" action:^{
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@""} completionHandler:^(BOOL success){}];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }];
            [self fj_alertView:@"打开相机权限" message:@"打开相机权限后，才能拍照哦" cancel:YES item:alert, nil];
        }
        return;
    }
    MF_WEAK_SELF
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            [weakSelf.navigationController presentViewController:weakSelf.imagePickerController animated:YES completion:nil];
        }else {
            //提醒用户打开开关
            FJAlertModel *goSettingAlertModel = [FJAlertModel alertModel:@"去开启" action:^{
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }];
            FJAlertModel *cancelAlertModel = [FJAlertModel alertModelDefaultCancel:^{
                [weakSelf fj_dismiss];
            }];
            [weakSelf fj_alertView:@"打开相机权限" message:@"打开相机权限后，才能拍照哦" cancel:NO item:goSettingAlertModel,cancelAlertModel, nil];
        }
    }];
    
}

- (void)_checkNextState {
    
    if (self.selectedPhotos.count > 0) {
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
            [self.photoAssetCollections fj_arrayAddObject:collection];
        }
    }
    
    // 自定义相册
    PHFetchResult<PHAssetCollection *> *customCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in customCollections) {
        [self.photoAssetCollections fj_arrayAddObject:collection];
    }
    
    // 去除相册集数量为0的对象
    for (int index = (int)self.photoAssetCollections.count - 1; index >= 0; index--) {
        PHAssetCollection *assetCollection = [self.photoAssetCollections objectAtIndex:index];
        PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        if (assets == nil || assets.count == 0) {
            [self.photoAssetCollections removeObjectAtIndex:index];
        }
    }
    
    // 默认选择 系统相册
    self.currentPhotoAssetColletion = self.photoAssetCollections.firstObject;
    
    [self.customTitleView updateAlbumTitle:self.currentPhotoAssetColletion.localizedTitle];
    [self _render];
    
    // 检查下一步的有效性
    [self _checkNextState];
}

- (void)_render {
    
    [self.collectionView.fj_dataSource removeAllObjects];
    
    // 相机Placeholder
    FJPhotoCollectionViewCellDataSource *placeholer = [[FJPhotoCollectionViewCellDataSource alloc] init];
    placeholer.isCameraPlaceholer = YES;
    [self.collectionView.fj_dataSource fj_arrayAddObject:placeholer];
    
    // 当前选中相册的照片流
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    // 排序（最新排的在前面）
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    if (@available(iOS 9.0, *)) {
        option.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
    } else {
    }
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:self.currentPhotoAssetColletion options:option];
    
    // 判断firstPhotoAutoSelected
    // 相片数据
    int i = 0;
    if (self.firstPhotoAutoSelected) {
        self.firstPhotoAutoSelected = NO;
        PHAsset *firstAsset = [assets firstObject];
        i = 1;
        FJPhotoModel *model = [[FJPhotoManager shared] add:firstAsset];
        [self.selectedPhotos fj_arrayAddObject:model];
        
        FJPhotoCollectionViewCellDataSource *ds = [[FJPhotoCollectionViewCellDataSource alloc] init];
        ds.isMultiSelection = YES;
        if (self.selectedPhotos.count == self.maxSelectionCount) {
            if (self.userOverLimitationBlock != nil) {
                self.userOverLimitationBlock();
            }else {
                [self.view fj_toast:FJToastImageTypeWarning message:[NSString stringWithFormat:@"最多可以选择 %lu 张图片", (unsigned long)self.maxSelectionCount]];
            }
            ds.isSelected = NO;
        }else {
            ds.isSelected = YES;
        }
        ds.photoAsset = firstAsset;
        ds.photoListColumn = self.photoListColumn;
        [self.collectionView.fj_dataSource addObject:ds];
    }
    for (; i < assets.count; i++) {
        PHAsset *asset = [assets objectAtIndex:i];
        BOOL isSelected = NO;
        for (FJPhotoModel *selectedPhoto in self.selectedPhotos) {
            if ([selectedPhoto.asset isEqual:asset]) {
                isSelected = YES;
                break;
            }
        }
        FJPhotoCollectionViewCellDataSource *ds = [[FJPhotoCollectionViewCellDataSource alloc] init];
        ds.isMultiSelection = YES;
        ds.isSelected = isSelected;
        ds.photoAsset = asset;
        ds.photoListColumn = self.photoListColumn;
        [self.collectionView.fj_dataSource addObject:ds];
    }
    [self.collectionView fj_refresh];
}

#pragma mark - UIImagePickerViewController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *image = info[UIImagePickerControllerEditedImage];
        if (image == nil) {
            image = info[UIImagePickerControllerOriginalImage];
            if (image == nil) {
                return;
            }
        }
        void *contextInfo = NULL;
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), contextInfo);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    [self.view fj_toast:FJToastImageTypeError message:[error description]];
    self.firstPhotoAutoSelected = YES;
    [self.imagePickerController fj_dismiss];
    [self _reloadPhotoAssetCollections];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [self.imagePickerController fj_dismiss];
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
