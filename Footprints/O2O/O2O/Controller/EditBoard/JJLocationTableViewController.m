//
//  JJLocationTableViewController.m
//  Footprints
//
//  Created by tt on 14/10/29.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJLocationTableViewController.h"

@interface JJLocationTableViewController ()<BMKLocationServiceDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,assign) BOOL locating;
@property (nonatomic,strong) BMKLocationService* locService;//定位服务
@property (nonatomic,strong) UITableView *table ;

@property (nonatomic,strong) NSArray *currentPoints;
@end

@implementation JJLocationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(startLocation)];
    
    //定位
    if (nil==self.locService) {
        self.locService  = [[BMKLocationService alloc] init];
    }
    
    self.title = @"定位";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.locService.delegate = self;
    [self startLocation];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    self.locService.delegate = nil;
}


- (id)initWithDidChooseActions:(CompelteBlock)compelte{
    
    self = [super init];
    if (self) {
        self.compelte = compelte;
    }
    return self;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.currentPoints.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    
    if (nil==cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"reuseIdentifier"];
    }
    
    if (indexPath.row==0) {
        cell.textLabel.text = @"不显示位置信息";
    }else{
        BMKPoiInfo *pInfo = self.currentPoints[indexPath.row-1];
        cell.textLabel.text = [NSString stringWithFormat:@"%@·%@",pInfo.city,pInfo.name];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    BMKPoiInfo *pInfo = nil;
    if (indexPath.row!=0) {
        pInfo = self.currentPoints[indexPath.row-1];
    }
    if (self.compelte) {
        self.compelte(pInfo);
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(locationTable:didChooseLocation:)]) {
        [self.delegate locationTable:self didChooseLocation:pInfo];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark - BMKLocationServiceDelegate

- (void)startLocation{
    
    if (self.locating) {
        return;
    }
    [self showHUDLoadingWithString:@"定位中.."];
    self.locating = YES;
    [self.locService startUserLocationService];
}

- (void)stopLocation{
    
    self.locating = NO;
    [self.locService stopUserLocationService];
    [self hideHUDLoading];
}




//开始反地理编码
-(void)startReverseGeoCodeSearch:(BMKUserLocation *)userLocation{
    
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){0, 0};
    pt = (CLLocationCoordinate2D){userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude};
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    
    BMKGeoCodeSearch *_geocodesearch = [[BMKGeoCodeSearch alloc]init];
    _geocodesearch.delegate = (id)self;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        if (TGO_DEBUG_LOG) NSLog(@"反geo检索发送成功");
    }
    else
    {
        if (TGO_DEBUG_LOG) NSLog(@"反geo检索发送失败");
    }
}


//反地理编码完成
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == 0) {
        
        NSString *detail = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",result.addressDetail.province,result.addressDetail.city,result.addressDetail.district,result.addressDetail.streetName,result.addressDetail.streetNumber];
        
        NSString *str = [NSString stringWithFormat:@"\n==================="];
        
        for (BMKPoiInfo *pInfo in result.poiList) {
            str = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%f,%f\n\n-------------------------------\n",str,pInfo.name,pInfo.address,pInfo.city,pInfo.pt.latitude,pInfo.pt.longitude];
        }
        
        
        NSString* showmeg = [NSString stringWithFormat:@"\n%@\n%@",detail,str];
        
        if (TGO_DEBUG_LOG)  NSLog(@"%@",showmeg);
        self.currentPoints = result.poiList;
    }
    
    [self.table reloadData];
    [self stopLocation];
}



#pragma mark - BMKLocationServiceDelegate
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    if (TGO_DEBUG_LOG) NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    
    [self startReverseGeoCodeSearch:userLocation];

}

- (void)didStopLocatingUser{
    
    if (TGO_DEBUG_LOG) NSLog(@"location stop");
}


/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error{
    
    [self showResultThenHide:@"定位失败，请重试"];
}



@end
