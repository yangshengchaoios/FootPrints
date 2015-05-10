//
//  TimeUtils.m
//  SCSDEnterprise
//
//  Created by  YangShengchao on 14-2-14.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import "TimeUtils.h"

@interface TimeUtils ()

+ (NSDateFormatter *)dateFormaterWithFormat:(NSString *)formatString;

@end

@implementation TimeUtils

+ (NSString *)timestamp {
    return [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
}

+ (NSString *)timeStringFromDate:(NSDate *)date withFormat:(NSString *)format {
    return [[self dateFormaterWithFormat:format] stringFromDate:date];
}

+ (NSString *)friendTimeStringForDate:(NSDate *)date {
    NSString *friendTimeString = @"";
    
    NSDate *currentDate = [NSDate date];
    NSString *currentYear = [[self dateFormaterWithFormat:@"YYYY"] stringFromDate:currentDate];
    NSString *currentDay = [[self dateFormaterWithFormat:@"dd"] stringFromDate:currentDate];
    if ( ! [currentYear isEqualToString:[[self dateFormaterWithFormat:@"YYYY"] stringFromDate:date]]) {
        return [[self dateFormaterWithFormat:@"M月d日"] stringFromDate:date];
    }
    else {
        NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:date];
        if (timeInterval < 60) {
            return @"刚刚";
        }
        else if (timeInterval < 3600) {
            return [NSString stringWithFormat:@"%.0f分钟前", timeInterval / 60];
        }
        else if (timeInterval < 86400) {
            if ([currentDay isEqualToString:[[self dateFormaterWithFormat:@"dd"] stringFromDate:date]]) {
                return [[self dateFormaterWithFormat:@"H:mm"] stringFromDate:date];
            }
            else {
                return @"昨天";
            }
        }
        else {
            return [[self dateFormaterWithFormat:@"M月d日"] stringFromDate:date];
        }
    }
    
    return friendTimeString;
}

+ (NSString *)friendTimeStringForTimestamp:(NSTimeInterval)timestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    return [self friendTimeStringForDate:date];
}

+ (NSString *)friendTimeStringFromNormalTimeString:(NSString *)timeString {
    NSDate *theDate = [self dateFromString:timeString withFormat:DateFormat6];
    if (theDate) {
        return [self friendTimeStringForDate:theDate];
    }
    else {
        return timeString;
    }
}

+ (NSString *)dayHourMinuteTimeStringForTimestamp:(NSTimeInterval)timestamp {
    NSDate *theDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSString *theYear = [[self dateFormaterWithFormat:@"YYYY"] stringFromDate:theDate];
    NSString *theMonthDay = [[self dateFormaterWithFormat:@"M-dd"] stringFromDate:theDate];
    
    NSDate *currentDate = [NSDate date];
    NSString *currentYear = [[self dateFormaterWithFormat:@"YYYY"] stringFromDate:currentDate];
    NSString *currentMonthDay = [[self dateFormaterWithFormat:@"M-dd"] stringFromDate:currentDate];
    
    if ( ! [currentYear isEqualToString:theYear]) {
        return @"去年";
    }
    else {
        if ( ! [currentMonthDay isEqualToString:theMonthDay]) {
            NSInteger dayInterval = [[[self dateFormaterWithFormat:@"d"] stringFromDate:currentDate] integerValue] - [[[self dateFormaterWithFormat:@"d"] stringFromDate:theDate] integerValue];
            if (dayInterval == 1) {
                return @"昨天";
            }
            else if (dayInterval == 2) {
                return @"前天";
            }
            else {
                return [[self dateFormaterWithFormat:@"M月d日"] stringFromDate:theDate];
            }
        }
        else {
            return [[self dateFormaterWithFormat:@"今天 H:mm"] stringFromDate:theDate];
        }
    }
}

+ (NSString *)dayHourMinuteTimeStringFromNormalTimeString:(NSString *)timeString {
    NSDate *theDate = [self dateFromString:timeString withFormat:DateFormat6];
    if (theDate) {
        return [self dayHourMinuteTimeStringForTimestamp:[theDate timeIntervalSince1970]];
    }
    else {
        return timeString;
    }
}

+ (NSString *)fullTimeStringNow {
    return [self fullTimeStringForDate:[NSDate date]];
}

+ (NSString *)fullTimeStringNowWithFormater:(NSString *)formater {
    return [[self dateFormaterWithFormat:formater] stringFromDate:[NSDate date]];
}

