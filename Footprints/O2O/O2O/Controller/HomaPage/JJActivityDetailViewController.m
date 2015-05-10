//
//  JJActivityDetailViewController.m
//  Footprints
//
//  Created by Jinjin on 14/11/17.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJActivityDetailViewController.h"
#import "JJActivityTopCell.h"
#import "JJActivityDetaiViewCell.h"
#import "JJActivityDetaiOpenCell.h"
#import "JJActivityTravelsCell.h"
#import "JJActiityRankCell.h"
#import "MJRefresh.h"
#import "JJDetailViewController.h"
#import "JJEditChooseViewController.h"
#import "JJPreviewViewController.h"
@interface JJActivityDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *postBtn;
@property (nonatomic,assign) BOOL isDetailOpen;
@property (strong, nonatomic) UILabel *worksCountLabel;
@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UIView *headerView1;
@property (strong, nonatomic) UILabel *worksCountLabel1;
@property (nonatomic,assign) NSInteger curPage;
@property (strong,nonatomic) NSMutableArray *worksDatas;
@property (strong,nonatomic) NSMutableDictionary *rankDatas;

@property (nonatomic,strong) MJRefreshHeaderView *mjHeader;
@property (nonatomic,strong) MJRefreshFooterView *mjFooter;

- (IBAction)postBtnDidTap:(id)sender;

@end

@implementation JJActivityDetailViewController

- (void)dealloc
{
    [self.mjHeader free];
    [self.mjFooter free];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"JJActivityTopCell" bundle:nil] forCellReuseIdentifier:@"JJActivityTopCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"JJActivityDetaiViewCell" bundle:nil] forCellReuseIdentifier:@"JJActivityDetaiViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"JJActivityDetaiOpenCell" bundle:nil] forCellReuseIdentifier:@"JJActivityDetaiOpenCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"JJActivityTravelsCell" bundle:nil] forCellReuseIdentifier:@"JJActivityTravelsCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"JJActiityRankCell" bundle:nil] forCellReuseIdentifier:@"JJActiityRankCell"];
    self.activityStatus = _activityStatus;
    
    self.tableView.backgroundColor = kDefaultViewColor;
    
    WS(ws);
    
    self.headerView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 54)];
    self.headerView1.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    label.backgroundColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    label.text = @"  参赛作品：";
    [self.headerView1 addSubview:label];
    [self.headerView1 addSubview:self.postBtn];
    self.postBtn.frame = CGRectMake(SCREEN_WIDTH-100, 7, 90, 30);
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    topLine.backgroundColor = kDefaultBorderColor;
    [self.headerView1 addSubview:topLine];
    topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 43, SCREEN_WIDTH, 1)];
    topLine.backgroundColor = kDefaultBorderColor;
    [self.headerView1 addSubview:topLine];
    
    self.worksCountLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 30, 34)];
    self.worksCountLabel1.font = [UIFont systemFontOfSize:20];
    self.worksCountLabel1.backgroundColor = [UIColor clearColor];
    self.worksCountLabel1.textColor = RGB(39, 129, 155);
    [self.headerView1 addSubview:self.worksCountLabel1];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 11)];
    label.backgroundColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:9];
    label.text = @"件";
    [self.headerView1 addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@(18.5));
        make.left.mas_equalTo(ws.worksCountLabel1.mas_right).with.offset(2);
        make.size.mas_equalTo(CGSizeMake(30, 11));
    }];
    
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 34)];
    self.headerView.backgroundColor = [UIColor whiteColor];
    topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    topLine.backgroundColor = kDefaultBorderColor;
    [self.headerView addSubview:topLine];
    
    self.worksCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH, 34)];
    self.worksCountLabel.font = [UIFont systemFontOfSize:12];
    self.worksCountLabel.backgroundColor = [UIColor clearColor];
    self.worksCountLabel.textColor = RGB(99, 99, 99);
    [self.headerView addSubview:self.worksCountLabel];
    
    addNObserver(@selector(didCountDown:), kCountDownFinishNotification);
    
    self.mjHeader = [MJRefreshHeaderView header];
    self.mjHeader.scrollView = self.tableView;
    self.mjHeader.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [ws refresh];
    };
    
    [self reloadDatas];
    
    [self updateUIs];
    [self refresh];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setActivityStatus:(ActivityStatus)activityStatus{

    if (activityStatus==self.activityStatus) {
        return;
    }

    _activityStatus = activityStatus;
    if (activityStatus!=ActivityStatusWaiting) [self refreshWorksDatasAtIndex:1];
    [self updateUIs];
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
    
    [self refreshModel];
    [self refreshWorksDatasAtIndex:1];
}

