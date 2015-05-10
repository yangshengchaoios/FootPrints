//
//  UserManager.m
//  Footprints
//
//  Created by tt on 14-10-15.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "UserManager.h"
#import "JJAccountViewController.h"
#define kUserModelName @"kUserModelName"

static UserManager *sharedManager = nil;

@implementation UserManager

+ (void)showLoginOnController:(id)controller{
    
    JJAccountViewController *account = [[JJAccountViewController alloc] initWithNibName:@"JJAccountViewController" bundle:nil];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:account];
    [controller presentViewController:navi animated:YES completion:^{
        
    }];
}

+ (id)sharedManager{
    
    if (nil==sharedManager) {
        sharedManager = [[UserManager alloc] init];
        sharedManager.loginUser = [[JJMemberModel alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kUserModelName] error:nil];
    }
    
    return sharedManager;
}

+ (BOOL)isLogin{
    
    BOOL isLogin = NO;
    
    id userid = [[[UserManager sharedManager] loginUser] memberId];
    id token = [[[UserManager sharedManager] loginUser] token];
    if (userid && token) {
        isLogin = YES;
    }
    return isLogin;
}

+ (void)logOut{

    sharedManager.loginUser = nil;
    [self saveLoginUser:nil];
}

//userid
+(id)loginUserId{
    
    id userid = [[[UserManager sharedManager] loginUser] memberId];
    return userid?userid:@0;
}

//token
+(id)loginUserToken{
    
    id token = [[[UserManager sharedManager] loginUser] token];
    return token;
}


+ (void)saveLoginUser:(JJMemberModel *)newUser{
    
    UserManager *manager = [UserManager sharedManager];
    manager.loginUser = newUser;
    NSString *newUserStr = [newUser toJSONString];
    if (newUserStr) {
        [[NSUserDefaults standardUserDefaults] setObject:newUserStr forKey:kUserModelName];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserModelName];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    postNWithObj(LoginUserModelDidChangeNotification, newUser);
}

+ (void)removeToken{
    
    
}

@end
