//
//  JJGroupViewController.m
//  Footprints
//
//  Created by Jinjin on 14/12/1.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJChooseFriendsController.h"
#import "MJRefresh.h"
#import "JJChooseFriendCell.h"
#import "pinyin.h"
#import "BATableView.h"
#import "JJCreateGroupController.h"

@interface JJChooseFriendsController ()<BATableViewDelegate,JJCreateGroupDelegate>

@property (strong,nonatomic) BATableView *tableView;
@property (nonatomic,strong) MJRefreshHeaderView *mjHeader;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSArray *orgSource;
@property (nonatomic,strong) NSMutableArray *groupedFriendsData;
@property (nonatomic,strong) NSMutableArray *arrayOfCharacters;
@property (nonatomic,strong) NSMutableArray *choosedSource;
@property (nonatomic,strong) NSMutableArray *deletedUser;
@property (strong, nonatomic) IBOutlet UIButton *nextStepBtn;
@property (nonatomic,strong) NSString *groupName;

- (IBAction)nextStepBtnDidTap:(id)sender;
@end

@implementation JJChooseFriendsController
- (void)dealloc
{
    [self.mjHeader free];
}

- (void)addDeletedUser:(id)user{
    
    if (nil==self.deletedUser) {
        self.deletedUser = [@[] mutableCopy];
    }
    [self didRemoveUserModel:user];
    [self.deletedUser addObject:user];
    [self didGetNewFriendDatas:self.orgSource];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"选择联系人";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.nextStepBtn];
    
    if (self.didChooseMember) {
        [self.nextStepBtn setTitle:@"完成" forState:UIControlStateNormal];
    }
    
    WS(ws);
    self.tableView = [[BATableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;

    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView.tableView registerNib:[UINib nibWithNibName:@"JJChooseFriendCell" bundle:nil] forCellReuseIdentifier:@"JJChooseFriendCell"];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    
    self.mjHeader = [MJRefreshHeaderView header];
    self.mjHeader.scrollView = self.tableView.tableView;
    self.mjHeader.beginRefreshingBlock = ^(MJRefreshBaseView *baseView){
        [ws refresh];
    };
    [self refresh];
    
    self.isRecommend = self.isRecommend;
}

