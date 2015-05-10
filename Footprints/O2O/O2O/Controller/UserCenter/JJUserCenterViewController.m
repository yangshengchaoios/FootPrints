//
//  JJUserCenterViewController.m
//  Footprints
//
//  Created by Jinjin on 14/11/20.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJUserCenterViewController.h"
#import "JJFriendsViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UploadManager.h"
#import <UIImage+Resize.h>
#import "JJActivityCell.h"
#import "JJMessageCell.h"
#import "MJRefresh.h"
#import "JJDetailViewController.h"
#import "TimeUtils.h"
#import "UserManager.h"
#import "JJChooseFriendsController.h"
#import "JJStoreViewController.h"
#import "JJGroupRemarkController.h"
#import "JJSettingViewController.h"
#import "JJMyColletionController.h"
#import "AFUserCenterController.h"
#import "JJLoveMyController.h"
#import "JJMyAddFriendsController.h"
@interface JJUserCenterViewController ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIScrollViewDelegate>
- (IBAction)myFriendsDidTap:(id)sender;
- (IBAction)bgImageBtnDidTap:(id)sender;
- (IBAction)dataSegementDidChange:(id)sender;

@property (nonatomic,assign) BOOL isActivitys;
@property (nonatomic,assign) NSInteger curActivityPage;
@property (nonatomic,assign) NSInteger curMessagePage;
@property (nonatomic,strong) NSMutableArray *activityDatas;
@property (nonatomic,strong) NSMutableDictionary *activityDict;
@property (weak, nonatomic) IBOutlet UIImageView *xuxianImageView;
@property (nonatomic,strong) NSMutableArray *activityDateKeys;
@property (nonatomic,strong) NSMutableArray *messageDatas;
@property (nonatomic,strong) MJRefreshHeaderView *mjHeader;
@property (nonatomic,strong) MJRefreshFooterView *mjFooter;
@property (nonatomic,strong) NSString *playingMessageId;
@property (nonatomic,assign) MessagePlayStatus status;

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIButton *bgImageBtnView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarBgImageView;
@property (weak, nonatomic) IBOutlet JJAvatarView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;
@property (weak, nonatomic) IBOutlet UIImageView *shadowView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *signatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *loveMeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *iLoveTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *iLoveCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *loveMeCountLabel;
@property (weak, nonatomic) IBOutlet UIView *segmentBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dataSegement;
@property (weak, nonatomic) IBOutlet UIButton *userBtn;
@property (strong, nonatomic) IBOutlet UIScrollView *dropDownVIew;//
@property (weak, nonatomic) IBOutlet UILabel *nodataLabel;

@property (assign,nonatomic) BOOL isBlack;
@property (assign,nonatomic) BOOL isLike;
@property (assign,nonatomic) FriendType friendType;
@property (weak, nonatomic) IBOutlet UIButton *avatarBtn;
- (IBAction)actionBtnDidTap:(id)sender;

- (IBAction)avatarDidTap:(id)sender;
@end

@implementation JJUserCenterViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.mjFooter free];
    [self.mjHeader free];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupDefaultUI];
    
    
    addNObserver(@selector(playDidEnd:), PlayAudioDidEndNotification);
    
    addNObserver(@selector(musicDidDownloadEnd:), PlayAudioDidStartNotification);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self refresh];
    
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-(self.isMy?49:0));
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#define kSegmentBarHeight 60
#define kHeaderHeight 150
#define kAvatarLeftPadding 23
#define kAvatarWidht 60
#define kAvatarPadding 2
#define kLineHeight 19

