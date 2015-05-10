//
//  JJServerTimeUtils.m
//  Footprints
//
//  Created by Jinjin on 14/11/17.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJServerTimeUtils.h"
#import <mach/mach_time.h>

// serverInterval = serverTime - LocalTime
// LocalTime = serverTime - serverInterval

@interface JJServerTimeUtils ()
@property (nonatomic, strong) NSMutableDictionary *countDownDicts;
@property (nonatomic, assign) BOOL isSyncSuccess;
@property (nonatomic, assign) NSTimeInterval serverInterval; //与Server的时间差
@property (nonatomic, strong) NSLock *theLock;

@end

static JJServerTimeUtils *serverTimeUtils = nil;
@implementation JJServerTimeUtils


- (void)dealloc {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    self = [super init];
    if (self) {
        self.countDownDicts = [@{} mutableCopy];
        self.serverInterval = -0.5;
        [self checkWishServerTime];
        self.theLock = [[NSLock alloc] init];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkWishServerTime) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clean) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}


+ (JJServerTimeUtils *)sharedServerTimeUtils {
   
    if (nil==serverTimeUtils) {
        serverTimeUtils = [[JJServerTimeUtils alloc] init];
    }
    return serverTimeUtils;
}

#pragma mark - 时钟
- (void)timerFireMethod:(NSTimer *)theTimer {
    [self.theLock lock];
    
    NSMutableArray *dicts = [self.countDownDicts.allValues mutableCopy];
    for (NSDictionary *dict in dicts) {
        [self setCountDownWithInfoDict:dict];
    }
    [self.theLock unlock];
}

