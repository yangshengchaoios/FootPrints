//
//  JJFriendsViewController.m
//  Footprints
//
//  Created by Jinjin on 14/11/20.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJFriendsViewController.h"
#import "JJFriendsCell.h"
#import "MJRefresh.h"
#import "pinyin.h"
#import "BATableView.h"
#import "JJMyAddFriendsController.h"
#import "JJLoveMyController.h"
#import "JJAddFriendsController.h"
#import "JJAdressFriendsController.h"
#import "JJUserCenterViewController.h"
#import "JJGroupViewController.h"

@interface JJFriendsViewController ()<UISearchBarDelegate,UISearchDisplayDelegate,BATableViewDelegate>
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchBarDisplayController;
@property (strong,nonatomic) BATableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSourceArr;
@property (nonatomic,strong) NSMutableArray *resultArr;
@property (nonatomic,assign) NSInteger curPage;
@property (nonatomic,assign) NSInteger newFriendsCount;
@property (nonatomic,strong) MJRefreshHeaderView *mjHeader;
@property (nonatomic,strong) MJRefreshFooterView *mjFooter;

@property (strong, nonatomic) IBOutlet UIButton *addBtn;
@property (nonatomic,strong) NSMutableArray *groupedFriendsData;
@property (nonatomic,strong) NSMutableArray *arrayOfCharacters;
- (IBAction)addBtnDidTap:(id)sender;
@end

@implementation JJFriendsViewController

- (void)dealloc
{
    [self.mjFooter free];
    [self.mjHeader free];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self getFriendsListAtPage:1];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我的好友";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.addBtn];
    
    self.tableView = [[BATableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [self.view addSubview:self.tableView];
    self.tableView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.tableView.tableHeaderView = self.searchBar;
    [self.tableView.tableView registerNib:[UINib nibWithNibName:@"JJFriendsCell" bundle:nil] forCellReuseIdentifier:@"JJFriendsCell"];
    self.tableView.backgroundColor = [UIColor clearColor];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self initMysearchBarAndMysearchDisPlay];
    
    WeakSelfType blockSelf = self;
    self.mjFooter = [MJRefreshFooterView footer];
    self.mjFooter.scrollView = self.tableView.tableView;
    self.mjFooter.beginRefreshingBlock = ^(MJRefreshBaseView *view){
        if (view.hidden) {
            [view endRefreshing];
            return ;
        }
        
        [blockSelf getFriendsListAtPage:blockSelf.curPage+1];
    };
    self.mjFooter.hidden = YES;
    
    self.mjHeader = [MJRefreshHeaderView header];
    self.mjHeader.scrollView = self.tableView.tableView;
    self.mjHeader.beginRefreshingBlock = ^(MJRefreshBaseView *view){
        [blockSelf getFriendsListAtPage:1];
    };
    [self getFriendsListAtPage:1];
}

-(void)initMysearchBarAndMysearchDisPlay
{
    self.resultArr = [@[] mutableCopy];
    
    
    self.navigationController.view.backgroundColor = kDefaultNaviBarColor;
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.barStyle = UIBarStyleDefault;
    [self.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.searchBar sizeToFit];
    self.tableView.tableView.tableHeaderView = self.searchBar;
    
    self.searchBarDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchBarDisplayController.delegate = self;
    self.searchBarDisplayController.searchResultsDataSource = self;
    self.searchBarDisplayController.searchResultsDelegate = self;
    [self.searchBarDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"JJFriendsCell" bundle:nil] forCellReuseIdentifier:@"JJFriendsCell"];
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

- (IBAction)addBtnDidTap:(id)sender {
    
    JJAddFriendsController *addFriends = [[JJAddFriendsController alloc] initWithNibName:@"JJAddFriendsController" bundle:nil];
    addFriends.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addFriends animated:YES];
}


#pragma mark UISearchBar and UISearchDisplayController Delegate Methods

//searchBar开始编辑时改变取消按钮的文字
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = YES;
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


