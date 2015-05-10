//
//  JJMyAddFriendsController.m
//  Footprints
//
//  Created by Jinjin on 14/11/20.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJAddFriendsController.h"
#import "MJRefresh.h"
#import "JJAddFriendsCell.h"
#import "JJNoFriendsCell.h"
#import "JJFriendsCell.h"
#import "JJRecommendFriendsController.h"
#import "StringUtils.h"
#import "JJUserCenterViewController.h"

@interface JJAddFriendsController ()<UISearchBarDelegate,UISearchDisplayDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchBarDisplayController;
@property (strong,nonatomic) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *historyArr;
@property (nonatomic,strong) NSMutableArray *fiendsRecommendArr;
@property (nonatomic,strong) NSMutableArray *systemRecommendArr;
@property (nonatomic,strong) NSMutableArray *resultArr;
@property (nonatomic,strong) MJRefreshHeaderView *mjHeader;

@end

@implementation JJAddFriendsController
- (void)dealloc
{
    [self.mjHeader free];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self getRecommedFriends];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"添加好友";
    self.historyArr = [[[NSUserDefaults standardUserDefaults] objectForKey:@"JJHistorySearchArr"] mutableCopy];
    self.fiendsRecommendArr = [@[] mutableCopy];
    self.systemRecommendArr = [@[] mutableCopy];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = self.searchBar;
    [self.tableView registerNib:[UINib nibWithNibName:@"JJAddFriendsCell" bundle:nil] forCellReuseIdentifier:@"JJAddFriendsCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"JJNoFriendsCell" bundle:nil] forCellReuseIdentifier:@"JJNoFriendsCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"JJFriendsCell" bundle:nil] forCellReuseIdentifier:@"JJFriendsCell"];
    
    [self initMysearchBarAndMysearchDisPlay];
    
    WeakSelfType blockSelf = self;
    self.mjHeader = [MJRefreshHeaderView header];
    self.mjHeader.scrollView = self.tableView;
    self.mjHeader.beginRefreshingBlock = ^(MJRefreshBaseView *view){
        [blockSelf getRecommedFriends];
    };
    [self getRecommedFriends];
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
    //    [self.searchBar setScopeButtonTitles:[NSArray arrayWithObjects:@"First",@"Last",nil]];
    [self.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.searchBar sizeToFit];
    //    self.searchBar.backgroundColor = RGBA(249,249,249,1);
    //    self.searchBar.backgroundImage = [self imageWithColor:[UIColor clearColor] size:self.searchBar.bounds.size];
    //加入列表的header里面
    self.tableView.tableHeaderView = self.searchBar;
    
    self.searchBarDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchBarDisplayController.delegate = self;
    self.searchBarDisplayController.searchResultsDataSource = self;
    self.searchBarDisplayController.searchResultsDelegate = self;
    [self.searchBarDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"JJAddFriendsCell" bundle:nil] forCellReuseIdentifier:@"JJAddFriendsCell"];
    
    [self.searchBarDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"JJFriendsCell" bundle:nil] forCellReuseIdentifier:@"JJFriendsCell"];
}

