//
//  FJPhotoDraftHistoryViewController.m
//  FJCamera
//
//  Created by Fu Jie on 2019/1/16.
//  Copyright © 2019 Fu Jie. All rights reserved.
//

#import "FJPhotoDraftHistoryViewController.h"
#import <FJKit_OC/NSString+Image_FJ.h>
#import "FJPhotoDraftCell.h"
#import "NSObject+Camera_Popup.h"
#import "FJPhotoDraftBottomView.h"

@interface LeftButton : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button;

@end

@implementation LeftButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.imageView];
        self.imageView.image = @"LeftButton.ic_back".fj_image;
        self.imageView.contentMode = UIViewContentModeCenter;
        self.label = [[UILabel alloc] initWithFrame:self.bounds];
        [self addSubview:self.label];
        self.label.text = @"取消";
        self.label.font = [UIFont systemFontOfSize:14.0];
        self.label.textColor = @"#FF7A00".fj_color;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.hidden = YES;
        self.button = [[UIButton alloc] initWithFrame:self.bounds];
        [self addSubview:self.button];
    }
    return self;
}

- (void)setTag:(NSInteger)tag {
    
    [super setTag:tag];
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (tag) {
            case 0:
            {
                self.imageView.hidden = NO;
                self.label.hidden = YES;
            }
                break;
            case 1:
            {
                self.imageView.hidden = YES;
                self.label.hidden = NO;
            }
                break;
            default:
                break;
        }
    });
}

@end

@interface RightButton : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIButton *button;

@end

@implementation RightButton

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.imageView];
        self.imageView.image = @"RightButton.ic_operation_more".fj_image;
        self.imageView.contentMode = UIViewContentModeCenter;
        self.label = [[UILabel alloc] initWithFrame:self.bounds];
        [self addSubview:self.label];
        self.label.hidden = YES;
        self.label.text = @"全选";
        self.label.textColor = @"#979797".fj_color;
        self.label.font = [UIFont systemFontOfSize:14.0];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.button = [[UIButton alloc] initWithFrame:self.bounds];
        [self addSubview:self.button];
    }
    return self;
}

- (void)setTag:(NSInteger)tag {
    
    [super setTag:tag];
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (tag) {
            case 0:
            {
                self.imageView.hidden = NO;
                self.label.hidden = YES;
                self.label.textColor = @"#979797".fj_color;
            }
                break;
            case 1:
            {
                self.imageView.hidden = YES;
                self.label.hidden = NO;
                self.label.textColor = @"#979797".fj_color;
                break;
            }
            case 2:
            {
                self.imageView.hidden = YES;
                self.label.hidden = NO;
                self.label.textColor = @"#FF7A00".fj_color;
            }
                break;
            default:
                break;
        }
    });
}

@end

@interface FJPhotoDraftHistoryViewController ()

@property (nonatomic, strong) FJTableView *tableView;
@property (nonatomic, strong) LeftButton *leftButton;
@property (nonatomic, strong) RightButton *rightButton;
@property (nonatomic, strong) FJPhotoDraftBottomView *bottomView;

@end

@implementation FJPhotoDraftHistoryViewController

- (LeftButton *)leftButton {
    
    if (_leftButton == nil) {
        _leftButton = [[LeftButton alloc] initWithFrame:CGRectMake(0, 0, 48.0, 48.0)];
    }
    return _leftButton;
}

- (RightButton *)rightButton {
    
    if (_rightButton == nil) {
        _rightButton = [[RightButton alloc] initWithFrame:CGRectMake(0, 0, 48.0, 48.0)];
    }
    return _rightButton;
}

- (FJPhotoDraftBottomView *)bottomView {
    
    if (_bottomView == nil) {
        _bottomView = MF_LOAD_NIB(@"FJPhotoDraftBottomView");
        [self.view addSubview:_bottomView];
        MF_WEAK_SELF
        _bottomView.frame = CGRectMake(0, self.view.frame.size.height - 48.0, self.view.frame.size.width, 48.0);
        _bottomView.deleteBlock = ^{
            for (FJPhotoDraftCellDataSource *ds in weakSelf.tableView.fj_dataSource) {
                if (ds.selected == YES) {
                    [[FJPhotoManager shared] removeDraft:ds.data];
                }
            }
            [weakSelf _loadAndRender];
            weakSelf.rightButton.tag = 0;
            weakSelf.leftButton.tag = 0;
            weakSelf.bottomView.hidden = YES;
        };
    }
    return _bottomView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self _buildUI];
    [self _loadAndRender];
}

