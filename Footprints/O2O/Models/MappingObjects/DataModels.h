//
//  DataModels.h
//  TGOMarket
//
//  Created by  YangShengchao on 14-4-29.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import "BaseModel.h"
#import "EnumType.h"



typedef NS_ENUM(NSInteger, FriendType) {
    //0陌生人1我关注的2 粉丝 3好友 4黑名单
    FriendTypeStranger = 0,
    FriendTypeILike = 1,
    FriendTypeFans = 2,
    FriendTypeFriends = 3,
    FriendTypeBlackList = 4,
};

/**
 *MemberName
 */
typedef enum MessageType{
    MessageTypeText = 1,
    MessageTypeVoice = 2
}MessageType;

typedef enum MemberStatus{
    MemberStatusNormal = 0,
    MemberStatusForbiden = 1,
    MemberStatusOfficer = 2,
}MemberStatus;

typedef enum GiftType{
    GiftTypeHuaFei = 1,
    GiftTypeYouHuiQuan = 2,
    GiftTypeShiWu = 3
}GiftType;


/**
 *  数组映射关系
 */
@protocol BannerModel               @end
@protocol JJMemberModel             @end
@protocol DetailImageModel          @end
@protocol ContactMemberModel        @end
@protocol BaseTravelModel           @end
@protocol DetailTravelModel         @end
@protocol MessageModel              @end
@protocol MemberInGroupModel        @end
/**
 *  要使用的model在本类里
 */
@class AddressModel,JJMemberModel;

/**
 *  公共model的基类，主要是设置所有参数都是optional的
 */
@interface CommonBaseModel : JSONModel

@end

@interface JJMemberModel : CommonBaseModel
@property (nonatomic, strong) NSString *memberId; //id
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *headImage;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, assign) NSInteger currentPoint;//当前积分
@property (nonatomic, assign) NSInteger totalPoint;//总积分
@property (nonatomic, assign) MemberStatus memberStatus;//会员状态(0:正常;1:冻结)
@property (nonatomic, strong) NSString *signature;//注册时间
@property (nonatomic, strong) NSDate *registDate;//注册时间
@property (nonatomic, strong) NSDate *lastLoginTime;//最后登录时间
@property (nonatomic, assign) double longitude;//
@property (nonatomic, assign) double latitude;//
@property (nonatomic, assign) double distance;//
@property (nonatomic, strong) NSString *token;
@property (nonatomic, assign) BOOL isFriend; ////0不是好友，可添加；1已经是好友
@property (nonatomic, assign) BOOL isBlack; ////0不是好友，可添加；1已经是好友
@property (nonatomic, assign) NSTimeInterval birthday;
@property (nonatomic, assign) NSInteger mylove;
@property (nonatomic, assign) NSInteger loveme;
@property (nonatomic, strong) NSString *backgroundImage;
@property (nonatomic, strong) NSString *remark;
@end

@interface ContactMemberModel : JJMemberModel
@property (nonatomic,assign) BOOL isNew;
@end

/**
 * 订单模型
 */
@interface BannerModel : CommonBaseModel

@property (nonatomic, strong) NSString *bannerId;
@property (nonatomic, strong) NSString *bannerTitle;
@property (nonatomic, strong) NSString *bannerImage;
@property (nonatomic, strong) NSString *bannerLink;
@property (nonatomic, strong) NSString *linkContent;
@property (nonatomic, assign) NSInteger sequence;
@property (nonatomic, assign) NSInteger linkType;
@end

/**
 * 商品属性类别
 */
@interface AttributeModel : CommonBaseModel

@property (nonatomic, strong) NSString *AttributeId;
@property (nonatomic, strong) NSString *AttributeName;
//@property (nonatomic, strong) NSArray<ValueModel> *AttributeValues;
@end

/*
 *背景音乐模型
 */
@interface BackgroundMusicModel :CommonBaseModel
@property (nonatomic, strong) NSString *musicId;
@property (nonatomic, strong) NSString *urlPath;
@property (nonatomic, strong) NSString *musicName;
@end




/*
 *基础事件
 */
@interface BaseTravelModel : CommonBaseModel

@property (nonatomic, assign) MemberStatus memberStatus;//会员状态(0:正常;1:冻结)
@property (nonatomic,strong) NSDate *addDate;
@property (nonatomic,strong) NSString *headImage;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *travelId;
@property (nonatomic,strong) NSString *memberId;
@property (nonatomic,strong) NSString *memberName;
@property (nonatomic,assign) NSInteger skimCount;
@property (nonatomic,strong) NSString *image;
@property (nonatomic,strong) NSString *location;
@end

