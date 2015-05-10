//
//  NSString+TimeCategory.h
//  SCSDTGO
//
//  Created by  YangHangbin on 14-3-5.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TimeCategory)
+ (NSString *)stringWithTime:(NSTimeInterval)time;
- (NSTimeInterval)timeValue;

@end
