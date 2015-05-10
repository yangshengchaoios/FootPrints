//
//  JJHomePageViewController.m
//  Footprints
//
//  Created by tt on 14-10-17.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJHomePageViewController.h"
#import "JJSearchViewController.h"
#import "AdScrollView.h"
#import "ZBFlowView.h"
#import "GAWebViewController.h"
#import "ZBWaterView.h"
#import "JJHomeCollectionViewCell.h"
#import "TimeUtils.h"
#import "JJHomeCollectionLayout.h"
#import "MJRefresh.h"
#import "JJFriendsEventsTableViewCell.h"
#import "JJDetailViewController.h"
#import "JJActivityViewCell.h"
#import "JJActivityDetailViewController.h"
#import "AFTitleView.h"
#import "JJUserCenterViewController.h"
#import "JJAddFriendsController.h"
#define kKeyOfCachedBannerArray         @"KeyOfCachedBannerArray"
#define kKeyOfCachedTravelArray         @"kKeyOfCachedTravelArray"
#define kKeyOfCachedFriendsArray        @"kKeyOfCachedFriendsArray"
#define kKeyOfCachedActivtityArray      @"kKeyOfCachedActivtityArray"

#define ksScrollAnimationDuration 3.0f


@interface JJHomePageViewController ()<UIScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UINavigationControllerDelegate,AFTitleViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *noFirendView;
@property (nonatomic,strong) NSMutableArray *dataSourceArr;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (strong, nonatomic) AdScrollView *headerView;
@property (nonatomic,strong) NSMutableArray* bannerViews;
@property (nonatomic,strong) NSMutableArray* bannerDatas;
@property (nonatomic,strong) NSMutableArray* friendsDatas;
@property (nonatomic,strong) NSMutableArray* activitiesDatas;
@property (nonatomic,assign) NSInteger curPage,lastIndex;
@property (nonatomic,assign) NSInteger curFriendsPage;
@property (nonatomic,assign) NSInteger curActivitiesPage;
@property (nonatomic,assign) CGFloat maxYOffset;
@property (nonatomic,assign) CGFloat segementY;
@property (nonatomic,assign) CGFloat curOffset;
@property (nonatomic,strong) NSArray *scrollViews;

@property (nonatomic,strong) AFTitleView *titleView;

@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic,strong) MJRefreshHeaderView *mjCollectionHeader;
@property (nonatomic,strong) MJRefreshFooterView *mjCollectionFooter;

- (IBAction)segmentedDidTap:(id)sender;
- (IBAction)addFriendBtnDidTap:(id)sender;

- (IBAction)searchButtonClicked:(id)sender;
@end

@implementation JJHomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupDefaultUI];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.collectionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-49);
    
    [self.mjCollectionFooter endRefreshing];
    [self.mjCollectionHeader endRefreshing];
    
    [self refresh];
    

}