#define judgeletter_classic(ch) (((ch)>='A'&&ch<='Z')||((ch)>='a'&&(ch)<='z'))
- (void)didGetNewFriendDatas:(NSArray *)datas atIndex:(NSInteger)index{
    
    self.curPage = index;
    if (index==1) {
        self.dataSourceArr = [datas mutableCopy];
    }else{
        [self.dataSourceArr addObjectsFromArray:datas];
    }
    //将好友分组
    NSMutableDictionary *tempDict = [@{} mutableCopy];
    for (ContactMemberModel *model in self.dataSourceArr) {
        
        NSString *groupName = @"#";
        unichar firstChar = model.nickName.length?[model.nickName characterAtIndex:0]:[@"#" characterAtIndex:0];
        if (judgeletter_classic(firstChar)) {
            //是字母
            groupName = [[NSString stringWithFormat:@"%c",firstChar] uppercaseString];
        }else{
            //不是字母
            char firstLetter = pinyinFirstLetter(firstChar);
            groupName = [[NSString stringWithFormat:@"%c",firstLetter] uppercaseString];
            groupName=groupName?:@"#";
        }
        NSMutableArray *tempDatas = tempDict[groupName];
        if (nil==tempDatas) {
            tempDatas = [@[] mutableCopy];
        }
        [tempDatas addObject:model];
        [tempDict setObject:tempDatas forKey:groupName];
    }
    //合并数据
    self.arrayOfCharacters = [[[tempDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }] mutableCopy];
    if (self.arrayOfCharacters.count>1 && [self.arrayOfCharacters[0] isEqualToString:@"#"]) {
        id obj = self.arrayOfCharacters[0];
        [self.arrayOfCharacters removeObjectAtIndex:0];
        [self.arrayOfCharacters addObject:obj];
    }

    self.groupedFriendsData = [@[] mutableCopy];
    for (NSString *key in self.arrayOfCharacters) {
        NSArray *data = tempDict[key];
        //friends
        //groupName
        if (datas && key) {
            [self.groupedFriendsData addObject:@{@"friends":data,@"groupName":key}];
        }
    }
    self.mjFooter.hidden = datas.count>0;
    [self.tableView reloadData];
}

