//
//  JJAppDelegate.m
//  O2O
//
//  Created by tt on 14-9-17.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJAppDelegate.h"
#import "JJRootViewController.h"
#import "JJSplashViewController.h"
#import <SMS_SDK/SMS_SDK.h>
#import "BMapKit.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaHandler.h"
#import "UMSocial.h"

#import "JJCommentViewController.h"
#import "JJRecordView.h"


#define kTGO_AppInfo_Key          @"DP_AppInfo_Key"
@interface JJAppDelegate(){
    BMKMapManager* _mapManager;
}
@end

@implementation JJAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UINavigationBar appearance] setBarTintColor:kDefaultNaviBarColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:RGB(0, 204, 255),NSForegroundColorAttributeName, nil]forState:UIControlStateSelected];
    [[UITabBar appearance] setBarTintColor:kDefaultNaviBarColor];

    [[UISwitch appearance] setOnTintColor:kDefaultNaviBarColor];
    
//    for(NSString *familyName in [UIFont familyNames])
//    {
//        NSLog(@"familyName = %@", familyName);
//        
//        for(NSString *fontName in [UIFont fontNamesForFamilyName:familyName])
//        {
//            NSLog(@"\tfontName = %@", fontName);
//        }  
//    }
    
    //确保缓存文件的目录存在
    [[StorageManager sharedInstance] ensureAllDirectories];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    
    self.window.rootViewController = [self setupRootViewController];
    
    [self.window makeKeyAndVisible];
    
    //若为新版本，弹出TipsView
    if ([self isFirstLoadForVersion:[self getCurrentVersion]]) {
        JJSplashViewController *splash = [[JJSplashViewController alloc] initWithNibName:@"JJSplashViewController" bundle:nil];
        [self.window.rootViewController presentViewController:splash animated:NO completion:NULL];
        
        [self setCurrentLoadVersion:[self getCurrentVersion]];
    }
    
    [self initExternal];
    
    ///注册HUD出现通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(HUDComeOut:) name:kLocalNotiHUDComeOut object:nil];
    [self checkVersion:NO andCanSkip:YES];
    
    

    return YES;
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return  [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation{
    return  [UMSocialSnsService handleOpenURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark 三方控制
- (void)initExternal{
    
    //SMS
    [SMS_SDK registerApp:kSMS_SDKAppkey withSecret:kSMS_SDKAppSecret];
    
    NSString *string = kSocialSinaBackUrl;
    [UMSocialData setAppKey:@"54910465fd98c5f75b000f17"];
    //设置微信AppId，url地址传nil，将默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:kSocialWeixinId appSecret:kSocialWeixinKey url:kSocialShareURL];
    [UMSocialSinaHandler openSSOWithRedirectURL:kSocialSinaBackUrl];
    
    
    //百度
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:kBaiduMap_Secret  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
}

#pragma mark 界面控制
- (UIViewController *)setupRootViewController{
    return [[JJRootViewController alloc] initWithNibName:@"JJRootViewController" bundle:nil];
}


#pragma mark 版本管理
- (NSString *)getCurrentVersion{
    return kAppVersion;
}

#define kHaveLoadedVersion @"kHaveLoadedVersion"
//检测当前版本是否是第一次启动
- (BOOL)isFirstLoadForVersion:(NSString *)version{
    NSString *haveLoadedVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kHaveLoadedVersion];
    return ![version isEqualToString:haveLoadedVersion];
}

//将当前版本设置最新启动的版本
- (void)setCurrentLoadVersion:(NSString *)version{
    
    if (version) {
        [[NSUserDefaults standardUserDefaults] setObject:version forKey:kHaveLoadedVersion];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}



#pragma mark - 版本更新
- (void)checkVersion:(BOOL)showMessage andCanSkip:(BOOL)skip {
    
    __block BOOL canSkip = skip;
    __block BOOL showM = showMessage;
    WS(ws);
    if(showMessage) [self showHUDLoadingWithString:@"检测中"];
    [AFNManager getObject:@{@"appType":@1,@"appVersionNumber":AppVersion}
                   apiName:@"Index/CheckVersion"
                 modelName:@"VersionModel"
          requestSuccessed:^(VersionModel *responseObject) {
        
              if ([responseObject isKindOfClass:[VersionModel class]]) {
                  BOOL need =   [self checkVersionInfo:canSkip withNewModel:responseObject];
                  if (showM) {
                      if (need) {
                          [ws hideHUDLoading];
                      }
                      else {
                          [ws showHUDResultThenHide:@"当前是最新版本" afterDelay:1];
                      }
                  }
              }else{
                  if (showMessage) {
                      [ws showHUDResultThenHide:@"获取更新失败" afterDelay:1];
                  }
                  else {
                      [ws hideHUDLoading];
                  }
              }
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        if (showMessage) {
            [ws showHUDResultThenHide:@"获取更新失败" afterDelay:1];
        }
        else {
            [ws hideHUDLoading];
        }
    }];
}

- (BOOL)checkVersionInfo:(BOOL)canSkip withNewModel:(VersionModel *)model{

    NSString *localVersion = AppVersion;//本地的版本号
    if (!model) {
        return NO;
    }
    
    NSString *newVersion = [NSString stringWithFormat:@"%ld",(long)model.appVersionNumber];//最新的版本号
    
    //---版本号大小判断---added by ysc------
    BOOL needUpdate = NO, isFixed = NO;
    NSArray *oldVersionArray = [localVersion componentsSeparatedByString:@"."];
    NSArray *newVersionArray = [newVersion componentsSeparatedByString:@"."];
    for (int i = 0; i < MIN([oldVersionArray count], [newVersionArray count]); i++) {
        NSInteger oldIndex = [oldVersionArray[i] integerValue];
        NSInteger newIndex = [newVersionArray[i] integerValue];
        if (newIndex < oldIndex) {
            needUpdate = NO;
            isFixed = YES;
            break;
        }
        else if (newIndex > oldIndex) {
            needUpdate = YES;
            isFixed = YES;
            break;
        }
    }
    if (!isFixed && [newVersionArray count] > [oldVersionArray count]) {
        needUpdate = YES;
    }
    //-----------------END---------------
    
    NSString *downloadUrl = model.appUrl;
    NSString *showMessage = model.appUpdateLog;
    BOOL isForcedUpdate = model.isForcedUpdate;
    if ([newVersion isKindOfClass:[NSNull class]]) {
        newVersion = @"";
    }
    if ([downloadUrl isKindOfClass:[NSNull class]]) {
        downloadUrl = @"";
    }
    if ([showMessage isKindOfClass:[NSNull class]]) {
        showMessage = @"";
    }
    
    //检测这个版本是否不再提示更新
    BOOL isSkipThisVersion = [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"IsSkipThisVersion-%@", newVersion]];
    
    if (!canSkip) {
        isSkipThisVersion = NO;
    }
    
    if (!isSkipThisVersion) {
        //简单判空
        if (newVersion && [newVersion length] > 0 &&
            downloadUrl && [downloadUrl length] > 0) {
            if (needUpdate) {
                //------added by ysc 根据updateType(0-不强制 1-强制)判断更新的策略
                UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:[NSString stringWithFormat:@"有版本%@需要更新", newVersion]
                                                                    message:showMessage];
                [alertView bk_addButtonWithTitle:@"立刻升级" handler:^{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downloadUrl]];
                    exit(0);
                }];
                
                if ( !isForcedUpdate ) {   //非强制更新的话才显示更多选项
                    [alertView bk_addButtonWithTitle:@"忽略此版本" handler:^{
                        //检测这个版本是否不再提示更新
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"IsSkipThisVersion-%@", newVersion]];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }];
                    [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];//稍后提示 不做任何操作，下次启动再次检测
                }
                [alertView show];
                //-----------------------END---------------------------------
            }
        }
    }
    return needUpdate;
}



#pragma mark 定位
- (void)HUDComeOut:(NSNotificationCenter *)notifi {
    for (id obj in self.window.subviews) {
        if ([obj isKindOfClass:[MBProgressHUD class]]) {
            [self.window bringSubviewToFront:obj];
            break;
        }
    }
}

#pragma mark - 在self.window上显示提示信息

- (void)showHUDResultThenHide:(NSString *)hintString {
    [self showHUDResultThenHide:hintString afterDelay:1.0f];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocalNotiHUDComeOut object:nil];
}

- (void)showHUDResultThenHide:(NSString *)hintString afterDelay:(NSTimeInterval)delay {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.window];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    }
    hud.labelText = hintString;
    hud.mode = MBProgressHUDModeText;
    [hud show:YES];
    [hud hide:YES afterDelay:delay];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocalNotiHUDComeOut object:nil];
}

- (void)showHUDLoadingWithString:(NSString *)hintString {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.window];
    if (hud) {
        [hud show:YES];
    }
    else {
        hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    }
    hud.labelText = hintString;
    hud.mode = MBProgressHUDModeIndeterminate;
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocalNotiHUDComeOut object:nil];
}

- (void)hideHUDLoading {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.window];
    [hud hide:YES];
}


@end
