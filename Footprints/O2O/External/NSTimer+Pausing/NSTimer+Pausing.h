//
//  NSTimer+Pausing.h
//  SCSDTGO
//
//  Created by  YangHangbin on 14-3-4.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Pausing)

- (NSMutableDictionary *)pauseDictionary;
- (void)pause;
- (void)resume;

@end