- (void)getFriendsListAtPage:(NSInteger)index{
    
    if (index==1) {
        WS(ws);
        //获取新粉丝数量
        [AFNManager getObject:nil
                      apiName:@"MemberCenter/GetNewestLoveMeCount"
                    modelName:@"BaseModel" requestSuccessed:^(id responseObject) {
                        ws.newFriendsCount = [responseObject integerValue];
                        [ws.tableView reloadData];
                    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                   
                    }];
    }
    
    WeakSelfType blockSelf = self;
    [AFNManager getObject:@{@"relationType":@0,@"pageIndex":@(index),@"pageSize":@(1000)}
                  apiName:kResPathGetMyFriends
                modelName:@"ContactMemberModel" requestSuccessed:^(id responseObject) {
                    
                    if ([responseObject isKindOfClass:[NSArray class]]) {
                        NSArray *array = responseObject;
                        [blockSelf didGetNewFriendDatas:array atIndex:index];
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

#pragma mark - UITableViewDataSource
- (NSArray *) sectionIndexTitlesForABELTableView:(BATableView *)tableView {
 
    return self.arrayOfCharacters;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section==0 || tableView==self.searchBarDisplayController.searchResultsTableView)return @"";
    NSDictionary *dataDict = self.groupedFriendsData[section-1];
    return dataDict[@"groupName"];
}

- (NSInteger)sectionIndexOffsetForABELTableView:(BATableView *)tableView{
    
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (tableView==self.searchBarDisplayController.searchResultsTableView) {
        return 1;
    }
    
    return self.groupedFriendsData.count+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    if (tableView==self.searchBarDisplayController.searchResultsTableView) {
        return self.resultArr.count;
    }
    
    NSInteger count = 0;
    if (section==0) {
        count = 4;
    }else{
        NSDictionary *groupFriendDict = self.groupedFriendsData[section-1];
        count = [groupFriendDict[@"friends"] count];
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    
    if (tableView==self.searchBarDisplayController.searchResultsTableView) {
        return 0;
    }
    return section==0?0:20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JJFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JJFriendsCell"];
    cell.nameLabel.font = [UIFont systemFontOfSize:13];
    cell.nameLabel.frame = CGRectMake(49, 0, 200, 22);
    
    [cell.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@4);
        make.left.mas_equalTo(@50);
        make.right.mas_equalTo(cell.mas_right).with.offset(-14);
        make.height.mas_equalTo(@20);
    }];
    
    NSInteger count = 0;
    if (tableView==self.searchBarDisplayController.searchResultsTableView) {
        ContactMemberModel *model = self.resultArr[indexPath.row];
        [cell.avatarView bindUserData:model];
        cell.summryLabel.hidden = NO;
        cell.summryLabel.text = model.signature;
        [cell setCount:0];
        cell.nameLabel.text = model.nickName;
        count = self.resultArr.count;
    }else{
        if (indexPath.section==0) {
            cell.nameLabel.font = [UIFont systemFontOfSize:17];
            cell.nameLabel.frame = CGRectMake(49, 0, 200, 45);
            [cell.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(@0);
                make.left.mas_equalTo(@50);
                make.right.mas_equalTo(cell.mas_right).with.offset(-14);
                make.height.mas_equalTo(@45);
            }];
            cell.summryLabel.hidden = YES;
            [cell setCount:0];
            cell.avatarView.iconView.hidden = YES;
            switch (indexPath.row) {
                case 0:
                    [cell setCount:self.newFriendsCount];
                    cell.nameLabel.text = @"我的粉丝";
                    cell.avatarView.avatarView.image = [UIImage imageNamed:@"icon_fans.png"];
                    break;
                case 1:
                    cell.nameLabel.text = @"我的关注";
                    cell.avatarView.avatarView.image = [UIImage imageNamed:@"icon_attention.png"];
                    break;
                case 2:
                    cell.nameLabel.text = @"通讯录好友";
                    cell.avatarView.avatarView.image = [UIImage imageNamed:@"icon_friends.png"];
                    break;
                case 3:
                    cell.nameLabel.text = @"标签/组";
                    cell.avatarView.avatarView.image = [UIImage imageNamed:@"icon_label.png"];
                    break;
                default:
                    break;
            }
            count = 4;
        }else{
            NSDictionary *dataDict = self.groupedFriendsData[indexPath.section-1];
            ContactMemberModel *model = [dataDict[@"friends"] objectAtIndex:indexPath.row];
            [cell.avatarView bindUserData:model];
            cell.summryLabel.hidden = NO;
            cell.summryLabel.text = model.signature;
            [cell setCount:0];
            cell.nameLabel.text = model.nickName;
            count = [dataDict[@"friends"] count];
        }
    }
    
    [(JJFriendsCell *)cell showTopLine:NO withInset:UIEdgeInsetsZero];
    if (indexPath.row==(count-1)) {
        [(JJFriendsCell *)cell showBottomLine:YES withInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }else{
        [(JJFriendsCell *)cell showBottomLine:YES withInset:UIEdgeInsetsMake(0, 9, 0, 0)];
    }
    
    if (indexPath.row==0) {
        [(JJFriendsCell *)cell showTopLine:YES withInset:UIEdgeInsetsZero];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView==self.searchBarDisplayController.searchResultsTableView) {
        ContactMemberModel *model = self.resultArr[indexPath.row];
           [self showUser:model];
    }else{
        if (indexPath.section==0) {
            switch (indexPath.row) {
                case 0:
                    //我的粉丝
                    [self showLoveMeUser];
                    break;
                case 1:
                    //我的关注
                    [self showMyAddUser];
                    break;
                case 2:
                    //通讯录好友
                    [self showAddressFriends];
                    break;
                case 3:
                    //标签/组
                    [self showGroup];
                    break;
                default:
                    break;
            }
            
            
        }else{
            NSDictionary *dataDict = self.groupedFriendsData[indexPath.section-1];
            ContactMemberModel *model = [dataDict[@"friends"] objectAtIndex:indexPath.row];
            [self showUser:model];
        }
    }
}

- (void)showAddressFriends{
    JJAdressFriendsController *friends = [[JJAdressFriendsController alloc] initWithNibName:@"JJAdressFriendsController" bundle:nil];
    friends.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:friends animated:YES];
}

- (void)showMyAddUser{
    JJMyAddFriendsController *myAdd = [[JJMyAddFriendsController alloc] initWithNibName:@"JJMyAddFriendsController" bundle:nil];
    myAdd.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myAdd animated:YES];
}

- (void)showLoveMeUser{
    
    JJLoveMyController *loveMe = [[JJLoveMyController alloc] initWithNibName:@"JJLoveMyController" bundle:nil];
    loveMe.title = @"我的粉丝";
    loveMe.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:loveMe animated:YES];
}

- (void)showGroup{
    JJGroupViewController *groupController = [[JJGroupViewController alloc] initWithNibName:@"JJGroupViewController" bundle:nil];
    groupController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:groupController animated:YES];
}

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

@end
