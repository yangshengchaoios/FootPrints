//
//  PaymentManager.m
//  TGOMarket
//
//  Created by  YangShengchao on 14-5-20.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import "PaymentManager.h"
#import "AlixLibService.h"
#import "AlixPayResult.h"
#import "AlixPayOrder.h"
#import "DataVerifier.h"
#import "DataSigner.h"

@implementation PaymentManager

+ (instancetype)sharedInstance {
	DEFINE_SHARED_INSTANCE_USING_BLOCK ( ^{
	    return [[self alloc] init];
	})
}

- (void)payTheOrder:(NSString *)orderId            //订单id
         orderTitle:(NSString *)title              //订单描述的标题
   orderDescription:(NSString *)description        //订单描述正文
             amount:(NSString *)amount             //总金额
            success:(AliPaySuccess)success
             failed:(AliPayFailed)failed {
    [self payTheOrder:orderId
           orderTitle:title
     orderDescription:description
               amount:amount
     alipayParameters:@{AlipayPartnerID : @"本地定义",
                        AlipaySellerID : @"本地定义",
                        AlipayNotifyURL : @"本地定义",
                        AlipayReturnURL : @"本地定义",
                        AlipayPartnerPrivKey : @"本地定义"}
              success:success
               failed:failed];
}

- (void)payTheOrder:(NSString *)orderId            //订单id
         orderTitle:(NSString *)title              //订单描述的标题
   orderDescription:(NSString *)description        //订单描述正文
             amount:(NSString *)amount             //总金额
   alipayParameters:(NSDictionary *)parameters     //alipay参数
            success:(AliPaySuccess)success
             failed:(AliPayFailed)failed {
    
    self.alipaySuccess = success;
	self.alipayFailed = failed;
    
	//生成支付宝的付款订单
	AlixPayOrder *alipayOrder = [AlixPayOrder new];
	alipayOrder.partner = parameters[AlipayPartnerID];
	alipayOrder.seller = parameters[AlipaySellerID];
	alipayOrder.tradeNO = orderId;
    
	//商品名称不能为空
	alipayOrder.productName = [StringUtils isEmpty:title] ? @"四川天购商品" : title;
	//商品描述也不能为空
	alipayOrder.productDescription = [StringUtils isEmpty:description] ? @"商品描述" : description;
    
    alipayOrder.amount = [NSString stringWithFormat:@"%.2f", [amount floatValue]];
	alipayOrder.notifyURL = parameters[AlipayNotifyURL];
	alipayOrder.returnUrl = parameters[AlipayReturnURL];
    
	//签名
	NSString *orderInfo = [alipayOrder description];
	id <DataSigner> signer = CreateRSADataSigner(parameters[AlipayPartnerPrivKey]);
	NSString *signedStr = [signer signString:orderInfo];
	NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
	                         orderInfo, signedStr, @"RSA"];
    
	[AlixLibService payOrder:orderString
	               AndScheme:AppScheme
	                 seletor:@selector(paymentResult:)
	                  target:self];
}

/**
 *  支付宝快捷支付接口回调
 *
 *  @param resultString 结果字符串
 */
- (void)paymentResult:(NSString *)resultString {
	//结果处理
	AlixPayResult *result = [[AlixPayResult alloc] initWithString:resultString];
	if (result) {
		if (result.statusCode == 9000) {
			if (self.alipaySuccess) {
				self.alipaySuccess();
			}
		}
		else { //交易失败
			if (self.alipayFailed) {
				NSString *error = [NSString stringWithFormat:@"交易失败！(%d)", result.statusCode];
				self.alipayFailed(error);
			}
		}
	}
	else { //失败
		if (self.alipayFailed) {
			self.alipayFailed(@"支付结果返回错误！");
		}
	}
}

- (void)paymentResultDelegate:(NSString *)result {
	NSLog(@"%@", result);
}

@end
