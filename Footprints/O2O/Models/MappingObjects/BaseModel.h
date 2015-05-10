//
//  BaseModel.h
//  SCSDTGO
//
//  Created by  YangHangbin on 14-3-3.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface BaseModel : JSONModel

@property (assign, nonatomic) NSInteger state;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSObject<ConvertOnDemand> *data;

@end
