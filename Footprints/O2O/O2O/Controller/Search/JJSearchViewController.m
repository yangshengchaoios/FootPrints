//
//  JJSearchViewController.m
//  Footprints
//
//  Created by tt on 14-10-17.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJSearchViewController.h"
#import "MJRefresh.h"
#import "TimeUtils.h"
#import "JJHomeCollectionViewCell.h"
#import "JJHomeCollectionLayout.h"
#import "StringUtils.h"
#import "JJDetailViewController.h"
@interface JJSearchViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *searchInput;
@property (strong, nonatomic) IBOutlet UIView *searchBar;
@property (nonatomic,strong) MJRefreshFooterView *mjCollectionFooter;
@property (weak, nonatomic) IBOutlet UIButton *hideBtn;
@property (nonatomic,assign) NSInteger curPage;
@property (nonatomic,strong) NSString *curKey;
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (nonatomic,strong) NSMutableArray *dataSourceArr;

- (IBAction)hideBtnDidTap:(id)sender;
@end

@implementation JJSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.resultLabel.textColor = RGB(99, 99, 99);
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 32, SCREEN_WIDTH, kDefaultBorderWidth)];
    line.backgroundColor = kDefaultLineColor;
    [self.resultLabel.superview addSubview:line];
    self.searchInput.tintColor = kDefaultNaviBarColor;
    self.resultLabel.text = @"";
    
    //搜索按钮放在导航条的右边按钮
    self.searchBar.frame = CGRectMake(0, 0, SCREEN_WIDTH-50, 44);
    WS(ws);
    [self.searchInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.searchBar).with.insets(UIEdgeInsetsMake(7, 0, 7, 0));
    }];
    
    UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    negativeSeperator.width = 20;
    
//    self.navigationItem.rightBarButtonItems = @[ [[UIBarButtonItem alloc] initWithCustomView:self.searchBar],negativeSeperator];
    self.hidesBottomBarWhenPushed = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchBar];
    self.hideBtn.hidden = YES;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"JJHomeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"JJHomeCollectionViewCell"];
    JJHomeCollectionLayout *layout = [[JJHomeCollectionLayout alloc] init];
    layout.style = 3;
    self.collectionView.collectionViewLayout = layout;
    
    [self reloadData];
    
//    WeakSelfType blockSelf = self;
//    self.mjCollectionFooter = [MJRefreshFooterView footer];
//    self.mjCollectionFooter.scrollView = self.collectionView;
//    self.mjCollectionFooter.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
//        [blockSelf loadTravelsAtIndex:blockSelf.curPage+1 withKey:blockSelf.curKey];
//    };
    
    [self.searchInput becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
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
- (void)reloadData{
    
    [self.collectionView reloadData];
//    self.collectionView.scrollEnabled = self.dataSourceArr.count?YES:NO;
}

- (void)loadTravelsAtIndex:(NSInteger)index withKey:(NSString *)key{
    
    if ([StringUtils isEmpty:key])
    {
        [self.mjCollectionFooter endRefreshing];
        return;
    }
    
    WeakSelfType blockSelf = self;
    [AFNManager getObject:@{@"sortType":@3,@"pageIndex":@(index),@"pageSize":@(1000),@"keyword":key}
                  apiName:@"Index/GetSearchTravels"
                modelName:@"SearchTravelModel" requestSuccessed:^(id responseObject) {
                    SearchTravelModel *model = responseObject;
                    
                    if ([responseObject isKindOfClass:[SearchTravelModel class]]) {
                        if (index==1) {
                            blockSelf.dataSourceArr = [model.datas mutableCopy];
                        }else{
                            [blockSelf.dataSourceArr addObjectsFromArray:model.datas];
                        }
                        [blockSelf reloadData];
                        blockSelf.curPage = index;
                    }
                    else{
                        [blockSelf showResultThenHide:@"加载不成功"];
                    }
                    blockSelf.resultLabel.text = model.totalCount?[NSString stringWithFormat:@"相关事件  (%ld)",(long)model.totalCount]:@"没有搜索到相关内容";
                    [blockSelf.mjCollectionFooter endRefreshing];
                    
                } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    NSLog(@"%@",errorMessage);
                    [blockSelf showResultThenHide:errorMessage];
                    
                    blockSelf.resultLabel.text = @"没有搜索到相关内容";
                    [blockSelf.mjCollectionFooter endRefreshing];
                }];
}

#pragma mark - CollectionView
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSourceArr.count;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"JJHomeCollectionViewCell";
    JJHomeCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    IndexTravelModel *data = [self.dataSourceArr objectAtIndex:indexPath.row];
    [cell.bgImageView setImageWithURLString:data.image placeholderImage:nil];
    [cell.avatarImageView.avatarView setImageWithURLString:data.headImage placeholderImage:kPlaceHolderImage];
    cell.avatarImageView.iconView.hidden = data.memberStatus!=MemberStatusOfficer;
    
    cell.timeLabel.text = [TimeUtils friendTimeStringForDate:data.addDate];
    cell.viewCountLabel.text = [NSString stringWithFormat:@"%ld",(long)data.skimCount];
    cell.titleLabel.text = data.title;
   
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    IndexTravelModel *data = [self.dataSourceArr objectAtIndex:indexPath.row];
    JJDetailViewController *detail = [[JJDetailViewController alloc] initWithNibName:@"JJDetailViewController" bundle:nil];
    detail.title = data.title;
    detail.travelId = data.travelId;
    
    detail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detail animated:YES];
}

- (IBAction)hideBtnDidTap:(id)sender {
    
    [self.searchInput resignFirstResponder];
    self.hideBtn.hidden = YES;
}

#pragma mark - TextView

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{

    self.hideBtn.hidden = NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    [self.dataSourceArr removeAllObjects];
    [self reloadData];
    [self loadTravelsAtIndex:1 withKey:textField.text];
    self.hideBtn.hidden = YES;
    [self.searchInput resignFirstResponder];
    self.curKey = textField.text;
    return YES;
}

@end
