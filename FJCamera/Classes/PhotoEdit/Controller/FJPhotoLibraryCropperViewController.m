//
//  FJPhotoLibraryCropperViewController.m
//  FJCamera
//
//  Created by Fu Jie on 2018/11/13.
//  Copyright © 2018 Fu Jie. All rights reserved.
//

#import "FJPhotoLibraryCropperViewController.h"
#import "FJPhotoLibrarySelectionView.h"
#import "FJPhotoLibraryAlbumSelectionView.h"
#import "FJPhotoCollectionViewCell.h"
#import "FJCropperView.h"
#import "PHAsset+Utility.h"
#import "FJTakePhotoButton.h"
#import <FJKit_OC/NSString+UUID_FJ.h>

#define PREVIEW_IMAGE_LEAST_HEIGHT (48.0)
#define UPDOWN_LEAST_HEIGHT (48.0)

@interface FJPhotoLibraryCropperViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

// CropperView
@property (nonatomic, strong) FJCropperView *cropperView;
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
// 拍摄照片Button
@property (nonatomic, strong) FJTakePhotoButton *takePhotoButton;
// 所有相册
@property (nonatomic, strong) NSMutableArray<PHAssetCollection *> *photoAssetCollections;
// 当前相册
@property (nonatomic, strong) PHAssetCollection *currentPhotoAssetColletion;
// 已选中的照片
@property (nonatomic, strong) NSMutableArray<FJPhotoModel *> *selectedPhotos;

// Edit Controller Block
@property (nonatomic, copy) __kindof FJPhotoUserTagBaseViewController * (^editController)(FJPhotoEditViewController *controller);

// First Picture Auto Selected (拍照后刷新自动选择)
@property (nonatomic, assign) BOOL firstPhotoAutoSelected;

// temporary photo model array
@property (nonatomic, strong) NSMutableArray<FJPhotoModel *> *temporaryPhotoModels;

// UUID
@property (nonatomic, copy) NSString *uuid;

@end

@implementation FJPhotoLibraryCropperViewController

- (NSMutableArray<FJPhotoModel *> *)temporaryPhotoModels {
    
    if (_temporaryPhotoModels == nil) {
        _temporaryPhotoModels = (NSMutableArray<FJPhotoModel *> *)[[NSMutableArray alloc] init];
    }
    return _temporaryPhotoModels;
}

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
        self.takeButtonPosition = FJTakePhotoButtonPositionBottom;
        self.sortType = FJPhotoSortTypeCreationDateDesc;
        self.uuid = [NSString fj_uuidRandomTimestamp];
    }
    return self;
}

