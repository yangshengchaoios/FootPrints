//
//  JJGroupViewController.m
//  Footprints
//
//  Created by Jinjin on 14/12/1.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJGroupViewController.h"
#import "MJRefresh.h"
#import "JJGroupCell.h"
#import "JJChooseFriendsController.h"
#import "JJCreateGroupController.h"

@interface JJGroupViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *addGroupBtn;
@property (nonatomic,strong) MJRefreshHeaderView *mjHeader;
@property (nonatomic,strong) NSMutableArray *dataSource;

- (IBAction)addGroupBtnDidTap:(id)sender;
@end

@implementation JJGroupViewController
- (void)dealloc
{
    [self.mjHeader free];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"标签/组";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.addGroupBtn];
    
    WS(ws);
    [self.tableView registerNib:[UINib nibWithNibName:@"JJGroupCell" bundle:nil] forCellReuseIdentifier:@"JJGroupCell"];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    
    self.mjHeader = [MJRefreshHeaderView header];
    self.mjHeader.scrollView = self.tableView;
    self.mjHeader.beginRefreshingBlock = ^(MJRefreshBaseView *baseView){
        [ws refresh];
    };
    
    self.addGroupBtn.hidden = self.isChoose;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [self refresh];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)addGroupBtnDidTap:(id)sender {
    
    JJChooseFriendsController *friends = [[JJChooseFriendsController alloc] initWithNibName:@"JJChooseFriendsController" bundle:nil];
    friends.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:friends animated:YES];
}

- (void)refresh{
    
    WS(ws);
    [AFNManager getObject:nil
                  apiName:@"MemberCenter/GetMemberGroups"
                modelName:@"MemberGroupModel"
         requestSuccessed:^(id responseObject) {
             ws.dataSource = [responseObject mutableCopy];
             [ws.tableView reloadData];
             [ws.mjHeader endRefreshing];
         } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
             
             [ws.mjHeader endRefreshing];
         }];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger count = 0;
    count = self.dataSource.count;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = 45;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    JJGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JJGroupCell"];
    MemberGroupModel *group = self.dataSource[indexPath.row];
    cell.groupNameLabel.text = [NSString stringWithFormat:@"%@ (%ld人)",group.groupName,(long)group.groupMemberNumber];
   
    NSString *title = nil;
    for (MemberInGroupModel *model in group.memberNames) {
        
        if (title==nil) {
            title = [StringUtils isEmpty:model.param2]?model.param1:model.param2;
        }else{
            title = [NSString stringWithFormat:@"%@,%@",title,[StringUtils isEmpty:model.param2]?model.param1:model.param2];
        }
    }
    cell.groupMenberModel.text = title;
    
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
    MemberGroupModel *group = self.dataSource[indexPath.row];
    if (self.isChoose) {
    
    }else{
        JJCreateGroupController *groupC = [[JJCreateGroupController alloc] initWithNibName:@"JJCreateGroupController" bundle:nil];
        groupC.groupId = group.groupId;
        groupC.groupName = group.groupName;
        groupC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:groupC animated:YES];
    }
}

@end