- (void)dealloc
{
    [self.mjCollectionHeader free];
    [self.mjCollectionFooter free];
}
/*
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 
#pragma mark UI Methods

- (void)setupDefaultUI{
    
    self.navigationController.delegate = self;
    self.maxYOffset = CGRectGetHeight(self.pageControl.superview.frame)+4;
    
    //搜索按钮放在导航条的右边按钮
    self.titleView = [[[UINib nibWithNibName:@"AFTitleView" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    self.titleView.delegate = self;
    self.titleView.realSize = CGSizeMake(SCREEN_WIDTH, 48);
    self.titleView.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = self.titleView;
    
    self.bannerViews = [@[] mutableCopy];
    
    self.segmentedControl.tintColor = kDefaultNaviBarColor;
    
    UIView *bannerBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kBannerHeight)];
    bannerBGView.backgroundColor = [UIColor whiteColor];
    self.headerView = [[AdScrollView alloc] initWithFrame:bannerBGView.bounds];
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.headerView.PageControlShowStyle  = UIPageControlShowStyleCenter;
    WS(ws);
    self.headerView.didTapBlock = ^(NSInteger index){
        if (index < [ws.dataSourceArr count]) {
            BannerModel *tapModel = ws.bannerDatas[index];
            //1.不跳转，2.跳转到网址，3.内部跳转到足迹详情，4.跳转到活动
            switch (tapModel.linkType) {
                case 2://网址
                {
                    GAWebViewController *webView = [[GAWebViewController alloc] init];
                    webView.hidesBottomBarWhenPushed = YES;
                    [ws.navigationController pushViewController:webView animated:YES];
                    webView.title = tapModel.bannerTitle;
                    [webView loadHtml:tapModel.linkContent baseUrlStr:nil];
                }
                    break;
                case 3://微秀详情
                {
                    JJDetailViewController *detail = [[JJDetailViewController alloc] initWithNibName:@"JJDetailViewController" bundle:nil];
                    detail.title = tapModel.bannerTitle;
                    detail.travelId = tapModel.bannerLink;
                    detail.hidesBottomBarWhenPushed = YES;
                    [ws.navigationController pushViewController:detail animated:YES];
                    
                }
                    break;
                case 4://活动
                {
                    ActivityModel *model = [[ActivityModel alloc] init];
                    model.activityId = tapModel.bannerLink;
                    JJActivityDetailViewController *controller = [[JJActivityDetailViewController alloc] initWithNibName:@"JJActivityDetailViewController" bundle:nil];
                    controller.model = model;
                    controller.title = controller.model.subject;
                    controller.activityStatus = [ws statusForModel:controller.model];
                    controller.hidesBottomBarWhenPushed= YES;
                    [ws.navigationController pushViewController:controller animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
            NSLog(@"点击Banner %@",[tapModel toJSONString]);
        }
    };
    self.pageControl.hidden = YES;
    [bannerBGView addSubview:self.pageControl];
    [bannerBGView addSubview:self.headerView];
    
    UIView *segmentBGView = [[UIView alloc] initWithFrame:CGRectMake(0, kBannerHeight, SCREEN_WIDTH, kSegmentHeight)];
    segmentBGView.backgroundColor = [UIColor whiteColor];
    [segmentBGView addSubview:self.segmentedControl];
    self.segmentedControl.frame = CGRectMake(0, 0, SCREEN_WIDTH-40, 30);
    self.segmentedControl.center = CGPointMake(SCREEN_WIDTH/2, kSegmentHeight/2);
   
    
    //事件
    self.curPage = 1;
    self.dataSourceArr = [NSMutableArray array];
   
    self.collectionView.collectionViewLayout = [[JJHomeCollectionLayout alloc] init];
    self.mjCollectionHeader = [MJRefreshHeaderView header];
    self.mjCollectionHeader.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [ws loadBanner];
        if (ws.segmentedControl.selectedSegmentIndex == 0) {
            [ws loadTravelsAtIndex:1];
        }
        if (ws.segmentedControl.selectedSegmentIndex == 1) {
            [ws loadFriendsTravelsAtIndex:1];
        }
        if (ws.segmentedControl.selectedSegmentIndex == 2) {
            [ws loadActivitisAtIndex:1];
        }
    };
    self.mjCollectionFooter = [MJRefreshFooterView footer];
    self.mjCollectionFooter.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        if (ws.segmentedControl.selectedSegmentIndex == 0) {
            [ws loadTravelsAtIndex:ws.curPage+1];
        }
        if (ws.segmentedControl.selectedSegmentIndex == 1) {
            [ws loadFriendsTravelsAtIndex:ws.curFriendsPage+1];
        }
        if (ws.segmentedControl.selectedSegmentIndex == 2) {
            [ws loadActivitisAtIndex:ws.curActivitiesPage+1];
        }
    };
    
    self.collectionView.backgroundColor= [UIColor clearColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JJHomeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"JJHomeCollectionViewCell"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"JJFriendsEventsTableViewCell" bundle:nil] forCellWithReuseIdentifier:@"JJFriendsEventsTableViewCell"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"JJActivityViewCell" bundle:nil] forCellWithReuseIdentifier:@"JJActivityViewCell"];
    
    
    CGFloat offset = 10;
    CGFloat width = (CGRectGetWidth(self.collectionView.frame)-offset*3)/2;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(offset, kHeaderOffset+offset, width, 40)];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.image = [UIImage imageNamed:@"tiao_er.png"];
    imageView.clipsToBounds = YES;
    imageView.tag = 10302;
    [self.collectionView addSubview:imageView];
    
    self.mjCollectionFooter.scrollView = self.collectionView;
    self.mjCollectionHeader.scrollView = self.collectionView;
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.view);
        make.left.mas_equalTo(@0);
        make.width.mas_equalTo(@(SCREEN_WIDTH));
        make.height.mas_equalTo(@(SCREEN_HEIGHT-64));
    }];
    
    [self.collectionView addSubview:self.pageControl.superview];
    [self.collectionView addSubview:self.segmentedControl.superview];
    [self segmentedDidTap:nil];
    
    self.noFirendView.frame = CGRectMake(0, kHeaderOffset, SCREEN_WIDTH, 250);
    [self.collectionView addSubview:self.noFirendView];
}

/**
 *  用下载的banners数据重新刷新界面
 */
