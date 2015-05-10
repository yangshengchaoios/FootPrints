//
//  SCSDEFunctionSignlation.h
//  SCSDEnterprise
//
//  Created by CP3 on 14-2-20.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//  用来调方法的单例

#import <Foundation/Foundation.h>
#import "BaseViewController.h"
#import <FMDatabase.h>
#import "ProvinceModel.h"
#import "CityModel.h"
#import "AreaModel.h"
@interface SCSDEFunctionSignlation : NSObject

///单例初始化
+ (SCSDEFunctionSignlation *) defaultSingleton;
///判断是否是手机号码
- (BOOL)isMobileNumber:(NSString*)mobileNum;
///根据区域id获得省市区信息
+ (NSString *)getAddressWithAndAreaId:(NSInteger )areaId;
///根据productmodel返回的skuarray，返回一个装着有的所有规格的数组（AttributeModel）
+ (NSMutableArray *)getAttributeModelArrayFromSkuArray:(NSMutableArray *)skuArray;
///返回No表示存在，不用创建 返回yes表示不存在 需要创建Attmodel
+ (BOOL)isExitWithArray:(NSMutableArray *)array andSkuModel:(SkuModel *)model;
///时间戳转换成时间
+(NSString *)timechange:(NSString*)endtime andType:(NSString *)type;
///根据size text font 返回一个自适应的size
+(CGSize )getActualsizeFromSize:(CGSize )size AndFont:(UIFont *)font AndText:(NSString *)text;
///获取收货默认地址（如果没有默认 则获取第一条）
+ (void)getOneAddressCompelte:(void (^)(id getOneAddress))GetAddress;
///去除skumodel里面的重合
+ (NSMutableArray *)getskuArrayWithArray:(NSArray *)array;
@end