- (instancetype)initWithMode:(FJPhotoEditMode)mode editController:(__kindof FJPhotoUserTagBaseViewController * (^)(FJPhotoEditViewController *controller))editController {
    
    self = [self init];
    if (self) {
        self.mode = mode;
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
                [weakSelf _buildUI];
                [weakSelf _reloadPhotoAssetCollections];
                FJPhotoCollectionViewCellDataSource *ds = nil;
                if (weakSelf.takeButtonPosition == FJTakePhotoButtonPositionCell) {
                    ds = [weakSelf.collectionView.fj_dataSource fj_arrayObjectAtIndex:1];
                }else if (weakSelf.takeButtonPosition == FJTakePhotoButtonPositionNone || weakSelf.takeButtonPosition == FJTakePhotoButtonPositionBottom) {
                    ds = [weakSelf.collectionView.fj_dataSource fj_arrayObjectAtIndex:0];
                }
                ds.isHighlighted = YES;
                FJPhotoModel *model = [weakSelf _addTemporary:ds.photoAsset];
                // 更新CropperView
                [weakSelf.cropperView updateModel:model];
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
    
    if (_cropperView == nil) {
        _cropperView = [FJCropperView create:9.0 / 16.0 verticalExtemeRatio:4.0 / 5.0 debug:NO croppedBlock:^(FJPhotoModel *photoModel, CGRect frame) {
            
        } updownBlock:^(BOOL up) {
            [weakSelf _move:up];
        }];
        _cropperView.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_WIDTH);
        [self.view addSubview:_cropperView];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_panAction:)];
        [_cropperView addGestureRecognizer:panGesture];
    }
    
    if (_collectionView == nil) {
        _collectionView = [FJCollectionView fj_createCollectionView:CGRectZero backgroundColor:[UIColor whiteColor] collectionViewBackgroundColor:[UIColor whiteColor] sectionInset:UIEdgeInsetsMake(5, 5, 5, 5) minimumLineSpace:5.0 minimumInteritemSpace:5.0 headerHeight:0 footerHeight:0 registerClasses:@[[FJPhotoCollectionViewCell class]] waterfallColumns:self.photoListColumn stickyHeader:NO];
        [self.view addSubview:_collectionView];
        _collectionView.frame = CGRectMake(0, UI_SCREEN_WIDTH, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT - UI_SCREEN_WIDTH - UI_TOP_HEIGHT);
        if (self.takeButtonPosition == FJTakePhotoButtonPositionBottom) {
            _collectionView.fj_collectionView.contentInset = UIEdgeInsetsMake(0, 0, 48.0, 0);
        }
    }
    
    _collectionView.fj_actionBlock = ^(FJCollectionView *collectionView, FJClActionBlockType type, NSInteger section, NSInteger item, __kindof NSObject *cellData, __kindof UIView *cell) {
        if ([cellData isKindOfClass:[FJPhotoCollectionViewCellDataSource class]]) {
            FJPhotoCollectionViewCellDataSource *ds = (FJPhotoCollectionViewCellDataSource *)cellData;
            if (ds.isCameraPlaceholer) {
                // 打开相机
                [weakSelf _openCamera];
                return;
            }
            if ([weakSelf.cropperView inCroppingImage]) {
                if (ds.isSelected == YES) {
                    ds.isSelected = NO;
                }
                return;
            }
            if (type == FJClActionBlockTypeCustomizedTapped) {
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
                    FJPhotoModel *model = [weakSelf _addTemporary:ds.photoAsset];
                    [[FJPhotoManager shared] addDistinct:model];
                    [weakSelf.selectedPhotos fj_arrayAddObject:model];
                    
                    // 更新CropperView
                    model.needCrop = YES;
                    BOOL updateSuccess = [weakSelf.cropperView updateModel:model];
                    if (updateSuccess == NO) {
                        ds.isSelected = NO;
                        return;
                    }
                }
                [weakSelf.collectionView.fj_collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:item inSection:section]]];
                [weakSelf _checkNextState];
            }else if (type == FJClActionBlockTypeTapped) {
                
                FJPhotoModel *model = [weakSelf _addTemporary:ds.photoAsset];
                // 更新CropperView
                model.needCrop = ds.isSelected;
                BOOL updateSuccess = [weakSelf.cropperView updateModel:model];
                if (updateSuccess == NO) {
                    return;
                }
            }
            for (FJPhotoCollectionViewCellDataSource *data in weakSelf.collectionView.fj_dataSource) {
                if ([data isEqual:cellData]) {
                    data.isHighlighted = YES;
                }else {
                    data.isHighlighted = NO;
                }
            }
            FJPhotoCollectionViewCell *cl = (FJPhotoCollectionViewCell *)[weakSelf.collectionView.fj_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
            for (FJPhotoCollectionViewCell *c in [weakSelf.collectionView.fj_collectionView visibleCells]) {
                if ([c isEqual:cl]) {
                    [c fj_cornerRadius:2.0 borderWidth:2.0 boderColor:@"#FF7725".fj_color];
                }else {
                    [c fj_cornerRadius:0 borderWidth:0 boderColor:[UIColor clearColor]];
                }
            }
        }
    };
    self.collectionView.fj_scrollBlock = ^(UIScrollView *scrollView, FJClScrollBlockType type, CGFloat height, BOOL willDecelerate) {
        
        static BOOL endDrag;
        
        if (type == FJClScrollBlockTypeDragDidEnd) {
            endDrag = YES;
        }else if (type == FJClScrollBlockTypeDragWillBegin) {
            endDrag = NO;
        }
        
        if (endDrag == NO && scrollView.contentOffset.y < 0) {
            
            weakSelf.cropperView.blurLabel.hidden = YES;
            
            if (weakSelf.cropperView.frame.origin.y <= 0) {
                weakSelf.cropperView.frame = CGRectMake(0, weakSelf.cropperView.frame.origin.y + fabs(scrollView.contentOffset.y) / 2.0, weakSelf.cropperView.frame.size.width, weakSelf.cropperView.frame.size.height);
                if (weakSelf.cropperView.frame.origin.y > 0) {
                    weakSelf.cropperView.frame = CGRectMake(0, 0, weakSelf.cropperView.frame.size.width, weakSelf.cropperView.frame.size.height);
                }
                weakSelf.collectionView.frame = CGRectMake(0, weakSelf.cropperView.frame.origin.y + weakSelf.cropperView.bounds.size.height, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT - UI_TOP_HEIGHT - UI_SCREEN_WIDTH - weakSelf.cropperView.frame.origin.y);
            }
        }
        if (type == FJClScrollBlockTypeDragDidEnd) {
            if (weakSelf.cropperView.frame.origin.y > - (UI_SCREEN_WIDTH - PREVIEW_IMAGE_LEAST_HEIGHT - UPDOWN_LEAST_HEIGHT) ) {
                [weakSelf _move:NO];
            }else {
                [weakSelf _move:YES];
            }
        }
    };
    
    // Take Photo Button
    if (self.takeButtonPosition == FJTakePhotoButtonPositionBottom) {
        if (_takePhotoButton == nil) {
            _takePhotoButton = [FJTakePhotoButton create:^{
                // 打开相机
                [weakSelf _openCamera];
            }];
            [self.view addSubview:_takePhotoButton];
            [_takePhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.right.equalTo(weakSelf.view);
                make.height.equalTo(@48.0);
            }];
        }
    }
}

