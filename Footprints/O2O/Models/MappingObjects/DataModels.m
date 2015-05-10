//
//  DataModels.h.m
//  TGOMarket
//
//  Created by  YangShengchao on 14-4-29.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import "DataModels.h"


@implementation CommonBaseModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

/**
 *  添加反序列化方法
 *
 *  @param aDecoder
 *
 *  @return
 */
-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        unsigned int outCount = 0;
        objc_property_t *properties = class_copyPropertyList([self class], &outCount);
        
        @try {
            for (int i = 0; i < outCount; i++) {
                objc_property_t property = properties[i];
                NSString *key=[[NSString alloc] initWithCString:property_getName(property)
                                                       encoding:NSUTF8StringEncoding];
                id value = [aDecoder decodeObjectForKey:key];
                if (value) {
                    [self setValue:value forKey:key];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception: %@", exception);
            return nil;
        }
        @finally {
            
        }
        
        free(properties);
    }
    return self;
}

/**
 *  添加序列化方法
 *
 *  @param aCoder
 */
- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (int i = 0; i < outCount; i++) {
        
        objc_property_t property = properties[i];
        NSString *key=[[NSString alloc] initWithCString:property_getName(property)
                                               encoding:NSUTF8StringEncoding];
        
        id value=[self valueForKey:key];
        if (value && key) {
            if ([value isKindOfClass:[NSObject class]]) {
                [aCoder encodeObject:value forKey:key];
            } else {
                NSNumber * v = [NSNumber numberWithInt:(int)value];
                [aCoder encodeObject:v forKey:key];
            }
        }
    }
    free(properties);
    properties = NULL;
}

@end


@implementation BannerModel

//+(JSONKeyMapper*)keyMapper {
//    return [[JSONKeyMapper alloc] initWithDictionary:@{@"AddedDate" : @"HelpAddedDate"}];
//}

@end

@implementation FriendRecommeds
+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"firstDatas":@"friendsRecommendDatas",@"secondDatas":@"systemRecommendDatas"}];
}
@end

@implementation JJMemberModel

- (NSString *)nickName{
    return ![StringUtils isEmpty:self.remark]?self.remark:_nickName;
}

- (void)setBirthday:(NSTimeInterval)birthday{
    
    NSTimeInterval interval = birthday;
    if (interval > 100000000.0f * 1000.0f) {//判断单位是秒还是毫秒
        interval = interval / 1000.0f;
    }
    _birthday = interval;
}

@end

@implementation AttributeModel


@end

@implementation BackgroundMusicModel

@end

@implementation BaseTravelModel

- (void)setAddDate:(NSDate *)addDate{
    
    NSTimeInterval interval = [addDate timeIntervalSince1970];
    if (interval > 100000000.0f * 1000.0f) {//判断单位是秒还是毫秒
        interval = interval / 1000.0f;
    }
    _addDate = [NSDate dateWithTimeIntervalSince1970:interval];
}
//+(JSONKeyMapper*)keyMapper {
//    return [[JSONKeyMapper alloc] initWithDictionary:@{@"travelImages":@"detailImages"}];
//}
@end

@implementation IndexTravelModel


@end

@implementation DetailImageModel

@end

@implementation DetailTravelModel

@end

@implementation FriendTravelModel

@end

@implementation ActivityModel
- (NSTimeInterval)startTime{
    NSTimeInterval interval = _startTime;
    if (_startTime > 100000000.0f * 1000.0f) {//判断单位是秒还是毫秒
        interval = interval / 1000.0f;
    }
    return interval;
}

- (NSTimeInterval)reviewStartTime{
    NSTimeInterval interval = _reviewStartTime;
    if (_reviewStartTime > 100000000.0f * 1000.0f) {//判断单位是秒还是毫秒
        interval = interval / 1000.0f;
    }
    return interval;
}
- (NSTimeInterval)reviewEndTime{
    NSTimeInterval interval = _reviewEndTime;
    if (_reviewEndTime > 100000000.0f * 1000.0f) {//判断单位是秒还是毫秒
        interval = interval / 1000.0f;
    }
    return interval;
}
@end

@implementation ActivityTravelModel
- (NSDate *)joinDate{
    NSTimeInterval interval = [_joinDate timeIntervalSince1970];
    if (interval > 1000000000.0f * 1000.0f) {//判断单位是秒还是毫秒
        interval = interval / 1000.0f;
    }
    return [NSDate dateWithTimeIntervalSince1970:interval];
}
@end

@implementation ServerTimeModel

@end

@implementation ContactMemberModel

@end

@implementation CheckContactMembersModel



@end

@implementation TravelTimeModel
@end

@implementation MessageModel
- (void)setMsgDate:(NSDate *)msgDate{
    NSTimeInterval interval = [msgDate timeIntervalSince1970];
    if (interval > 1000000000.0f * 1000.0f) {//判断单位是秒还是毫秒
        interval = interval / 1000.0f;
    }
    _msgDate = [NSDate dateWithTimeIntervalSince1970:interval];
}
@end

@implementation MessageListModel

@end

@implementation MemberGroupModel

@end

@implementation MemberInGroupModel


@end

@implementation ShakeActivityModel

@end

@implementation GiftProductModel
- (void)setAddDate:(NSDate *)addDate{
    NSTimeInterval interval = [addDate timeIntervalSince1970];
    if (interval > 1000000000.0f * 1000.0f) {//判断单位是秒还是毫秒
        interval = interval / 1000.0f;
    }
    _addDate = [NSDate dateWithTimeIntervalSince1970:interval];
}
- (void)setExChangeDate:(NSDate *)exChangeDate{
    NSTimeInterval interval = [exChangeDate timeIntervalSince1970];
    if (interval > 1000000000.0f * 1000.0f) {//判断单位是秒还是毫秒
        interval = interval / 1000.0f;
    }
    _exChangeDate = [NSDate dateWithTimeIntervalSince1970:interval];
}
@end

@implementation PointRuleModel

@end

@implementation ShakeResult


@end

@implementation FriendGroupInfo

@end

@implementation VersionModel

@end

@implementation CollectionModel

- (void)setTravelDate:(NSDate *)travelDate{
    NSTimeInterval interval = [travelDate timeIntervalSince1970];
    if (interval > 1000000000.0f * 1000.0f) {//判断单位是秒还是毫秒
        interval = interval / 1000.0f;
    }
    _travelDate = [NSDate dateWithTimeIntervalSince1970:interval];
}
@end

@implementation SearchTravelModel

@end