- (void)setupDefaultUI{
    
    self.title = self.isMy?@"个人中心":@"时间轴";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.userBtn];
    self.view.backgroundColor = [UIColor whiteColor];
    self.dropDownVIew.alpha = 0;
    WS(ws);
    self.bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.tableView.tableHeaderView = self.headerView;
    [self.tableView registerNib:[UINib nibWithNibName:@"JJActivityCell" bundle:nil] forCellReuseIdentifier:@"JJActivityCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"JJMessageCell" bundle:nil] forCellReuseIdentifier:@"JJMessageCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.mjHeader = [MJRefreshHeaderView header];
    self.mjHeader.scrollView = self.tableView;
    self.mjHeader.backgroundColor = [UIColor whiteColor];
    self.mjHeader.beginRefreshingBlock = ^(MJRefreshBaseView *header){
        [ws refresh];
    };
    
    self.mjFooter = [MJRefreshFooterView footer];
    self.mjFooter.scrollView = self.tableView;
    self.mjFooter.beginRefreshingBlock = ^(MJRefreshBaseView *header){
        [ws loadNextPage];
    };
//    self.avatarBgImageView.backgroundColor = [UIColor lightGrayColor];
//    self.avatarImageView.backgroundColor = [UIColor redColor];
//    self.sexImageView.backgroundColor = [UIColor greenColor];
//    self.nameLabel.backgroundColor = [UIColor blueColor];
//    self.signatureLabel.backgroundColor = [UIColor whiteColor];
//    self.loveMeTitleLabel.backgroundColor = [UIColor redColor];
//    self.iLoveTitleLabel.backgroundColor = [UIColor redColor];
//    self.loveMeCountLabel.backgroundColor = [UIColor greenColor];
//    self.iLoveCountLabel.backgroundColor = [UIColor greenColor];
    [self loadDataWithModel:self.model];
    //位置约束
    
    
    self.isMy = self.isMy;
    self.isActivitys = YES;
    
    self.bgImageBtnView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    self.avatarBgImageView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    self.avatarImageView.avatarView.layer.cornerRadius = (kAvatarWidht-kAvatarPadding)/2;
    self.avatarBgImageView.clipsToBounds = YES;
    self.avatarBgImageView.layer.cornerRadius = (kAvatarWidht)/2;
    
    self.segmentBar.backgroundColor = [UIColor whiteColor];
    self.dataSegement.tintColor = kDefaultNaviBarColor;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, kSegmentBarHeight-15, SCREEN_WIDTH, kDefaultBorderWidth)];
    line.backgroundColor = kDefaultLineColor;
    [self.segmentBar addSubview:line];
    
    CGFloat alpha = 0.3;
    self.nameLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:alpha];
    self.nameLabel.shadowOffset = CGSizeMake(0, 1);
    self.iLoveTitleLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:alpha];
    self.iLoveTitleLabel.shadowOffset = CGSizeMake(0, 1);
    self.loveMeTitleLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:alpha];
    self.loveMeTitleLabel.shadowOffset = CGSizeMake(0, 1);
    self.signatureLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:alpha];
    self.signatureLabel.shadowOffset = CGSizeMake(0, 1);
    self.loveMeCountLabel.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:alpha];
    self.loveMeCountLabel.shadowOffset = CGSizeMake(0, 1);
    self.iLoveCountLabel.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:alpha];
    self.iLoveCountLabel.shadowOffset = CGSizeMake(0, 1);
    
    self.loveMeCountLabel.textColor = kDefaultNaviBarColor;
    self.iLoveCountLabel.textColor = kDefaultNaviBarColor;
    
    self.nodataLabel.frame = CGRectMake(0, 300, SCREEN_WIDTH, 30);
    [self.tableView addSubview:self.nodataLabel];
    self.nodataLabel.hidden = YES;
}

- (void)makeConstraints{
    WS(ws);
    UIView *sv = self.view;
    
    CGFloat  realSegmentHeight = self.isActivitys?kSegmentBarHeight:(kSegmentBarHeight-15);
    CGFloat height = (kHeaderHeight+realSegmentHeight);
    self.headerView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, height);
    
    [self.bgImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@0);
        make.left.mas_equalTo(@0);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, kHeaderHeight));
    }];
    
    [self.bgImageBtnView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(_bgImageView);
    }];
    [self.avatarBgImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_headerView).with.offset(-realSegmentHeight);
        make.left.mas_equalTo(_headerView).with.offset(kAvatarLeftPadding);
        make.size.mas_equalTo(CGSizeMake(kAvatarWidht, kAvatarWidht));
    }];
    [self.avatarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(_avatarBgImageView).with.insets(UIEdgeInsetsMake(kAvatarPadding, kAvatarPadding, kAvatarPadding, kAvatarPadding));
    }];
    [self.avatarBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(_avatarBgImageView);
    }];
    
    [self.xuxianImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(20, 60));
        make.centerX.mas_equalTo(_avatarBgImageView);
        make.top.mas_equalTo(@(kHeaderHeight));
    }];
    
    [self.sexImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(16, 16));
        make.right.mas_equalTo(_avatarBgImageView.mas_right).with.offset(5);
        make.bottom.mas_equalTo(_avatarBgImageView).with.offset(-2);
    }];
    
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@(kLineHeight));
        make.left.mas_equalTo(_avatarBgImageView.mas_right).with.offset(10);
