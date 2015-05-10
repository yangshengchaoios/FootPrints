//
//  StorageManager.m
//  SCSDEnterprise
//
//  Created by  YangShengchao on 14-2-14.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//


#import "StorageManager.h"

#define kCommonDirName      @"common/"
#define kDatabaseFileName   @"scsd.sqlite"
#define kSettingsFileName   @"settings.archive"
#define kLbsInfoFileName    @"lbs.archive"
#define kAudioDirName       @"audio/"
#define kVideoDirName       @"video/"
#define kPictureDirName     @"pic/"
#define kUploadPicsDirName  @"uploading_pictures/"
#define kUserInfoFileName   @"userInfo.archive"

@interface StorageManager ()

@property (nonatomic, strong) NSString *userDir;
@property (nonatomic, strong) NSDictionary *appConfigDictionary;

@end

@implementation StorageManager

+ (instancetype)sharedInstance {
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^ {
        return [[self alloc] init];
    })
}

- (id)init {
    self = [super init];
    if (self) {
        self.userDir = kCommonDirName;
    }
    return self;
}

- (void)setUserId:(NSString *)userId {
    if ( ! [StringUtils isEmpty:userId]) {
        self.userDir = [userId copy];
    }
    else {
        self.userDir = kCommonDirName;
    }
    
    [self ensureAllDirectories];
}

#pragma mark - 文件和目录路径

- (NSString *)documentsDirectoryPath {
    return [FileUtils documentsDirectory];
}

- (NSString *)documentsDirectoryPathByUser {
    return [[self documentsDirectoryPath] stringByAppendingPathComponent:self.userDir];
}

- (NSString *)documentsDirectoryPathCommon {
    return [[self documentsDirectoryPath] stringByAppendingPathComponent:kCommonDirName];
}

- (NSString *)databaseFilePath {
    return [[self documentsDirectoryPathByUser] stringByAppendingPathComponent:kDatabaseFileName];
}

- (NSString *)settingsFilePath {
    return [[self documentsDirectoryPathCommon] stringByAppendingPathComponent:kSettingsFileName];
}

- (NSString *)documentsDirectoryLogPath {
    return [[self documentsDirectoryPath] stringByAppendingPathComponent:@"Log/"];
}

- (NSString *)cachesDirectoryPath {
    return [FileUtils cacheDirectory];
}

- (NSString *)cachesDirectoryPathByUser {
    return [[self cachesDirectoryPath] stringByAppendingPathComponent:self.userDir];
}

- (NSString *)cachesDirectoryPathCommon {
    return [[self cachesDirectoryPath] stringByAppendingPathComponent:kCommonDirName];
}

- (NSString *)lbsInfoFilePath {
    return [[self cachesDirectoryPathCommon] stringByAppendingPathComponent:kLbsInfoFileName];
}

- (NSString *)userInfoFilePath {
    return [[self documentsDirectoryPathByUser] stringByAppendingPathComponent:kUserInfoFileName];
}

- (NSString *)audioDirectoryPath; {
    return [[self cachesDirectoryPathByUser] stringByAppendingPathComponent:kAudioDirName];
}

- (NSString *)videoDirectoryPath {
    return [[self cachesDirectoryPathByUser] stringByAppendingPathComponent:kVideoDirName];
}

- (NSString *)chatPictureDirectoryPath {
    return [[self cachesDirectoryPathByUser] stringByAppendingPathComponent:kPictureDirName];
}

- (NSString *)tmpDirectoryPath {
    return [FileUtils tmpDirectory];
}

- (NSString *)uploadingPictureDirectoryPath {
    return [[self tmpDirectoryPath] stringByAppendingPathComponent:kUploadPicsDirName];
}

#pragma mark - 配置文件存取
/**
 *  设置config某个key对应的value
 *
 *  @param value
 *  @param key
 */
- (void)setConfigValue:(NSObject *)value forKey:(NSString *)key {
    [self setConfigWithValuesAndKeys:value, key, nil];
}
/**
 *  设置config的通用方法
 *  overwrite = yes
 *
 *  @param firstObject object+key...
 */
- (void)setConfigWithValuesAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *keys = [NSMutableArray array];
    NSMutableArray *values = [NSMutableArray array];
    
    va_list args;
    va_start(args, firstObject);
    for (id value = firstObject; value != nil; value = va_arg(args, id)) {
        id key = va_arg(args, id);
        [values addObject:value];
        [keys addObject:key];
    }
    va_end(args);
    
    int valueCount = [values count];
    if (valueCount != [keys count]) {
        NSLog(@"set config error : objects and keys don’t have the same number of elements.");
    }
    else {
        NSMutableDictionary *configDictionary = [NSMutableDictionary dictionary];
        for(int index = 0; index < valueCount; index ++) {
            [configDictionary setObject:[values objectAtIndex:index] forKey:[keys objectAtIndex:index]];
        }
        [self archiveDictionary:configDictionary toFilePath:[self settingsFilePath] overwrite:NO];
    }
    
}
/**
 *  获取config中key对应的value
 *
 *  @param key
 *
 *  @return value
 */
- (id)configValueForKey:(NSString *)key {
    if ([StringUtils isEmpty:key]) {
        return nil;
    }
    
    return [self configDictionary][key];
}
/**
 *  获取所有config的dict
 *
 *  @return dict
 */
