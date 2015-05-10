//
//  ExternalShareManager.m
//  SCSDTGO
//
//  Created by  YangShengchao on 14-3-6.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import "ExternalShareManager.h"

@implementation ExternalShareManager

+ (instancetype)sharedInstance {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^ {
        return [[self alloc] init];
    })
}

- (void)shareToSNSWithImage:(UIImage *)image
                    content:(NSString *)content
                  shareType:(ShareType)type
                     result:(SSPublishContentEventHandler)result {
    id<ISSContent> publishContent = [ShareSDK content:content
                                       defaultContent:@"【来自天购】 http://www.t-go.biz/"
                                                image:(image ? [ShareSDK jpegImageWithImage:image quality:0.8] : nil)
                                                title:(content ? content : @"天购——这就是生活习惯")
                                                  url:@"http://www.t-go.biz/"
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeNews];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:NO
                                                         authViewStyle:SSAuthViewStylePopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    [authOptions setPowerByHidden:YES];
    
    [ShareSDK shareContent:publishContent
                      type:type
               authOptions:authOptions
             statusBarTips:YES
                    result:result];
}

@end
