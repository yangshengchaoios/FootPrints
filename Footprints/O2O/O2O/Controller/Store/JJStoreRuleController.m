//
//  JJStoreRuleController.m
//  Footprints
//
//  Created by Jinjin on 14/12/3.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJStoreRuleController.h"
#import "MJRefresh.h"
#import "JJRoleCell.h"


@interface JJStoreRuleController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) MJRefreshHeaderView *mjHeader;

@end

@implementation JJStoreRuleController
- (void)dealloc
{
    [self.mjHeader free];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.hidesBottomBarWhenPushed = YES;
    self.title = @"积分规则";
    WS(ws);
    [self.tableView registerNib:[UINib nibWithNibName:@"JJRoleCell" bundle:nil] forCellReuseIdentifier:@"JJRoleCell"];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 59, 0, 0);
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
    [AFNManager getObject:nil apiName:@"MemberCenter/GetPointRules" modelName:@"PointRuleModel" requestSuccessed:^(id responseObject) {
        ws.dataSource = responseObject;
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
    
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    JJRoleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JJRoleCell"];
    PointRuleModel *model = self.dataSource[indexPath.row];
    cell.nameLabel.text = model.ruleDesc;
    [cell.iconImageView setImageWithURLString:model.ruleImage placeholderImage:nil];
    cell.scoreLabel.text = [NSString stringWithFormat:@"+%ld积分",(long)model.point];
    return cell;
}

@end