//        make.left.mas_equalTo(_sexImageView.mas_right).with.offset(5);
        make.top.mas_equalTo(_avatarBgImageView).with.offset(-2);
        make.right.mas_equalTo(_headerView).with.offset(-10);
    }];
    
    [self.iLoveTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@(kLineHeight));
        make.left.mas_equalTo(_nameLabel).with.offset(0);
        make.top.mas_equalTo(_nameLabel.mas_bottom);
        make.width.mas_equalTo(@28);
    }];
    [self.iLoveCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@(kLineHeight));
        make.left.mas_equalTo(_iLoveTitleLabel.mas_right).with.offset(0);
        make.top.mas_equalTo(_nameLabel.mas_bottom);
        make.width.mas_equalTo(@35);
    }];
    [self.loveMeTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@(kLineHeight));
        make.left.mas_equalTo(_iLoveCountLabel.mas_right).with.offset(5);
        make.top.mas_equalTo(_nameLabel.mas_bottom);
        make.width.mas_equalTo(@28);
    }];
    [self.loveMeCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@(kLineHeight));
        make.left.mas_equalTo(_loveMeTitleLabel.mas_right).with.offset(0);
        make.top.mas_equalTo(_nameLabel.mas_bottom);
        make.width.mas_equalTo(@50);
    }];
    
    
    [self.signatureLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@(kLineHeight));
        make.left.mas_equalTo(_nameLabel).with.offset(0);
        make.top.mas_equalTo(_iLoveTitleLabel.mas_bottom);
        make.right.mas_equalTo(_headerView).with.offset(-10);
    }];
    
    [self.segmentBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@(kSegmentBarHeight-14));
        make.left.mas_equalTo(sv);
        make.right.mas_equalTo(sv);
        make.top.mas_equalTo(@(kHeaderHeight));
    }];
    [self.dataSegement mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(_segmentBar);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-40, 30));
    }];
    
    self.bgImageView.image = self.bgImageView.image;
    
    [self.view addSubview:self.dropDownVIew];
    [self.dropDownVIew mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.view).with.offset(5);
        make.right.mas_equalTo(ws.view).with.offset(-5);
        make.size.mas_equalTo(CGSizeMake(138, 183));
    }];
    
    [self.shadowView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 60));
        make.bottom.mas_equalTo(ws.bgImageBtnView);
        make.left.mas_equalTo(@0);
    }];
    self.shadowView.image = [UIImage imageNamed:@"zhezhao.png"];
//    self.shadowView.backgroundColor = [UIColor redColor];
    
    self.tableView.tableHeaderView = self.headerView;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor  = [UIColor whiteColor];
    UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shixian3.png"]];
    line.hidden = YES;
    line.tag = 10043;
    line.frame = CGRectMake(43, kHeaderHeight, 20, SCREEN_HEIGHT);
    [self.view insertSubview:line belowSubview:self.tableView];
}


- (void)playDidEnd:(NSNotification *)noti{
    NSString *messageID = (id)noti.object;
    if ([messageID isEqualToString:self.playingMessageId]) {
        NSLog(@"playDidEnd");
        self.playingMessageId = nil;
        self.status = MessagePlayStatusNormal;
        [self.tableView reloadData];
    }
}
- (void)musicDidDownloadEnd:(NSNotification *)noti{
    NSString *messageID = (id)noti.object;
    if ([messageID isEqualToString:self.playingMessageId]) {
        NSLog(@"musicDidDownloadEnd");
        
        self.status = MessagePlayStatusPlaying;
        [self.tableView reloadData];
    }
}


- (void)didLogin{
    self.model = [[UserManager sharedManager] loginUser];
    [self refresh];
}

- (void)setModel:(JJMemberModel *)model{
    _model = model;
    [self loadDataWithModel:model];
}

- (void)setIsMy:(BOOL)isMy{
    
    _isMy = isMy;
    if (self.headerView.superview) {
        [self makeConstraints];
    }
    self.segmentBar.hidden = !_isMy;
    self.xuxianImageView.hidden = self.activityDatas.count<=0 || _isMy;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (isMy) {
        addNObserver(@selector(didLogin), LoginUserModelDidChangeNotification);
    }
}

