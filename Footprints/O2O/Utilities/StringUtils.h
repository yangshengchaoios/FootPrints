//
//  StringUtils.h
//  SCSDEnterprise
//
//  Created by  YangShengchao on 14-2-14.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SCSD)

- (NSArray *)nonemptyComponentsSeparatedByString:(NSString *)separator;
- (BOOL)isContainString:(NSString *)subString;

@end

@interface StringUtils : NSObject {
    
}

+ (BOOL)isEmpty:(NSString *)string;

+ (NSString *)trimString:(NSString *)source;
+ (NSString *)nonnilString:(NSString *)originString;
+ (NSString *)nonemptyString:(NSString *)firstString andString:(NSString *)secondString;

#pragma mark - 正则表达式

+ (BOOL)isEmail:(NSString *)email;
+ (BOOL)isMobilePhone:(NSString *)mobile;
+ (BOOL)isUserName:(NSString *)userName;
+ (BOOL)isPassword:(NSString *)passWord;
+ (BOOL)isNickname:(NSString *)nickname;
+ (BOOL)isIdentityCard:(NSString *)identityCard;
+ (BOOL)isAllNumbers:(NSString *)string;

+ (NSString *)md5FromString:(NSString *)string;
+ (NSString *)deviceTokenFromString:(NSString *)string;

# pragma mark - SCSD

+ (NSString *)resBaseUrl;
+ (NSURL *)fullUrlWithPicturePath:(NSString *)picturePath;
+ (NSString *)fullPathWithPicturePath:(NSString *)picturePath;
+ (NSURL *)thumbnailUrlWithPicturePath:(NSString *)picturePath wantedWidth:(NSInteger)pictureWidth;
+ (NSString *)thumbnailPathFromOriginPath:(NSString *)picturePath;
+ (NSString *)thumbnailBigPathFromOriginPath:(NSString *)picturePath;
+ (NSString *)thumbnailPathFromOriginPath:(NSString *)picturePath wantedWidth:(NSInteger)pictureWidth;

+ (NSString *)fullPathWithAudioPath:(NSString *)audioPath;

+ (NSString *)distanceWithMeters:(NSInteger)meter;

+ (NSString *)friendlyNameForViewController:(NSString *)viewControllerClassName;

#pragma mark UTF8编码解码

+ (NSString *)UTF8EncodedString:(NSString *)source;
+ (NSString *)UTF8DecodedString:(NSString *)source;

#pragma mark 格式化金额字符串

+ (NSString *)formatPrice:(NSNumber *)price;
+ (NSString *)formatPriceWithUnit:(NSNumber *)price;
+ (NSString *)formatPrice:(NSNumber *)price showMoneyTag:(BOOL)isTagUsed showDecimalPoint:(BOOL) isDecimal useUnit:(BOOL)isUnitUsed;

#pragma mark 打电话

+ (void)makeCall:(NSString *)phoneNumber;

@end