+ (NSString *)fullTimeStringForDate:(NSDate *)date {
    return [[self dateFormaterWithFormat:DateFormat5] stringFromDate:date];
}

+ (NSString *)chineseTimeStringForTimestamp:(NSTimeInterval)timestamp {
    return [self chineseTimeStringForDate:[NSDate dateWithTimeIntervalSince1970:timestamp]];
}

+ (NSString *)chineseTimeStringForDate:(NSDate *)date {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM"];
    int i_month=0;
    NSString *theMonth = [dateFormat stringFromDate:date];
    if([[theMonth substringToIndex:0] isEqualToString:@"0"]){
        i_month = [[theMonth substringFromIndex:1] intValue];
    }
    else{
        i_month = [theMonth intValue];
    }
    
    if (i_month == 1) {
        return @"一";
    }
    else if (i_month == 2) {
        return @"二";
    }
    else if (i_month == 3) {
        return @"三";
    }
    else if (i_month == 4) {
        return @"四";
    }
    else if (i_month == 5) {
        return @"五";
    }
    else if (i_month == 6) {
        return @"六";
    }
    else if (i_month == 7) {
        return @"七";
    }
    else if (i_month == 8) {
        return @"八";
    }
    else if (i_month == 9) {
        return @"九";
    }
    else if (i_month == 10) {
        return @"十";
    }
    else if (i_month == 11) {
        return @"十一";
    }
    else if (i_month == 12) {
        return @"十二";
    }
    else {
        return @"";
    }
}

+ (NSString *)convertString:(NSString *)string fromFormat:(NSString *)oldFormat toFormat:(NSString *)newFormat {
    NSDate *date = [self dateFromString:string withFormat:oldFormat];
    return [[self dateFormaterWithFormat:newFormat] stringFromDate:date];
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
    return [[self dateFormaterWithFormat:format] dateFromString:string];
}

+ (NSString *)timeStringFromTimeStamp:(NSString *)timestamp withFormat:(NSString *)format {
    return [[self dateFormaterWithFormat:format] stringFromDate:[NSDate dateWithTimeIntervalSince1970:[timestamp longLongValue]]];
}

+ (NSString *)constellationFromDate:(NSDate *)date {
    NSString *retStr=@"";
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM"];
    int i_month=0;
    NSString *theMonth = [dateFormat stringFromDate:date];
    if([[theMonth substringToIndex:0] isEqualToString:@"0"]){
        i_month = [[theMonth substringFromIndex:1] intValue];
    }
    else{
        i_month = [theMonth intValue];
    }
    
    [dateFormat setDateFormat:@"dd"];
    int i_day=0;
    NSString *theDay = [dateFormat stringFromDate:date];
    if([[theDay substringToIndex:0] isEqualToString:@"0"]){
        i_day = [[theDay substringFromIndex:1] intValue];
    }
    else{
        i_day = [theDay intValue];
    }
    /*
     摩羯座 12月22日------1月19日
     水瓶座 1月20日-------2月18日
     双鱼座 2月19日-------3月20日
     白羊座 3月21日-------4月19日
     金牛座 4月20日-------5月20日
     双子座 5月21日-------6月21日
     巨蟹座 6月22日-------7月22日
     狮子座 7月23日-------8月22日
     处女座 8月23日-------9月22日
     天秤座 9月23日------10月23日
     天蝎座 10月24日-----11月21日
     射手座 11月22日-----12月21日
     */
    switch (i_month) {
        case 1:
            if(i_day>=20 && i_day<=31){
                retStr=@"水瓶座";
            }
            if(i_day>=1 && i_day<=19){
                retStr=@"摩羯座";
            }
            break;
        case 2:
            if(i_day>=1 && i_day<=18){
                retStr=@"水瓶座";
            }
            if(i_day>=19 && i_day<=31){
                retStr=@"双鱼座";
            }
            break;
        case 3:
            if(i_day>=1 && i_day<=20){
                retStr=@"双鱼座";
            }
            if(i_day>=21 && i_day<=31){
                retStr=@"白羊座";
            }
            break;
        case 4:
            if(i_day>=1 && i_day<=19){
                retStr=@"白羊座";
            }
            if(i_day>=20 && i_day<=31){
                retStr=@"金牛座";
            }
            break;
        case 5:
            if(i_day>=1 && i_day<=20){
                retStr=@"金牛座";
            }
            if(i_day>=21 && i_day<=31){
                retStr=@"双子座";
            }
            break;
        case 6:
            if(i_day>=1 && i_day<=21){
                retStr=@"双子座";
            }
            if(i_day>=22 && i_day<=31){
                retStr=@"巨蟹座";
            }
            break;
        case 7:
            if(i_day>=1 && i_day<=22){
                retStr=@"巨蟹座";
            }
            if(i_day>=23 && i_day<=31){
                retStr=@"狮子座";
            }
            break;
        case 8:
            if(i_day>=1 && i_day<=22){
                retStr=@"狮子座";
            }
            if(i_day>=23 && i_day<=31){
                retStr=@"处女座";
            }
            break;
        case 9:
            if(i_day>=1 && i_day<=22){
                retStr=@"处女座";
            }
            if(i_day>=23 && i_day<=31){
                retStr=@"天秤座";
            }
            break;
        case 10:
            if(i_day>=1 && i_day<=23){
                retStr=@"天秤座";
            }
            if(i_day>=24 && i_day<=31){
                retStr=@"天蝎座";
            }
            break;
        case 11:
            if(i_day>=1 && i_day<=21){
                retStr=@"天蝎座";
            }
            if(i_day>=22 && i_day<=31){
                retStr=@"射手座";
            }
            break;
        case 12:
            if(i_day>=1 && i_day<=21){
                retStr=@"射手座";
            }
            if(i_day>=21 && i_day<=31){
                retStr=@"摩羯座";
            }
            break;
    }
    return retStr;
}

