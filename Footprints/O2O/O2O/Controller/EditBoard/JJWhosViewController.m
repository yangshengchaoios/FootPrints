//
//  JJWhosViewController.m
//  Footprints
//
//  Created by Jinjin on 15/1/12.
//  Copyright (c) 2015年 JiaJun. All rights reserved.
//

#import "JJWhosViewController.h"
#import "MJRefresh.h"
#import "JJWhosViewCell.h"

#define kSoildCount 4
@interface JJWhosViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *doneBtn;
@property (strong, nonatomic) MJRefreshHeaderView *mjHeader;
@property (strong, nonatomic) NSMutableArray *dataSource;
- (IBAction)doneBtnDidTap:(id)sender;

@end

@implementation JJWhosViewController

- (void)dealloc
{
    [self.mjHeader free];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"可见范围";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.doneBtn];
    
    WS(ws);
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"JJWhosViewCell" bundle:nil] forCellReuseIdentifier:@"JJWhosViewCell"];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    
    self.mjHeader = [MJRefreshHeaderView header];
    self.mjHeader.scrollView = self.tableView;
    self.mjHeader.beginRefreshingBlock = ^(MJRefreshBaseView *baseView){
        [ws refresh];
    };
    [self refresh];

    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self refresh];
}

- (NSMutableArray *)choosedArr{
    if (nil==_choosedArr) {
        _choosedArr = [@[] mutableCopy];
    }
    return _choosedArr;
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

- (IBAction)doneBtnDidTap:(id)sender {
    NSString *groupId = nil;
    for (NSString *str in self.choosedArr) {
        if (groupId==nil) {
            groupId = str;
        }else{
            groupId = [NSString stringWithFormat:@"%@,%@",groupId,str];
        }
    }
    if (self.block) {
        self.block(groupId);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return kSoildCount+self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    JJWhosViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JJWhosViewCell"];
    NSString *title = nil;
    NSString *subTitle = nil;
    NSString *groupId = nil;
    if (indexPath.row<kSoildCount) {
        [cell setDetailModel:NO];
        switch (indexPath.row) {
            case 0:
                title = @"公开";
                groupId = @"1";
                break;
            case 1:
                title = @"所有粉丝可见";
                groupId = @"2";
                break;
            case 2:
                title = @"仅自己可见";
                groupId = @"0";
                break;
            case 3:
                title = @"互粉好友可见";
                groupId = @"3";
                break;
            default:
                break;
        }
    }else{
        [cell setDetailModel:YES];
        MemberGroupModel *group = self.dataSource[indexPath.row-kSoildCount];
        title = group.groupName;
        groupId = group.groupId;
        for (MemberInGroupModel *model in group.memberNames) {
            
            if (subTitle==nil) {
                subTitle = [StringUtils isEmpty:model.param2]?model.param1:model.param2;
            }else{
                subTitle = [NSString stringWithFormat:@"%@,%@",title,[StringUtils isEmpty:model.param2]?model.param1:model.param2];
                
            }
        }
        if (subTitle==nil) {
            subTitle = @"0人";
        }
    }
    
    if (indexPath.row==0) {
        [cell showTopLine:YES withInset:UIEdgeInsetsZero];
    }else{
        [cell showTopLine:NO withInset:UIEdgeInsetsZero];
    }
    
    if (indexPath.row==(kSoildCount-1) || indexPath.row==(self.dataSource.count+(kSoildCount-1))) {
        [cell showBottomLine:YES withInset:UIEdgeInsetsZero];
    }else{
        [cell showBottomLine:YES withInset:UIEdgeInsetsMake(0, 9, 0, 0)];
    }
    
    cell.choosed = [self isSelectedForGroupId:groupId];
    cell.nameLabel.text = title;
    cell.detaiTextLabel.text = subTitle;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *groupId = nil;
    if (indexPath.row<kSoildCount) {
        switch (indexPath.row) {
            case 0:
                groupId = @"1";
                break;
            case 1:
                groupId = @"2";
                break;
            case 2:
                groupId = @"0";
                break;
            case 3:
                groupId = @"3";
                break;
                
            default:
                break;
        }
        
        [self.choosedArr removeAllObjects];
        
    }else{
        MemberGroupModel *group = self.dataSource[indexPath.row-kSoildCount];
        groupId = group.groupId;
        //公开状态（默认为0:私密 1:公开 2粉丝 3好友 其他为好友分组ID,多个组用 英文逗号分开）
        
        NSArray *array = [self.choosedArr copy];
        for (NSString *str in array) {
            if (([str isEqualToString:@"0"] || [str isEqualToString:@"1"] || [str isEqualToString:@"2"] || [str isEqualToString:@"3"])) {
                [self.choosedArr removeObject:str];
            }
        }
    }
   

    if (groupId) {
        [self.choosedArr addObject:groupId];
    }
    
    [self.tableView reloadData];
}

- (BOOL)isSelectedForGroupId:(NSString *)gid{
    
    BOOL isSelected = NO;
    for (NSString *str  in self.choosedArr) {
        if ([str isEqualToString:gid]) {
            isSelected = YES;
            break;
        }
    }
    return isSelected;
}
@end