- (void)_panAction:(UIPanGestureRecognizer *)panGesture {
    
    CGPoint point = [panGesture translationInView:panGesture.view];
    static CGFloat y = 0;
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            y = self.cropperView.frame.origin.y;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            
            self.cropperView.blurLabel.hidden = YES;
            
            CGRect frame = CGRectMake(0,  y + point.y, self.cropperView.bounds.size.width, self.cropperView.bounds.size.height);
            if (frame.origin.y >= 0) {
                frame.origin.y = 0;
            }else if (frame.origin.y <= -(UI_SCREEN_WIDTH - PREVIEW_IMAGE_LEAST_HEIGHT)) {
                frame.origin.y = -(UI_SCREEN_WIDTH - PREVIEW_IMAGE_LEAST_HEIGHT);
            }
            self.cropperView.frame = frame;
            self.collectionView.frame = CGRectMake(0, self.cropperView.frame.origin.y + self.cropperView.bounds.size.height, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT - UI_TOP_HEIGHT - UI_SCREEN_WIDTH - self.cropperView.frame.origin.y);
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            if ([self.cropperView getUp]) {
                if (self.cropperView.frame.origin.y > - (UI_SCREEN_WIDTH - PREVIEW_IMAGE_LEAST_HEIGHT - UPDOWN_LEAST_HEIGHT) ) {
                    [self _move:NO];
                }else {
                    [self _move:YES];
                }
            }else {
                if (self.cropperView.frame.origin.y < - UPDOWN_LEAST_HEIGHT ) {
                    [self _move:YES];
                }else {
                    [self _move:NO];
                }
            }
            
            break;
        }
        default:
            break;
    }
}