/*
 *详情图片
 */
@interface DetailImageModel : CommonBaseModel
@property (nonatomic,strong) NSString *imageUrl;
@property (nonatomic,assign) NSInteger widthSize;
@property (nonatomic,assign) NSInteger heightSize;
@end

/*
 *足迹详情
 */
@interface DetailTravelModel : BaseTravelModel

@property (nonatomic,assign) NSInteger ranking;
@property (nonatomic,assign) NSInteger messageCount;
@property (nonatomic,strong) NSString *releaseContent;
@property (nonatomic,strong) NSString *voice;
@property (nonatomic,strong) NSString *groupId;
@property (nonatomic,assign) BOOL isCollection;
@property (nonatomic,assign) BOOL isPraise;
@property (nonatomic,assign) BOOL isJoinActivity;
@property (nonatomic,strong) NSString *backgroundMusic;
@property (nonatomic,assign) NSInteger praiseCount;
@property (nonatomic,assign) NSInteger visibleRange;
@property (nonatomic,strong) NSArray<DetailImageModel> *detailImages;
@end

/*
 *足迹推荐
 */
@interface IndexTravelModel : BaseTravelModel

@property (nonatomic,assign) NSInteger heightSize;
@property (nonatomic,assign) NSInteger widthSize;
@end

/*
 *好友足迹
 */
@interface FriendTravelModel : BaseTravelModel

@property (nonatomic,assign) BOOL isSkim;           //登陆用户是否已查阅0未查阅，1已查阅
@property (nonatomic,strong) NSString *remark;
@property (nonatomic,assign) NSInteger unSkimCount,messageCount; //当isSkim为0时有效，未浏览该好友的足迹数
@end

@interface ActivityTravelModel : BaseTravelModel
@property (nonatomic,strong) NSString *activityTravelId;
@property (nonatomic,strong) NSString *travelTitle;
@property (nonatomic,strong) NSString *travelImage;
@property (nonatomic,strong) NSDate *joinDate;
@property (nonatomic,strong) NSString *memberHeadimg;
@property (nonatomic,assign) NSInteger voteCount,ranking;
@property (nonatomic,assign) BOOL status;
@property (nonatomic,assign) BOOL isVote;
@end

/*
 *活动
 */
@interface ActivityModel : CommonBaseModel
@property (nonatomic,strong) NSString *activityId;
@property (nonatomic,strong) NSString *indexImage;
@property (nonatomic,strong) NSString *subject;
@property (nonatomic,strong) NSString *summary;
@property (nonatomic,strong) NSString *detailImage;
@property (nonatomic,assign) NSTimeInterval startTime;
@property (nonatomic,assign) NSTimeInterval endTime;
@property (nonatomic,assign) NSTimeInterval addDate;
@property (nonatomic,assign) NSInteger skimCount;
@property (nonatomic,assign) NSInteger travelsCount;
@property (nonatomic,assign) NSTimeInterval reviewStartTime;
@property (nonatomic,assign) NSTimeInterval reviewEndTime;
@property (nonatomic,assign) BOOL isVote;
@end


@interface ServerTimeModel : CommonBaseModel
@property (nonatomic,assign) NSTimeInterval timestamp;
@end

@interface FriendRecommeds : CommonBaseModel
@property (nonatomic,strong) NSArray<ContactMemberModel> *friendsRecommendDatas;
@property (nonatomic,strong) NSArray<ContactMemberModel> *systemRecommendDatas;
@end

@interface CheckContactMembersModel : CommonBaseModel
@property (nonatomic,strong) NSArray<ContactMemberModel> *data;
@end

@interface TravelTimeModel : CommonBaseModel
@property (nonatomic,assign) FriendType friendType;
@property (nonatomic,assign) BOOL isBlack;
@property (nonatomic,strong) NSArray<DetailTravelModel> *detailImages;
@end

@interface MessageModel : CommonBaseModel
/*
 "messageId":”123456”,//id
 "memberId":”123456”//会员id
 "travelId":”123456”,//足迹id
 "toMemberId":”123456”,//针对会员的回复
 "toNickName":”123456”,//被回复会员的昵称
 "travelImage":””,//足迹主题图片
 "nickName":””//昵称
 "remark":””//备注名
 "memberHeadimg":””//会员头像
 "msgType":””// 留言类型(1：内容，2：语音)
 "msgContent":””// 留言内容
 "msgVoice":””// 留言声音
 "msgDate":””// 留言时间
 */
