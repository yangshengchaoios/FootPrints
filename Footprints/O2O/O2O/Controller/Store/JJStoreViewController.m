//
//  JJStoreViewController.m
//  Footprints
//
//  Created by Jinjin on 14/12/2.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJStoreViewController.h"
#import "JJProductCell.h"
#import "MJRefresh.h"
#import "JJExchangeViewController.h"
#import "JJStoreRuleController.h"
#import "JJMyExchangeController.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>

@interface JJStoreViewController ()<UITableViewDataSource,UITableViewDelegate>
{
         SystemSoundID                 soundID;
}
@property (strong, nonatomic) IBOutlet UIButton *rlueBtn;
@property (weak, nonatomic) IBOutlet JJAvatarView *avatarView;
@property (weak, nonatomic) IBOutlet UIImageView *sexView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *myStore;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UILabel *notStartLabel;
@property (weak, nonatomic) IBOutlet UILabel *countDownLabel;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UIImageView *yaoView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (assign, nonatomic) BOOL canShake ;
@property (nonatomic,strong) NSArray *gifDatas;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSMutableArray *headerNames;
@property (nonatomic,strong) JJMemberModel *memberModel;
@property (nonatomic,strong) MJRefreshHeaderView *mjHeader;
@property (nonatomic,strong) UIView *headerView;

@property (weak, nonatomic) IBOutlet UIView *shakeView;
@property (weak, nonatomic) IBOutlet UIImageView *shakeImage;
@property (weak, nonatomic) IBOutlet UILabel *shakeTitle;
@property (weak, nonatomic) IBOutlet UIButton *showShakeResultBtn;
@property (weak, nonatomic) IBOutlet UIButton *hideShareBtn;

- (IBAction)showResult:(id)sender;

@property (strong,nonatomic) ShakeActivityModel *shakeModel;

- (IBAction)ruleBtnDidTap:(id)sender;
- (IBAction)myExchangeDidTap:(id)sender;
@end

@implementation JJStoreViewController

- (void)dealloc
{
    
    [self.shakeView removeFromSuperview];
    [self.mjHeader free];
    [JJServerTimeUtils removeListenr:self forKeyPath:@"countDownLabel.text"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"积分商城";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rlueBtn];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    addNObserver(@selector(didCountDown:), kCountDownFinishNotification);
    
    WS(ws);
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 135+16)];
    [self.headerView addSubview:self.topView];
    
    self.topView.frame= CGRectMake(8, 8, SCREEN_WIDTH-16, 135);
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-16, 1)];
    line.backgroundColor = kDefaultBorderColor;
    [self.topView addSubview:line];
    line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 135-40)];
    line.backgroundColor = kDefaultBorderColor;
    [self.topView addSubview:line];line = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-16-1, 0, 1, 135-40)];
    line.backgroundColor = kDefaultBorderColor;
    [self.topView addSubview:line];
    
    self.avatarView.avatarView.layer.cornerRadius = 30;
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.topView).with.offset(17);
        make.left.mas_equalTo(ws.topView).with.offset(8);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    self.sexView.backgroundColor = [UIColor clearColor];
    self.sexView.image = [UIImage imageNamed:@"male.png"];
    [self.sexView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.avatarView).with.offset(13);
        make.left.mas_equalTo(ws.avatarView.mas_right).with.offset(5);
        make.size.mas_equalTo(CGSizeMake(15, 19));
    }];
    
    self.nameLabel.font = [UIFont systemFontOfSize:17];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.sexView);
        make.left.mas_equalTo(ws.sexView.mas_right).with.offset(5);
        make.right.mas_equalTo(ws.myStore.mas_left).with.offset(15);
        make.height.mas_equalTo(@(20));
    }];
    
    self.scoreLabel.font = [UIFont systemFontOfSize:12];
    self.scoreLabel.textColor = RGB(39, 39, 39);
    [self.scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.nameLabel.mas_bottom).with.offset(10);
        make.left.mas_equalTo(ws.nameLabel);
        make.right.mas_equalTo(ws.nameLabel);
        make.height.mas_equalTo(@(14));
    }];
    
    [self.myStore mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@34);
        make.right.mas_equalTo(ws.topView).with.offset(-10);
        make.size.mas_equalTo(CGSizeMake(90, 30));
    }];
    
    self.bottomBar.backgroundColor = RGB(59, 186, 199);
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(ws.topView).with.offset(0);
        make.right.mas_equalTo(ws.topView).with.offset(0);
        make.left.mas_equalTo(ws.topView).with.offset(0);
        make.height.mas_equalTo(@40);
    }];
    
    self.tableView.tableHeaderView = self.headerView;
    [self.tableView registerNib:[UINib nibWithNibName:@"JJProductCell" bundle:nil] forCellReuseIdentifier:@"JJProductCell"];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    
    
    [self.notStartLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.bottomBar).with.insets(UIEdgeInsetsMake(0, 10, 0, 0));
    }];
    
    [self.countDownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.bottomBar).with.insets(UIEdgeInsetsMake(0, 0, 0, 10));
    }];
    
    
    self.yaoView.backgroundColor = [UIColor clearColor];
    self.yaoView.image = [UIImage imageNamed:@"icon_shake.png"];
    [self.yaoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.centerY.mas_equalTo(ws.bottomBar);
        make.right.mas_equalTo(ws.startLabel.mas_left);
    }];
    
    [self.startLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@(40));
        make.width.mas_equalTo(@(200));
        make.centerY.mas_equalTo(ws.bottomBar);
        make.centerX.mas_equalTo(ws.bottomBar);
    }];
    
    self.mjHeader = [MJRefreshHeaderView header];
    self.mjHeader.scrollView = self.tableView;
    self.mjHeader.beginRefreshingBlock = ^(MJRefreshBaseView *header){
    
        [ws refresh];
    };
    
    self.memberModel = [[UserManager sharedManager] loginUser];
    
    [self bindData];
    [self refresh];
    
    self.shakeTitle.textColor = RGB(79, 79, 79);
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.shakeView];
    [self showShake:NO title:@"摇啊摇 摇啊摇" shaking:NO animation:NO error:NO];
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"glass" ofType:@"wav"];
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self refresh];
}

