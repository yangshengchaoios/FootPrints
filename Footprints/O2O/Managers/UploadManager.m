//
//  UploadManager.m
//  TGOMarket
//
//  Created by  YangShengchao on 14-3-13.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import "UploadManager.h"
#import "UDIDManager.h"
#import "NSString+MD5.h"
#import "NSData+MD5.h"

/*
 秘钥：
 
 空间名：
 
 访问文件的前缀：http://zuji-app-file.b0.upaiyun.com/
 */

#if TGO_DEBUG_MODEL
#define DEFAULT_UPLOAD_KEY              @"l5i6un8Z3eacrLB+6MNUX4EG67Y="
#define DEFAULT_UPLOAD_IMG_BUCKET       @"tiangou-app-img"
#define DEFAULT_UPLOAD_FILE_BUCKET      @"zuji-app-file"
#define DEFAULT_UPLOAD_PATH             @"zuji/upload"
#else
#define DEFAULT_UPLOAD_KEY              @"4i317dpuEhjCAauQMe/og/dY2vk="
#define DEFAULT_UPLOAD_IMG_BUCKET       @"zuji-app-img"
#define DEFAULT_UPLOAD_FILE_BUCKET      @"zuji-app-music"
#define DEFAULT_UPLOAD_PATH             @"zuji/upload"
#endif
static UploadManager *sharedManager = nil;
@interface UploadManager()
{
}
@property (nonatomic,strong) UpYun *fileUploader;
@property (nonatomic,strong) UpYun *imageUploader;
@end
@implementation UploadManager


+ (instancetype)sharedManager{
    
    if (nil==sharedManager){
        sharedManager = [[UploadManager alloc] init];
    }
    return sharedManager;
}

- (void)uploadImage:(NSData *)file
            success:(SUCCESS_BLOCK)successBlocker
          failBlock:(FAIL_BLOCK) fail
      progressBlock:(PROGRESS_BLOCK)progress{
    
    NSString *saveKey = [NSString stringWithFormat:@"%@/%@/%@",DEFAULT_UPLOAD_PATH,[UploadManager getDateStr:[NSDate date]],[file MD5Digest]];
    if(nil==self.imageUploader){
        self.imageUploader = [[UpYun alloc] init];
        self.imageUploader.bucket = DEFAULT_UPLOAD_IMG_BUCKET;
        self.imageUploader.passcode = DEFAULT_UPLOAD_KEY;
    }
    [self.imageUploader uploadFile:file saveKey:saveKey success:successBlocker fail:fail progress:progress];
}

- (void)uploadFile:(NSData *)file
              type:(NSString *)type
           success:(SUCCESS_BLOCK)successBlocker
         failBlock:(FAIL_BLOCK) fail
     progressBlock:(PROGRESS_BLOCK)progress{
    
    NSString *saveKey = [NSString stringWithFormat:@"%@/%@/%@",DEFAULT_UPLOAD_PATH,[UploadManager getDateStr:[NSDate date]],[file MD5Digest]];
    if (type) {
        saveKey = [NSString stringWithFormat:@"%@.%@",saveKey,type];
    }
    
    if (nil==self.fileUploader) {
        self.fileUploader = [[UpYun alloc] init];
        self.fileUploader.bucket = DEFAULT_UPLOAD_FILE_BUCKET;
        self.fileUploader.passcode = @"ItB73feGtfo30mU5vMOjc8Llm2I=";
    }
    [self.fileUploader uploadFile:file saveKey:saveKey success:successBlocker fail:fail progress:progress];
}


+ (void)uploadImage:(NSData *)file
           success:(SUCCESS_BLOCK)successBlocker
         failBlock:(FAIL_BLOCK) fail
     progressBlock:(PROGRESS_BLOCK)progress{
         [[UploadManager sharedManager] uploadImage:file success:successBlocker failBlock:fail progressBlock:progress];
}

+ (void)uploadFile:(NSData *)file
              type:(NSString *)type
           success:(SUCCESS_BLOCK)successBlocker
         failBlock:(FAIL_BLOCK) fail
     progressBlock:(PROGRESS_BLOCK)progress{
    
    [[UploadManager sharedManager] uploadFile:file type:type success:successBlocker failBlock:fail progressBlock:progress];
}

+ (NSString * )gen_uuid
{
    
    CFUUIDRef identifier = CFUUIDCreate(NULL);
    NSString* identifierString = (NSString*)CFBridgingRelease(CFUUIDCreateString(NULL, identifier));
    CFRelease(identifier);
    return identifierString;
}


+ (NSString *)getDateStr:(NSDate *) date{
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    return [formatter stringFromDate:date];
}

@end