- (void)displayHeaderView {
    
//    WeakSelfType blockSelf = self;
    
    self.headerView.imageNameArray = self.bannerViews;
}

/**
 *  初始化bannerimage的数组
 */
- (void)initHeaderPageViewArray {
    
    BOOL needReloadBanner = NO;
    if (self.bannerViews.count != self.bannerDatas.count) {
        needReloadBanner = YES;
    }else{
        for (NSString *imagePath in self.bannerViews) {
            BannerModel *bannerModel = self.bannerDatas[[self.bannerViews indexOfObject:imagePath]];
            if (![bannerModel.bannerImage isEqualToString:imagePath]) {
                 needReloadBanner = YES;
                break;
            }
        }
    }
    
    if (needReloadBanner) {
        [self.bannerViews removeAllObjects];
        for (BannerModel *bannerModel in self.bannerDatas) {
            if ( ! [bannerModel isKindOfClass:[BannerModel class]]) {
                continue;
            }
            if (bannerModel.bannerImage) {
                [self.bannerViews addObject:bannerModel.bannerImage];
            }
        }
        self.pageControl.numberOfPages = [self.bannerViews count];
        self.pageControl.currentPage = 0;
        [self displayHeaderView];
    }
}


- (ActivityStatus)statusForModel:(ActivityModel *)model{
    
    ActivityStatus status = ActivityStatusWaiting;
    if ([JJServerTimeUtils isTimeGone:model.reviewStartTime]) {
        status = ActivityStatusVoting;
    }
    if ([JJServerTimeUtils isTimeGone:model.reviewEndTime]) {
        status = ActivityStatusEnd;
    }
    return status;
}

#pragma mark -
#pragma mark Data Methods
- (void)loadCache{
    [super loadCache];
    
    self.bannerDatas = [[self cachedObjectByKey:kKeyOfCachedBannerArray] mutableCopy];
    self.friendsDatas = [[self cachedObjectByKey:kKeyOfCachedFriendsArray] mutableCopy];
    self.dataSourceArr = [[self cachedObjectByKey:kKeyOfCachedTravelArray] mutableCopy];
    self.activitiesDatas = [[self cachedObjectByKey:kKeyOfCachedActivtityArray] mutableCopy];
    [self initHeaderPageViewArray];
}

- (void)refresh{
    
    [self loadBanner];
    [self.mjCollectionHeader beginRefreshing];
    [self loadFriendsTravelsAtIndex:1];
    [self loadActivitisAtIndex:1];
}

- (void)loadBanner{
    WeakSelfType blockSelf = self;
    [AFNManager getObject:@{}
                   apiName:kResPathGetBanners
                 modelName:@"BannerModel"
          requestSuccessed:^(id responseObject) {
              blockSelf.bannerDatas = [responseObject mutableCopy];
              [blockSelf initHeaderPageViewArray];
              [blockSelf saveObjectToCache:blockSelf.bannerDatas toKey:kKeyOfCachedBannerArray];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        NSLog(@"%@",errorMessage);
    }];
}

