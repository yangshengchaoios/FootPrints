//
//  SCSDEFunctionSignlation.m
//  SCSDEnterprise
//
//  Created by CP3 on 14-2-20.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import "SCSDEFunctionSignlation.h"

static SCSDEFunctionSignlation *singleton = nil;

@implementation SCSDEFunctionSignlation

//初始化
+ (SCSDEFunctionSignlation *) defaultSingleton
{
    @synchronized (self)
    {
        if (singleton == nil)
        {
            singleton = [[SCSDEFunctionSignlation alloc] init];
        }
    }
    return singleton;
}
+ (id) allocWithZone:(NSZone *)zone
{
    if (singleton == nil)
    {
        singleton = [super allocWithZone:zone];
    }
    return singleton;
}
///验证是不是手机号
- (BOOL)isMobileNumber:(NSString*)mobileNum
{
    
#if  0
    /**  手机号码
     *
     移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     *
     联通：130,131,132,152,155,156,185,186
     *
     电信：133,1349,153,180,189
     */
    NSString *MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    
    // 中国移动：China Mobile
    // 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
    NSString *CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    
    // 中国联通：China Unicom
    // 130,131,132,152,155,156,185,186
    NSString *CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    
    // 中国电信：China Telecom
    //  133,1349,153,180,189
    NSString *CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    
    // 大陆地区固话及小灵通
    // 区号：010,020,021,022,023,024,025,027,028,029
    // 号码：七位或八位
    NSString *PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    
    NSPredicate *regextestmobile =[NSPredicate predicateWithFormat:@"SELF MATCHES %@",MOBILE];
    
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CM];
    
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CU];
    
    NSPredicate*regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CT];
    
    NSPredicate*regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",PHS];
    
    if(([regextestmobile evaluateWithObject:mobileNum]==YES)
       ||([regextestcm evaluateWithObject:mobileNum]== YES)
       ||([regextestct evaluateWithObject:mobileNum]== YES)
       ||([regextestcu evaluateWithObject:mobileNum]== YES)
       ||([regextestphs evaluateWithObject:mobileNum]== YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
#endif
    
    NSString *phoneRegex = @"(^(01|1)[3,4,5,8][0-9])\\d{8}$" ;
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobileNum];
}
///根据countryId返回最开始选择的row（省，市，区）
+ (TGOInitialRow *)getInitialRowFromCountryId:(NSString *)countryId andTGOAddressArray:(TGOAddressArray *)addressArray
{
    TGOInitialRow *initialRow = [[TGOInitialRow alloc]init];
    NSInteger provinceId = 0;
    NSInteger cityId = 0;
    NSInteger areaId = [countryId integerValue];
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"ormlite" ofType:@"db"];
    FMDatabase *db = [FMDatabase databaseWithPath:filePath];
    BOOL ret = NO;
    if([db open])
    {
        if(areaId && areaId !=0)
        {
            FMResultSet *rs = [db executeQuery:@"SELECT * FROM area"];
            while ([rs next])
            {
                ///如果省份ID一样 则把城市加入到数组
                if ([rs intForColumn:@"areaId"] == areaId)
                {
                    cityId = [rs intForColumn:@"cityId"];
                    provinceId = [rs intForColumn:@"provinceId"];
                    ret = YES;
                    break;
                }
            }
            [rs close];
            [db close];
        }
    }
    
    for(int i=0;i<addressArray.provinces.count;i++)
    {
        ProvinceModel *model = addressArray.provinces[i];
        if(model.provinceId == provinceId)
        {
            initialRow.provinceRow = i;
            break;
        }
    }
    
    for(int i=0;i<addressArray.citys.count;i++)
    {
        CityModel *model = addressArray.citys[i];
        if(model.cityId == cityId)
        {
            initialRow.cityRow = i;
            break;
        }
    }
    
    for(int i=0;i<addressArray.countrys.count;i++)
    {
        AreaModel *model = addressArray.countrys[i];
        if(model.areaId == areaId)
        {
            initialRow.countyrRow = i;
            break;
        }
    }
    return initialRow;
}
///根据countryId返回最开始的数组
+ (TGOAddressArray *)getAddressArrayFromCountryId:(NSString *)countryId;
{
    
    TGOAddressArray *addressArray = [[TGOAddressArray alloc]init];
    addressArray.provinces = [NSMutableArray array];
    addressArray.citys = [NSMutableArray array];
    addressArray.countrys = [NSMutableArray array];
    
    NSInteger provinceId = 0;
    NSInteger cityId = 0;
    NSInteger areaId = [countryId integerValue];
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"ormlite" ofType:@"db"];
    FMDatabase *db = [FMDatabase databaseWithPath:filePath];
    BOOL ret = NO;
    if([db open])
    {
        if(areaId && areaId !=0)
        {
            FMResultSet *rs = [db executeQuery:@"SELECT * FROM area"];
            while ([rs next])
            {
                ///如果省份ID一样 则把城市加入到数组
                if ([rs intForColumn:@"areaId"] == areaId)
                {
                    cityId = [rs intForColumn:@"cityId"];
                    provinceId = [rs intForColumn:@"provinceId"];
                    ret = YES;
                    break;
                }
            }
            [rs close];
            [db close];
        }
    }
    
    
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM province"];
        while ([rs next]){
            ProvinceModel *model = [[ProvinceModel alloc] init];
            model.province = [rs stringForColumn:@"provinceName"];
            model.provinceId = [rs intForColumn:@"provinceId"];
            [addressArray.provinces addObject:model];
        }
        [rs close];
        [db close];
    }
    
    if ([db open])
    {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM city"];
        while ([rs next])
        {
            ///如果省份ID一样 则把城市加入到数组
            if ([rs intForColumn:@"provinceId"] == provinceId)
            {
                CityModel *model = [[CityModel alloc] init];
                model.cityName = [rs stringForColumn:@"cityName"];
                model.cityId = [rs intForColumn:@"cityId"];
                model.provinceId = [rs intForColumn:@"provinceId"];
                [addressArray.citys addObject:model];
            }
        }
        [rs close];
        [db close];
    }
    
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:@"SELECT *FROM area"];
        while ([rs next]) {
            ///城市id一样 把区域加入到区域数组
            ///[self.locatePicker selectedRowInComponent:1]会返回
            ///compoment=1的当前选择的Row
            if ([rs intForColumn:@"cityId"] == cityId) {
                AreaModel *model = [[AreaModel alloc] init];
                model.areaName = [rs stringForColumn:@"areaName"];
                model.areaId = [rs intForColumn:@"areaId"];
                model.cityId = [rs intForColumn:@"cityId"];
                model.provinceId = [rs intForColumn:@"provinceId"];
                [addressArray.countrys addObject:model];
            }
        }
        [rs close];
        [db close];
    }
    
    return  addressArray;
}
///根据省，市，区获取地区信息，入四川省成都市成华区
+ (NSString *)getAddressWithAndAreaId:(NSInteger )areaId
{
    NSMutableString *address = [NSMutableString stringWithFormat:@""];
    NSString *country;
    NSString *city;
    NSString *province;
    NSInteger provinceId = 0;
    NSInteger cityId = 0;
    
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"ormlite" ofType:@"db"];
    FMDatabase *db = [FMDatabase databaseWithPath:filePath];
    BOOL ret = NO;
    if([db open])
    {
        if(areaId && areaId !=0)
        {
            FMResultSet *rs = [db executeQuery:@"SELECT * FROM area"];
            while ([rs next])
            {
                ///如果省份ID一样 则把城市加入到数组
                if ([rs intForColumn:@"areaId"] == areaId)
                {
                    country = [rs stringForColumn:@"areaName"];
                    cityId = [rs intForColumn:@"cityId"];
                    provinceId = [rs intForColumn:@"provinceId"];
                    ret = YES;
                    break;
                }
            }
            [rs close];
            [db close];
        }
    }
    if(ret)
    {
        if ([db open])
        {
            FMResultSet *rs = [db executeQuery:@"SELECT * FROM province"];
            while ([rs next])
            {
                ///如果省份ID一样 则把城市加入到数组
                if ([rs intForColumn:@"provinceId"] == provinceId)
                {
                    province = [rs stringForColumn:@"provinceName"];
                    break;
                }
            }
            [rs close];
            [db close];
        }
        if([db open])
        {
            FMResultSet *rs = [db executeQuery:@"SELECT * FROM city"];
            while ([rs next])
            {
                ///如果省份ID一样 则把城市加入到数组
                if ([rs intForColumn:@"cityId"] == cityId)
                {
                    city = [rs stringForColumn:@"cityName"];
                    break;
                }
            }
            [rs close];
            [db close];
        }
        address = [NSMutableString stringWithFormat:@"%@ %@ %@",province,city,country];
    }
    else
    {
        return nil;
    }
    return address;
}
///根据productmodel返回的skuarray，返回一个装着有的所有规格的数组（AttributeModel）
+ (NSMutableArray *)getAttributeModelArrayFromSkuArray:(NSMutableArray *)skuArray{
    
/*
 skuMOdel
 @property (nonatomic, strong) NSString *SkuId;
 @property (nonatomic, strong) NSString *AttributeId;
 @property (nonatomic, strong) NSString *AttributeName;
 @property (nonatomic, assign) BOOL UseAttributeImage;
 @property (nonatomic, strong) NSString *ValueId;
 @property (nonatomic, strong) NSString *ValueName;
 @property (nonatomic, strong) NSString *ImageUrl;
 */
    
/*
 AttributeModel 
 
 @property (nonatomic, strong) NSString *AttributeId;
 @property (nonatomic, strong) NSString *AttributeName;
 @property (nonatomic, strong) NSArray<ValueModel> *AttributeValues;
 */
    
/*
 ValueModel
 
 @property (nonatomic, strong) NSString *ValueId;
 @property (nonatomic, strong) NSString *ValueName;
 ///便于选择规格
 @property (nonatomic, strong) NSString *SkuId;
 @property (nonatomic, strong) NSString *AttributeId;
 @property (nonatomic, strong) NSString *AttributeName;
 */
    
    NSMutableArray *attArray = [NSMutableArray array];
    
    ///创建attmodel
    for(int i=0;i<skuArray.count;i++)
    {
        SkuModel *skuModel = skuArray[i];
        if([self isExitWithArray:attArray andSkuModel:skuModel])
        {
            AttributeModel *attmodel = [[AttributeModel alloc]init];
            attmodel.AttributeId = skuModel.AttributeId;
            attmodel.AttributeName = skuModel.AttributeName;
            attmodel.AttributeValues = [NSArray array];
            [attArray addObject:attmodel];
        }
    }
    ///给attmodel里面的valuearray添加元素
    for(int i=0;i<skuArray.count;i++)
    {
        SkuModel *skuModel = skuArray[i];
        for(AttributeModel *attmodel in attArray)
        {
            if([skuModel.AttributeId isEqualToString:attmodel.AttributeId])
            {
                ValueModel *valueModel = [[ValueModel alloc]init];
                valueModel.SkuId = skuModel.SkuId;
                valueModel.AttributeId= skuModel.AttributeId;
                valueModel.AttributeName = skuModel.AttributeName;
                valueModel.ValueId = skuModel.SkuValueId;
                valueModel.ValueName = skuModel.SkuValueName;
                NSMutableArray *newArray = [NSMutableArray arrayWithArray:attmodel.AttributeValues];
                [newArray addObject:valueModel];
                attmodel.AttributeValues = nil;
                attmodel.AttributeValues = [NSArray arrayWithArray:newArray];
            }
        }
    }
    
    return attArray;
}
///返回No表示存在，不用创建 返回yes表示不存在 需要创建Attmodel
+ (BOOL)isExitWithArray:(NSMutableArray *)array andSkuModel:(SkuModel *)model
{
    for(int i=0;i<array.count;i++)
    {
        AttributeModel *attModel = array[i];
        if([model.AttributeId isEqualToString:attModel.AttributeId])
        {
            return NO;
        }
    }
    return YES;
}
///时间戳转换成时间
+(NSString *)timechange:(NSString*)endtime andType:(NSString *)type;
{
    NSDate *date=[NSDate dateWithTimeIntervalSince1970:[endtime intValue]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:type];
    return [formatter stringFromDate:date];
}
+(CGSize )getActualsizeFromSize:(CGSize )size AndFont:(UIFont *)font AndText:(NSString *)text{
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    CGSize  actualsize =[text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    return actualsize;
}
///获取收货默认地址（如果没有默认 则获取第一条）
+ (void)getOneAddressCompelte:(void (^)(id getOneAddress))GetAddress;
{
    [AFNManager getDataWithAPI:kResPathGetAddresses
                 andArrayParam:@[USERID]
                  andDictParam:@{}
                     dataModel:@"AddressModel"
                requestSuccessed:^(id responseObject) {
                    BOOL flag = NO;
                    AddressModel *defaultItem = nil;
                    if([responseObject isKindOfClass:[NSArray class]])
                    {
                        NSArray *array = (NSArray *)responseObject;
                        if([responseObject isKindOfClass:[NSArray class]] && array.count > 0)
                        {
                            for(AddressModel *item in array)
                            {
                                if(item.IsDefault)
                                {
                                    defaultItem = item;
                                    flag = YES;
                                    break;
                                }
                            }
                            if(!flag)
                            {
                                defaultItem = array[0];
                            }
                        }
                    }
                    
                    if (GetAddress) {
                        GetAddress(defaultItem);
                    }
                    
                } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    if (GetAddress) {
                        GetAddress(nil);
                    }
                }];
    
}
///去除skumodel里面的重合
+ (NSMutableArray *)getskuArrayWithArray:(NSArray *)array
{
    NSMutableArray *muArray = [NSMutableArray array];
    
    for(SkuModel *model in array)
    {
        BOOL ret = NO;
        for(SkuModel *submodel in muArray)
        {
            if([submodel.SkuValueId isEqualToString:model.SkuValueId])
            {
                ret = YES;
                break;
            }
        }
        if(!ret)
        {
            [muArray addObject:model];
        }
    }
    
    return muArray;
    
}
@end
