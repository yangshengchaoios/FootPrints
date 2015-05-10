//
//  UrlConstants.h
//  SCSDEnterprise
//
//  Created by  YangShengchao on 14-2-13.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//  FORMATED!
//

#ifndef SCSDEnterprise_UrlConstants_h
#define SCSDEnterprise_UrlConstants_h


#define TGO_DEBUG_MODEL 0     //0-正式发布 1-测试环境
#define TGO_DEBUG_LOG   0     //0-关闭调试日志 1-打开调试日志

/**
 *  定义项目的配置文件路径
 */
#define ConfigPlistPath             [[NSBundle mainBundle] pathForResource:@"AppConfig" ofType:@"plist"]
#define ConfigValue(x)              [[StorageManager sharedInstance] valueInAppConfig:x]                //获取项目动态的配置信息


/**
 *  定义各种正式和测试的接口地址
 */
#pragma mark - define urls

#if TGO_DEBUG_MODEL
    #define kResPathBaseUrl           @"http://192.168.1.116:8080/FootprintService/"            //内网业务接口前缀
    #define kAppChannel               @"微秀内测版"
    #define kUMAppKey                 @"5355d71956240bc5f9068f79"  //UM APP Key
    #define kSMS_SDKAppkey            @"3e6b878c415a"
    #define kAPPItunesId              ConfigValue(@"APPItunesId")
    #define kSMS_SDKAppSecret         @"415fe9b8677158a286515bed8743a92a"
    #define kBaiduMap_Secret          @"ubo1YAzjLrRdQCLbl6D9Aud9"
//QQ  562305405
    #define kShareSDKKey  @"4ba487a1bb16"
    #define kSocialQQId     @"1103675394"
    #define kSocialQQKey    @"kQPwvIz1UpRKC5Kf"
//Weibo  thislifee@me.com
    #define kSocialSinaId       @"2588309835"
    #define kSocialSinaKey      @"de552bc3c98d94f7c7dce970a1b02c58"
    #define kSocialSinaBackUrl  @"http://www.gajent.com/appauth"
//Weixin  562305405@qq.com  0301
    #define kSocialWeixinId     @"wx6de568d21fa5f9b7"
    #define kSocialWeixinKey    @"34823f304a4ca3062c31513166d11fef"
    #define kSocialShareURL     @"http://baidu.com"
#else
    #define kResPathBaseUrl           ConfigValue(@"APPBaseUrl")                //外网业务接口前缀
    #define kAppChannel               ConfigValue(@"APPChannel")
    #define kUMAppKey                 ConfigValue(@"UMAppKey")      //UM APP Key
    #define kAPPItunesId              ConfigValue(@"APPItunesId")
    #define kSMS_SDKAppkey            @"3e6b878c415a"
    #define kSMS_SDKAppSecret         @"415fe9b8677158a286515bed8743a92a"
    #define kBaiduMap_Secret          @"ubo1YAzjLrRdQCLbl6D9Aud9"
//QQ  562305405
#define kShareSDKKey  ConfigValue(@"kShareSDKKey")
#define kSocialQQId    ConfigValue(@"kSocialQQId")
#define kSocialQQKey   ConfigValue(@"kSocialQQKey")
//Weibo  thislifee@me.com
#define kSocialSinaId       ConfigValue(@"kSocialSinaId")
#define kSocialSinaKey     ConfigValue(@"kSocialSinaKey")
#define kSocialSinaBackUrl  ConfigValue(@"kSocialSinaBackUrl")
//Weixin  562305405@qq.com  0301
#define kSocialWeixinId     ConfigValue(@"kSocialWeixinId")
#define kSocialWeixinKey    ConfigValue(@"kSocialWeixinKey")
#define kSocialShareURL     ConfigValue(@"kSocialShareURL")
#endif


/**
 *  第三方登录、分享平台key定义
 */
#pragma mark - 第三方平台key控制

#define TgoAppKeyOfShareSDK         @"14f56e096690"
#define RedirectUrlTencentWeibo     ConfigValue(@"AppRedirectUrlTencentWeibo")
#define RedirectUrlSinaWeibo        ConfigValue(@"AppRedirectUrlSinaWeibo")

//qq互联
#define AppKeyQQ                ConfigValue(@"AppKeyQQ")
#define AppSecretQQ             ConfigValue(@"AppSecretQQ")

//腾讯微博
#define AppKeyTencentWeibo      ConfigValue(@"AppKeyTencentWeibo")
#define AppSecretTencentWeibo   ConfigValue(@"AppSecretTencentWeibo")

