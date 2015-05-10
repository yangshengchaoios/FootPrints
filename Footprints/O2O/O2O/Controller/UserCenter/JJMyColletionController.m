//
//  JJMyColletionController.m
//  Footprints
//
//  Created by Jinjin on 14/12/12.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJMyColletionController.h"
#import "MJRefresh.h"
#import "JJCollectionCell.h"
#import "TimeUtils.h"
#import "JJDetailViewController.h"

@interface JJMyColletionController ()<UITableViewDataSource,UITableViewDelegate,JJCollectionCellDelegate>
@property (strong, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSMutableArray *checkIds;
@property (nonatomic,strong) id removingData;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UIButton *deleteAllBtn;
@property (weak, nonatomic) IBOutlet UIButton *barDeleteBtn;
- (IBAction)deleteAllBtnDidTap:(id)sender;
- (IBAction)barDeleteBtnDidTap:(id)sender;
@property (nonatomic,assign) BOOL isFirstAppear;
@property (nonatomic,strong) MJRefreshHeaderView *mjHeader;
@property (nonatomic,strong) MJRefreshFooterView *mjFooter;
@property (nonatomic,assign) NSInteger curPage;
- (IBAction)editBtnDidTap:(id)sender;
@end

@implementation JJMyColletionController

- (void)dealloc
{
    [self.mjHeader free];
    [self.mjFooter free];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tableView registerNib:[UINib nibWithNibName:@"JJCollectionCell" bundle:nil] forCellReuseIdentifier:@"JJCollectionCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.editBtn];
    
    self.curPage = 1;
    self.dataSource = [@[] mutableCopy];
    self.checkIds = [@[] mutableCopy];
    
    self.bottomBar.backgroundColor = RGB(73, 73, 75);
    [self.deleteAllBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.barDeleteBtn setTitleColor:RGB(235, 83, 83) forState:UIControlStateNormal];

    self.title = @"我的收藏";
    
    WS(ws);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    self.mjFooter = [MJRefreshFooterView footer];
    self.mjFooter.scrollView = self.tableView;
    self.mjFooter.beginRefreshingBlock = ^(MJRefreshBaseView *header){
        [ws loadNextPage];
    };
    self.mjHeader = [MJRefreshHeaderView header];
    self.mjHeader.scrollView = self.tableView;
    self.mjHeader.beginRefreshingBlock = ^(MJRefreshBaseView *view){
        [ws refresh];
    };
    
    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    if (!self.isFirstAppear) {
        
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        self.bottomBar.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 44);
        self.isFirstAppear = YES;
    }
}

- (void)refresh{
    
    WS(ws);
    [AFNManager getObject:@{@"pageIndex":@1,@"pageSize":@20}
                  apiName:@"MemberCenter/GetMyCollections"
                modelName:@"CollectionModel"
         requestSuccessed:^(id responseObject) {
             ws.curPage = 1;
             ws.dataSource = [responseObject mutableCopy];
             [ws.tableView reloadData];
             
             [ws.mjHeader endRefreshing];
         } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                [ws.mjHeader endRefreshing];
         }];
}

- (void)loadNextPage{

    WS(ws);
    [AFNManager getObject:@{@"pageIndex":@(self.curPage+1),@"pageSize":@20}
                  apiName:@"MemberCenter/GetMyCollections"
                modelName:@"CollectionModel"
         requestSuccessed:^(id responseObject) {
             ws.curPage++;
             [ws.dataSource addObjectsFromArray:responseObject];
             [ws.tableView reloadData];
             [ws.mjFooter endRefreshing];
             
         } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
             [ws.mjFooter endRefreshing];
          }];
}

#pragma mark - Table view data source
- (BOOL)isCheckedForId:(NSString *)dataId{
    BOOL isChecked = NO;
    for (NSString *str in self.checkIds) {
        if ([str isEqualToString:dataId]) {
            isChecked = YES;
            break;
        }
    }
    return isChecked;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    JJCollectionCell *cell = (id) [tableView dequeueReusableCellWithIdentifier:@"JJCollectionCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.tag = indexPath.row;
    CollectionModel *data = self.dataSource[indexPath.row];
    cell.nameLabel.text = data.memberName;
    [cell.avatarView.avatarView setImageWithURLString:data.headImage placeholderImage:nil];
    cell.avatarView.iconView.hidden = data.memberStatus!=MemberStatusOfficer;
    cell.timeLabel.text = [TimeUtils friendTimeStringForDate:data.travelDate];
    cell.contentLabel.text = data.title;
    cell.dataId = data.travelId;
    cell.isChecked = [self isCheckedForId:cell.dataId];
    [cell setIsEditing:[data.travelId isEqualToString:self.removingData] animation:NO completion:NULL];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (IBAction)editBtnDidTap:(id)sender {

    self.tableView.editing = !self.tableView.editing;
    [self.editBtn setTitle:self.tableView.editing?@"取消":@"编辑" forState:UIControlStateNormal];
    
    self.barDeleteBtn.enabled = NO;
    self.checkIds = [@[] mutableCopy];
    [UIView animateWithDuration:0.3 animations:^{
        if (self.tableView.editing) {
            
            self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44);
            self.bottomBar.frame = CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44);
        }else{
            self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
            self.bottomBar.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 44);
        }
    }];
}




