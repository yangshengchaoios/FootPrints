//
//  UDIDManager.h
//  TGOMarket
//
//  Created by  YangShengchao on 14-5-8.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  兼容iOS6和iOS7的UDID解决方案
 *  iOS6-获取的是MAC地址
 *  iOS7-从keychain中获取

    源码详解文章：http://www.cnblogs.com/smileEvday/p/UDID.html
    完整代码地址: https://github.com/smileEvday/SvUDID
 　　大家如果要在真机运行时，需要替换两个地方:
 　　1. plist文件中的accessGroup中的APPIdentifier。
 　　2. UDIDManager.m中的kKeyChainUDIDAccessGroup的APPIdentity为你所使用的profile的APPIdentifier。
 */

@interface UDIDManager : NSObject

+ (NSString*)UDID;

@end
