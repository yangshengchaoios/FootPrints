//
//  StorageManager.h
//  SCSDEnterprise
//
//  Created by  YangShengchao on 14-2-14.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

/**
 * 用来根据不同用户管理文件的存储
 */

#import <Foundation/Foundation.h>
#import "FileUtils.h"
#import "StringUtils.h"

@interface StorageManager : NSObject

+ (instancetype)sharedInstance;

/**
 *	设置用户目录对应的id
 *
 *	@param	userId	用户的id
 */
- (void)setUserId:(NSString *)userId;

#pragma mark - 文件和目录路径

/**
 *	Documents/
 *
 *	@return	Documents路径
 */
- (NSString *)documentsDirectoryPath;
/**
 *	Documents/user_id/
 *
 *	@return	文档目录下的用户目录
 */
- (NSString *)documentsDirectoryPathByUser;
/**
 *	Documents/common/
 *
 *	@return	文档目录下的公共目录
 */
- (NSString *)documentsDirectoryPathCommon;

/**
 *	Documents/user_id/scsd.sqlite
 *
 *	@return	用户数据库路径
 */
- (NSString *)databaseFilePath;

/**
 *	Documents/common/settings.archive
 *
 *	@return	设置项的归档文件路径
 */
- (NSString *)settingsFilePath;

/**
 *  Documents/Log/
 *
 *  @return 日志目录
 */
- (NSString *)documentsDirectoryLogPath;

/**
 *	Library/Caches
 *
 *	@return	Caches目录路径
 */
- (NSString *)cachesDirectoryPath;
/**
 *	Library/Caches/user_id/
 *
 *	@return	文档目录下的用户目录
 */
- (NSString *)cachesDirectoryPathByUser;
/**
 *	Library/Caches/common/
 *
 *	@return	文档目录下的公共目录
 */
- (NSString *)cachesDirectoryPathCommon;

/**
 *	Library/Caches/common/lbs.archive
 *
 *	@return	地理位置信息的归档文件路径
 */
- (NSString *)lbsInfoFilePath;

/**
 *	Library/Caches/user_id/userInfo.archive
 *
 *	@return	用户登录信息的归档文件路径
 */
- (NSString *)userInfoFilePath;

/**
 *	Library/Caches/user_id/audio/
 *
 *	@return	音频文件的缓存路径
 */
- (NSString *)audioDirectoryPath;

/**
 *	Library/Caches/user_id/video/
 *
 *	@return	视频文件的缓存路径
 */
- (NSString *)videoDirectoryPath;

/**
 *	Library/Caches/user_id/pic/
 *
 *	@return	发送的图片的保存路径
 */
- (NSString *)chatPictureDirectoryPath;

/**
 *	temp/
 *
 *	@return	临时文件目录路径
 */
- (NSString *)tmpDirectoryPath;

/**
 *	temp/uploading_pictures
 *
 *	@return	要上传的图片临时保存的目录路径
 */
- (NSString *)uploadingPictureDirectoryPath;

#pragma mark - 配置文件存取

/**
 *	设置配置文件键值对
 *
 *	@param	value	值
 *	@param	key	键
 */
- (void)setConfigValue:(NSObject *)value forKey:(NSString *)key;

/**
 *	设置配置文件键值对
 *
 *	@param	firstObject	按照"值,键,值,键,nil"的顺序输入
 */
- (void)setConfigWithValuesAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

/**
 *	根据某个key获取配置项的值
 *
 *	@param	key	键
 *
 *	@return	配置的值
 */
- (id)configValueForKey:(NSString *)key;

/**
 *	获取所有配置项的值
 *
 *	@return	包含用户配置项的字典
 */
- (NSDictionary *)configDictionary;



/**
 *	设置用户配置文件键值对
 *
 *	@param	value	值
 *	@param	key	键
 */
- (void)setUserConfigValue:(NSObject *)value forKey:(NSString *)key;

/**
 *	设置用户配置文件键值对
 *
 *	@param	firstObject	按照"值,键,值,键,nil"的顺序输入
 */
- (void)setUserConfigWithValuesAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

/**
 *	根据某个key获取用户配置项的值
 *
 *	@param	key	键
 *
 *	@return	配置的值
 */
- (id)userConfigValueForKey:(NSString *)key;

/**
 *	获取所有用户配置项的值
 *
 *	@return	包含用户配置项的字典
 */
- (NSDictionary *)userConfigDictionary;


/**
 *	读取归档文件到字典
 *
 *	@param	filePath	归档文件的地址
 *
 *	@return	字典
 */
- (NSDictionary *)unarchiveDictionaryFromFilePath:(NSString *)filePath;

- (BOOL)archiveDictionary:(NSDictionary *)dicionary toFilePath:(NSString *)filePath;

/**
 *	保存字典到归档文件
 *
 *	@param	dicionary	要保存的字典
 *	@param	filePath	归档文件的地址
 *  @param	overwrite	是否抛弃已有的键值对
 *
 *	@return	保存是否成功
 */
- (BOOL)archiveDictionary:(NSDictionary *)dicionary toFilePath:(NSString *)filePath overwrite:(BOOL)overwrite;

#pragma mark - 文件管理

/**
 *	清除某些缓存目录。注意不是整个Caches目录的删除。
 */
- (void)clearCaches;

- (void)ensureAllDirectories;


#pragma mark - AppConfig.plist管理

- (NSString *)valueInAppConfig:(NSString *)key;

@end
