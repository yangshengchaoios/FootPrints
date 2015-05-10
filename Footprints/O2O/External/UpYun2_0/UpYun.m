//
//  UpYun.m
//  UpYunSDK2.0
//
//  Created by jack zhou on 13-8-6.
//  Copyright (c) 2013年 upyun. All rights reserved.
//

#import "UpYun.h"
#define ERROR_DOMAIN @"upyun.com"
#define DATE_STRING(expiresIn) [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970] + expiresIn]
#define REQUEST_URL(bucket) [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/",API_DOMAIN,bucket]]

#define SUB_SAVE_KEY_FILENAME @"{filename}"

@implementation UpYun
-(id)init
{
    if (self = [super init]) {
        self.bucket = DEFAULT_BUCKET;
        self.expiresIn = DEFAULT_EXPIRES_IN;
        self.passcode = DEFAULT_PASSCODE;
        
        
        self.httpManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:REQUEST_URL(self.bucket)];
        [self.httpManager.operationQueue setMaxConcurrentOperationCount:2];
        self.httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
	}
	return self;
}

- (void)setBucket:(NSString *)bucket{
    
    if (![_bucket isEqualToString:bucket]) {
        
        _bucket = bucket;
        self.httpManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:REQUEST_URL(self.bucket)];
        [self.httpManager.operationQueue setMaxConcurrentOperationCount:2];
        self.httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
}

- (void) uploadImage:(UIImage *)image savekey:(NSString *)savekey success:(SUCCESS_BLOCK)success fail:(FAIL_BLOCK)fail progress:(PROGRESS_BLOCK)progress
{
    if (![self checkSavekey:savekey fail:fail]) {
        return;
    }
    NSData *imageData = UIImagePNGRepresentation(image);
    [self uploadImageData:imageData savekey:savekey success:success fail:fail progress:progress];
}

- (void) uploadImagePath:(NSString *)path savekey:(NSString *)savekey success:(SUCCESS_BLOCK)success fail:(FAIL_BLOCK)fail progress:(PROGRESS_BLOCK)progress
{
    [self uploadFilePath:path savekey:savekey success:success fail:fail progress:progress];
}

- (void) uploadImageData:(NSData *)data savekey:(NSString *)savekey success:(SUCCESS_BLOCK)success fail:(FAIL_BLOCK)fail progress:(PROGRESS_BLOCK)progress
{
    if (![self checkSavekey:savekey fail:fail]) {
        return;
    }
    [self uploadFileData:data savekey:savekey success:success fail:fail progress:progress];
}

- (void) uploadFilePath:(NSString *)path savekey:(NSString *)savekey success:(SUCCESS_BLOCK)success fail:(FAIL_BLOCK)fail progress:(PROGRESS_BLOCK)progress{
    
    [self creatOperationWithSaveKey:savekey data:nil filePath:path success:success fail:fail progress:progress];
}

- (void) uploadFileData:(NSData *)data savekey:(NSString *)savekey success:(SUCCESS_BLOCK)success fail:(FAIL_BLOCK)fail progress:(PROGRESS_BLOCK)progress{
    
    [self creatOperationWithSaveKey:savekey data:data filePath:nil success:success fail:fail progress:progress];
}

- (BOOL)checkSavekey:(NSString *)string fail:(FAIL_BLOCK)fail
{
    NSRange rangeFileName;
    NSRange rangeFileNameOnDic;
    rangeFileName = [string rangeOfString:SUB_SAVE_KEY_FILENAME];
    if ([_params objectForKey:@"save-key"]) {
        rangeFileNameOnDic = [[_params objectForKey:@"save-key"]
                              rangeOfString:SUB_SAVE_KEY_FILENAME];
    }else {
        rangeFileNameOnDic.location = NSNotFound;
    }
    
    
    if(rangeFileName.location != NSNotFound || rangeFileNameOnDic.location != NSNotFound)
    {
        NSString *  message = [NSString stringWithFormat:@"传入file为NSData或者UIImage时,不能使用%@方式生成savekey",
                               SUB_SAVE_KEY_FILENAME];
        NSError *err = [NSError errorWithDomain:ERROR_DOMAIN
                                           code:-1998
                                       userInfo:@{@"message":message}];
        if (fail) {
            fail(err);
        }
        return NO;
    }
    return YES;
}

- (void)uploadFile:(id)file saveKey:(NSString *)saveKey success:(SUCCESS_BLOCK)success fail:(FAIL_BLOCK)fail progress:(PROGRESS_BLOCK)progress
{
    if (![file isKindOfClass:[NSString class]] && ![self checkSavekey:saveKey fail:fail])//非path传入的需要检查savekey
    {
        return;
    }
    if([file isKindOfClass:[UIImage class]]){
        [self uploadImage:file savekey:saveKey success:success fail:fail progress:progress];
    }else if([file isKindOfClass:[NSData class]]) {
        [self uploadFileData:file savekey:saveKey success:success fail:fail progress:progress];
    }else if([file isKindOfClass:[NSString class]]) {
        [self uploadFilePath:file savekey:saveKey success:success fail:fail progress:progress];
    }else {
        NSError *err = [NSError errorWithDomain:ERROR_DOMAIN
                                           code:-1999
                                       userInfo:@{@"message":@"传入参数类型错误"}];
        if (fail) {
            fail(err);
        }
    }
}

- (NSString *)getPolicyWithSaveKey:(NSString *)savekey {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.bucket forKey:@"bucket"];
    [dic setObject:DATE_STRING(self.expiresIn) forKey:@"expiration"];
    if (savekey && ![savekey isEqualToString:@""]) {
        [dic setObject:savekey forKey:@"save-key"];
    }
    
    if (self.params) {
        for (NSString *key in self.params.keyEnumerator) {
            [dic setObject:[self.params objectForKey:key] forKey:key];
        }
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:NULL];
    NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [json base64EncodedString];
}

