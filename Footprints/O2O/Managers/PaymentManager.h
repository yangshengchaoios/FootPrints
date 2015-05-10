//
//  PaymentManager.h
//  TGOMarket
//
//  Created by  YangShengchao on 14-5-20.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AliPaySuccess)();
typedef void (^AliPayFailed)(NSString *errorMessage);

@interface PaymentManager : NSObject

@property (copy, nonatomic) AliPaySuccess alipaySuccess;
@property (copy, nonatomic) AliPayFailed alipayFailed;


+ (instancetype)sharedInstance;

//本地保存alipay参数
- (void)payTheOrder:(NSString *)orderId             //订单id
         orderTitle:(NSString *)title               //订单描述的标题
   orderDescription:(NSString *)description         //订单描述正文
             amount:(NSString *)amount              //总金额
            success:(AliPaySuccess)success
             failed:(AliPayFailed)failed;

//服务器传递进来alipay参数
- (void)payTheOrder:(NSString *)orderId            //订单id
         orderTitle:(NSString *)title              //订单描述的标题
   orderDescription:(NSString *)description        //订单描述正文
             amount:(NSString *)amount             //总金额
   alipayParameters:(NSDictionary *)parameters
            success:(AliPaySuccess)success
             failed:(AliPayFailed)failed;

@end
