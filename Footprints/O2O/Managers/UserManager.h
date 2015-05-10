//
//  UserManager.h
//  Footprints
//
//  Created by tt on 14-10-15.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JJMemberModel;
@interface UserManager : NSObject

@property (nonatomic,strong) JJMemberModel *loginUser;
+ (BOOL)isLogin;

+ (id)sharedManager;

+ (void)logOut;

//userid
+(id)loginUserId;
//token
+(id)loginUserToken;

+ (void)showLoginOnController:(id)controller;

+ (void)saveLoginUser:(JJMemberModel *)newUser;
@end