@property (nonatomic,strong) NSString *messageId;
@property (nonatomic,strong) NSString *memberId;
@property (nonatomic, assign) MemberStatus memberStatus;//会员状态(0:正常;1:冻结)
@property (nonatomic,strong) NSString *friendMemberId;
@property (nonatomic,strong) NSString *friendMemberHeadImage;
@property (nonatomic,strong) NSString *msgImage;
@property (nonatomic,strong) NSString *travelId;
@property (nonatomic,strong) NSString *toMemberId;
@property (nonatomic,strong) NSString *toNickName;
@property (nonatomic,strong) NSString *travelImage;
@property (nonatomic,strong) NSString *nickName;
@property (nonatomic,strong) NSString *remark;
@property (nonatomic,strong) NSString *memberHeadimg;
@property (nonatomic,strong) NSString *msgContent;
@property (nonatomic,strong) NSString *msgVoice;
@property (nonatomic,strong) NSString *activityId;
@property (nonatomic,strong) NSDate *msgDate;
@property (nonatomic,assign) MessageType msgType;
@property (nonatomic,assign) NSInteger contentType;
@end

@interface MessageListModel : CommonBaseModel
@property (nonatomic,assign) NSInteger totalCount;
@property (nonatomic,strong) NSArray<MessageModel> *datas;
@end

@interface MemberGroupModel : CommonBaseModel
@property (nonatomic,strong) NSString *groupId;
@property (nonatomic,strong) NSString *groupName;
@property (nonatomic,assign) NSInteger groupMemberNumber;
@property (nonatomic,strong) NSArray<MemberInGroupModel> *memberNames;
@end

@interface MemberInGroupModel : CommonBaseModel
@property (nonatomic,strong) NSString *param1;//昵称1
@property (nonatomic,strong) NSString *param2;//备注1
@end



@interface ShakeActivityModel : CommonBaseModel
@property (nonatomic,strong) NSString *shakeActivityId;
@property (nonatomic,assign) NSTimeInterval startTime;
@property (nonatomic,assign) NSTimeInterval endTime;
@end


@interface GiftProductModel : CommonBaseModel
@property (nonatomic,strong) NSString *giftId;
@property (nonatomic,strong) NSString *giftName;
@property (nonatomic,strong) NSString *giftDescription;
@property (nonatomic,assign) NSInteger pointValue;
@property (nonatomic,strong) NSString *giftImage;
@property (nonatomic,strong) NSDate *addDate;
@property (nonatomic,strong) NSDate *exChangeDate;
@property (nonatomic,assign) GiftType giftType;
@property (nonatomic,assign) NSInteger giftStatus;
@property (nonatomic,assign) NSInteger skuCount;
@end


@interface PointRuleModel : CommonBaseModel

@property (nonatomic,strong) NSString *ruleId;
@property (nonatomic,strong) NSString *ruleCode;
@property (nonatomic,strong) NSString *ruleDesc;
@property (nonatomic,strong) NSString *ruleImage;
@property (nonatomic,assign) NSInteger point;

@end

@interface ShakeResult : CommonBaseModel

@property (nonatomic,assign) NSInteger point;

@end

@interface FriendGroupInfo : CommonBaseModel

@property (nonatomic,strong) NSString *groupId;
@property (nonatomic,strong) NSString *remark;
@property (nonatomic,strong) NSString *groupName;
@end

@interface VersionModel : CommonBaseModel
@property (nonatomic,strong) NSString *appId;
@property (nonatomic,strong) NSString *appVersion;
@property (nonatomic,strong) NSString *appUrl;
@property (nonatomic,strong) NSString *appUpdateLog;
@property (nonatomic,assign) NSInteger appVersionNumber;

@property (nonatomic,assign) BOOL isForcedUpdate; //App是否强制更新( 1：强制更新 0不强制更新)
@end

@interface CollectionModel : CommonBaseModel
@property (nonatomic,strong) NSString *collectionId;
@property (nonatomic,strong) NSString *travelId;
@property (nonatomic,strong) NSString *title;
@property (nonatomic, assign) MemberStatus memberStatus;//会员状态(0:正常;1:冻结)
@property (nonatomic,strong) NSString *memberName;
@property (nonatomic,strong) NSString *headImage;
@property (nonatomic,strong) NSString *remark;
@property (nonatomic,strong) NSDate *travelDate;
@end

@interface SearchTravelModel : CommonBaseModel

@property (nonatomic,assign) NSInteger totalCount;
@property (nonatomic,strong) NSArray<BaseTravelModel> *datas;
@end