- (void)setIsActivitys:(BOOL)isActivitys{
    
    if (_isActivitys==isActivitys) {
        return;
    }
    
    _isActivitys = isActivitys;
    [self makeConstraints];
    [self.mjHeader endRefreshing];
    [self.mjFooter endRefreshing];
    [self reloadData];
}

- (void)loadDataWithModel:(JJMemberModel *)model{
    
    self.bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.avatarImageView bindUserData:model];
    [self.bgImageView setImageWithURLString:model.backgroundImage placeholderImage:[UIImage imageNamed:@"default-covor.jpg"]];//TODO 替换默认背景图
    self.nameLabel.text = model.nickName;
    self.sexImageView.image = [UIImage imageNamed:[model.sex isEqualToString:@"男"]?@"icon_woman_1.png":@"icon_male_1.png"];
    self.signatureLabel.text = model.signature;
    self.iLoveCountLabel.text = [NSString stringWithFormat:@"%ld",(long)model.mylove];
    self.loveMeCountLabel.text = [NSString stringWithFormat:@"%ld",(long)model.loveme];
}

- (void)refresh{
    if (self.model.memberId) {
        WS(ws);
        [AFNManager getObject:@{@"memberId":self.model.memberId} apiName:kResPathGetMemberInfo modelName:@"JJMemberModel" requestSuccessed:^(id responseObject) {
            ws.model = responseObject;
            [ws loadDataWithModel:responseObject];
        } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
            
        }];
        
        if (self.isActivitys) {
            [AFNManager getObject:@{@"pageIndex":@1,@"pageSize":kDefaultPageSize,@"memberId":self.model.memberId}
                          apiName:kResPathGetUserTimeTravels
                        modelName:@"TravelTimeModel"
                 requestSuccessed:^(id responseObject) {
                     ws.curActivityPage = 1;
                     TravelTimeModel *model = responseObject;
                     ws.isBlack = model.isBlack;
                     ws.friendType = model.friendType;
                     ws.isLike = model.friendType==FriendTypeFriends || model.friendType==FriendTypeILike;
                         ws.activityDatas = [[model.detailImages sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                             DetailTravelModel *model1 = obj1;
                             DetailTravelModel *model2 = obj2;
                             
                             NSTimeInterval interval1 = [model1.addDate timeIntervalSince1970];
                             NSTimeInterval interval2 = [model2.addDate timeIntervalSince1970];
                             
                             return interval1<interval2;
                         }] mutableCopy];
                     [ws reloadData];
                     [ws.mjHeader endRefreshing];
                 } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                     [ws.mjHeader endRefreshing];
                 }];
        }else{
            [AFNManager getObject:@{@"pageIndex":@1,@"pageSize":kDefaultPageSize}
                          apiName:kResPathGetMyMessages
                        modelName:@"MessageModel"
                 requestSuccessed:^(id responseObject) {
                     ws.curMessagePage = 1;
                     ws.messageDatas = [responseObject mutableCopy];
                     [ws reloadData];
                     [ws.mjHeader endRefreshing];
                 } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                     [ws.mjHeader endRefreshing];
                 }];
        }
    }else{
        [self.mjHeader endRefreshing];
    }
}

- (void)reloadData{
    
    UIView *lineView = [self.view viewWithTag:10043];
    if (self.isActivitys) {
        self.activityDateKeys = [@[] mutableCopy];
        self.activityDict = [@{} mutableCopy];
        
        for (DetailTravelModel *model in self.activityDatas) {
            NSString *timeKey = [TimeUtils timeStringFromDate:model.addDate withFormat:@"MM-dd"];
            if (timeKey) {
                NSMutableArray *datas = self.activityDict[timeKey];
                if (nil==datas) {
                    [self.activityDateKeys addObject:timeKey];
                    datas = [@[] mutableCopy];
                }
                [datas addObject:model];
                [self.activityDict setObject:datas forKey:timeKey];
            }
        }
        self.nodataLabel.hidden = self.activityDatas.count>0;
        self.xuxianImageView.hidden = self.activityDatas.count<=0 || self.isMy;
        lineView.hidden = self.activityDatas.count<=0;
    }else{
        self.nodataLabel.hidden = self.messageDatas.count>0;
        lineView.hidden = YES;
    }
    [self.tableView reloadData];
}

