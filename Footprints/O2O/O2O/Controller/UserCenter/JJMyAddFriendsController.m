//
//  JJMyAddFriendsController.m
//  Footprints
//
//  Created by Jinjin on 14/11/20.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJMyAddFriendsController.h"
#import "MJRefresh.h"
#import "JJAddFriendsCell.h"
#import "JJUserCenterViewController.h"

@interface JJMyAddFriendsController ()<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchBarDisplayController;
@property (strong,nonatomic) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSourceArr;
@property (nonatomic,strong) NSMutableArray *resultArr;
@property (nonatomic,assign) NSInteger curPage;
@property (nonatomic,strong) MJRefreshHeaderView *mjHeader;
@property (nonatomic,strong) MJRefreshFooterView *mjFooter;

@end

@implementation JJMyAddFriendsController
- (void)dealloc
{
    [self.mjFooter free];
    [self.mjHeader free];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我的关注";
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.tableHeaderView = self.searchBar;
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64);
    [self.tableView registerNib:[UINib nibWithNibName:@"JJAddFriendsCell" bundle:nil] forCellReuseIdentifier:@"JJAddFriendsCell"];
    
    [self initMysearchBarAndMysearchDisPlay];
    
    WeakSelfType blockSelf = self;
    self.mjFooter = [MJRefreshFooterView footer];
    self.mjFooter.scrollView = self.tableView;
    self.mjFooter.beginRefreshingBlock = ^(MJRefreshBaseView *view){
        if (view.hidden) {
            [view endRefreshing];
            return ;
        }
        [blockSelf getFriendsListAtPage:blockSelf.curPage+1];
    };
    self.mjFooter.hidden = YES;
    
    self.mjHeader = [MJRefreshHeaderView header];
    self.mjHeader.scrollView = self.tableView;
    self.mjHeader.beginRefreshingBlock = ^(MJRefreshBaseView *view){
        [blockSelf getFriendsListAtPage:1];
    };
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self getFriendsListAtPage:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initMysearchBarAndMysearchDisPlay
{
    self.resultArr = [@[] mutableCopy];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    //设置选项
    [self.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.searchBar sizeToFit];
    //加入列表的header里面
    self.tableView.tableHeaderView = self.searchBar;
    
    self.searchBarDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchBarDisplayController.delegate = self;
    self.searchBarDisplayController.searchResultsDataSource = self;
    self.searchBarDisplayController.searchResultsDelegate = self;
    [self.searchBarDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"JJAddFriendsCell" bundle:nil] forCellReuseIdentifier:@"JJAddFriendsCell"];
}

