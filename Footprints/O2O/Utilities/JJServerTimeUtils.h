//
//  JJServerTimeUtils.h
//  Footprints
//
//  Created by Jinjin on 14/11/17.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kLocalNotiTypeKey @"LocalNotiType"
@interface JJServerTimeUtils : NSObject

+ (JJServerTimeUtils *)sharedServerTimeUtils;

//+ (BOOL)removeLocalNotificationForCountDownModel:(NSDictionary *)countDownModel;

+ (void)removeAllLocalNotificationForType:(NSString *)type;

+ (void)addListener:(NSObject *)obj
      startInterval:(NSTimeInterval)startInterval
      changeKeyPath:(NSString *)keyPath
      countDownText:(NSString *)countDownText
           userInfo:(id)userInfo
    withTimeFormart:(NSString *)timeFormat;

+ (void)removeListenr:(NSObject *)obj forKeyPath:(NSString *)keyPath;


//时间是否已经过去  YES -- 已经过去
+(BOOL)isTimeGone:(NSTimeInterval)timeInterval;
@end
