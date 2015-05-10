//
//  JJAdressFriendsController.m
//  Footprints
//
//  Created by Jinjin on 14/11/24.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJAdressFriendsController.h"
#import <SMS_SDK/SMS_SDK.h>
#import <SMS_SDK/SMS_AddressBook.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "MJRefresh.h"
#import "BATableView.h"
#import "JJAddressCell.h"
#import "pinyin.h"
#import "JJUserCenterViewController.h"

typedef NS_ENUM(NSInteger, JJAddressStatus) {
    JJAddressStatusNone = 0,
    JJAddressStatusFriends,
    JJAddressStatusRegister,
};

@interface JJAdressFriendsController ()<BATableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UIView *noInfoView;
@property (strong, nonatomic) NSMutableArray *friendAaddress;

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchBarDisplayController;
@property (strong,nonatomic) BATableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSourceArr;
@property (nonatomic,strong) NSMutableArray *allDictArr;
@property (nonatomic,strong) NSMutableArray *address;
@property (nonatomic,strong) NSMutableArray *friendsArray;
@property (nonatomic,strong) NSMutableArray *arrayOfCharacters;
@property (nonatomic,strong) NSMutableArray *resultArr;
@property (nonatomic,assign) NSInteger curPage;
@property (nonatomic,strong) MJRefreshHeaderView *mjHeader;

- (IBAction)startSyncDidTap:(id)sender;

@end

@implementation JJAdressFriendsController

- (void)dealloc
{
    [self.mjHeader free];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"通讯录好友";
    
    self.tableView = [[BATableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableView.tableHeaderView = self.searchBar;
    [self.tableView.tableView registerNib:[UINib nibWithNibName:@"JJAddressCell" bundle:nil] forCellReuseIdentifier:@"JJAddressCell"];
    
    [self initMysearchBarAndMysearchDisPlay];
    
    WeakSelfType blockSelf = self;
    self.mjHeader = [MJRefreshHeaderView header];
    self.mjHeader.scrollView = self.tableView.tableView;
    self.mjHeader.beginRefreshingBlock = ^(MJRefreshBaseView *view){
        [blockSelf refreshUserData];
    };
    [self refreshUserData];

    
    [self.view bringSubviewToFront:self.noInfoView];
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
    self.tableView.tableView.tableHeaderView = self.searchBar;
    
    self.searchBarDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchBarDisplayController.delegate = self;
    self.searchBarDisplayController.searchResultsDataSource = self;
    self.searchBarDisplayController.searchResultsDelegate = self;
    [self.searchBarDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"JJAddressCell" bundle:nil] forCellReuseIdentifier:@"JJAddressCell"];
}


#define judgeletter_classic(ch) (((ch)>='A'&&ch<='Z')||((ch)>='a'&&(ch)<='z'))
- (void)reloadData{
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"SyncAddressBookFriends"]) {
        [self.address removeAllObjects];
    }
    
    self.allDictArr = [@[] mutableCopy];
    self.noInfoView.hidden = self.address.count;
    //将好友分组
    NSMutableDictionary *tempDict = [@{} mutableCopy];
    for (SMS_AddressBook *model in self.address) {
        if (model.phones && model.name){
            NSString *groupName = @"#";
            unichar firstChar = model.name.length?[model.name characterAtIndex:0]:[@"#" characterAtIndex:0];
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
            
            NSMutableDictionary *tmpAddressDict = [@{} mutableCopy];
            ContactMemberModel *cmodel = [self getAddressStatusForPhone:model.phones];
            if (cmodel) [tmpAddressDict setObject:cmodel forKey:@"model"];
            [tmpAddressDict setObject:model.name forKey:@"name"];
            [tmpAddressDict setObject:model.phones forKey:@"phone"];
            
            [tempDatas addObject:tmpAddressDict];
            [tempDict setObject:tempDatas forKey:groupName];
            
            [self.allDictArr addObject:tmpAddressDict];
        }
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
    
    self.dataSourceArr = [@[] mutableCopy];
    for (NSString *key in self.arrayOfCharacters) {
        NSArray *data = tempDict[key];
        if (data && key) {
            [self.dataSourceArr addObject:@{@"friends":data,@"groupName":key}];
        }
    }
    
    [self.tableView reloadData];
}

- (ContactMemberModel *)getAddressStatusForPhone:(NSString *)phone{
    ContactMemberModel *model = nil;
    for (ContactMemberModel *tmpModel in self.friendsArray) {
        if ([tmpModel.phone isEqualToString:phone]) {
            model = tmpModel;
            break;
        }
    }
    return model;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)refreshUserData{

    if ([self getLocalAddress]) {
        NSString *postData = @"";
        for (SMS_AddressBook *model in self.address) {
            postData = postData.length?[NSString stringWithFormat:@"%@,%@",postData,model.phones]:[NSString stringWithFormat:@"%@",model.phones];
        }
        
        if (![StringUtils isEmpty:postData]) {
            WS(ws);
            [AFNManager postObject:@{@"phoneData":postData} apiName:kResPathCheckContactMembers modelName:@"ContactMemberModel"
                  requestSuccessed:^(id responseObject) {
                      ws.friendsArray = [responseObject mutableCopy];
                      [ws reloadData];
                      [ws.mjHeader endRefreshing];
                  } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                      [ws showResultThenHide:errorMessage];
                      [ws.mjHeader endRefreshing];
                  }];
        }
    }
}