- (void)loadNextPage{
    
    if (self.model.memberId) {
        WS(ws);
        if (self.isActivitys) {
            [AFNManager getObject:@{@"pageIndex":@(self.curActivityPage+1),@"pageSize":kDefaultPageSize,@"memberId":self.model.memberId}
                          apiName:kResPathGetUserTimeTravels
                        modelName:@"TravelTimeModel"
                 requestSuccessed:^(id responseObject) {
                     TravelTimeModel *model = responseObject;
                     ws.isBlack = model.isBlack;
                     ws.friendType = model.friendType;
                     ws.isLike = model.friendType==FriendTypeFriends || model.friendType==FriendTypeILike;
                         ws.curActivityPage++;
                         [ws.activityDatas addObjectsFromArray:model.detailImages];
                         ws.activityDatas = [[ws.activityDatas sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                             DetailTravelModel *model1 = obj1;
                             DetailTravelModel *model2 = obj2;
                             
                             NSTimeInterval interval1 = [model1.addDate timeIntervalSince1970];
                             NSTimeInterval interval2 = [model2.addDate timeIntervalSince1970];
                             
                             return interval1<interval2;
                         }] mutableCopy];
                     [ws reloadData];
                     [ws.mjFooter endRefreshing];
                 } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                     [ws.mjFooter endRefreshing];
                 }];
        }else{
            [AFNManager getObject:@{@"pageIndex":@(self.curMessagePage+1),@"pageSize":kDefaultPageSize}
                          apiName:kResPathGetMyMessages
                        modelName:@"MessageModel"
                 requestSuccessed:^(id responseObject) {
                     ws.curMessagePage++;
                     [ws.messageDatas addObjectsFromArray:responseObject];
                     [ws reloadData];
                     [ws.mjFooter endRefreshing];
                 } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                     [ws.mjFooter endRefreshing];
                 }];
        }
    }else{
        [self.mjFooter endRefreshing];
    }
}

- (void)uploadUserBgImage:(UIImage *)img{
    
    CGFloat quality = 1000;
    UIImage *resizeImage = img;
    if (img.size.width*img.scale>quality) {
        resizeImage = [img resizedImage:CGSizeMake(quality, quality) interpolationQuality:kCGInterpolationDefault];
    }
    WS(ws);
    [self showHUDLoadingWithString:@"图片修改中.."];
    if (resizeImage) {
        [UploadManager uploadImage:UIImageJPEGRepresentation(resizeImage, 1) success:^(id result) {
            NSDictionary *data = result;
            NSMutableDictionary *dict = [@{} mutableCopy];
            [dict setObject:data[@"url"]?:@"" forKey:@"backgroundImage"];
            [AFNManager postObject:dict
                           apiName:kResPathChangeBackgroundImage
                         modelName:@"BaseModel"
                  requestSuccessed:^(id responseObject) {
                      
                      [ws showResultThenHide:@"图片修改成功"];
                      ws.bgImageView.image = resizeImage;
                  }
                    requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                        [ws showResultThenHide:@"图片修改失败"];
                    }];
            
        } failBlock:^(NSError *error) {
            [ws showResultThenHide:@"图片修改失败"];
        } progressBlock:^(CGFloat percent, long long requestDidSendBytes) {
            
        }];
    }
}

- (IBAction)showStore{
    self.dropDownVIew.alpha = 0;
    JJStoreViewController *store = [[JJStoreViewController alloc] initWithNibName:@"JJStoreViewController" bundle:nil];
    store.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:store animated:YES];
}

- (IBAction)showCollctions{
    
    self.dropDownVIew.alpha = 0;
    JJMyColletionController *store = [[JJMyColletionController alloc] initWithNibName:@"JJMyColletionController" bundle:nil];
    store.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:store animated:YES];
    
}

- (IBAction)showSetting{
    self.dropDownVIew.alpha = 0;
    
    JJSettingViewController *store = [[JJSettingViewController alloc] initWithNibName:@"JJSettingViewController" bundle:nil];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:store];
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

- (IBAction)showFriends{
    self.dropDownVIew.alpha = 0;
    JJFriendsViewController *friends = [[JJFriendsViewController alloc] initWithNibName:@"JJFriendsViewController" bundle:nil];
    friends.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:friends animated:YES];
}