- (void)setIsAllFriends:(BOOL)isAllFriends{
    
    _isAllFriends = isAllFriends;
    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setIsRecommend:(BOOL)isRecommend{
    
    _isRecommend = isRecommend;
    [self.nextStepBtn setTitle:self.isRecommend?@"完成":@"下一步" forState:UIControlStateNormal];
    if (self.didChooseMember) {
        [self.nextStepBtn setTitle:@"完成" forState:UIControlStateNormal];
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

- (IBAction)nextStepBtnDidTap:(id)sender {
    
    if (self.isRecommend) {
        if (self.choosedSource.count) {
            if (self.recommendMemberId) {
                NSString *friendMemberId = @"";
                for (ContactMemberModel *model in self.choosedSource) {
                    if (friendMemberId.length==0) {
                        friendMemberId = model.memberId;
                    }else{
                        friendMemberId = [NSString stringWithFormat:@"%@,%@",friendMemberId,model.memberId];
                    }
                }
                WS(ws);
                [AFNManager postObject:@{@"friendMemberId":friendMemberId,@"recommendMemberId":self.recommendMemberId}
                               apiName:@"MemberCenter/RecommendMember"
                             modelName:@"BaseModel"
                      requestSuccessed:^(id responseObject) {
                          [ws showResultThenBack:@"推荐成功"];
                      }
                        requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                            [ws showResultThenHide:errorMessage];
                        }];
            }
            
        }else{
            [self showResultThenHide:@"请选择好友"];
        }
    }else if(self.didChooseMember || self.chooseComplete){
        
        if (self.chooseComplete) {
            self.chooseComplete(self.choosedSource);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        JJCreateGroupController *cGroup = [[JJCreateGroupController alloc] initWithNibName:@"JJCreateGroupController" bundle:nil];
        cGroup.choosedSource = self.choosedSource;
        cGroup.groupName = self.groupName;
        cGroup.delegate = self;
        cGroup.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:cGroup animated:YES];
    }
}

- (void)refresh{
    
    WeakSelfType blockSelf = self;
    
    NSNumber *relationType = self.isRecommend?@0:@2;
    if ( self.isAllFriends) {
        relationType = @0;
    }
    [AFNManager getObject:@{@"pageIndex":@(1),@"pageSize":@(2000),@"relationType":relationType}
                  apiName:kResPathGetMyFriends
                modelName:@"ContactMemberModel" requestSuccessed:^(id responseObject) {
                    
                    if ([responseObject isKindOfClass:[NSArray class]]) {
                        NSArray *array = responseObject;
                        [blockSelf didGetNewFriendDatas:array];
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

- (void)didRemoveUserModel:(ContactMemberModel *)model{
    BOOL choose = [self didChooseForModel:model];
    if (choose) {
        NSInteger index = -1;
        for (ContactMemberModel *m in self.choosedSource) {
            if ([m.memberId isEqualToString:model.memberId]) {
                index = [self.choosedSource indexOfObject:m];
                break;
            }
        }
        if(index>=0)[self.choosedSource removeObjectAtIndex:index];
    }
    [self.tableView reloadData];
}

- (void)didSetGroupName:(NSString *)groupName{

    self.groupName = groupName;
}

#pragma mark - TableView

#define judgeletter_classic(ch) (((ch)>='A'&&ch<='Z')||((ch)>='a'&&(ch)<='z'))
- (void)didGetNewFriendDatas:(NSArray *)datas{
    
    self.orgSource = datas;
    self.dataSource = [datas mutableCopy];

    //过滤一次 防止重复数据
    for (ContactMemberModel *model in self.deletedUser) {
        BOOL add = YES;
        for (ContactMemberModel *model2 in self.dataSource) {
            
            if ([model.memberId isEqualToString:model2.memberId]) {
                add = NO;
                break;
            }
        }
        if (add) [self.dataSource addObject:model];
    }
    
    //将好友分组
    NSMutableDictionary *tempDict = [@{} mutableCopy];
    for (ContactMemberModel *model in self.dataSource) {
        
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
    
    NSInteger count = 0;
    count = self.groupedFriendsData.count;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    NSInteger count = 0;
    NSDictionary *groupFriendDict = self.groupedFriendsData[section];
    count = [groupFriendDict[@"friends"] count];
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = 45;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    

    JJChooseFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JJChooseFriendCell"];
    NSDictionary *dataDict = self.groupedFriendsData[indexPath.section];
    ContactMemberModel *model = [dataDict[@"friends"] objectAtIndex:indexPath.row];
    [cell.avatarView bindUserData:model];
    cell.nameLabel.text = model.nickName;
    [cell setChoose:[self didChooseForModel:model]];
    
    if (indexPath.row==0) {
        [cell showTopLine:YES withInset:UIEdgeInsetsZero];
    }else{
        [cell showTopLine:NO withInset:UIEdgeInsetsZero];
    }
    
    if (indexPath.row==(self.dataSource.count-1)) {
        [cell showBottomLine:YES withInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }else{
        [cell showBottomLine:YES withInset:UIEdgeInsetsMake(0, 15, 0, 0)];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (nil==self.choosedSource) {
        self.choosedSource = [@[] mutableCopy];
    }
    NSDictionary *dataDict = self.groupedFriendsData[indexPath.section];
    ContactMemberModel *model = [dataDict[@"friends"] objectAtIndex:indexPath.row];
    BOOL choose = [self didChooseForModel:model];
    if (choose) {
        [self.choosedSource removeObject:model];
    }else{
        [self.choosedSource addObject:model];
    }
    
    if (self.didChooseMember) {
        [self.deletedUser removeObject:model];
        self.didChooseMember(model,!choose);
    }
    
    [self.tableView reloadData];
}

- (BOOL)didChooseForModel:(ContactMemberModel *)model{
    BOOL choose = NO;
    for (ContactMemberModel *m in self.choosedSource) {
        if ([m.memberId isEqualToString:model.memberId]) {
            choose = YES;
            break;
        }
    }
    return choose;
}
@end
