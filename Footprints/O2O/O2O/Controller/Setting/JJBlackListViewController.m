//
//  JJBlackListViewController.m
//  Footprints
//
//  Created by Jinjin on 14/12/12.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJBlackListViewController.h"
#import "MJRefresh.h"
#import "pinyin.h"
#import "BATableView.h"
#import "JJFriendsCell.h"
#import "JJUserCenterViewController.h"

@interface JJBlackListViewController ()<BATableViewDelegate>
@property (strong,nonatomic) BATableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSourceArr;
@property (nonatomic,strong) NSMutableArray *resultArr;
@property (nonatomic,assign) NSInteger curPage;
@property (nonatomic,strong) MJRefreshHeaderView *mjHeader;
@property (nonatomic,strong) NSMutableArray *groupedFriendsData;
@property (nonatomic,strong) NSMutableArray *arrayOfCharacters;
@end

@implementation JJBlackListViewController
- (void)dealloc
{
    [self.mjHeader free];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"黑名单";
    
    // Do any additional setup after loading the view from its nib.
    self.tableView = [[BATableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView.tableView registerNib:[UINib nibWithNibName:@"JJFriendsCell" bundle:nil] forCellReuseIdentifier:@"JJFriendsCell"];

    WeakSelfType blockSelf = self;
    self.mjHeader = [MJRefreshHeaderView header];
    self.mjHeader.scrollView = self.tableView.tableView;
    self.mjHeader.beginRefreshingBlock = ^(MJRefreshBaseView *view){
        [blockSelf getBlackListAtPage:1];
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self getBlackListAtPage:1];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)getBlackListAtPage:(NSInteger)index{
    
    WeakSelfType blockSelf = self;
    [AFNManager getObject:@{@"relationType":@1,@"pageIndex":@(index),@"pageSize":@(1000)}
                  apiName:kResPathGetMyFriends
                modelName:@"ContactMemberModel" requestSuccessed:^(id responseObject) {
                    
                    if ([responseObject isKindOfClass:[NSArray class]]) {
                        NSArray *array = responseObject;
                        [blockSelf didGetNewFriendDatas:array atIndex:index];
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
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource
- (NSArray *) sectionIndexTitlesForABELTableView:(BATableView *)tableView {
    
    return self.arrayOfCharacters;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSDictionary *dataDict = self.groupedFriendsData[section];
    return dataDict[@"groupName"];
}

- (NSInteger)sectionIndexOffsetForABELTableView:(BATableView *)tableView{
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.groupedFriendsData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    NSInteger count = 0;
    NSDictionary *groupFriendDict = self.groupedFriendsData[section];
    count = [groupFriendDict[@"friends"] count];
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 46;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return section=20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JJFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JJFriendsCell"];
    NSDictionary *dataDict = self.groupedFriendsData[indexPath.section];
    ContactMemberModel *model = [dataDict[@"friends"] objectAtIndex:indexPath.row];
    [cell.avatarView bindUserData:model];
    cell.summryLabel.hidden = NO;
    cell.summryLabel.text = model.signature;
    [cell setCount:0];
    cell.nameLabel.text = model.nickName;
    
    [(JJFriendsCell *)cell showTopLine:NO withInset:UIEdgeInsetsZero];
    if (indexPath.row==(self.groupedFriendsData.count-1)) {
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
    
    NSDictionary *dataDict = self.groupedFriendsData[indexPath.section];
    ContactMemberModel *model = [dataDict[@"friends"] objectAtIndex:indexPath.row];
    [self showUser:model];
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