- (void)endingEditAtIndexPath:(NSIndexPath *)indexPath{
    JJCollectionCell *lastCell = (id)[self.tableView cellForRowAtIndexPath:indexPath];
    lastCell.isEditing = NO;
    self.removingData = nil;
}

- (void)collectionCellDidCheck:(JJCollectionCell *)cell{

    self.barDeleteBtn.enabled = YES;
    [self.checkIds addObject:cell.dataId];
}

- (void)collectionCellDidUnCheck:(JJCollectionCell *)cell{

    
    NSMutableArray *tempIds = [@[] mutableCopy];
    for (NSString *str in self.checkIds) {
        if (![str isEqualToString:cell.dataId]) {
            [tempIds addObject:str];
        }
    }
    self.checkIds = tempIds;
    if (self.checkIds.count==0) {
        self.barDeleteBtn.enabled = NO;
    }
}

- (void)collectionCellWilBeginEdit:(JJCollectionCell *)cell{
   
    if (self.removingData) {
         [self endingEditAtIndexPath:[NSIndexPath indexPathForRow:[self.dataSource indexOfObject:self.removingData] inSection:0]];
    }
    self.removingData = cell.dataId;
}

- (void)collectionCellDidEndEdit:(JJCollectionCell *)cell{

    self.removingData = nil;
}

- (void)collectionCellDidTap:(JJCollectionCell *)cell{
    
    if (self.removingData) {
        //点中其他Cell，将正在编辑的Cell收拢
        [self endingEditAtIndexPath:[NSIndexPath indexPathForRow:[self.dataSource indexOfObject:self.removingData] inSection:0]];
    }else{
    
        //查看收藏
        
        CollectionModel *data = self.dataSource[cell.tag];
        JJDetailViewController *detail = [[JJDetailViewController alloc] initWithNibName:@"JJDetailViewController" bundle:nil];
        detail.title = data.title;
        detail.travelId = data.travelId;
        detail.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (void)collectionCellDidSwipToRight:(JJCollectionCell *)cell{

}

- (void)collectionCellNeedRemove:(JJCollectionCell *)cell{

    [self deleteCollections:@[cell.dataId]];
    self.removingData = nil;
}
- (IBAction)deleteAllBtnDidTap:(id)sender {
 
    self.checkIds = [@[] mutableCopy];
    for (CollectionModel *model in self.dataSource) {
        [self.checkIds addObject:model.travelId];
    }
    [self deleteCollections:self.checkIds];
    [self editBtnDidTap:nil];
}

- (IBAction)barDeleteBtnDidTap:(id)sender {
    
    [self deleteCollections:self.checkIds];
    [self editBtnDidTap:nil];
}

- (CollectionModel *)dataOfDataId:(NSString *)dataId{
    
    CollectionModel *rmodel = nil;
    for (CollectionModel *model in self.dataSource) {
        if([dataId isEqualToString:model.travelId]){
            rmodel = model;
            break;
        }
    }
    return rmodel;
}

- (void)deleteCollections:(NSArray *)datas{
    
    
    NSMutableArray *modelDatas = [@[] mutableCopy];
    NSMutableArray *indexPaths = [@[] mutableCopy];
    NSString *collectionIds = nil;
    if (datas.count) {
        for (NSString *dataId in datas) {
    
            id model = [self dataOfDataId:dataId];
            if (model) {
                [modelDatas addObject:model];
                NSInteger index = [self.dataSource indexOfObject:model];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [indexPaths addObject:indexPath];
                
                if (nil==collectionIds) {
                    collectionIds = dataId;
                }
                else{
                    collectionIds = [NSString stringWithFormat:@"%@,%@",collectionIds,dataId];
                }
            }
        }
    }
    
    if (collectionIds) {
        [self showHUDLoadingWithString:@"删除中"];
        WS(ws);
        [AFNManager postObject:@{@"travelId":collectionIds}
                       apiName:@"MemberCenter/MultDeleteCollection"
                     modelName:@"BaseModel"
              requestSuccessed:^(id responseObject) {
                  [ws.dataSource removeObjectsInArray:modelDatas];
                  [ws.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                  [ws hideHUDLoading];
              } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                  
                  [ws showResultThenHide:errorMessage?:@"删除失败"];
              }];
    }
}
@end