- (void)loadTravelsAtIndex:(NSInteger)index{

    WeakSelfType blockSelf = self;
    [AFNManager getObject:@{@"sortType":@3,@"pageIndex":@(index),@"pageSize":@(kCountPerPage)}
                  apiName:kResPathGetTravels
                modelName:@"IndexTravelModel" requestSuccessed:^(id responseObject) {
                    
                    if ([responseObject isKindOfClass:[NSArray class]]) {
                        NSArray *array = responseObject;
                        if (index==1) {
                            [blockSelf saveObjectToCache:array toKey:kKeyOfCachedTravelArray];
                            blockSelf.dataSourceArr = [array mutableCopy];
                        }else{
                            [blockSelf.dataSourceArr addObjectsFromArray:array];
                        }
                        [blockSelf.collectionView reloadData];
                        blockSelf.curPage = index;
                    }
                    else{
                        [blockSelf showResultThenHide:@"加载不成功"];
                    }
                    if (blockSelf.segmentedControl.selectedSegmentIndex==0) {
                        [blockSelf.mjCollectionFooter endRefreshing];
                        [blockSelf.mjCollectionHeader endRefreshing];
                    }
                } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    NSLog(@"%@",errorMessage);
                    [blockSelf showResultThenHide:errorMessage];
                    if (blockSelf.segmentedControl.selectedSegmentIndex==0) {
                        [blockSelf.mjCollectionFooter endRefreshing];
                        [blockSelf.mjCollectionHeader endRefreshing];
                    }
                }];
}


- (void)loadFriendsTravelsAtIndex:(NSInteger)index{
    WeakSelfType blockSelf = self;
    [AFNManager getObject:@{@"pageIndex":@(index),@"pageSize":@(kCountPerPage)}
                  apiName:kResPathGetFriendTravels
                modelName:@"FriendTravelModel" requestSuccessed:^(id responseObject) {
                    
                    if ([responseObject isKindOfClass:[NSArray class]]) {
                        NSArray *array = responseObject;
                        if (index==1) {
                            [blockSelf saveObjectToCache:array toKey:kKeyOfCachedFriendsArray];
                            blockSelf.friendsDatas = [array mutableCopy];
                        }else{
                            [blockSelf.friendsDatas addObjectsFromArray:array];
                        }
                        
                        if (blockSelf.segmentedControl.selectedSegmentIndex!=1) {
                            blockSelf.noFirendView.hidden = YES;
                        }else{
                            blockSelf.noFirendView.hidden = blockSelf.friendsDatas.count>0;
                        }
                        [blockSelf.collectionView reloadData];
                        blockSelf.curFriendsPage = index;
                    }
                    else{
                        [blockSelf showResultThenHide:@"加载不成功"];
                    }
                    if (blockSelf.segmentedControl.selectedSegmentIndex==1) {
                        [blockSelf.mjCollectionFooter endRefreshing];
                        [blockSelf.mjCollectionHeader endRefreshing];
                    }
                } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    NSLog(@"%@",errorMessage);
//                      [blockSelf showResultThenHide:errorMessage];
                    if (blockSelf.segmentedControl.selectedSegmentIndex==1) {
                        [blockSelf.mjCollectionFooter endRefreshing];
                        [blockSelf.mjCollectionHeader endRefreshing];
                    }
                }];
}