- (void)showShake:(BOOL)show title:(NSString *)title shaking:(BOOL)shaking animation:(BOOL)animation error:(BOOL)error{

    [UIView animateWithDuration:animation?0.3:0 animations:^{
        self.shakeView.alpha = show?1:0;
    }];
    
    if (shaking) {
        [self addShakeAnimationForView:self.shakeImage];
    }else{
        [self.shakeImage.layer removeAllAnimations];
    }
    
    self.showShakeResultBtn.hidden = shaking;
    self.shakeTitle.text = title;
    [self.shakeImage setImage:shaking?[UIImage imageNamed:@"shake1.png"]:[UIImage imageNamed:@"1img.png"]];
    
    if (error) {
        self.showShakeResultBtn.hidden = YES;
        
        [self.shakeImage setImage:[UIImage imageNamed:@"2img.png"]];
    }
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

- (void)startShakeAnimation:(BOOL)start{

    self.yaoView.hidden = !start;
    
    if (start) {
        [self addShakeAnimationForView:self.yaoView];
    }else{
        [self.yaoView.layer removeAllAnimations];
    }
}

- (void)bindData{
    
    JJMemberModel *user = self.memberModel;
    
    [self.avatarView bindUserData:user];
    self.nameLabel.text = user.nickName;
    
    self.scoreLabel.text = [NSString stringWithFormat:@"当前积分：%ld",(long)user.currentPoint];
    self.sexView.image = [user.sex isEqualToString:@"男"]?[UIImage imageNamed:@"male.png"]:[UIImage imageNamed:@"female.png"];
    
     WS(ws);
    self.canShake = NO;
    if ([JJServerTimeUtils isTimeGone:self.shakeModel.startTime] && ![JJServerTimeUtils isTimeGone:self.shakeModel.endTime]) {
        //正在摇一摇
        [JJServerTimeUtils removeListenr:self forKeyPath:@"countDownLabel.text"];
        self.notStartLabel.hidden = YES;
        self.countDownLabel.hidden = YES;
        self.startLabel.hidden = NO;
        self.startLabel.text = @"摇一摇 有惊喜";
        [self.startLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(@(30));
            make.width.mas_equalTo(@(110));
            make.centerY.mas_equalTo(ws.bottomBar);
            make.centerX.mas_equalTo(ws.bottomBar).with.offset(10);
        }];
        [self startShakeAnimation:YES];
        self.canShake = YES;
    }else if ([JJServerTimeUtils isTimeGone:self.shakeModel.startTime] && [JJServerTimeUtils isTimeGone:self.shakeModel.endTime]) {
        //活动结束
        [JJServerTimeUtils removeListenr:self forKeyPath:@"countDownLabel.text"];
        self.notStartLabel.hidden = YES;
        self.countDownLabel.hidden = YES;
        self.startLabel.hidden = NO;
        self.startLabel.text = @"当前没有摇一摇活动";
        [self.startLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(@(30));
            make.width.mas_equalTo(@(180));
            make.centerY.mas_equalTo(ws.bottomBar);
            make.centerX.mas_equalTo(ws.bottomBar);
        }];
        [self startShakeAnimation:NO];
    }else{
        //正在倒计时
        [JJServerTimeUtils addListener:self
                         startInterval:self.shakeModel.startTime
                         changeKeyPath:@"countDownLabel.text"
                         countDownText:nil
                              userInfo:self.shakeModel.shakeActivityId
                       withTimeFormart:@"hh:mm:ss"];
        self.notStartLabel.hidden = NO;
        self.countDownLabel.hidden = NO;
        self.startLabel.hidden = YES;
        [self startShakeAnimation:NO];
    }
}



