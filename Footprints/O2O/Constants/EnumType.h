//
//  EnumType.h
//  SCSDTGO
//
//  Created by  YangShengchao on 14-3-6.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

typedef NS_ENUM(NSInteger, GenderType) {
    GenderTypeNotSet = 0,
    GenderTypeMale,
    GenderTypeFeMale
};

typedef NS_ENUM(NSInteger, ExternalLoginType) {
    ExternalLoginTypeTencentWeibo = 0,
    ExternalLoginTypeSinaWeibo
};

typedef NS_ENUM(NSUInteger, BackType) {
    BackTypePop = 0,        //显示返回上一级箭头
    BackTypeSliding         //显示侧边栏按钮
};

typedef NS_ENUM(NSUInteger, CommentUserType) {
    CommentUserTypeMyself = 0,
    CommentUserTypeAdmin
};

typedef enum {
    ActivityStatusWaiting =1,
    ActivityStatusVoting = 2,
    ActivityStatusEnd = 3,
}ActivityStatus;