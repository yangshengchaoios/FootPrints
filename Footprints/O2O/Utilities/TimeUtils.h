//
//  TimeUtils.h
//  SCSDEnterprise
//
//  Created by  YangShengchao on 14-2-14.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DateFormat1 @"yyyy-MM-dd hh:mm:ss"      //the naming is not good
#define DateFormat2 @"yyyy-MM-dd hh:mm:ss:SSS"
#define DateFormat3 @"yyyy-MM-dd-hh-mm-ss-SSS"
#define DateFormat4 @"h-mm"
#define DateFormat5 @"yyyy-MM-dd a H:mm:ss"
#define DateFormat6 @"yyyy-MM-dd H:mm:ss"
#define DateFormat7 @"M月d日 H:mm"

@interface TimeUtils : NSObject

+ (NSString *)timestamp;

+ (NSString *)timeStringFromDate:(NSDate *)date withFormat:(NSString *)format;

+ (NSString *)friendTimeStringForDate:(NSDate *)date;
+ (NSString *)friendTimeStringForTimestamp:(NSTimeInterval)timestamp;
+ (NSString *)friendTimeStringFromNormalTimeString:(NSString *)timeString;   //DateFormat6

+ (NSString *)dayHourMinuteTimeStringForTimestamp:(NSTimeInterval)timestamp;
+ (NSString *)dayHourMinuteTimeStringFromNormalTimeString:(NSString *)timeString;   //DateFormat6

+ (NSString *)fullTimeStringNow;
+ (NSString *)fullTimeStringNowWithFormater:(NSString *)formater;
+ (NSString *)fullTimeStringForDate:(NSDate *)date;
+ (NSString *)chineseTimeStringForTimestamp:(NSTimeInterval)timestamp;
+ (NSString *)chineseTimeStringForDate:(NSDate *)date;

+ (NSString *)convertString:(NSString *)string fromFormat:(NSString *)oldFormat toFormat:(NSString *)newFormat;
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;

+ (NSString *)timeStringFromTimeStamp:(NSString *)timestamp withFormat:(NSString *)format;

+ (NSString *)constellationFromDate:(NSDate *)date;

+ (NSString *)weekDayForDateString:(NSString *)dateString withFormat:(NSString *)format;
+ (NSString *)weekDayForDate:(NSDate *)date;

+ (NSDate *)beginningOfDay:(NSDate *)date;//当天开头
+ (NSDate *)beginningOfNextDay:(NSDate *)date;//当天开头
+ (NSDate *)endOfDay:(NSDate *)date;//当天结尾

@end