//新浪微博(Johnny_ZW天购APP)
#define AppKeySinaWeibo         ConfigValue(@"AppKeySinaWeibo")
#define AppSecretSinaWeibo      ConfigValue(@"AppSecretSinaWeibo")

//微信
#define AppKeyWeiXin            ConfigValue(@"AppKeyWeiXin")



/**
 *  接口地址
 */
#pragma mark - 接口访问地址

//Account
#define kResPathLogin                       @"LoginRegister/Login"               //登录
#define kResPathRegister                    @"LoginRegister/Register"            //用户注册
#define kResPathFindPassword                @"LoginRegister/FindPassword"        //找回密码

//Index
#define kResPathGetBanners                  @"Index/GetBanners"
#define kResPathGetTravels                  @"Index/GetTravels"
#define kResPathGetFriendTravels            @"Index/GetFriendTravels"
#define kResPathGetTravel                   @"Index/GetTravel"
#define kResPathGetActivities               @"Index/GetActivities"
#define kResPathGetServerTime               @"Index/GetServerTime"
#define kResPathGetActivityTravels          @"Index/GetActivityTravels"
#define kResPathVoteActivity                @"Index/VoteActivity"
#define kResPathSaveTravel                  @"Index/SaveTravel"                           //保存足迹
#define kResPathParticipationActivity       @"Index/ParticipationActivity"
#define kResPathGetBackgroundMusic          @"Index/GetBackgroundMusic"                   //获取背景音乐
#define kResPathGetMyTravels                @"Index/GetMyTravels"
#define kResPathGetUserTimeTravels          @"Index/GetUserTimeTravels"


#define kResPathGetMemberInfo               @"MemberCenter/GetMemberInfo"
#define kResPathGetMyFriends                @"MemberCenter/GetMyFriends"
#define kResPathGetMyLoveMember             @"MemberCenter/GetMyLoveMember"
#define kResPathGetLoveMeMember             @"MemberCenter/GetLoveMeMember"
#define kResPathAddMember                   @"MemberCenter/AddMember"
#define kResPathGetRecommends               @"MemberCenter/GetRecommends"
#define kResPathGetFriendRecommends         @"MemberCenter/GetFriendRecommends"
#define kResPathGetNearbyMember             @"MemberCenter/GetNearbyMember"
#define kResPathGetParticularlyRecommends   @"MemberCenter/GetParticularlyRecommends"
#define kResPathSearchMember                @"MemberCenter/SearchMember"
#define kResPathCheckContactMembers         @"MemberCenter/CheckContactMembers"
#define kResPathChangeBackgroundImage       @"MemberCenter/ChangeBackgroundImage"

#define kResPathGetMyMessages               @"MemberCenter/GetMyMessages"
/**
 *  定义网络POST提交、GET提交、页面间传递的参数
 */
#pragma mark - Param Name of POST & GET

#define kParamHeadImage                     @"headImage"                    //头像
#define kParamSex                           @"sex"                          //性别
#define kParamNickName                      @"nickName"                     //昵称
#define kParamNewPassword                   @"newPassword"                  //新密码
#define kParamContactWay                    @"contactWay"                   //修改密码方式
#define kParamOldMemberName                 @"OldMemberName"                //旧手机号
#define kParamNewMemberName                 @"NewMemberName"                //新手机号
#define kParamPassword                      @"password"                     //登录密码
#define kParamMemberName                    @"memberName"                   //手机号
#define kParamMemberId                      @"MemberId"                     //用户ID


/**
 *  支付宝（商家服务）常量对应
 */
#ifndef MQPDemo_PartnerConfig_h
    #define MQPDemo_PartnerConfig_h

    #define AlipayNotifyURL         @"AlipayNotifyURL"
    #define AlipayReturnURL         @"AlipayReturnURL"
    #define AlipayPartnerID         @"AlipayPartnerID"
    #define AlipaySellerID          @"AlipaySellerID"



    //安全校验码（MD5）密钥，以数字和字母组成的32位字符
//    #define AlipayMD5KEY            ConfigValue(@"AlipayMD5KEY")

    //商户私钥，自助生成
    #define AlipayPartnerPrivKey    @"AlipayPartnerPrivKey"


    //支付宝公钥
    #define AlipayPubKey   @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDbMJM0dSylF/6v29Us83CG7nemkbdzUwKIPH6Lz1n7kks0u1RgpDRakyLgzN8v1OSFbD05RE/FHI6ooTMuNDhPHEKr+p7l/fty6K0ed1C2nlm6mbb3QifRv6+iIFYuwREFr+3lvro01zbRrz4uDYhZfbAqvGydiPZt6unig4NKMwIDAQAB"
#endif





#endif
