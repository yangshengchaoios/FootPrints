//
//  JJMyAddFriendsController.m
//  Footprints
//
//  Created by Jinjin on 14/11/20.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJRecommendFriendsController.h"
#import "MJRefresh.h"
#import "JJAddFriendsCell.h"
#import "BMapKit.h"
#import "JJUserCenterViewController.h"
#import <CoreLocation/CoreLocation.h>


@interface JJRecommendFriendsController ()<UITableViewDelegate,UITableViewDataSource,BMKLocationServiceDelegate>
@property (strong,nonatomic) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSourceArr;

@property (nonatomic,strong) BMKLocationService* locService;//定位服务
@property (nonatomic,strong) MJRefreshHeaderView *mjHeader;
@property (nonatomic,assign) BOOL isLocating;
@property (nonatomic,strong) BMKUserLocation *userLocation;

@end

@implementation JJRecommendFriendsController
- (void)dealloc
{
    [self.mjHeader free];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.locService.delegate = self;
    if (self.isLocation) [self startLocation];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [self stopLocation];
    [self.mjHeader endRefreshing];
    self.locService.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"JJAddFriendsCell" bundle:nil] forCellReuseIdentifier:@"JJAddFriendsCell"];
  
    WeakSelfType blockSelf = self;
    self.mjHeader = [MJRefreshHeaderView header];
    self.mjHeader.scrollView = self.tableView;
    self.mjHeader.beginRefreshingBlock = ^(MJRefreshBaseView *view){
        [blockSelf getFriendsListAtPage:1];
    };
    if (self.isLocation) [self startLocation];
    [self.mjHeader beginRefreshing];
    
    
    self.noDataInfo.text = self.isLocation?@"没有周边好友":@"没有推荐好友";
    [self.view bringSubviewToFront:self.noDataInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getFriendsListAtPage:(NSInteger)index{
    
    if (self.isLocation) [self startLocation];
    else [self getDAta];
}

- (void)getDAta{
    self.noDataInfo.hidden = YES;
    WeakSelfType blockSelf = self;
    [AFNManager getObject:@{@"recommendType":@1,@"pageIndex":@(1),@"pageSize":@(1000),@"longitude":@(self.userLocation.location.coordinate.longitude),@"latitude":@(self.userLocation.location.coordinate.latitude)}
                  apiName:self.resPath
                modelName:@"ContactMemberModel" requestSuccessed:^(id responseObject) {
                    
                    if ([responseObject isKindOfClass:[NSArray class]]) {
                        NSArray *array = responseObject;
                        blockSelf.dataSourceArr = [array mutableCopy];
                        [blockSelf.tableView reloadData];
                    }
                    else{
                        [blockSelf showResultThenHide:@"获取失败"];
                    }
                    blockSelf.noDataInfo.hidden = blockSelf.dataSourceArr.count>0;
                    [blockSelf.mjHeader endRefreshing];
                } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    NSLog(@"%@",errorMessage);
                    blockSelf.noDataInfo.hidden = blockSelf.dataSourceArr.count>0;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataSourceArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JJAddFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JJAddFriendsCell"];
    JJMemberModel *model = self.dataSourceArr[indexPath.row];
    if (self.isLocation) {
        cell.locationLabel.text = [NSString stringWithFormat:@"%.2fKm",[self LantitudeLongitudeDist:model.longitude other_Lat:model.latitude self_Lon:self.userLocation.location.coordinate.longitude self_Lat:self.userLocation.location.coordinate.latitude]/1000.0f];
    }
    
    [cell.avatarView bindUserData:model];
    cell.summryLabel.hidden = NO;
    cell.summryLabel.text = model.signature;
    cell.nameLabel.text = model.nickName;
    cell.friendMemberId = model.memberId;
    cell.locationLabel.hidden = !self.isLocation;
    WS(ws);
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
                      for (ContactMemberModel *mmodel in ws.dataSourceArr) {
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
            //TODO 取消关注
        }
    };
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
    cell.cellStyle = model.isFriend?AddFriendsCellStyleDidAdd:AddFriendsCellStyleAdd;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ContactMemberModel *model = self.dataSourceArr[indexPath.row];
    [self showUser:model];
}

#pragma mark - BMKLocationServiceDelegate

- (void)startLocation{
    
    if (self.isLocating) {
        return;
    }
    if (nil==self.locService) {
        self.locService  = [[BMKLocationService alloc] init];
    }
    self.isLocating = YES;
    [self.locService startUserLocationService];
}

- (void)stopLocation{
    self.isLocating = NO;
    [self.locService stopUserLocationService];
}

#pragma mark - BMKLocationServiceDelegate
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    
    if (TGO_DEBUG_LOG) NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    self.userLocation = userLocation;
    
    JJMemberModel *model = [[UserManager sharedManager] loginUser];
    model.longitude = self.userLocation.location.coordinate.longitude;
    model.latitude = self.userLocation.location.coordinate.latitude;
    
    WS(ws);
    [AFNManager postObject:@{@"longitude":@(self.userLocation.location.coordinate.longitude),@"latitude":@(self.userLocation.location.coordinate.latitude)} apiName:@"MemberCenter/SyncLocation" modelName:@"BaseModel" requestSuccessed:^(id responseObject) {
        
        [ws getDAta];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        [ws getDAta];
    }];
    
    [self stopLocation];
}

- (void)didStopLocatingUser{
    
    if (TGO_DEBUG_LOG) NSLog(@"location stop");
}


/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error{
    self.noDataInfo.hidden = self.dataSourceArr.count>0;
    
    [self showResultThenHide:@"定位失败，请重试"];
    [self.mjHeader endRefreshing];
    [self stopLocation];
}

#pragma mark - calculate distance  根据2个经纬度计算距离

#define JJPI 3.1415926
-(double) LantitudeLongitudeDist:(double)lon1 other_Lat:(double)lat1 self_Lon:(double)lon2 self_Lat:(double)lat2{
    double er = 6378137; // 6378700.0f;
    //ave. radius = 6371.315 (someone said more accurate is 6366.707)
    //equatorial radius = 6378.388
    //nautical mile = 1.15078
    double radlat1 = JJPI*lat1/180.0f;
    double radlat2 = JJPI*lat2/180.0f;
    //now long.
    double radlong1 = JJPI*lon1/180.0f;
    double radlong2 = JJPI*lon2/180.0f;
    if( radlat1 < 0 ) radlat1 = JJPI/2 + fabs(radlat1);// south
    if( radlat1 > 0 ) radlat1 = JJPI/2 - fabs(radlat1);// north
    if( radlong1 < 0 ) radlong1 = JJPI*2 - fabs(radlong1);//west
    if( radlat2 < 0 ) radlat2 = JJPI/2 + fabs(radlat2);// south
    if( radlat2 > 0 ) radlat2 = JJPI/2 - fabs(radlat2);// north
    if( radlong2 < 0 ) radlong2 = JJPI*2 - fabs(radlong2);// west
    //spherical coordinates x=r*cos(ag)sin(at), y=r*sin(ag)*sin(at), z=r*cos(at)
    //zero ag is up so reverse lat
    double x1 = er * cos(radlong1) * sin(radlat1);
    double y1 = er * sin(radlong1) * sin(radlat1);
    double z1 = er * cos(radlat1);
    double x2 = er * cos(radlong2) * sin(radlat2);
    double y2 = er * sin(radlong2) * sin(radlat2);
    double z2 = er * cos(radlat2);
    double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
    //side, side, side, law of cosines and arccos
    double theta = acos((er*er+er*er-d*d)/(2*er*er));
    double dist  = theta*er;
    return dist;
}
@end