- (void)loadActivitisAtIndex:(NSInteger)index{
    
    WeakSelfType blockSelf = self;
    [AFNManager getObject:@{@"pageIndex":@(index),@"pageSize":@(kCountPerPage)}
                  apiName:kResPathGetActivities
                modelName:@"ActivityModel" requestSuccessed:^(id responseObject) {
                    if ([responseObject isKindOfClass:[NSArray class]]) {
                        NSArray *array = responseObject;
                        if (index==1) {
                            [blockSelf saveObjectToCache:array toKey:kKeyOfCachedActivtityArray];
                            blockSelf.activitiesDatas = [array mutableCopy];
                        }else{
                            [blockSelf.activitiesDatas addObjectsFromArray:array];
                        }
                        
                        //排序 进行中》投票中》结束
                        //排序 进行中》投票中》结束

                        NSMutableArray *watingDatas = [@[] mutableCopy];
                        NSMutableArray *VotingDatas = [@[] mutableCopy];
                        NSMutableArray *endDatas = [@[] mutableCopy];
                        for (ActivityModel *model in blockSelf.activitiesDatas) {
                            
                            ActivityStatus status1 = [blockSelf statusForModel:model];
                            if (status1==ActivityStatusWaiting) {
                                [watingDatas addObject:model];
                            }
                            if (status1==ActivityStatusVoting) {
                                [VotingDatas addObject:model];
                            }
                            if (status1==ActivityStatusEnd) {
                                [endDatas addObject:model];
                            }
                        }
                        [blockSelf.activitiesDatas removeAllObjects];
                        [blockSelf.activitiesDatas addObjectsFromArray:watingDatas];
                        [blockSelf.activitiesDatas addObjectsFromArray:VotingDatas];
                        [blockSelf.activitiesDatas addObjectsFromArray:endDatas];
//
//                        [watingDatas sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//                            ActivityModel *model1 = obj1;
//                            ActivityModel *model2 = obj2;
//                            NSComparisonResult result = NSOrderedSame;
//                            ActivityStatus status1 = [blockSelf statusForModel:model1];
//                            if (status1==ActivityStatusWaiting) {
//                                result = model1.reviewStartTime<model2.reviewStartTime?NSOrderedAscending:NSOrderedDescending;
//                            }else if (status1==ActivityStatusVoting) {
//                                result = model1.reviewEndTime<model2.reviewEndTime?NSOrderedAscending:NSOrderedDescending;
//                            }
//                            else{
//                                result = model1.reviewEndTime<model2.reviewEndTime?NSOrderedAscending:NSOrderedDescending;
//                            }
//                            return result;
//                        }];
                        
//                        [blockSelf.activitiesDatas sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//                            ActivityModel *model1 = obj1;
//                            ActivityModel *model2 = obj2;
//                            
//                            NSComparisonResult result = NSOrderedSame;
//                           
//                            ActivityStatus status1 = [blockSelf statusForModel:model1];
//                            ActivityStatus status2 = [blockSelf statusForModel:model2];
//                            
//                            if (status1 != status2) {
//                                result = status1<status2?NSOrderedAscending:NSOrderedDescending;
//                            }else{
//                                if (status1==ActivityStatusWaiting) {
//                                    result = model1.reviewStartTime<model2.reviewStartTime?NSOrderedAscending:NSOrderedDescending;
//                                }else if (status1==ActivityStatusVoting) {
//                                    result = model1.reviewEndTime<model2.reviewEndTime?NSOrderedAscending:NSOrderedDescending;
//                                }
//                                else{
//                                    result = model1.reviewEndTime<model2.reviewEndTime?NSOrderedDescending:NSOrderedAscending;
//                                }
//                            }
//                            return result;
//                        }];
                        
                        [blockSelf.collectionView reloadData];
                        blockSelf.curActivitiesPage = index;
                    }
                    else{
                        [blockSelf showResultThenHide:@"加载不成功"];
                    }
                    if (blockSelf.segmentedControl.selectedSegmentIndex==2) {
                        [blockSelf.mjCollectionFooter endRefreshing];
                        [blockSelf.mjCollectionHeader endRefreshing];
                    }
                } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    NSLog(@"%@",errorMessage);
                    [blockSelf showResultThenHide:errorMessage];
                    if (blockSelf.segmentedControl.selectedSegmentIndex==2) {
                        [blockSelf.mjCollectionFooter endRefreshing];
                        [blockSelf.mjCollectionHeader endRefreshing];
                    }
                }];
}