- (void)_move:(BOOL)up {
    
    MF_WEAK_SELF
    CGRect frame = CGRectZero;
    if (up) {
        frame = CGRectMake(0,  -(UI_SCREEN_WIDTH - PREVIEW_IMAGE_LEAST_HEIGHT), weakSelf.cropperView.bounds.size.width, weakSelf.cropperView.bounds.size.height);
    }else {
        frame = CGRectMake(0,  0, weakSelf.cropperView.bounds.size.width, weakSelf.cropperView.bounds.size.height);
    }
    static BOOL inAnimation = NO;
    if (inAnimation) {
        return;
    }
    inAnimation = YES;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.cropperView.frame = frame;
        if (up) {
            weakSelf.collectionView.frame = CGRectMake(0, weakSelf.cropperView.frame.origin.y + weakSelf.cropperView.bounds.size.height, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT - UI_TOP_HEIGHT - UI_SCREEN_WIDTH - weakSelf.cropperView.frame.origin.y);
        }else {
            weakSelf.collectionView.frame = CGRectMake(0, weakSelf.cropperView.frame.origin.y + weakSelf.cropperView.bounds.size.height, UI_SCREEN_WIDTH, weakSelf.collectionView.bounds.size.height);
        }
    } completion:^(BOOL finished) {
        inAnimation = NO;
        weakSelf.collectionView.frame = CGRectMake(0, weakSelf.cropperView.frame.origin.y + weakSelf.cropperView.bounds.size.height, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT - UI_TOP_HEIGHT - UI_SCREEN_WIDTH - weakSelf.cropperView.frame.origin.y);
        [weakSelf.cropperView updateUp:up];
    }];
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
}

- (void)_render {
    
    MF_WEAK_SELF
    [self.collectionView.fj_dataSource removeAllObjects];
    
    // 相机Placeholder
    if (self.takeButtonPosition == FJTakePhotoButtonPositionCell) {
        FJPhotoCollectionViewCellDataSource *placeholer = [[FJPhotoCollectionViewCellDataSource alloc] init];
        placeholer.isCameraPlaceholer = YES;
        [self.collectionView.fj_dataSource fj_arrayAddObject:placeholer];
    }
    
    // 当前选中相册的照片流
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    // 排序（最新排的在前面）
    switch (self.sortType) {
        case FJPhotoSortTypeModificationDateDesc:
        {
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:NO]];
            break;
        }
        case FJPhotoSortTypeModificationDateAsc:
        {
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:YES]];
            break;
        }
        case FJPhotoSortTypeCreationDateDesc:
        {
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            break;
        }
        case FJPhotoSortTypeCreationDateAsc:
        {
            option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            break;
        }
        default:
            break;
    }
    
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    if (@available(iOS 9.0, *)) {
        option.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
    } else {
    }
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:self.currentPhotoAssetColletion options:option];
    
    // 判断firstPhotoAutoSelected
    // 相片数据
    int i = 0;
    if (self.firstPhotoAutoSelected) {
        i = 1;
        self.firstPhotoAutoSelected = NO;
        PHAsset *firstAsset = [assets firstObject];
        __block FJPhotoCollectionViewCellDataSource *ds = [[FJPhotoCollectionViewCellDataSource alloc] init];
        ds.isMultiSelection = YES;
        ds.isSelected = YES;
        ds.photoAsset = firstAsset;
        ds.photoListColumn = self.photoListColumn;
        [self.collectionView.fj_dataSource addObject:ds];
        
        // 选择
        FJPhotoModel *model = [weakSelf _addTemporary:ds.photoAsset];
        [[FJPhotoManager shared] addDistinct:model];
        [self.selectedPhotos fj_arrayAddObject:model];
        
        // 更新CropperView
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            model.needCrop = YES;
            [weakSelf.cropperView updateModel:model];
        });
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
    
    // 检查下一步的有效性
    [self _checkNextState];
}

- (FJPhotoModel *)_addTemporary:(PHAsset *)asset {
    
    for (FJPhotoModel *model in self.temporaryPhotoModels) {
        if ([model.asset isEqual:asset]) {
            return model;
        }
    }
    FJPhotoModel *model = [[FJPhotoModel alloc] initWithAsset:asset];
    model.uuid = self.uuid;
    [self.temporaryPhotoModels fj_arrayAddObject:model];
    return model;
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