- (IBAction)myFriendsDidTap:(id)sender {
    
    self.dropDownVIew.alpha = 0;
    if (self.isMy) {
        [UIView animateWithDuration:0.35 animations:^{
            self.dropDownVIew.alpha = self.dropDownVIew.alpha?0:1;
        }];
    }else{
        NSString *likeStr = self.isLike?@"取消关注":@"加关注";
        NSString *blackStr = self.isBlack?@"移除黑名单":@"加入黑名单";
        UIActionSheet *sheet = nil;
        if (self.friendType==FriendTypeFriends) {
            sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:likeStr,@"备注及标签",@"推荐给好友",blackStr,@"投诉", nil];
        }else{
            sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:likeStr,@"推荐给好友",blackStr,@"投诉", nil];
        }
        sheet.delegate = self;
        [sheet showInView:self.view];
    }
}

- (IBAction)bgImageBtnDidTap:(id)sender{
        self.dropDownVIew.alpha = 0;
    if (!self.isMy) return;
    BOOL isCameraSupport = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (isCameraSupport) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
        sheet.tag = 9;
        [sheet showInView:self.view];
    }else{
        [self showImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }
}


- (IBAction)actionBtnDidTap:(UIButton *)sender {
    
    self.dropDownVIew.alpha = 0;
    if (!self.isMy) return;
    if (sender.tag==0) {
        //关注
        JJMyAddFriendsController *myAdd = [[JJMyAddFriendsController alloc] initWithNibName:@"JJMyAddFriendsController" bundle:nil];
        myAdd.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:myAdd animated:YES];
    }else{
        //粉丝
        JJLoveMyController *loveMe = [[JJLoveMyController alloc] initWithNibName:@"JJLoveMyController" bundle:nil];
        loveMe.title = @"我的粉丝";
        loveMe.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:loveMe animated:YES];
    }
}

- (IBAction)avatarDidTap:(id)sender{
    self.dropDownVIew.alpha = 0;
    if (!self.isMy) return;
    AFUserCenterController *userCenter = [[AFUserCenterController alloc] initWithNibName:@"AFUserCenterController" bundle:nil];
    userCenter.hidesBottomBarWhenPushed = YES;
    userCenter.user = self.model;
    [self.navigationController pushViewController:userCenter animated:YES];
}

- (IBAction)dataSegementDidChange:(UISegmentedControl *)sender {
        self.dropDownVIew.alpha = 0;
    self.isActivitys = sender.selectedSegmentIndex==0;
}

