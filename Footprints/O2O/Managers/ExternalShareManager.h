//
//  ExternalShareManager.h
//  SCSDTGO
//
//  Created by  YangShengchao on 14-3-6.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDK/ShareSDK.h>

@interface ExternalShareManager : NSObject

+ (instancetype)sharedInstance;

- (void)shareToSNSWithImage:(UIImage *)image
                    content:(NSString *)content
                  shareType:(ShareType)type
                     result:(SSPublishContentEventHandler)result;

@end
