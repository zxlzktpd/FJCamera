//
//  FJPhotoDraftHistoryViewController.m
//  FJCamera
//
//  Created by Fu Jie on 2019/1/16.
//  Copyright © 2019 Fu Jie. All rights reserved.
//

#import "FJPhotoDraftHistoryViewController.h"
#import "FJPhotoDraftCell.h"

@interface FJPhotoDraftHistoryViewController ()

@property (nonatomic, strong) FJTableView *tableView;

@end

@implementation FJPhotoDraftHistoryViewController

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
    [self fj_addLeftBarButton:[FJStorage podImage:@"ic_back" class:[self class]] action:^{
        [weakSelf fj_dismiss];
    }];
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
        if (type == FJActionBlockTypeTapped) {
            if ([cellData isKindOfClass:[FJPhotoDraftCellDataSource class]]) {
                FJPhotoDraftCellDataSource *ds = cellData;
                weakSelf.userSelectDraftBlock == nil ? : weakSelf.userSelectDraftBlock(ds.data, ds.pictureRemoved);
            }
        }else if (type == FJActionBlockTypeDeleted) {
            if ([cellData isKindOfClass:[FJPhotoDraftCellDataSource class]]) {
                FJPhotoDraftCellDataSource *ds = cellData;
                [[FJPhotoManager shared] removeDraft:ds.data];
            }
        }
    };
}

- (void)_loadAndRender {
    
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
