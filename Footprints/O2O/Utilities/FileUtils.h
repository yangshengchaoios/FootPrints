//
//  FileUtils.h
//  SCSDEnterprise
//
//  Created by  YangShengchao on 14-2-14.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//


/**
 
 * 数据库和账户信息，放在Documents目录
 * 程序长期使用的缓存，放在Library/Caches目录
 * 只在当次程序打开使用的，放在tmp目录

 **/
#import <Foundation/Foundation.h>

#import "UrlConstants.h"

#define kPlistAccountName       @"plistAccountName"
#define kPlistPassword          @"plistPassword"
#define kPlistUserId            @"plistUserId"
#define kPlistSession           @"plistSession"
#define kPlistSid               @"plistSid"
#define kPlistUserNickName      @"plistUserNickName"
#define kPlistUserRealName      @"plistUserRealName"
#define kPlistUserBgPic         @"plistUserBgPic"
#define kPlistUserAvatar        @"plistUserAvatar"
#define kPlistUserGender        @"plistUserGender"

#define kPlistXmppPassword      @"plistXmppPassword"

#define kPlistLastShareType     @"plistLastShareType"

#define kPlistDeviceToken       @"plistDeviceToken"

@interface FileUtils : NSObject

+ (NSString *)documentsDirectory;
+ (NSString *)tmpDirectory;
+ (NSString *)cacheDirectory;
+ (NSString *)subDocumentsPath:(NSString *)subFilepath;
+ (NSString *)ensureDirectory:(NSString *)filepath;
+ (NSString *)ensureParentDirectory:(NSString *)filepath;  //如果父级目录不存在就创建

+ (void)saveImage:(UIImage *)image toFile:(NSString *)filePath;
+ (void)saveImage:(UIImage *)image toFile:(NSString *)filePath maxWidth:(CGFloat)maxWidth;
+ (NSString *)saveImageWithTimestampName:(UIImage *)image;

+ (NSString *)convertString:(NSString *)string fromFormat:(NSString *)oldFormat toFormat:(NSString *)newFormat;

@end