- (BOOL)getLocalAddress{
    BOOL isSuccess = NO;
    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
    if (authStatus == kABAuthorizationStatusDenied){
        
    }else{
        self.address = [[SMS_SDK addressBook] mutableCopy];
        [self reloadData];
        isSuccess = YES;
    }
    return isSuccess;
}

- (IBAction)startSyncDidTap:(id)sender {
   

    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
    if (authStatus == kABAuthorizationStatusDenied){
        UIAlertView *av = [[UIAlertView alloc]
                           initWithTitle:@"授权访问通讯录"
                           message:@"请到设置>通用>隐私中设置通讯录访问授权."
                           delegate:nil
                           cancelButtonTitle:nil
                           otherButtonTitles:@"好的",nil];
        [av show];
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SyncAddressBookFriends"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self refreshUserData];
    }
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

#pragma mark - UITableViewDataSource
- (NSArray *) sectionIndexTitlesForABELTableView:(BATableView *)tableView {
    
    return self.arrayOfCharacters;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(tableView==self.searchBarDisplayController.searchResultsTableView)return @"";
    NSDictionary *dataDict = self.dataSourceArr[section];
    return dataDict[@"groupName"];
}

- (NSInteger)sectionIndexOffsetForABELTableView:(BATableView *)tableView{
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (tableView==self.searchBarDisplayController.searchResultsTableView) {
        return 1;
    }
    return self.dataSourceArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (tableView==self.searchBarDisplayController.searchResultsTableView) {
        return self.resultArr.count;
    }else{
        NSDictionary *groupFriendDict = self.dataSourceArr[section];
        return [groupFriendDict[@"friends"] count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (tableView==self.searchBarDisplayController.searchResultsTableView) {
        return 0;
    }
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JJAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JJAddressCell"];
    NSDictionary *dict = nil;
    if (tableView==self.searchBarDisplayController.searchResultsTableView) {
        dict = self.resultArr[indexPath.row];
        
    }else{
        
        NSDictionary *groupFriendDict = self.dataSourceArr[indexPath.section];
        dict = groupFriendDict[@"friends"][indexPath.row];
    }
    cell.nameLabel.text = dict[@"name"];
    ContactMemberModel *model = dict[@"model"];
    
    AddressFriendsStatus status = AddressFriendsStatusNotRegister;
    if (model){
        status = model.isFriend?AddressFriendsStatusFriend:AddressFriendsStatuRegister;
    }
    cell.status = status;
    cell.phone = dict[@"phone"];
    cell.friendMemberId = model.memberId;
    WS(ws);
    cell.block = ^(AddressFriendsStatus status,NSString *memberId,NSString *phone){
        if (status==AddressFriendsStatusNotRegister) {
            if (phone) [SMS_SDK sendSMS:phone AndMessage:[NSString stringWithFormat:@"我正在使用微秀,下载地址是"]];//TODO 修改文案
        }else if (status==AddressFriendsStatuRegister){
            [AFNManager postObject:@{@"friendMemberId":memberId}
                           apiName:kResPathAddMember
                         modelName:@"BaseModel"
                  requestSuccessed:^(id responseObject) {
                      [ws showResultThenHide:@"关注成功"];
                      NSMutableArray *array = [NSMutableArray arrayWithArray:ws.friendsArray];
                      for (ContactMemberModel *mmodel in array) {
                          if ([mmodel.memberId isEqualToString:memberId]) {
                              mmodel.isFriend = YES;
                          }
                      }
                      [ws.tableView reloadData];
                  }
                    requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                        [ws showResultThenHide:errorMessage?:@"关注失败"];
                    }];
        }
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dict = nil;
    if (tableView==self.searchBarDisplayController.searchResultsTableView) {
        dict = self.resultArr[indexPath.row];
        
    }else{
        NSDictionary *groupFriendDict = self.dataSourceArr[indexPath.section];
        dict = groupFriendDict[@"friends"][indexPath.row];
    }
    ContactMemberModel *model = dict[@"model"];
    if (!model) {
       [self showUser:model];
    }
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
    
    for (int i = 0; i < self.allDictArr.count; i++){
        NSDictionary *model = self.allDictArr[i];
        NSString *storeString = model[@"name"];
        NSRange storeRange = NSMakeRange(0, storeString.length);
        NSRange foundRange = [storeString rangeOfString:searchText options:searchOptions range:storeRange];
        if (foundRange.length) {
            [tempResults addObject:model];
        }
    }
    self.resultArr = [tempResults mutableCopy];
}


@end