- (void)didCountDown:(NSNotification *)noti{
    
    NSString *countDownId = noti.object;
    if ([[NSString stringWithFormat:@"%@",countDownId] isEqualToString:self.shakeModel.shakeActivityId]) {
        //倒计时完成 切换状态
        [self bindData];
    }
}

- (void)refresh{
    [self getShakes];
    [self getGiftProductModel];
    [self getUserInfo];
}

- (void)reload{
    
    NSMutableDictionary *dataDic = [@{} mutableCopy];
    
    self.gifDatas = [[self.gifDatas sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        GiftProductModel *model1 = obj1;
        GiftProductModel *model2 = obj2;
        return model1.giftType>model2.giftType;
    }] mutableCopy];
    
    for (GiftProductModel *model in self.gifDatas) {
        if (model.giftStatus==1) {
            GiftType type = model.giftType;
            NSString *typeName = @"";
            switch (type) {
                case GiftTypeHuaFei:
                    typeName = @"话费";
                    break;
                case GiftTypeYouHuiQuan:
                     typeName = @"优惠券";
                    break;
                case GiftTypeShiWu:
                     typeName = @"实体商品";
                    break;
                default:
                    break;
            }
            NSMutableArray *datas = dataDic[typeName];
            if (nil==datas) {
                datas = [@[] mutableCopy];
            }
            [datas addObject:model];
            [dataDic setObject:datas forKey:typeName];
        }
    }
    
    self.headerNames = [@[] mutableCopy];
    if (dataDic[@"话费"]) {
        [self.headerNames addObject:@"话费"];
    }  if (dataDic[@"优惠券"]) {
        [self.headerNames addObject:@"优惠券"];
    }  if (dataDic[@"实体商品"]) {
        [self.headerNames addObject:@"实体商品"];
    }
    
    self.dataSource = [@[] mutableCopy];
    for (NSString *header in self.headerNames) {
        [self.dataSource addObject:dataDic[header]];
    }
    [self.tableView reloadData];
}

- (void)getGiftProductModel{
    
    WS(ws);
    [AFNManager getObject:nil apiName:@"MemberCenter/GetGiftProducts" modelName:@"GiftProductModel" requestSuccessed:^(id responseObject) {
        ws.gifDatas = responseObject;
        [ws reload];
        [ws.mjHeader endRefreshing];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        [ws.mjHeader endRefreshing];
    }];
}


- (void)getUserInfo{
    
    WS(ws);
    
    [AFNManager getObject:nil apiName:@"MemberCenter/GetMemberInfo" modelName:@"JJMemberModel" requestSuccessed:^(id responseObject) {
        ws.memberModel = responseObject;
        [ws bindData];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
    }];
}