- (void)showImagePicker:(UIImagePickerControllerSourceType) type{
    
    UIImagePickerController *imagepicker = [[UIImagePickerController alloc] init];
    imagepicker.sourceType = type;
    imagepicker.delegate = self;
    imagepicker.allowsEditing = YES;
    imagepicker.mediaTypes = @[(NSString*)kUTTypeImage];
    [self presentViewController:imagepicker animated:YES completion:NULL];
}
#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.isActivitys?self.activityDateKeys.count:1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger count = 0;
    if (self.isActivitys) {
        NSString *key = self.activityDateKeys[section];
        NSArray *datas = self.activityDict[key];
        count = datas.count;
    }else{
        count = self.messageDatas.count;
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = 0;
    if (self.isActivitys) {
        NSString *key = self.activityDateKeys[indexPath.section];
        NSArray *datas = self.activityDict[key];
        DetailTravelModel *traveModel = datas[indexPath.row];
        height = [JJActivityCell heightForFCPhotoCell:traveModel.detailImages.count];
    }else{
        
        MessageModel *message = self.messageDatas[indexPath.row];
        height = [JJMessageCell heightForFCPhotoCell:message.msgContent messageType:message.msgType andCellType:MessageCellTypeWithTravel];
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = nil;
    if (self.isActivitys) {
        JJActivityCell *aCell = [tableView dequeueReusableCellWithIdentifier:@"JJActivityCell"];
        NSString *key = self.activityDateKeys[indexPath.section];
        NSArray *datas = self.activityDict[key];
        DetailTravelModel *traveModel = datas[indexPath.row];
        aCell.travelModel = traveModel;
        if (indexPath.row==0) {
            aCell.dateLabel.text = self.activityDateKeys[indexPath.section];
            aCell.dateLabel.hidden = NO;
            aCell.lineImageVIew.image = [[UIImage imageNamed:@"shixian.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:18];
        }else{
            aCell.dateLabel.hidden = YES;
            aCell.lineImageVIew.image = [[UIImage imageNamed:@"shixian2.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
        }
        cell = aCell;
        
    }else{
        WS(ws);
        MessageModel *message = self.messageDatas[indexPath.row];
        JJMessageCell *mCell = [tableView dequeueReusableCellWithIdentifier:@"JJMessageCell"];
        mCell.messageModel = message;
        mCell.cellType = MessageCellTypeWithTravel;
        [mCell.avatarImageView.avatarView setImageWithURLString:message.friendMemberHeadImage placeholderImage:kPlaceHolderImage];
        mCell.avatarImageView.iconView.hidden = message.memberStatus!=MemberStatusOfficer;
        [mCell.activityImage setImageWithURLString:message.msgImage placeholderImage:kPlaceHolderImage];
        
        
        if ([self.playingMessageId isEqualToString:message.messageId]) {
            [mCell setPlayStatus:self.status];
        }else{
            [mCell setPlayStatus:MessagePlayStatusNormal];
        }
        
        mCell.didTap = ^(NSString *memberId){
            JJMemberModel *model = [[JJMemberModel alloc] init];
            model.memberId = memberId;
            if (![[UserManager loginUserId] isEqualToString:model.memberId]) {
                JJUserCenterViewController *user = [[JJUserCenterViewController alloc] initWithNibName:@"JJUserCenterViewController" bundle:nil];
                user.isMy = NO;
                user.model = model;
                [user refresh];
                user.hidesBottomBarWhenPushed = YES;
                [ws.navigationController pushViewController:user animated:YES];
            }
        };
        mCell.audioDidTap = ^(NSString *path,NSString *messageId,JJMessageCell *cell){
            
            if (path) {
                if ([ws.playingMessageId isEqualToString:messageId]) {
                    //暂停
                    ws.status = MessagePlayStatusNormal;
                    [cell setPlayStatus:MessagePlayStatusNormal];
                    [[AudioUtils sharedAudioUtils] stopPlay];
                    ws.playingMessageId = nil;
                }else{
                    //播放
                    BOOL isPlaying = [[AudioUtils sharedAudioUtils] playAudioAtPath:path andUserInfo:messageId];
                    ws.status = isPlaying?MessagePlayStatusPlaying:MessagePlayStatusDownloading;
                    [cell setPlayStatus:ws.status];
                    ws.playingMessageId = messageId;
                }
                [ws reloadData];
            }
        };

        cell = mCell;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    self.dropDownVIew.alpha = 0;
    if (self.isActivitys) {
        NSString *key = self.activityDateKeys[indexPath.section];
        NSArray *datas = self.activityDict[key];
        DetailTravelModel *traveModel = datas[indexPath.row];
        
        JJDetailViewController *detail = [[JJDetailViewController alloc] initWithNibName:@"JJDetailViewController" bundle:nil];
        detail.title = traveModel.title;
        detail.travelId = traveModel.travelId;

        detail.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detail animated:YES];

    }else{
        MessageModel *model = self.messageDatas[indexPath.row];
        JJDetailViewController *detail = [[JJDetailViewController alloc] initWithNibName:@"JJDetailViewController" bundle:nil];
        detail.travelId = model.travelId;
        detail.showMessageId = model.messageId;
        if (model.contentType!=2) {
            [detail commentToUsername:model.nickName andUserId:model.friendMemberId];
        }
        detail.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    self.dropDownVIew.alpha = 0;
}


#pragma mark - actionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.tag==1001) {
        NSString *content = nil;
        switch (buttonIndex) {
            case 0:
                content = @"色情";
                break;
            case 1:
                content = @"垃圾广告";
                break;
            case 2:
                content = @"人身攻击";
                break;
            case 3:
                content = @"政治";
                break;
            default:
                break;
        }
        [self jubao:content];
    }else if (actionSheet.tag==9) {
        switch (buttonIndex) {
            case 0:
                [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
                break;
            case 1:
                [self showImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
                break;
            default:
                break;
        }
    }else{
        if (self.friendType==FriendTypeFriends) {
            switch (buttonIndex) {
                case 0:
                    //关注
                    [self like];
                    break;
                case 1:
                    //备注及标签
                    [self bookmark];
                    break;
                case 2:
                    //推荐
                    [self recommendFriends];
                    break;
                case 3:
                    //黑名单
                    [self blackList];
                    break;
                case 4:
                    //投诉
                    [self showJubaoActionSheet];
                    break;
                default:
                    break;
            }
        }else{
            switch (buttonIndex) {
                case 0:
                    //关注/
                    [self like];
                    break;
                case 1:
                    //推荐
                    [self recommendFriends];
                    break;
                case 2:
                    //黑名单
                    [self blackList];
                    break;
                case 3:
                    //投诉
                    [self showJubaoActionSheet];
                    break;
                    
                default:
                    break;
            }
        }
    }
}

- (void)recommendFriends{

    JJChooseFriendsController *friends = [[JJChooseFriendsController alloc] initWithNibName:@"JJChooseFriendsController" bundle:nil];
    friends.isRecommend = YES;
    friends.recommendMemberId = self.model.memberId;
    friends.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:friends animated:YES];
}

- (void)bookmark{
    
    JJGroupRemarkController *remark = [[JJGroupRemarkController alloc] initWithNibName:@"JJGroupRemarkController" bundle:nil];
    remark.memberId = self.model.memberId;
    remark.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:remark animated:YES];
}

- (void)like{
    BOOL like = self.isLike?NO:YES;
    NSString *modelId = self.model.memberId;
    if (!modelId) {
        return;
    }
    WS(ws);
    if (like) {
        [AFNManager postObject:@{@"friendMemberId":modelId}
                       apiName:kResPathAddMember
                     modelName:@"BaseModel"
              requestSuccessed:^(id responseObject) {
                  [ws showResultThenHide:@"关注成功"];
                  ws.isLike = like;
                  ws.friendType = (ws.friendType==FriendTypeFans)?FriendTypeFriends:FriendTypeILike;
                  [ws refresh];
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    [ws showResultThenHide:errorMessage?:@"关注失败"];
                }];
    }else{
        [AFNManager postObject:@{@"friendMemberId":modelId}
                       apiName:@"MemberCenter/DeleteMember"
                     modelName:@"BaseModel"
              requestSuccessed:^(id responseObject) {
                  [ws showResultThenHide:@"关注已取消"];
                  ws.isLike = NO;
                  ws.friendType = (ws.friendType==FriendTypeFriends)?FriendTypeFans:FriendTypeStranger;
                  [ws refresh];
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    [ws showResultThenHide:errorMessage?:@"取消失败"];
                }];
    }
}

- (void)blackList{
    
    BOOL addToBlack = self.isBlack?NO:YES;
    NSString *modelId = self.model.memberId;
    if (!modelId) {
        return;
    }
    WS(ws);
    [AFNManager postObject:@{@"blackMemberId":modelId,@"operateType":@(addToBlack?1:0)}
                   apiName:@"MemberCenter/OperateBlacklist"
                 modelName:@"BaseModel"
          requestSuccessed:^(id responseObject) {
              [ws showResultThenHide:addToBlack?@"已加入黑名单":@"已从黑名单移除"];
              ws.isBlack = addToBlack;
              [ws refresh];
          }
            requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                [ws showResultThenHide:errorMessage];
            }];
}

- (void)showJubaoActionSheet{

    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择投诉原因" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"色情",@"垃圾广告",@"人身攻击",@"政治", nil];
    sheet.tag = 1001;
    [sheet showInView:self.view];
}

- (void)jubao:(NSString *)content{
    NSString *modelId = self.model.memberId;
    if (!modelId || !content) {
        return;
    }
    WS(ws);
    [AFNManager postObject:@{@"toObjectId":modelId,@"toTypeId":@(1),@"category":content}
                   apiName:@"Index/MemberComplaint"
                 modelName:@"BaseModel"
          requestSuccessed:^(id responseObject) {
              [ws showResultThenHide:@"已举报"];
          }
            requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                [ws showResultThenHide:errorMessage];
            }];
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    //获取图片裁剪的图
    UIImage* img = [info objectForKey:UIImagePickerControllerEditedImage];
    [self uploadUserBgImage:[JJUserCenterViewController fixOrientation:img]];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

+ (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
@end