//显示搜索界面
- (IBAction)segmentedDidTap:(id)sender {
    
    if (![UserManager isLogin] && self.segmentedControl.selectedSegmentIndex==1) {
        self.segmentedControl.selectedSegmentIndex = self.lastIndex;
        [UserManager showLoginOnController:self];
        return;
    }
    
    UIView *view = [self.collectionView viewWithTag:10302];
    view.hidden = self.segmentedControl.selectedSegmentIndex!=0;
    if (self.segmentedControl.selectedSegmentIndex!=1) {
        self.noFirendView.hidden = YES;
    }else{
        self.noFirendView.hidden = self.friendsDatas.count>0;
    }
    
    self.lastIndex = self.segmentedControl.selectedSegmentIndex;
    [self.mjCollectionFooter endRefreshing];
    [self.mjCollectionHeader endRefreshing];
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            if (!self.dataSourceArr.count) {
                [self loadTravelsAtIndex:1];
            }
            break;
        case 1:
            
            if (!self.friendsDatas.count) {
                [self loadFriendsTravelsAtIndex:1];
            }
            [NewGuyHelper addNewGuyHelperOnView:[[UIApplication sharedApplication] keyWindow] withKey:@"NewGuyFiends" andImage:[UIImage imageNamed:SCREEN_HEIGHT>480?@"新_2.png":@"新4_2.png"]];
            break;
        case 2:
            
            if (!self.activitiesDatas.count) {
                [self loadActivitisAtIndex:1];
            }
            [NewGuyHelper addNewGuyHelperOnView:[[UIApplication sharedApplication] keyWindow] withKey:@"NewGuyActivity" andImage:[UIImage imageNamed:SCREEN_HEIGHT>480?@"新_3.png":@"新4_3.png"]];
            break;
            
        default:
            break;
    }
    [(JJHomeCollectionLayout *)self.collectionView.collectionViewLayout setStyle:self.segmentedControl.selectedSegmentIndex];
}

- (IBAction)addFriendBtnDidTap:(id)sender {
    JJAddFriendsController *addFriends = [[JJAddFriendsController alloc] initWithNibName:@"JJAddFriendsController" bundle:nil];
    addFriends.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addFriends animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
 
        CGFloat offset = scrollView.contentOffset.y;
        CGFloat y = kBannerHeight;
    if (offset>kBannerHeight) {
        y = offset;
    }
    CGRect frame  = self.segmentedControl.superview.frame;
    frame.origin = CGPointMake(frame.origin.x, y);
        self.segmentedControl.superview.frame = frame;
}


