//
//  JJSplashViewController.m
//  Footprints
//
//  Created by tt on 14-10-15.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJSplashViewController.h"
#import "JJAccountViewController.h"

@interface JJSplashViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *toolsBarView;
@property (weak, nonatomic) IBOutlet UIButton *loginAndRegBtn;
@property (weak, nonatomic) IBOutlet UIButton *skipBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *welcomeScroll;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

- (IBAction)loginAndRegBtnDidTap:(id)sender;
- (IBAction)skipBtnDidTap:(id)sender;

@end

@implementation JJSplashViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupDefaultUI];
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
#pragma mark -
#pragma mark UI Methods
- (void)setupDefaultUI{
    
//    BOOL isLogin = [UserManager isLogin];
//    self.skipBtn.hidden = !isLogin;
//    self.loginAndRegBtn.hidden = isLogin;
    
    NSInteger pageCount = 4;
    self.pageControl.numberOfPages = pageCount;
    for (NSInteger index=0; index<pageCount; index++) {
        UIImageView *img = [[UIImageView alloc] initWithFrame:self.welcomeScroll.bounds];
        img.clipsToBounds = YES;
        img.contentMode = UIViewContentModeScaleAspectFill;
        
        if (SCREEN_HEIGHT<568) {
            img.image = [UIImage imageNamed:[NSString stringWithFormat:@"ss%li.png",(long)(index+1)]];
            
        }else{
            img.image = [UIImage imageNamed:[NSString stringWithFormat:@"s%li.png",(long)(index+1)]];
        }
        img.frame = CGRectMake(index*CGRectGetWidth(self.welcomeScroll.frame), 0, CGRectGetWidth(self.welcomeScroll.frame), SCREEN_HEIGHT);
        [self.welcomeScroll addSubview:img];
        
        if (index==3) {
            self.skipBtn.frame = CGRectMake(0, 0, 150, 45);
            [self.welcomeScroll addSubview:self.skipBtn];
            self.skipBtn.center = CGPointMake(SCREEN_WIDTH/2 + 3*SCREEN_WIDTH, SCREEN_HEIGHT/2-30);
        }
    }
    
    self.welcomeScroll.contentSize = CGSizeMake(pageCount*CGRectGetWidth(self.welcomeScroll.frame), SCREEN_HEIGHT);
    self.welcomeScroll.delegate = self;
    
    WS(ws);
    [self.welcomeScroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    
    addNObserver(@selector(showHomePage), kShowHomePageNotification);
}

- (void)showHomePage{
    
    [self dismissViewControllerAnimated:NO completion:NULL];
}

#pragma mark -
#pragma mark Actions
- (IBAction)loginAndRegBtnDidTap:(id)sender {
    
    JJAccountViewController *accountController = [[JJAccountViewController alloc] initWithNibName:@"JJAccountViewController" bundle:nil];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:accountController];
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

- (IBAction)skipBtnDidTap:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSInteger page = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
    self.pageControl.currentPage = page;
}
@end
