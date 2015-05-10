//
//  JJMyExchangeController.m
//  Footprints
//
//  Created by Jinjin on 14/12/3.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJMyExchangeController.h"
#import "MJRefresh.h"
#import "JJMyExchangeCell.h"
#import "TimeUtils.h"

@interface JJMyExchangeController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) MJRefreshHeaderView *mjHeader;
@property (weak, nonatomic) IBOutlet UIView *noInfoView;

- (IBAction)backBtnDidTap:(id)sender;

@end

@implementation JJMyExchangeController

- (void)dealloc
{
    [self.mjHeader free];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.hidesBottomBarWhenPushed = YES;
    self.title = @"我的兑换";
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.noInfoView.hidden = YES;
    
    WS(ws);
    [self.tableView registerNib:[UINib nibWithNibName:@"JJMyExchangeCell" bundle:nil] forCellReuseIdentifier:@"JJMyExchangeCell"];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    
    self.mjHeader = [MJRefreshHeaderView header];
    self.mjHeader.scrollView = self.tableView;
    self.mjHeader.beginRefreshingBlock = ^(MJRefreshBaseView *header){
        [ws refresh];
    };
    
    [ws refresh];

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

- (void)refresh{
    
    //PointRuleModel
    WS(ws);
    [AFNManager getObject:nil apiName:@"MemberCenter/GetMyGiftProducts" modelName:@"GiftProductModel" requestSuccessed:^(id responseObject) {
        ws.dataSource = responseObject;
        ws.noInfoView.hidden = ws.dataSource.count!=0;
        [ws.tableView reloadData];
        [ws.mjHeader endRefreshing];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        [ws.mjHeader endRefreshing];
    }];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JJMyExchangeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JJMyExchangeCell"];
    GiftProductModel *model = self.dataSource[indexPath.row];
    cell.nameLabel.text = [NSString stringWithFormat:@"获得%@",model.giftName];
    [cell.iconView setImageWithURLString:model.giftImage placeholderImage:nil];
    cell.exchangeLabel.text = [TimeUtils friendTimeStringForDate:model.addDate];
    cell.costPointLabel.text = [NSString stringWithFormat:@"使用%ld积分",(long)model.pointValue];
    return cell;
}


- (IBAction)backBtnDidTap:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
