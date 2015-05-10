//
//  AreaModel.h
//  SCSDTGO
//
//  Created by ZhangPeng on 14-3-7.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AreaModel : NSObject

@property (strong, nonatomic) NSString *areaName;
@property (assign, nonatomic) NSInteger areaId;
@property (assign, nonatomic) NSInteger cityId;
@property (assign, nonatomic) NSInteger provinceId;

@end