#pragma mark - private metholds

+ (NSDateFormatter *)dateFormaterWithFormat:(NSString *)formatString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatString];
    return dateFormatter;
}

+ (NSString *)weekDayForDateString:(NSString *)dateString withFormat:(NSString *)format{
    NSString *weekDay = @"";
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:format];
    
    NSDate *formatterDate = [inputFormatter dateFromString:dateString];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"EEEE"];
    
    NSString *newDateString = [outputFormatter stringFromDate:formatterDate];
    
    if ([newDateString isEqualToString:@"Monday"]) {
        weekDay = @"周一";
    }else if ([newDateString isEqualToString:@"Tuesday"]){
        weekDay = @"周二";
    }else if ([newDateString isEqualToString:@"Wednesday"]){
        weekDay = @"周三";
    }else if ([newDateString isEqualToString:@"Thursday"]){
        weekDay = @"周四";
    }else if ([newDateString isEqualToString:@"Friday"]){
        weekDay = @"周五";
    }else if ([newDateString isEqualToString:@"Saturday"]){
        weekDay = @"周六";
    }else {
        weekDay = @"周日";
    }
    return weekDay;
}

+ (NSString *)weekDayForDate:(NSDate *)date{
    NSString *weekDay = @"";
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"EEEE"];
    NSString *newDateString = [outputFormatter stringFromDate:date];
    
    if ([newDateString isEqualToString:@"Monday"]) {
        weekDay = @"周一";
    }else if ([newDateString isEqualToString:@"Tuesday"]){
        weekDay = @"周二";
    }else if ([newDateString isEqualToString:@"Wednesday"]){
        weekDay = @"周三";
    }else if ([newDateString isEqualToString:@"Thursday"]){
        weekDay = @"周四";
    }else if ([newDateString isEqualToString:@"Friday"]){
        weekDay = @"周五";
    }else if ([newDateString isEqualToString:@"Saturday"]){
        weekDay = @"周六";
    }else {
        weekDay = @"周日";
    }
    return weekDay;
}

+ (NSDate *)beginningOfDay:(NSDate *)date {
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents* parts = [[NSCalendar currentCalendar] components:flags fromDate:date];
    [parts setHour:0];
    [parts setMinute:0];
    [parts setSecond:0];
    return [[NSCalendar currentCalendar] dateFromComponents:parts];
}

+ (NSDate *)beginningOfNextDay:(NSDate *)date{

    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents* parts = [[NSCalendar currentCalendar] components:flags fromDate:date];
    [parts setDay:parts.day+1];
    [parts setHour:0];
    [parts setMinute:0];
    [parts setSecond:0];
    return [[NSCalendar currentCalendar] dateFromComponents:parts];
}

+ (NSDate *)endOfDay:(NSDate *)date {
    
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents* parts = [[NSCalendar currentCalendar] components:flags fromDate:date];
    [parts setHour:23];
    [parts setMinute:59];
    [parts setSecond:59];
    return [[NSCalendar currentCalendar] dateFromComponents:parts];
}
@end