- (void)refreshModel{
    if (nil==self.model.activityId) {
        return;
    }
    WS(ws);
    [AFNManager getObject:@{@"activityId":self.model.activityId}
                  apiName:@"Index/GetActivity"
                modelName:@"ActivityModel" requestSuccessed:^(id responseObject) {
                    if ([responseObject isKindOfClass:[ActivityModel class]]) {
                        ws.model = responseObject;
                        [ws reloadDatas];
                    }
                } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
              
                }];
}

- (void)didCountDown:(NSNotification *)noti{
    
    NSString *countDownId = noti.object;
    if ([[NSString stringWithFormat:@"%@",countDownId] isEqualToString:self.model.activityId]) {
      
        //倒计时完成 切换状态
        self.activityStatus = [self statusForModel:self.model];
        if (self.activityStatus!=ActivityStatusWaiting) [self refreshWorksDatasAtIndex:1];
    }
}

- (void)refreshWorksDatasAtIndex:(NSInteger) index{

    if (nil==self.model.activityId) {
        return;
    }
    
    WS(ws);
    [AFNManager getObject:@{@"pageIndex":@(index),@"activityId":self.model.activityId,@"pageSize":@(kCountPerPage)}
                  apiName:kResPathGetActivityTravels
                modelName:@"ActivityTravelModel" requestSuccessed:^(id responseObject) {
                    if ([responseObject isKindOfClass:[NSArray class]]) {
                        NSArray *array = responseObject;
                        if (index==1) {
                            ws.worksDatas = [array mutableCopy];
                        }else{
                            [ws.worksDatas addObjectsFromArray:array];
                        }
                        [ws reloadDatas];
                        ws.curPage = index;
                    }
                    else{
                        [ws showResultThenHide:@"加载不成功"];
                    }
                    [ws.mjFooter endRefreshing];
                    [ws.mjHeader endRefreshing];
                } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    NSLog(@"%@",errorMessage);
                    [ws showResultThenHide:errorMessage];
                    [ws.mjFooter endRefreshing];
                    [ws.mjHeader endRefreshing];
                }];
}

- (ActivityStatus)statusForModel:(ActivityModel *)model{
    
    ActivityStatus status = ActivityStatusWaiting;
    if ([JJServerTimeUtils isTimeGone:model.reviewStartTime-1]) {
        status = ActivityStatusVoting;
    }
    if ([JJServerTimeUtils isTimeGone:model.reviewEndTime-1]) {
        status = ActivityStatusEnd;
    }
    return status;
}

- (void)updateUIs{
    self.headerView.hidden = self.activityStatus==ActivityStatusWaiting;
    self.postBtn.hidden = self.activityStatus!=ActivityStatusWaiting;
    
    WS(ws);
    if (self.activityStatus!=ActivityStatusWaiting) {
        
        [self.mjFooter removeFromSuperview];
        [self.mjFooter free];
       
        self.mjFooter = [MJRefreshFooterView footer];
        self.mjFooter.scrollView = self.tableView;
        self.mjFooter.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
            [ws refreshWorksDatasAtIndex:ws.curPage+1];
        };
    }else{
        [self.mjFooter removeFromSuperview];
        [self.mjFooter free];
        self.mjFooter = nil;
    }
}