- (void)getRecommedFriends{
    
    WeakSelfType blockSelf = self;
    [AFNManager getObject:@{@"recommendNumber":@4}
                  apiName:kResPathGetRecommends
                modelName:@"FriendRecommeds" requestSuccessed:^(id responseObject) {
                    
                    if ([responseObject isKindOfClass:[FriendRecommeds class]]) {
                        FriendRecommeds *recommends = responseObject;
                        blockSelf.fiendsRecommendArr = [recommends.friendsRecommendDatas mutableCopy];
                        blockSelf.systemRecommendArr = [recommends.systemRecommendDatas mutableCopy];
                        [blockSelf.tableView reloadData];
                    }
                    else{
                        [blockSelf showResultThenHide:@"获取失败"];
                    }
                    [blockSelf.mjHeader endRefreshing];
                } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    NSLog(@"%@",errorMessage);
                    [blockSelf showResultThenHide:errorMessage?:@"获取失败"];
                    [blockSelf.mjHeader endRefreshing];
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger count = 0;
    if (tableView==self.searchBarDisplayController.searchResultsTableView) {
        count=1;
    }else{
        count=1;
        if (self.systemRecommendArr.count) ++count;
        if (self.fiendsRecommendArr.count) ++count;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger count = 0;
    if (tableView==self.searchBarDisplayController.searchResultsTableView) {
        count = self.resultArr.count;
    }else{
        
        if (self.fiendsRecommendArr.count) {
            if (section==0) count=self.fiendsRecommendArr.count>3?4:self.fiendsRecommendArr.count;
            else if(section==1) count=1;
            else {
                count= (self.systemRecommendArr.count>3)?4:self.systemRecommendArr.count;
            }
        }else{
            if (section==0) count=1;
            else count=self.systemRecommendArr.count>3?4:self.systemRecommendArr.count;
        }
    }
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    NSString *title = @"";
    if (tableView==self.searchBarDisplayController.searchResultsTableView) {
       
    }else{
        if (self.fiendsRecommendArr.count) {
            if (section==0) title=@"好友向你推荐";
            else if(section==1) title=@" ";
            else title=@"特别推荐";
        }else{
            if (section==0) title=@" ";
            else title=@"特别推荐";
        }
    }
    return title;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    CGFloat height = 0;
    if (tableView==self.searchBarDisplayController.searchResultsTableView) {
        height = 0;
    }else{
        
        if (self.fiendsRecommendArr.count) {
            if (section==0) height=44;
            else if(section==1) height = 17;
            else height=44;
        }else{
            if (section==0) height = 17;
            else height=44;
        }
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    ContactMemberModel *model = nil;
    
    if (tableView==self.searchBarDisplayController.searchResultsTableView) {
        //搜索结果
        cell = [tableView dequeueReusableCellWithIdentifier:@"JJAddFriendsCell"];
        model = self.resultArr[indexPath.row];
        
        [(JJAddFriendsCell *)cell showTopLine:NO withInset:UIEdgeInsetsZero];
        if (indexPath.row==(self.resultArr.count-1)) {
            [(JJAddFriendsCell *)cell showBottomLine:YES withInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        }else{
            [(JJAddFriendsCell *)cell showBottomLine:YES withInset:UIEdgeInsetsMake(0, 9, 0, 0)];
        }
        
        if (indexPath.row==0) {
            [(JJAddFriendsCell *)cell showTopLine:YES withInset:UIEdgeInsetsZero];
        }
        
    }else{
        if(self.fiendsRecommendArr.count) {
            if (indexPath.section==0) {
                if (indexPath.row!=3) {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"JJAddFriendsCell"];
                    model = self.fiendsRecommendArr[indexPath.row];
                    
                    [(JJAddFriendsCell *)cell showTopLine:NO withInset:UIEdgeInsetsZero];
                    if (indexPath.row==(self.fiendsRecommendArr.count-1)) {
                        [(JJAddFriendsCell *)cell showBottomLine:YES withInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                    }else{
                        [(JJAddFriendsCell *)cell showBottomLine:YES withInset:UIEdgeInsetsMake(0, 9, 0, 0)];
                    }
                    
                    if (indexPath.row==0) {
                        [(JJAddFriendsCell *)cell showTopLine:YES withInset:UIEdgeInsetsZero];
                    }
                }else{
                    //查看更多好友推荐
                    JJFriendsCell *fCell = [tableView dequeueReusableCellWithIdentifier:@"JJFriendsCell"];
                    fCell.avatarView.hidden = YES;
                    fCell.summryLabel.hidden = YES;
                    [fCell setCount:0];
                    fCell.nameLabel.text = @"查看更多";
                    cell = fCell;
                    fCell.nameLabel.font = [UIFont systemFontOfSize:17];
                    fCell.nameLabel.textColor = RGB(99, 99, 99);
                    fCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    [fCell.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(@0);
                        make.left.mas_equalTo(@9);
                        make.right.mas_equalTo(fCell.mas_right).with.offset(-14);
                        make.height.mas_equalTo(@44);
                    }];
                    
                    [(JJFriendsCell *)cell showTopLine:NO withInset:UIEdgeInsetsZero];
                    [(JJFriendsCell *)cell showBottomLine:YES withInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                }
            }
            else if(indexPath.section==1){
                JJFriendsCell *fCell = [tableView dequeueReusableCellWithIdentifier:@"JJFriendsCell"];
                fCell.avatarView.hidden = NO;
                fCell.avatarView.iconView.hidden = YES;
                fCell.avatarView.avatarView.image = [UIImage imageNamed:@"icon_surrounding_friends.png"];
                fCell.summryLabel.hidden = YES;
                [fCell setCount:0];
                fCell.nameLabel.text = @"周边好友";
                fCell.nameLabel.font = [UIFont systemFontOfSize:17];
                fCell.nameLabel.textColor = RGB(99, 99, 99);
                fCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [fCell.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(@0);
                    make.left.mas_equalTo(@50);
                    make.right.mas_equalTo(fCell.mas_right).with.offset(-14);
                    make.height.mas_equalTo(@44);
                }];
                cell = fCell;
                
                [(JJFriendsCell *)cell showTopLine:YES withInset:UIEdgeInsetsZero];
                [(JJFriendsCell *)cell showBottomLine:YES withInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            }
            else{
                if (indexPath.row!=3) {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"JJAddFriendsCell"];
                    model = self.systemRecommendArr[indexPath.row];
                    
                    [(JJAddFriendsCell *)cell showTopLine:NO withInset:UIEdgeInsetsZero];
                    if (indexPath.row==(self.systemRecommendArr.count-1)) {
                        [(JJAddFriendsCell *)cell showBottomLine:YES withInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                    }else{
                        [(JJAddFriendsCell *)cell showBottomLine:YES withInset:UIEdgeInsetsMake(0, 9, 0, 0)];
                    }
                    
                    if (indexPath.row==0) {
                        [(JJAddFriendsCell *)cell showTopLine:YES withInset:UIEdgeInsetsZero];
                    }
                }else{
                    //查看更多系统推荐
                    JJFriendsCell *fCell = [tableView dequeueReusableCellWithIdentifier:@"JJFriendsCell"];
                    fCell.avatarView.hidden = YES;
                    fCell.summryLabel.hidden = YES;
                    [fCell setCount:0];
                    fCell.nameLabel.text = @"查看更多";
                    cell = fCell;
                    fCell.nameLabel.font = [UIFont systemFontOfSize:17];
                    fCell.nameLabel.textColor = RGB(99, 99, 99);
                    fCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    [fCell.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(@0);
                        make.left.mas_equalTo(@9);
                        make.right.mas_equalTo(fCell.mas_right).with.offset(-14);
                        make.height.mas_equalTo(@44);
                    }];
                    
                    [(JJFriendsCell *)cell showTopLine:NO withInset:UIEdgeInsetsZero];
                    [(JJFriendsCell *)cell showBottomLine:YES withInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                }
            }
        }else{
            if (indexPath.section==0){
                JJFriendsCell *fCell = [tableView dequeueReusableCellWithIdentifier:@"JJFriendsCell"];
                fCell.avatarView.hidden = NO;
                fCell.summryLabel.hidden = YES;
                [fCell setCount:0];
                fCell.nameLabel.text = @"周边好友";
                fCell.avatarView.avatarView.hidden = YES;
                fCell.avatarView.avatarView.image = [UIImage imageNamed:@"icon_surrounding_friends.png"];
                cell = fCell;
                fCell.nameLabel.font = [UIFont systemFontOfSize:17];
                fCell.nameLabel.textColor = RGB(99, 99, 99);
                fCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [fCell.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(@0);
                    make.left.mas_equalTo(@50);
                    make.right.mas_equalTo(fCell.mas_right).with.offset(-14);
                    make.height.mas_equalTo(@44);
                }];
                [(JJFriendsCell *)cell showTopLine:YES withInset:UIEdgeInsetsZero];
                [(JJFriendsCell *)cell showBottomLine:YES withInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            }
            else {
                if (indexPath.row!=3) {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"JJAddFriendsCell"];
                    model = self.systemRecommendArr[indexPath.row];
                    
                    [(JJAddFriendsCell *)cell showTopLine:NO withInset:UIEdgeInsetsZero];
                    if (indexPath.row==(self.systemRecommendArr.count-1)) {
                        [(JJAddFriendsCell *)cell showBottomLine:YES withInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                    }else{
                        [(JJAddFriendsCell *)cell showBottomLine:YES withInset:UIEdgeInsetsMake(0, 9, 0, 0)];
                    }
                    
                    if (indexPath.row==0) {
                        [(JJAddFriendsCell *)cell showTopLine:YES withInset:UIEdgeInsetsZero];
                    }
                }else{
                    //查看更多系统推荐
                    JJFriendsCell *fCell = [tableView dequeueReusableCellWithIdentifier:@"JJFriendsCell"];
                    fCell.avatarView.hidden = YES;
                    fCell.summryLabel.hidden = YES;
                    [fCell setCount:0];
                    fCell.nameLabel.text = @"查看更多";
                    cell = fCell;
                    fCell.nameLabel.font = [UIFont systemFontOfSize:17];
                    fCell.nameLabel.textColor = RGB(99, 99, 99);
                    fCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    [fCell.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                        make.top.mas_equalTo(@0);
                        make.left.mas_equalTo(@9);
                        make.right.mas_equalTo(fCell.mas_right).with.offset(-14);
                        make.height.mas_equalTo(@44);
                    }];
                    [(JJFriendsCell *)cell showTopLine:NO withInset:UIEdgeInsetsZero];
                    [(JJFriendsCell *)cell showBottomLine:YES withInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                }
            }
        }
    }
    if (model) {
        [self setFriendsCell:(id)cell withModel:model atIndexPath:indexPath];
    }
    return cell;
}

- (void)setFriendsCell:(JJAddFriendsCell *)cell withModel:(ContactMemberModel *)model atIndexPath:(NSIndexPath *)indexPath{
    
    WS(ws);
    [cell.avatarView bindUserData:model];
    cell.summryLabel.hidden = NO;
    cell.summryLabel.text = model.signature;
    cell.nameLabel.text = model.nickName;
    cell.friendMemberId = model.memberId;
    
    cell.addBlock = ^(BOOL isAdd,NSString *friendMemberId){
        if (!friendMemberId) {
            return ;
        }
        if (isAdd) {
            [AFNManager postObject:@{@"friendMemberId":friendMemberId}
                           apiName:kResPathAddMember
                         modelName:@"BaseModel"
                  requestSuccessed:^(id responseObject) {
                      [ws showResultThenHide:@"关注成功"];
                      NSMutableArray *array = [NSMutableArray arrayWithArray:ws.fiendsRecommendArr];
                      [array addObjectsFromArray:ws.systemRecommendArr];
                      for (ContactMemberModel *mmodel in array) {
                          if ([mmodel.memberId isEqualToString:friendMemberId]) {
                              mmodel.isFriend = YES;
                          }
                      }
                      [ws.tableView reloadData];
                  }
                    requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                        [ws showResultThenHide:errorMessage?:@"关注失败"];
                    }];
        }else{
        }
    };
    cell.cellStyle = model.isFriend?AddFriendsCellStyleDidAdd:AddFriendsCellStyleAdd;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ContactMemberModel *model = nil;
    if (tableView==self.searchBarDisplayController.searchResultsTableView) {
        
        if (self.resultArr.count) {
            //搜索结果
            model = self.resultArr[indexPath.row];
        }else{
            //历史
            
        }
    }else{
        if(self.fiendsRecommendArr.count) {
            if (indexPath.section==0) {
                if (indexPath.row!=3) {
                    model = self.fiendsRecommendArr[indexPath.row];
                }else{
                    //查看更多好友推荐
                    JJRecommendFriendsController *rec = [[JJRecommendFriendsController alloc] initWithNibName:@"JJRecommendFriendsController" bundle:nil];
                    rec.title = @"好友推荐";
                    rec.resPath = kResPathGetFriendRecommends;
                    rec.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:rec animated:YES];
                }
            }
            else if(indexPath.section==1){
                //周边好友
                JJRecommendFriendsController *rec = [[JJRecommendFriendsController alloc] initWithNibName:@"JJRecommendFriendsController" bundle:nil];
                rec.title = @"附近的人";
                rec.isLocation = YES;
                rec.resPath = kResPathGetNearbyMember;
                rec.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:rec animated:YES];
            }
            else{
                if (indexPath.row!=3) {
                    model = self.systemRecommendArr[indexPath.row];
                }else{
                    //查看更多系统推荐
                    JJRecommendFriendsController *rec = [[JJRecommendFriendsController alloc] initWithNibName:@"JJRecommendFriendsController" bundle:nil];
                    rec.title = @"特别推荐";
                    rec.resPath = kResPathGetParticularlyRecommends;
                    rec.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:rec animated:YES];
                }
            }
        }else{
            if (indexPath.section==0){
                //周边好友
                JJRecommendFriendsController *rec = [[JJRecommendFriendsController alloc] initWithNibName:@"JJRecommendFriendsController" bundle:nil];
                rec.title = @"附近的人";
                rec.isLocation = YES;
                rec.resPath = kResPathGetNearbyMember;
                rec.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:rec animated:YES];
            }
            else {
                if (indexPath.row!=3) {
                    model = self.systemRecommendArr[indexPath.row];
                }else{
                    //查看更多系统推荐
                    JJRecommendFriendsController *rec = [[JJRecommendFriendsController alloc] initWithNibName:@"JJRecommendFriendsController" bundle:nil];
                    rec.title = @"特别推荐";
                    rec.resPath = kResPathGetParticularlyRecommends;
                    rec.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:rec animated:YES];
                }
            }
        }
    }
    if (model) [self showUser:model];
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
    
    
    [self.searchBarDisplayController.searchResultsTableView reloadData];
    //準備搜尋前，把上面調整的TableView調整回全屏幕的狀態
    [UIView animateWithDuration:1.0 animations:^{
        _tableView.frame = CGRectMake(0, 20, 320, SCREEN_HEIGHT-20);
    }];
    
    return YES;
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    //搜尋結束後，恢復原狀
    
    [self.searchBarDisplayController.searchResultsTableView reloadData];
    self.resultArr = nil;
    [UIView animateWithDuration:1.0 animations:^{
        _tableView.frame = CGRectMake(0, 0, 320, SCREEN_HEIGHT-64);
    }];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{

    if ([StringUtils isEmpty:searchBar.text]) {
        self.resultArr = nil;
    }else{
        [self startSearchUser:searchBar.text];
    }
    [self.searchBarDisplayController.searchResultsTableView reloadData];
}

- (void)startSearchUser:(NSString *)userStr{
    
    if ([StringUtils isEmpty:userStr]) {
        return;
    }
    NSMutableArray *newSearch = [@[] mutableCopy];
    [newSearch addObject:userStr];
    for (NSString *str in self.historyArr) {
        if (![str isEqualToString:userStr]) {
            [newSearch addObject:str];
        }
    }
    self.historyArr = newSearch;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.historyArr forKey:@"JJHistorySearchArr"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    WS(ws);
    [AFNManager getObject:@{@"keyword":userStr,@"pageIndex":@1,@"pageSize":@200} apiName:kResPathSearchMember modelName:@"ContactMemberModel" requestSuccessed:^(id responseObject) {
        ws.resultArr = [responseObject mutableCopy];
        [ws.searchBarDisplayController.searchResultsTableView reloadData];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        [ws showResultThenHide:@"搜索失败"];
    }];
}
@end