- (void)getShakes{

    WS(ws);
    [AFNManager getObject:nil apiName:@"MemberCenter/GetShakes" modelName:@"ShakeActivityModel" requestSuccessed:^(id responseObject) {
        ws.shakeModel = responseObject;
        [ws bindData];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSArray *datas = self.dataSource[section];
    return datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 110;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    label.text = [NSString stringWithFormat:@"    %@",self.headerNames[section]];
    label.font = [UIFont systemFontOfSize:17];
    return  label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    JJProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JJProductCell"];
    
    NSArray *datas = self.dataSource[indexPath.section];
    GiftProductModel *model = datas[indexPath.row];
    
    cell.nameLabel.text = model.giftName;
    [cell.avatarLabel setImageWithURLString:model.giftImage placeholderImage:nil];
    cell.jifenLabel.text = [NSString stringWithFormat:@"%ld积分",(long)model.pointValue];
    cell.model = model;
    cell.countLabel.text = [NSString stringWithFormat:@"剩余数量:%i",model.skuCount];
    
    BOOL enabled = YES;
    if (model.skuCount==0) {
        enabled = NO;
    }
    if (model.pointValue>self.memberModel.currentPoint) {
        enabled = NO;
    }
    
    cell.exchangeBtn.enabled = enabled;
    WS(ws);
    cell.exChangeBlock = ^(GiftProductModel *exModel){
    
        JJExchangeViewController *exchange = [[JJExchangeViewController alloc] initWithNibName:@"JJExchangeViewController" bundle:nil];
        exchange.model = exModel;
        [ws.navigationController pushViewController:exchange animated:YES];
    };
    return cell;
}

- (IBAction)ruleBtnDidTap:(id)sender {
    JJStoreRuleController *rule = [[JJStoreRuleController alloc] initWithNibName:@"JJStoreRuleController" bundle:nil];
    rule.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:rule animated:YES];
}

- (IBAction)myExchangeDidTap:(id)sender {
    JJMyExchangeController *myExchange = [[JJMyExchangeController alloc] initWithNibName:@"JJMyExchangeController" bundle:nil];
    myExchange.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myExchange animated:YES];
}


- (void)addShakeAnimationForView:(UIView *)view{

    CABasicAnimation* shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    shake.fromValue = [NSNumber numberWithFloat:-M_PI/32];
    shake.toValue   = [NSNumber numberWithFloat:+M_PI/32];
    shake.duration = 0.1;
    shake.autoreverses = YES;
    shake.repeatCount = NSIntegerMax;
    [view.layer addAnimation:shake forKey:@"shakeAnimation"];
}


- (void)shake{
    
    if (self.shakeModel.shakeActivityId) {
        self.hideShareBtn.hidden = YES;
        AudioServicesPlaySystemSound (soundID);
        [self showShake:YES title:@"摇啊摇 摇啊摇" shaking:YES animation:YES error:NO];
        WS(ws);
        [AFNManager postObject:@{@"shakeActivityId":self.shakeModel.shakeActivityId} apiName:@"MemberCenter/ShakePoints" modelName:@"ShakeResult" requestSuccessed:^(id responseObject) {
    
            ws.hideShareBtn.hidden = NO;
            NSInteger point = [responseObject integerValue];
            [ws showShake:YES title:point>0?@"没有获得积分":[NSString stringWithFormat:@"恭喜获得%@积分",responseObject] shaking:NO animation:NO  error:point<=0];
            [ws performSelector:@selector(hideShake) withObject:nil afterDelay:5];
        } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
            
            ws.hideShareBtn.hidden = NO;
            [ws showShake:YES title:errorMessage shaking:NO animation:NO error:YES];
            [ws performSelector:@selector(hideShake) withObject:nil afterDelay:5];
        }];
    }
}


- (IBAction)showResult:(id)sender {
    
    [self showShake:NO title:self.shakeTitle.text shaking:NO animation:YES error:self.showShakeResultBtn.hidden];
    [self ruleBtnDidTap:nil];
}

- (IBAction)hideShake{
    [self showShake:NO title:self.shakeTitle.text shaking:NO animation:YES error:self.showShakeResultBtn.hidden];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake )
    {
        // User was shaking the device. Post a notification named "shake".
        [self shake];
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{	
}
@end