- (BOOL)voteTravelAtIndex:(NSInteger)index{
    
    if (![UserManager isLogin]) {
        [UserManager showLoginOnController:self];
        return NO;
    }
    
    if (self.model.isVote || !(0<=index && index<self.worksDatas.count) || !self.model.activityId) {
        if (self.model.isVote) {
            [self showResultThenHide:@"您已经投过票了"];
        }
        return NO;
    }
    
    WS(ws);
    ActivityTravelModel *data = [ws.worksDatas objectAtIndex:index];
    [AFNManager postObject:@{@"activityTravelId":data.activityTravelId} apiName:kResPathVoteActivity modelName:@"BaseModel" requestSuccessed:^(id responseObject) {
        [ws showResultThenHide:@"投票成功"];
        
        ws.model.isVote = YES;
        for (ActivityTravelModel *data in ws.worksDatas) {
            if (data.isVote) {
                data.isVote = NO;;
                data.voteCount--;
                break;
            }
        }
        ActivityTravelModel *data = [ws.worksDatas objectAtIndex:index];
        data.isVote = YES;
        data.voteCount++;
        
        [ws reloadDatas];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        [ws showResultThenHide:errorMessage];
        
        [ws reloadDatas];
    }];
    
    return NO;
}

- (void)showTravelAtIndex:(NSInteger)index{
    
    if (0<=index && index<self.worksDatas.count) {
        ActivityTravelModel *data = [self.worksDatas objectAtIndex:index];
        JJDetailViewController *detail = [[JJDetailViewController alloc] initWithNibName:@"JJDetailViewController" bundle:nil];
        detail.title = data.title;
        detail.travelId = data.travelId;
        detail.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (IBAction)postBtnDidTap:(id)sender {
    
    if (![UserManager isLogin]) {
        [UserManager showLoginOnController:self];
        return;
    }
    
    JJPreviewViewController *preview = [JJPreviewViewController sharedPreview];
    [JJPreviewViewController clean];
    preview.activityId = self.model.activityId;
    
    
    JJEditChooseViewController *edit = [[JJEditChooseViewController alloc] initWithNibName:@"JJEditChooseViewController" bundle:nil];
    [self presentViewController:edit animated:YES completion:^{
        edit.backBtn.hidden = NO;
    }];
}


- (void)reloadDatas{
    
    self.title = self.model.subject;
    self.rankDatas = [@{} mutableCopy];
    for (ActivityTravelModel *model in self.worksDatas) {
        switch (model.ranking) {
            case 1:
                [self.rankDatas setObject:model forKey:@"1"];
                break;
            case 2:
                [self.rankDatas setObject:model forKey:@"2"];
                break;
            case 3:
                [self.rankDatas setObject:model forKey:@"3"];
                break;
                
            default:
                break;
        }
    }
    
    [self.tableView reloadData];
    
    self.headerView.hidden = self.activityStatus==ActivityStatusWaiting;
    self.postBtn.hidden = self.activityStatus!=ActivityStatusWaiting;
    
    self.worksCountLabel1.text = [NSString stringWithFormat:@"%ld",(long)self.worksDatas.count];
    self.worksCountLabel.text = [NSString stringWithFormat:@"参赛作品 (共%ld件)",(long)self.worksDatas.count];
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = self.worksCountLabel1.lineBreakMode;
    CGSize size = [self.worksCountLabel1.text boundingRectWithSize:CGSizeMake(10000, 42) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.worksCountLabel1.font,NSParagraphStyleAttributeName:paragraphStyle.copy} context:nil].size;
    
    self.worksCountLabel1.frame = CGRectMake(72, 0, size.width, 42);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    NSInteger count = 0;
    switch (self.activityStatus) {
        case ActivityStatusWaiting:
            count = 2;
            break;
        case ActivityStatusVoting:
            count = 2;
            break;
        case ActivityStatusEnd:
            count = 3;
            break;
            
        default:
            break;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WS(ws);
    UITableViewCell *cell = nil;
    switch (self.activityStatus) {
        case ActivityStatusWaiting:
        {
            if (indexPath.section==0){
                JJActivityTopCell *tCell = [tableView dequeueReusableCellWithIdentifier:@"JJActivityTopCell"];
                tCell.startLabel.text = @"距离投稿结束还有";
                 tCell.startLabel.superview.hidden = NO;
                [tCell.bgImageView setImageWithURLString:self.model.detailImage placeholderImage:nil];
                [JJServerTimeUtils addListener:tCell
                                 startInterval:self.model.reviewStartTime
                                 changeKeyPath:@"countDownLabel.text"
                                 countDownText:nil
                                      userInfo:self.model.activityId
                               withTimeFormart:@"hh:mm:ss"];
                cell = tCell;
            }
            if (indexPath.section==1){
            
                JJActivityDetaiViewCell *dCell = [tableView dequeueReusableCellWithIdentifier:@"JJActivityDetaiViewCell"];
//                dCell.countLabel.text = [NSString stringWithFormat:@"参赛作品: %ld",self.model.travelsCount];
                dCell.detailLabel.text = self.model.summary;
                cell = dCell;
            }
        }
            break;
        case ActivityStatusVoting:
            switch (indexPath.section) {
                case 0:
                {
                    if (indexPath.row==0){
                        JJActivityTopCell *tCell = [tableView dequeueReusableCellWithIdentifier:@"JJActivityTopCell"];
                        tCell.startLabel.text = @"距离评审结束还有";
                         tCell.startLabel.superview.hidden = NO;
                        [tCell.bgImageView setImageWithURLString:self.model.detailImage placeholderImage:nil];
                        [JJServerTimeUtils addListener:tCell
                                         startInterval:self.model.reviewEndTime
                                         changeKeyPath:@"countDownLabel.text"
                                         countDownText:nil
                                              userInfo:self.model.activityId
                                       withTimeFormart:@"hh:mm:ss"];
                        cell = tCell;
                    }
                    if (indexPath.row==1){
                        JJActivityDetaiOpenCell *oCell = [tableView dequeueReusableCellWithIdentifier:@"JJActivityDetaiOpenCell"];
                        [oCell setDetailLabelText:self.model.summary];
//                        oCell.selfTable = tableView;
                       oCell.block = ^(BOOL isOpen){
                            ws.isDetailOpen = isOpen;
                            [ws.tableView beginUpdates];
                            [ws.tableView reloadData];
                            [ws.tableView endUpdates];
                        };
                        cell = oCell;
                    }
                }
                    break;
                case 1:
                {
                    //投票作品数量
                    cell = [self cellForTable:tableView atIndexPath:indexPath isEnd:NO];
                }
                    break;
                default:
                    break;
            }
            break;
        case ActivityStatusEnd:
            switch (indexPath.section) {
                case 0:
                {
                    if (indexPath.row==0){
                        JJActivityTopCell *tCell = [tableView dequeueReusableCellWithIdentifier:@"JJActivityTopCell"];
                        tCell.startLabel.text = @"活动已结束";
                        tCell.startLabel.superview.hidden = YES;
                        [tCell.bgImageView setImageWithURLString:self.model.detailImage placeholderImage:nil];
                        tCell.countDownLabel.text = nil;
                        [JJServerTimeUtils removeListenr:tCell forKeyPath:@"countDownLabel.text"];
                        cell = tCell;
                    }
                    if (indexPath.row==1){
                        JJActivityDetaiOpenCell *oCell = [tableView dequeueReusableCellWithIdentifier:@"JJActivityDetaiOpenCell"];
                        [oCell setDetailLabelText:self.model.summary];
                        //                        oCell.selfTable = tableView;
                        oCell.block = ^(BOOL isOpen){
                            ws.isDetailOpen = isOpen;
                            [ws.tableView beginUpdates];
                            [ws.tableView reloadData];
                            [ws.tableView endUpdates];
                        };
                        cell = oCell;
                    }

                }
                    break;
                case 1:
                {
                    //1，2，3名数量
                    JJActiityRankCell *tCell = [tableView dequeueReusableCellWithIdentifier:@"JJActiityRankCell"];
                    tCell.block = ^(NSInteger rank){
                        [ws showTravelAtIndex:rank];
                    };
                    NSMutableArray *objects = [@[] mutableCopy];
                    if (self.rankDatas[@"1"]) [objects addObject:self.rankDatas[@"1"]];
                    if (self.rankDatas[@"2"]) [objects addObject:self.rankDatas[@"2"]];
                    if (self.rankDatas[@"3"]) [objects addObject:self.rankDatas[@"3"]];
                    [tCell setRanksWithData:objects];
                    cell = tCell;
                }
                    break;
                case 2:
                {
                    cell = [self cellForTable:tableView atIndexPath:indexPath isEnd:YES];
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    return cell;
}

- (JJActivityTravelsCell *)cellForTable:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath isEnd:(BOOL)isEnd{
    //投票作品数量
    WS(ws);
    NSInteger count = (indexPath.row*2 + 2)<=self.worksDatas.count?2:1;
   JJActivityTravelsCell *tCell = [tableView dequeueReusableCellWithIdentifier:@"JJActivityTravelsCell"];
  
    if (isEnd) {
        if (indexPath.row==0) {
            tCell.view1.itemStyle = ActivityTravelItemStyleCrown;
            tCell.view2.itemStyle = ActivityTravelItemStyleDiamond;
        }else if (indexPath.row==1){
            tCell.view1.itemStyle = ActivityTravelItemStylePlatinum;
            tCell.view2.itemStyle = ActivityTravelItemStyleNormal;
        }
        else{
            tCell.view1.itemStyle = ActivityTravelItemStyleNormal;
            tCell.view2.itemStyle = ActivityTravelItemStyleNormal;
        }
        tCell.view1.voteBtn.userInteractionEnabled = NO;
        tCell.view2.voteBtn.userInteractionEnabled = NO;
        
        
        tCell.view1.voteCountLabel.hidden = NO;
        tCell.view1.voteBtn.frame = CGRectMake(tCell.view1.frame.size.width-26-15, tCell.view1.frame.size.height-26, 26, 26);
        
        tCell.view2.voteCountLabel.hidden = NO;
        tCell.view2.voteBtn.frame = CGRectMake(tCell.view1.frame.size.width-26-15, tCell.view1.frame.size.height-26, 26, 26);
        
        tCell.changeBlock = NULL;
    }else{
        tCell.view1.itemStyle = ActivityTravelItemStyleNormal;
        tCell.view2.itemStyle = ActivityTravelItemStyleNormal;
        tCell.view1.voteBtn.userInteractionEnabled = YES;
        tCell.view2.voteBtn.userInteractionEnabled = YES;
        
        tCell.view1.voteCountLabel.hidden = NO;
        tCell.view1.voteBtn.frame = CGRectMake(tCell.view1.frame.size.width-26-15, tCell.view1.frame.size.height-26, 26, 26);
        
        tCell.view2.voteCountLabel.hidden = NO;
        tCell.view2.voteBtn.frame = CGRectMake(tCell.view1.frame.size.width-26-15, tCell.view1.frame.size.height-26, 26, 26);
        tCell.changeBlock = ^(NSInteger index,BOOL isVote){
            //投票、、
           return [ws voteTravelAtIndex:index];
        };
    }
    tCell.path = indexPath;
    tCell.block = ^(NSInteger index){
        [ws showTravelAtIndex:index];
    };
    [tCell setTravelsWithData:[self.worksDatas subarrayWithRange:NSMakeRange(indexPath.row*2, count)]];
    return tCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger count = 0;
    switch (self.activityStatus) {
        case ActivityStatusWaiting:
            count = 1;
            break;
        case ActivityStatusVoting:
            switch (section) {
                case 0:
                    count = 2;
                    break;
                case 1:
                {
                    //投票作品数量
                    
                    count = ceil(self.worksDatas.count/2.0);
                }
                    break;
                default:
                    break;
            }
            break;
        case ActivityStatusEnd:
            switch (section) {
                case 0:
                    count = 2;
                    break;
                case 1:
                {
                    //1，2，3名数量
                    count = MIN(self.worksDatas.count, 1);
                }
                    break;
                case 2:
                {
                    //投票作品数量
                    count = ceil(self.worksDatas.count/2.0);
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat count = 0;
    switch (self.activityStatus) {
        case ActivityStatusWaiting:
        {
            if (indexPath.section==0) count = 170; //self.model.summary
            if (indexPath.section==1) count = self.model.summary.length?[JJActivityDetaiViewCell heightForText:self.model.summary]:0;//自动适应高度
        }
            break;
        case ActivityStatusVoting:
            switch (indexPath.section) {
                case 0:
                {
                    if (indexPath.row==0) count = 170;
                    if (indexPath.row==1) count = self.model.summary.length?[JJActivityDetaiOpenCell heightForText:self.model.summary isOpen:self.isDetailOpen]:0;//自动适应关闭的高度
                }
                    break;
                case 1:
                {
                    CGFloat offset = 8;
                    CGFloat scale = 640.0/1008;
                    CGFloat width = (SCREEN_WIDTH-offset*3)/2;
                    CGFloat height = width/scale;
                    count = height+8;
                }
                    break;
                default:
                    break;
            }
            break;
        case ActivityStatusEnd:
            switch (indexPath.section) {
                case 0:
                {
                    if (indexPath.row==0) count = 170;
                    if (indexPath.row==1) count = self.model.summary.length?[JJActivityDetaiOpenCell heightForText:self.model.summary isOpen:self.isDetailOpen]:0;//自动适应关闭的高度
                }
                    break;
                case 1:
                {
                    //1，2，3名数量
                    count = 105;
                }
                    break;
                case 2:
                {
                    //投票作品数量
                    CGFloat offset = 8;
                    CGFloat scale = 640.0/1008;
                    CGFloat width = (SCREEN_WIDTH-offset*3)/2;
                    CGFloat height = width/scale;
                    count = height+8;
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    return count;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = nil;
    switch (self.activityStatus) {
        case ActivityStatusWaiting:
        {
            switch (section) {
                case 0:
                    break;
                case 1:
                    //投票作品数量
                    view = self.headerView1;
                    break;
                default:
                    break;
            }
        }
            break;
        case ActivityStatusVoting:
            switch (section) {
                case 0:
                    break;
                case 1:
                    //投票作品数量
                    view = self.headerView;
                    break;
                default:
                    break;
            }
            break;
        case ActivityStatusEnd:
            switch (section) {
                case 0:
                    break;
                case 1:
                    break;
                case 2:
                    //投票作品数量
                    view = self.headerView;
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    CGFloat count = 0;
    switch (self.activityStatus) {
        case ActivityStatusWaiting:
            switch (section) {
                case 0:
                {
                    count = 0;
                }
                    break;
                case 1:
                {
                    count = 54;
                }
                    break;
                default:
                    break;
            }
            break;
        case ActivityStatusVoting:
            switch (section) {
                case 0:
                {
                    count = 0;
                }
                    break;
                case 1:
                {
                    count = 34;
                }
                    break;
                default:
                    break;
            }
            break;
        case ActivityStatusEnd:
            switch (section) {
                case 0:
                {
                    count = 0;
                }
                    break;
                case 1:
                {
                    count = 0;
                }
                    break;
                case 2:
                {
                    count = 34;
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    return count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

}
@end