- (NSString *)getSignatureWithPolicy:(NSString *)policy
{
    NSString *str = [NSString stringWithFormat:@"%@&%@",policy,self.passcode];
    NSString *signature = [[str MD5Digest] lowercaseString];
    return signature;
}

- (id <AFMultipartFormData>)setData:(id <AFMultipartFormData>)formData
                               data:(NSData *)data
                           filePath:(NSString *)filePath
{
    if (data) {
        [formData appendPartWithFileData:data
                                    name:@"file"
                                fileName:[NSString stringWithFormat:@"file%@",[data detectImageSuffix]]
                                mimeType:@"multipart/form-data"];
        return formData;
    }
    if (filePath) {
        NSURL * url = [NSURL fileURLWithPath:filePath];
        NSString * fileName = [filePath lastPathComponent];
        fileName = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                         (CFStringRef)fileName,
                                                                                         NULL,
                                                                                         (CFStringRef)@"!*'();:@&=+$,?%#[]",
                                                                                         kCFStringEncodingUTF8));
        NSError * error = [[NSError alloc]init];
        [formData appendPartWithFileURL:url
                                   name:@"file"
                               fileName:fileName
                               mimeType:@"multipart/form-data"
                                  error:&error];
        
        return formData;
    }
    return nil;
}

- (AFHTTPRequestOperation *)creatOperationWithSaveKey:(NSString *)saveKey
                                                 data:(NSData *)data
                                             filePath:(NSString *)filePath
                                              success:(SUCCESS_BLOCK)successBlock fail:(FAIL_BLOCK)failBlock progress:(PROGRESS_BLOCK)progressBlock{
    //进度回调
    void(^progress)(NSUInteger bytesWritten,long long totalBytesWritten,long long totalBytesExpectedToWrite) = ^(NSUInteger bytesWritten,long long totalBytesWritten,long long totalBytesExpectedToWrite){
        CGFloat percent = totalBytesWritten/(float)totalBytesExpectedToWrite;
        if (progressBlock) {
            progressBlock(percent,totalBytesWritten);
        }
    };
    //成功回调
    void(^success)(AFHTTPRequestOperation *operation, id responseObject)= ^(AFHTTPRequestOperation *operation, id responseObject){
        NSDictionary * jsonDic = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:NULL];
        NSString *message = [jsonDic objectForKey:@"message"];
        if ([@"ok" isEqualToString:message]) {
            if (successBlock) {
                successBlock(jsonDic);
            }
        } else {
            NSError *err = [NSError errorWithDomain:ERROR_DOMAIN
                                               code:[[jsonDic objectForKey:@"code"] intValue]
                                           userInfo:jsonDic];
            if (failBlock) {
                failBlock(err);
            }
        }
    };
    //失败回调
    void(^fail)(AFHTTPRequestOperation * opetation,NSError * error)= ^(AFHTTPRequestOperation * opetation,NSError * error){
        if (failBlock) {
            failBlock(error);
        }
    };
    
    NSString *policy = [self getPolicyWithSaveKey:saveKey];
    NSString *signature = [self getSignatureWithPolicy:policy];
    NSDictionary * parameDic = @{@"policy":policy, @"signature":signature};
    
    __block UpYun * blockSelf = self;
    AFHTTPRequestOperation *operation = [self.httpManager POST:@"" parameters:parameDic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [blockSelf setData:formData data:data filePath:filePath];
    } success:success failure:fail];
    [operation setUploadProgressBlock:progress];
    return operation;
}
/*- (NSURLSessionTask *)aacreatOperationWithSaveKey:(NSString *)saveKey
                                                 data:(NSData *)data
                                             filePath:(NSString *)filePath{
    //进度回调
    void(^progress)(NSUInteger bytesWritten,NSInteger totalBytesWritten,NSInteger totalBytesExpectedToWrite) = ^(NSUInteger bytesWritten,NSInteger totalBytesWritten,NSInteger totalBytesExpectedToWrite){
        CGFloat percent = totalBytesWritten/(float)totalBytesExpectedToWrite;
        if (_progressBlocker) {
            _progressBlocker(percent,totalBytesWritten);
        }
    };
    //成功回调
    void(^success)(NSURLSessionDataTask *operation, id responseObject)= ^(NSURLSessionDataTask *operation, id responseObject){
        NSDictionary * jsonDic = responseObject;
        NSString *message = [jsonDic objectForKey:@"message"];
        if ([@"ok" isEqualToString:message]) {
            if (_successBlocker) {
                _successBlocker(jsonDic);
            }
        } else {
            NSError *err = [NSError errorWithDomain:ERROR_DOMAIN
                                               code:[[jsonDic objectForKey:@"code"] intValue]
                                           userInfo:jsonDic];
            if (_failBlocker) {
                _failBlocker(err);
            }
        }
    };
    //失败回调
    void(^fail)(NSURLSessionDataTask * opetation,NSError * error)= ^(NSURLSessionDataTask * opetation,NSError * error){
        if (_failBlocker) {
            _failBlocker(error);
        }
    };
    
    NSString *policy = [self getPolicyWithSaveKey:saveKey];
    NSString *signature = [self getSignatureWithPolicy:policy];
    NSDictionary * parameDic = @{@"policy":policy, @"signature":signature};
    
    __block UpYun * blockSelf = self;
    AFHTTPSessionManager *httpManager = [[AFHTTPSessionManager alloc] initWithBaseURL:REQUEST_URL(self.bucket)];
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLSessionTask *task = [httpManager POST:@"" parameters:parameDic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [blockSelf setData:formData data:data filePath:filePath];
    } success:success failure:fail];
    
    return task;
}*/

@end