- (void)getFriendsListAtPage:(NSInteger)index{
    
    WeakSelfType blockSelf = self;
    [AFNManager getObject:@{@"relationType":@0,@"pageIndex":@(index),@"pageSize":@(1000)}
                  apiName:kResPathGetMyLoveMember
                modelName:@"ContactMemberModel" requestSuccessed:^(id responseObject) {
                    
                    if ([responseObject isKindOfClass:[NSArray class]]) {
                        NSArray *array = responseObject;
                        blockSelf.curPage = index;
                        if (index==1) {
                            blockSelf.dataSourceArr = [array mutableCopy];
                        }else{
                            [blockSelf.dataSourceArr addObjectsFromArray:array];
                        }
                        [blockSelf.tableView reloadData];
                    }
                    else{
                        [blockSelf showResultThenHide:@"获取失败"];
                    }
                    [blockSelf.mjFooter endRefreshing];
                    [blockSelf.mjHeader endRefreshing];
                } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    NSLog(@"%@",errorMessage);
                    [blockSelf showResultThenHide:errorMessage?:@"获取失败"];
                    [blockSelf.mjHeader endRefreshing];
                    [blockSelf.mjFooter endRefreshing];
                }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)showUser:(ContactMemberModel *)model{
    if ([[UserManager loginUserId] isEqualToString:model.memberId]) {
        return;
    }
    JJUserCenterViewController *user = [[JJUserCenterViewController alloc] initWithNibName:@"JJUserCenterViewController" bundle:nil];
    user.isMy = NO;
    user.model = model;
    [user refresh];
    user.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:user animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"全部关注";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    if (tableView==self.searchBarDisplayController.searchResultsTableView) {
        return self.resultArr.count;
    }
    return self.dataSourceArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    if (tableView==self.searchBarDisplayController.searchResultsTableView) {
        return 0;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JJAddFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JJAddFriendsCell"];
    ContactMemberModel *model = nil;
    if (tableView==self.searchBarDisplayController.searchResultsTableView) {
        model = self.resultArr[indexPath.row];
        
    }else{
        model = self.dataSourceArr[indexPath.row];
    }
    [cell.avatarView bindUserData:model];
    cell.summryLabel.hidden = NO;
    cell.summryLabel.text = model.signature;
    cell.nameLabel.text = model.nickName;
    cell.cellStyle = model.isFriend?AddFriendsCellStyleBothAdd:AddFriendsCellStyleSingleAdd;
    
    if ([cell isKindOfClass:[JJAddFriendsCell class]]) {
        
        [(JJAddFriendsCell *)cell showTopLine:NO withInset:UIEdgeInsetsZero];
        if (indexPath.row==(self.dataSourceArr.count-1)) {
            [(JJAddFriendsCell *)cell showBottomLine:YES withInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        }else{
            [(JJAddFriendsCell *)cell showBottomLine:YES withInset:UIEdgeInsetsMake(0, 9, 0, 0)];
        }
        if (indexPath.row==0) {
            [(JJAddFriendsCell *)cell showTopLine:YES withInset:UIEdgeInsetsZero];
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ContactMemberModel *model = nil;
    if (tableView==self.searchBarDisplayController.searchResultsTableView) {
        model = self.resultArr[indexPath.row];
        
    }else{
        model = self.dataSourceArr[indexPath.row];
    }
    [self showUser:model];
}
#pragma mark UISearchBar and UISearchDisplayController Delegate Methods

//searchBar开始编辑时改变取消按钮的文字
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = YES;
//    self.searchBar.backgroundColor = RGBA(249,249,249,1);
//    self.searchBar.backgroundImage = [self imageWithColor:[UIColor clearColor] size:self.searchBar.bounds.size];
    
    //    NSArray *subViews;
    //
    //    if (is_IOS_7) {
    //        subViews = [(mySearchBar.subviews[0]) subviews];
    //    }
    //    else {
    //        subViews = mySearchBar.subviews;
    //    }
    //
    //    for (id view in subViews) {
    //        if ([view isKindOfClass:[UIButton class]]) {
    //            UIButton* cancelbutton = (UIButton* )view;
    //            [cancelbutton setTitle:@"取消" forState:UIControlStateNormal];
    //            break;
    //        }
    //    }
}

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    //準備搜尋前，把上面調整的TableView調整回全屏幕的狀態
    [UIView animateWithDuration:1.0 animations:^{
        _tableView.frame = CGRectMake(0, 20, 320, SCREEN_HEIGHT-20);
    }];
    
    return YES;
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    //搜尋結束後，恢復原狀
    [UIView animateWithDuration:1.0 animations:^{
        _tableView.frame = CGRectMake(0, 0, 320, SCREEN_HEIGHT-64);
    }];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller

shouldReloadTableForSearchString:(NSString *)searchString

{
    //一旦SearchBar輸入內容有變化，則執行這個方法，詢問要不要重裝searchResultTableView的數據
    
    // Return YES to cause the search result table view to be reloaded.
    
    [self filterContentForSearchText:searchString
                               scope:[self.searchBar scopeButtonTitles][self.searchBar.selectedScopeButtonIndex]];
    
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller

shouldReloadTableForSearchScope:(NSInteger)searchOption

{
    //如果设置了选项，当Scope Button选项有變化的时候，則執行這個方法，詢問要不要重裝searchResultTableView的數據
    
    // Return YES to cause the search result table view to be reloaded.
    
    [self filterContentForSearchText:self.searchBar.text
                               scope:self.searchBar.scopeButtonTitles[searchOption]];
    
    return YES;
}

//源字符串内容是否包含或等于要搜索的字符串内容
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSMutableArray *tempResults = [NSMutableArray array];
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    
    for (int i = 0; i < self.dataSourceArr.count; i++) {
        ContactMemberModel *model = self.dataSourceArr[i];
        NSString *storeString = model.nickName;
        NSRange storeRange = NSMakeRange(0, storeString.length);
        NSRange foundRange = [storeString rangeOfString:searchText options:searchOptions range:storeRange];
        if (foundRange.length) {
            [tempResults addObject:model];
        }
    }
    [self.resultArr removeAllObjects];
    [self.resultArr addObjectsFromArray:tempResults];
}


@end
