//
//  UploadManager.h
//  TGOMarket
//
//  Created by  YangShengchao on 14-3-13.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UpYun.h"

@interface UploadManager : NSObject


/*
 *上传图片到又拍云
 */
+ (void)uploadImage:(NSData *)file
           success:(SUCCESS_BLOCK)successBlocker
         failBlock:(FAIL_BLOCK) fail
     progressBlock:(PROGRESS_BLOCK)progress;

+ (void)uploadFile:(NSData *)file
              type:(NSString *)type
           success:(SUCCESS_BLOCK)successBlocker
         failBlock:(FAIL_BLOCK) fail
     progressBlock:(PROGRESS_BLOCK)progress;
@end