#pragma mark - CollectionView
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (self.segmentedControl.selectedSegmentIndex==0) {
        count = self.dataSourceArr.count;
    }if (self.segmentedControl.selectedSegmentIndex==1) {
        count = self.friendsDatas.count;
    }if (self.segmentedControl.selectedSegmentIndex==2) {
        count = self.activitiesDatas.count;
    }
    return count;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    
    
    if (self.segmentedControl.selectedSegmentIndex==0){
        static NSString * CellIdentifier = @"JJHomeCollectionViewCell";
        JJHomeCollectionViewCell * hcell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        IndexTravelModel *data = [self.dataSourceArr objectAtIndex:indexPath.row];
        [hcell.bgImageView setImageWithURLString:data.image placeholderImage:kPlaceHolderImage];
        [hcell.avatarImageView.avatarView setImageWithURLString:data.headImage placeholderImage:kPlaceHolderImage];
        hcell.avatarImageView.iconView.hidden = data.memberStatus!=MemberStatusOfficer;
        hcell.timeLabel.text = [TimeUtils timeStringFromDate:data.addDate withFormat:@"MM-dd HH:mm"];
        hcell.viewCountLabel.text = [NSString stringWithFormat:@"%ld",(long)data.skimCount];
        hcell.titleLabel.text = data.title;
        cell = hcell;
    }
    if (self.segmentedControl.selectedSegmentIndex==1) {
        JJFriendsEventsTableViewCell *fCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JJFriendsEventsTableViewCell" forIndexPath:indexPath];
        FriendTravelModel *model = self.friendsDatas[indexPath.row];
        fCell.locationLabel.text = model.location;
        fCell.guanIconView.hidden = model.memberStatus!=MemberStatusOfficer;
        fCell.locationIcon.hidden = [StringUtils isEmpty:model.location];
        fCell.viewsLabel.text = [NSString stringWithFormat:@"%ld",(long)model.skimCount];
        [fCell.avatarVIew setImageWithURLString:model.headImage placeholderImage:kPlaceHolderImage];
        fCell.nameLabel.text = model.remark?:model.memberName;
        fCell.eventTitleLabel.text = model.title;
        fCell.commentsLabel.text = [NSString stringWithFormat:@"%i",model.messageCount];
        fCell.timeLabel.text = [TimeUtils timeStringFromDate:model.addDate withFormat:@"MM-dd HH:mm"];
        [fCell setMessageCount:model.isSkim?0:model.unSkimCount];
        cell = fCell;
    }
    if (self.segmentedControl.selectedSegmentIndex==2) {
        JJActivityViewCell *aCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JJActivityViewCell" forIndexPath:indexPath];
        ActivityModel *model = self.activitiesDatas[indexPath.row];
        aCell.activityTitleLabel.text = model.subject;
        [aCell.iconView setImageWithURLString:model.indexImage placeholderImage:nil];
        aCell.detailLabel.text = model.summary;
        //作品数量
        aCell.worksLabel.text = [NSString stringWithFormat:@"%ld",(long)model.travelsCount];
        //观看数
        aCell.viewsLabel.text = [NSString stringWithFormat:@"%ld",(long)model.skimCount];
        //活动状态
        aCell.activityStatus = [self statusForModel:model];
        //倒计时
        NSTimeInterval interval = 0;
        switch (aCell.activityStatus) {
            case ActivityStatusWaiting:
                interval = model.reviewStartTime;
                break;
            case ActivityStatusVoting:
                interval = model.reviewEndTime;
                break;
            default:
                break;
        }
    
        
        aCell.timeLabel.text = [TimeUtils timeStringFromTimeStamp:[NSString stringWithFormat:@"%f",model.reviewStartTime] withFormat:@"MM-dd HH:mm"];
        
        if (interval>0) {
            [JJServerTimeUtils addListener:aCell
                             startInterval:interval
                             changeKeyPath:@"countDownLabel.text"
                             countDownText:@"已开始"
                                  userInfo:nil
                           withTimeFormart:@"倒计时 hh:mm:ss"];
        }else{
            
            [JJServerTimeUtils removeListenr:aCell forKeyPath:@"countDownLabel.text"];
            aCell.countDownLabel.text = nil;
        }
        cell = aCell;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.segmentedControl.selectedSegmentIndex==0) {
        IndexTravelModel *data = [self.dataSourceArr objectAtIndex:indexPath.row];
        JJDetailViewController *detail = [[JJDetailViewController alloc] initWithNibName:@"JJDetailViewController" bundle:nil];
        detail.title = data.title;
        detail.travelId = data.travelId;
        
        detail.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detail animated:YES];
        
    }
    if (self.segmentedControl.selectedSegmentIndex==1) {
        FriendTravelModel *travel = self.friendsDatas[indexPath.row];
        JJUserCenterViewController *user = [[JJUserCenterViewController alloc] initWithNibName:@"JJUserCenterViewController" bundle:nil];
        user.isMy = NO;
        JJMemberModel *model = [JJMemberModel new];
        model.memberId = travel.memberId;
        model.headImage = travel.headImage;
        model.remark = travel.remark;
        model.nickName = travel.memberName;
        user.model = model;
        [user refresh];
        user.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:user animated:YES];
    }
    if (self.segmentedControl.selectedSegmentIndex==2) {
        JJActivityDetailViewController *controller = [[JJActivityDetailViewController alloc] initWithNibName:@"JJActivityDetailViewController" bundle:nil];
        controller.model = self.activitiesDatas[indexPath.row];
        controller.title = controller.model.subject;
        controller.activityStatus = [self statusForModel:controller.model];
        controller.hidesBottomBarWhenPushed= YES;
        
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)titleViewDidTapSearchBtn:(AFTitleView *)titleView{
    
    [self searchButtonClicked:nil];
}


- (IBAction)searchButtonClicked:(id)sender {
    
    JJSearchViewController *searchViewController = [[JJSearchViewController alloc] initWithNibName:@"JJSearchViewController" bundle:nil];
    searchViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchViewController animated:NO];
}


@end