- (NSDictionary *)configDictionary {
    return [self unarchiveDictionaryFromFilePath:[self settingsFilePath]];
}


/**
 *  设置user的某个key对应的value
 *
 *  @param value
 *  @param key
 */
- (void)setUserConfigValue:(NSObject *)value forKey:(NSString *)key {
    [self setUserConfigWithValuesAndKeys:value, key, nil];
}
/**
 *  设置user的key和value的通用方法
 *  overwrite = no
 *
 *  @param firstObject
 */
- (void)setUserConfigWithValuesAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *keys = [NSMutableArray array];
    NSMutableArray *values = [NSMutableArray array];
    
    va_list args;
    va_start(args, firstObject);
    for (id value = firstObject; value != nil; value = va_arg(args, id)) {
        id key = va_arg(args, id);
        [values addObject:value];
        [keys addObject:key];
    }
    va_end(args);
    
    int valueCount = [values count];
    if (valueCount != [keys count]) {
        NSLog(@"set config error : objects and keys don’t have the same number of elements.");
    }
    else {
        NSMutableDictionary *configDictionary = [NSMutableDictionary dictionary];
        for(int index = 0; index < valueCount; index ++) {
            [configDictionary setObject:[values objectAtIndex:index] forKey:[keys objectAtIndex:index]];
        }
        [self archiveDictionary:configDictionary toFilePath:[self userInfoFilePath] overwrite:NO];
    }
}
/**
 *  获取user的某个key
 *
 *  @param key
 *
 *  @return
 */
- (id)userConfigValueForKey:(NSString *)key {
    if ([StringUtils isEmpty:key]) {
        return nil;
    }
    
    return [self userConfigDictionary][key];
}
/**
 *  获取user的整个dict
 *
 *  @return
 */
- (NSDictionary *)userConfigDictionary {
    return [self unarchiveDictionaryFromFilePath:[self userInfoFilePath]];
}


/**
 *  反序列化
 *
 *  @param filePath
 *
 *  @return
 */
- (NSDictionary *)unarchiveDictionaryFromFilePath:(NSString *)filePath {
    NSDictionary *dictionary;
    @try {
        dictionary = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    }
    @catch(NSException *exception) {
        
    }
    @finally {
        
    }
    return dictionary;
}

/**
 *  序列化dict
 *  overwrite = no
 *
 *  @param dicionary
 *  @param filePath
 *
 *  @return
 */
- (BOOL)archiveDictionary:(NSDictionary *)dicionary toFilePath:(NSString *)filePath {
    return [self archiveDictionary:dicionary toFilePath:filePath overwrite:NO];
}

/**
 *  序列化通用方法
 *
 *  @param dicionary
 *  @param filePath
 *  @param overwrite YES-会把相同filePath的dict替换成新的 NO-相同的filePath合并（里面相同key的值会被新的value代替）
 *
 *  @return
 */
- (BOOL)archiveDictionary:(NSDictionary *)dicionary toFilePath:(NSString *)filePath overwrite:(BOOL)overwrite {
    if (overwrite) {
        return [NSKeyedArchiver archiveRootObject:dicionary toFile:filePath];
    }
    else {
        NSMutableDictionary *allDictionary = [NSMutableDictionary dictionaryWithCapacity:[dicionary count]];
        [allDictionary addEntriesFromDictionary:[self unarchiveDictionaryFromFilePath:filePath]];
        [allDictionary addEntriesFromDictionary:dicionary];
        return [NSKeyedArchiver archiveRootObject:allDictionary toFile:filePath];
    }
}

#pragma mark - 文件管理

- (void)clearCaches {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[[StorageManager sharedInstance] cachesDirectoryPathByUser] error:&error];
    [fileManager removeItemAtPath:[[StorageManager sharedInstance] cachesDirectoryPathCommon] error:&error];
    
    [self ensureAllDirectories];
}

#pragma mark - 私有方法

- (void)ensureAllDirectories {
    [FileUtils ensureDirectory:[self documentsDirectoryPathCommon]];
    [FileUtils ensureDirectory:[self documentsDirectoryPathByUser]];
    [FileUtils ensureDirectory:[self documentsDirectoryLogPath]];
    [FileUtils ensureDirectory:[self cachesDirectoryPathCommon]];
    [FileUtils ensureDirectory:[self cachesDirectoryPathByUser]];
    [FileUtils ensureDirectory:[self audioDirectoryPath]];
    [FileUtils ensureDirectory:[self videoDirectoryPath]];
    [FileUtils ensureDirectory:[self chatPictureDirectoryPath]];
    [FileUtils ensureDirectory:[self uploadingPictureDirectoryPath]];
}

#pragma mark - AppConfig.plist管理

/**
 *  返回项目配置文件里的配置信息
 *
 *  @param key
 *
 *  @return
 */
- (NSString *)valueInAppConfig:(NSString *)key {
    if ( ! self.appConfigDictionary) {
        self.appConfigDictionary = [NSDictionary dictionaryWithContentsOfFile:ConfigPlistPath];
    }
    
    if (self.appConfigDictionary[key]) {
        return self.appConfigDictionary[key];
    }
    else {
        return nil;
    }
}

@end