- (void)setCountDownWithInfoDict:(NSDictionary *)dict{
    
    NSString *keyPath = dict[@"keyPath"];
    NSString *timeFormat = dict[@"timeFormat"];
    NSTimeInterval startInterval = [dict[@"startInterval"] doubleValue];
    id obj = dict[@"obj"];
    
    //定义一个NSCalendar对象
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [cal setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDate *startDate =  [NSDate dateWithTimeIntervalSince1970:startInterval];//目标开始时间
    NSDate *nowDate = [NSDate date]; //得到当前时间
    
    //用来得到具体的时差
    unsigned int unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *countDown = [cal components:unitFlags fromDate:nowDate toDate:startDate options:0];
    [countDown setHour:[countDown day] * 24 + [countDown hour]];
    
    NSString *countDownText = timeFormat;
    //某商品倒计时结束发送通知
    if ((countDown.hour + countDown.second + countDown.minute) <= 0) {
        [JJServerTimeUtils removeListenr:obj forKeyPath:keyPath];
        id userInfo = dict[@"userInfo"];
        countDownText = dict[@"countDownText"];
        if (keyPath && countDownText) {
            [obj setValue:countDownText forKeyPath:keyPath];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kCountDownFinishNotification object:userInfo];
    }
    else { //计算出倒计时多少
        NSInteger hour = MAX(countDown.hour, 0);
        countDownText = hour < 10 ? [countDownText stringByReplacingOccurrencesOfString:@"hh" withString:[NSString stringWithFormat:@"0%ld", hour]] : [countDownText stringByReplacingOccurrencesOfString:@"hh" withString:[NSString stringWithFormat:@"%ld", hour]];
        
        NSInteger minute = MAX(countDown.minute, 0);
        countDownText = minute < 10 ? [countDownText stringByReplacingOccurrencesOfString:@"mm" withString:[NSString stringWithFormat:@"0%ld", minute]] : [countDownText stringByReplacingOccurrencesOfString:@"mm" withString:[NSString stringWithFormat:@"%ld", minute]];
        
        NSInteger second = MAX(countDown.second, 0);
        countDownText = second < 10 ? [countDownText stringByReplacingOccurrencesOfString:@"ss" withString:[NSString stringWithFormat:@"0%ld", second]] : [countDownText stringByReplacingOccurrencesOfString:@"ss" withString:[NSString stringWithFormat:@"%ld", second]];
        
        if (keyPath && countDownText) {
            [obj setValue:countDownText forKeyPath:keyPath];
        }
        //计算出最后10s 发通知
        if (countDown.hour==0 && countDown.minute==0 && countDown.second<=10 && dict[@"userInfo"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CountDown==10" object:dict[@"userInfo"]];
        }
    }
}

+ (void)removeListenr:(NSObject *)obj forKeyPath:(NSString *)keyPath {
    JJServerTimeUtils *shard = [JJServerTimeUtils sharedServerTimeUtils];
    NSString *key = [NSString stringWithFormat:@"%@-%p", keyPath, obj];
    [shard.countDownDicts removeObjectForKey:key];
}

+ (void)addListener:(NSObject *)obj
      startInterval:(NSTimeInterval)startInterval
      changeKeyPath:(NSString *)keyPath
      countDownText:(NSString *)countDownText
           userInfo:(id)userInfo
    withTimeFormart:(NSString *)timeFormat{
    
    if (startInterval > 100000000.0f * 1000.0f) {//判断单位是秒还是毫秒
        startInterval = startInterval / 1000.0f;
    }
    NSString *key = [NSString stringWithFormat:@"%@-%p", keyPath, obj];
    JJServerTimeUtils *shard = [JJServerTimeUtils sharedServerTimeUtils];
    NSDictionary *dict = @{ @"obj":obj,
                            @"countDownText":countDownText?countDownText:@" ",
                            @"keyPath":keyPath,
                            @"timeFormat":timeFormat,
                            @"userInfo":userInfo ? userInfo : @" ",
                            @"startInterval":@(startInterval-shard.serverInterval)//转换为本地时间
                            };
    [shard setCountDownWithInfoDict:dict];
    [shard.countDownDicts setObject:dict
                             forKey:key];
}

////删除已经添加的通知
//+ (BOOL)removeLocalNotificationForCountDownModel:(NSDictionary *)countDownModel {
//    BOOL isSuccess = NO;
//    //获取本地推送数组
//    NSArray *localArr = [[[UIApplication sharedApplication] scheduledLocalNotifications] copy];
//    //声明本地通知对象
//    UILocalNotification *localNoti;
//    for (UILocalNotification *noti in localArr) {
//        NSDictionary *dict = noti.userInfo;
//        if (dict) {
//            NSString *notiType = [NSString stringWithFormat:@"%@",[dict objectForKey:kLocalNotiTypeKey]];
//            NSString *notiId = [NSString stringWithFormat:@"%@",[dict objectForKey:kLocalNotiIdKey]];
//            //            NSNumber *notiId = [dict objectForKey:kLocalNotiIdKey];
//            if ([notiType isEqualToString:kLocalNotiTypeCountDownAlert] && [notiId isEqualToString:countDownModel[@"CountDownId"]]) {
//                //发现本地通知
//                localNoti = noti;
//                //删除通知
//                [[UIApplication sharedApplication] cancelLocalNotification:localNoti];
//                isSuccess = YES;
//                break;
//            }
//        }
//    }
//    return isSuccess;
//}

//删除所有的WishCountDown
+ (void)removeAllLocalNotificationForType:(NSString *)type{
    //获取本地推送数组
    NSArray *localArr = [[[UIApplication sharedApplication] scheduledLocalNotifications] copy];
    //声明本地通知对象
    for (UILocalNotification *noti in localArr) {
        NSDictionary *dict = noti.userInfo;
        if (dict) {
            NSString *notiType = [NSString stringWithFormat:@"%@",[dict objectForKey:kLocalNotiTypeKey]];
            if ([notiType isEqualToString:type]) {
                //删除通知
                [[UIApplication sharedApplication] cancelLocalNotification:noti];
            }
        }
    }
}

+(BOOL)isTimeGone:(NSTimeInterval)timeInterval{

    NSTimeInterval time = timeInterval;
    if (time > 100000000.0f * 1000.0f) {//判断单位是秒还是毫秒
        time = time / 1000.0f;
    }
    JJServerTimeUtils *shared = [JJServerTimeUtils sharedServerTimeUtils];
    NSTimeInterval server = [[NSDate date] timeIntervalSince1970]+shared.serverInterval;
    return server>=time;
}

#pragma mark - 获取服务器时间
- (void)checkWishServerTime{
    
    NSLog(@"开始获取  checkWishServerTime");
    NSDate *date = [NSDate date];
    WeakSelfType blockSelf = self;
    [AFNManager getObject:nil apiName:kResPathGetServerTime modelName:@"ServerTimeModel" requestSuccessed:^(id responseObject) {
        NSTimeInterval httpWaste = [[NSDate date] timeIntervalSinceDate:date];
        NSTimeInterval number = ((ServerTimeModel *)responseObject).timestamp;
        if (httpWaste < 2) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkWishServerTime) object:nil];
            if (number > 100000000.0f * 1000.0f) {//判断单位是秒还是毫秒
                number = number / 1000.0f;
            }
            NSTimeInterval serverTime = number + (httpWaste / 2);
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            blockSelf.serverInterval =  (serverTime - now);
            blockSelf.isSyncSuccess = YES;
            NSLog(@" \nblockSelf.interval:%f\nhttpWaste: %f",  blockSelf.serverInterval,httpWaste);
        }
        else {
            [blockSelf syncWishFaild];
        }
        
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
            [blockSelf syncWishFaild];
    }];
}

- (void)syncWishFaild {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (self.isSyncSuccess == NO) {
        self.serverInterval = -0.5;
        [self performSelector:@selector(checkWishServerTime) withObject:nil afterDelay:30];
    }
}

- (void)clean {
    self.isSyncSuccess = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}
@end
