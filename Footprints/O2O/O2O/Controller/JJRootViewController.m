//
//  JJRootViewController.m
//  Footprints
//
//  Created by tt on 14-10-15.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJRootViewController.h"
#import "JJHomePageViewController.h"
#import "JJUserCenterViewController.h"
#import "JJAccountViewController.h"
#import "JJPreviewViewController.h"
#import "JJEditChooseViewController.h"

@interface JJRootViewController ()<UITabBarControllerDelegate>

@end

@implementation JJRootViewController

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
- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
//    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
     [NewGuyHelper addNewGuyHelperOnView:self.view withKey:@"NewGuyHomePage" andImage:[UIImage imageNamed:SCREEN_HEIGHT>480?@"新_1.png":@"新4_1.png"]];
}

#pragma mark -
#pragma mark UI Methods
- (void)setupDefaultUI{
        
    addNObserver(@selector(hideTabBar), @"EditViewNeedHideTabBar");
    addNObserver(@selector(showTabBar), @"EditViewNeedShowTabBar");
    addNObserver(@selector(didLoginOut), @"DidLoginOut");
    addNObserver(@selector(didSendTraval), @"TravalDidSend");
    
    self.delegate = self;
    
    JJHomePageViewController *home = [[JJHomePageViewController alloc] initWithNibName:@"JJHomePageViewController" bundle:nil];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:home];
    
    JJEditChooseViewController *edit = [[JJEditChooseViewController alloc] initWithNibName:@"JJEditChooseViewController" bundle:nil];
    UINavigationController *navi2 = [[UINavigationController alloc] initWithRootViewController:edit];
    
    JJUserCenterViewController *userCenter = [[JJUserCenterViewController alloc] initWithNibName:@"JJUserCenterViewController" bundle:nil];
    userCenter.model = [[UserManager sharedManager] loginUser];
    userCenter.isMy = YES;
    [userCenter refresh];
    UINavigationController *navi3 = [[UINavigationController alloc] initWithRootViewController:userCenter];
    [self setViewControllers:@[navi,navi2,navi3]];
    
    UITabBar *tabBar = self.tabBar;
    // repeat for every tab, but increment the index each time
    UITabBarItem *firstTab = [tabBar.items objectAtIndex:0];
    firstTab.title = @"首页";
    firstTab.image = [[UIImage imageNamed:@"tab_bar_1.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    firstTab.selectedImage = [[UIImage imageNamed:@"tab_bar_1_2.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    firstTab = [tabBar.items objectAtIndex:1];
    firstTab.title = @"发布";
    firstTab.image = [[UIImage imageNamed:@"tab_bar_2.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    firstTab.selectedImage = [[UIImage imageNamed:@"tab_bar_2_2.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    firstTab = [tabBar.items objectAtIndex:2];
    firstTab.title = @"个人中心";
    firstTab.image = [[UIImage imageNamed:@"tab_bar_3.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    firstTab.selectedImage = [[UIImage imageNamed:@"tab_bar_3_2.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
    if (0!=[self.viewControllers indexOfObject:viewController] && ![UserManager isLogin]) {
        [UserManager showLoginOnController:self];
        return NO;
    }
    
    if (1==[self.viewControllers indexOfObject:viewController]) {
        JJPreviewViewController *preview = [JJPreviewViewController sharedPreview];
        preview.activityId = nil;
    }
    BOOL hidden = 1==[self.viewControllers indexOfObject:viewController];
    
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:hidden?UIStatusBarAnimationNone:UIStatusBarAnimationFade];
    return YES;
}

- (void)hideTabBar{
    
    [UIView animateWithDuration:0.3 animations:^{
        self.tabBar.frame = CGRectMake(0, CGRectGetHeight(self.view.frame)+50, CGRectGetWidth(self.tabBar.frame), CGRectGetHeight(self.tabBar.frame));
    }];
}

- (void)didLoginOut{
    [self setSelectedIndex:0];
}

- (void)didSendTraval{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self performSelector:@selector(showStatusBar) withObject:nil afterDelay:0.4];
    [self setSelectedIndex:2];
}

- (void)showStatusBar{
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)showTabBar{
    
    [UIView animateWithDuration:0.3 animations:^{
        self.tabBar.frame = CGRectMake(0, CGRectGetHeight(self.view.frame)-CGRectGetHeight(self.tabBar.frame), CGRectGetWidth(self.tabBar.frame), CGRectGetHeight(self.tabBar.frame));
    }];
}
@end