- (void)_buildUI {
    
    MF_WEAK_SELF
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    [self fj_navigationBarHidden:NO];
    [self fj_navigationBarStyle:[UIColor whiteColor] translucent:NO bottomLineColor:@"#E6E6E6".fj_color];
    [self fj_removeLeftBarButtons];
    [self fj_addLeftBarCustomView:self.leftButton action:nil];
    [self.leftButton.button addTarget:self action:@selector(_leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self fj_addRightBarCustomView:self.rightButton action:nil];
    [self.rightButton.button addTarget:self action:@selector(_rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self fj_navigationDefaultBarTitle:@"草稿箱"];
    
    if (self.tableView == nil) {
        self.tableView = [FJTableView fj_createDefaultTableView];
        [self.view addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(weakSelf.view);
        }];
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.fj_tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.fj_editingStyle = FJCellEditingStyleDeletionSwipe;
    }
    
    self.tableView.fj_actionBlock = ^(FJTableView *__weak tableView, FJActionBlockType type, NSInteger section, NSInteger row, __kindof FJCellDataSource *cellData, __kindof FJCell *cell, __kindof FJTableHeaderFooterViewDataSource *headerFooterData, __kindof FJTableHeaderFooterView *headerFooter) {
        FJPhotoDraftCellDataSource *ds = cellData;
        if (type == FJActionBlockTypeTapped) {
            if ([cellData isKindOfClass:[FJPhotoDraftCellDataSource class]]) {
                weakSelf.userSelectDraftBlock == nil ? : weakSelf.userSelectDraftBlock(ds.data, ds.pictureRemoved);
            }
        }else if (type == FJActionBlockTypeDeleted) {
            if ([cellData isKindOfClass:[FJPhotoDraftCellDataSource class]]) {
                [[FJPhotoManager shared] removeDraft:ds.data];
            }
        }else if (type == FJActionBlockTypeCustomizedTapped) {
            if (ds.action == 0) {
                // Check
                for (FJPhotoDraftCellDataSource *ds in weakSelf.tableView.fj_dataSource) {
                    if (ds.selected == NO) {
                        weakSelf.rightButton.tag = 1;
                        return;
                    }
                }
                weakSelf.rightButton.tag = 2;
            }else if (ds.action == 1) {
                // 长按
                weakSelf.leftButton.tag = 1;
                weakSelf.rightButton.tag = 1;
                weakSelf.bottomView.hidden = NO;
                for (FJPhotoDraftCellDataSource *ds in weakSelf.tableView.fj_dataSource) {
                    ds.editable = YES;
                    if ([ds isEqual:cellData]) {
                        ds.selected = YES;
                    }else {
                        ds.selected = NO;
                    }
                }
                [weakSelf.tableView fj_refresh];
            }
        }
    };
}

- (void)_leftButtonAction {
    
    if (self.leftButton.tag == 0) {
        // 点击返回
        [self fj_dismiss];
    }else if (self.leftButton.tag == 1) {
        // 点击取消
        for (FJPhotoDraftCellDataSource *ds in self.tableView.fj_dataSource) {
            ds.editable = NO;
        }
        [self.tableView fj_refresh];
        self.leftButton.tag = 0;
        self.rightButton.tag = 0;
        self.bottomView.hidden = YES;
    }
}

- (void)_rightButtonAction {
    
    MF_WEAK_SELF
    if (self.rightButton.tag == 0) {
        // 点击更多
        [NSObject popupDraftEditTool:^{
            weakSelf.rightButton.tag = 1;
            weakSelf.leftButton.tag = 1;
            for (FJPhotoDraftCellDataSource *ds in weakSelf.tableView.fj_dataSource) {
                ds.editable = YES;
                ds.selected = NO;
            }
            [weakSelf.tableView fj_refresh];
            
            weakSelf.bottomView.hidden = NO;
        }];
    }else if (self.rightButton.tag == 1) {
        // 点击全选（灰 未选）
        weakSelf.rightButton.tag = 2;
        for (FJPhotoDraftCellDataSource *ds in weakSelf.tableView.fj_dataSource) {
            ds.editable = YES;
            ds.selected = YES;
        }
        [weakSelf.tableView fj_refresh];
    }else if (self.rightButton.tag == 2) {
        // 点击全选（橙 已选）
        weakSelf.rightButton.tag = 1;
        for (FJPhotoDraftCellDataSource *ds in weakSelf.tableView.fj_dataSource) {
            ds.editable = YES;
            ds.selected = NO;
        }
        [weakSelf.tableView fj_refresh];
    }
}

- (void)_loadAndRender {
    
    [self.tableView.fj_dataSource removeAllObjects];
    FJPhotoPostDraftListSavingModel *listModel = [[FJPhotoManager shared] loadDraftCache];
    MF_WEAK_SELF
    [listModel.drafts enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(FJPhotoPostDraftSavingModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FJPhotoDraftCellDataSource *ds = [[FJPhotoDraftCellDataSource alloc] init];
        ds.data = obj;
        [weakSelf.tableView fj_addDataSource:ds];
    }];
    [self.tableView fj_refresh];
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
