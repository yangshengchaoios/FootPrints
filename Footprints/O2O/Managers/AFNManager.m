//
//  AFNManager.m
//  TGOMarket
//
//  Created by  YangShengchao on 14-5-4.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import "AFNManager.h"
#import "AFNetworking.h"
#import "ImageUtils.h"
#import <UIImage+Resize.h>
#import "UserManager.h"

@implementation AFNManager




#pragma mark - GET
+ (void)getObject:(NSDictionary*)paramDict
          apiName:(NSString *)apiName
        modelName:(NSString *)modelName
 requestSuccessed:(RequestSuccessed)requestSuccessed
   requestFailure:(RequestFailure)requestFailure {
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",kResPathBaseUrl,apiName];
    
    if (TGO_DEBUG_LOG) NSLog(@"urlStr = %@", urlStr);
    NSArray *allKeys = [paramDict allKeys];
    for (NSString *key in allKeys) {
        id param = paramDict[key];
        if (param) {
            NSInteger index = [allKeys indexOfObject:key];
            if (index==0) {
                urlStr = [NSString stringWithFormat:@"%@?%@=%@",urlStr,key,param];
            }else{
                urlStr = [NSString stringWithFormat:@"%@&%@=%@",urlStr,key,param];
            }
        }
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [request setHTTPMethod:@"GET"];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:kDefaultAppType forHTTPHeaderField:@"User-Agent"];
    [request setValue:kAppVersion forHTTPHeaderField:@"version"];
    [request setValue:kAppSignature forHTTPHeaderField:@"signature"];
    [request setValue:kUserToken forHTTPHeaderField:@"token"];
    
    if (nil==kUserToken) {
        NSLog(@"Token 不存在");
    }
    if (TGO_DEBUG_LOG) NSLog(@"Token = %@", kUserToken);
//    if (TGO_DEBUG_LOG) NSLog(@"request = %@", request);
    
    
    NSOperationQueue *queue=[[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                id dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                if (TGO_DEBUG_LOG) NSLog(@"url:%@\ndata = %@",request.URL, dataDic);
                JSONModelError *initError;
                BaseModel *baseModel = nil;
                if ([dataDic isKindOfClass:[NSDictionary class]]) {
                    baseModel = [[BaseModel alloc] initWithDictionary:dataDic error:&initError];
                }
                else if ([dataDic isKindOfClass:[NSString class]]) {
                    baseModel = [[BaseModel alloc] initWithString:dataDic error:&initError];
                }
                if (TGO_DEBUG_LOG) NSLog(@"message = %@", baseModel.message);
                if (baseModel.state == 1) {  //接口访问成功
                    NSObject *dataModel = baseModel.data;
                    JSONModelError *initError = nil;
                    if ([dataModel isKindOfClass:[NSArray class]]) {
                        if ( [modelName length] > 0 && [NSClassFromString(modelName) isSubclassOfClass:[CommonBaseModel class]]) {
                            dataModel = [NSClassFromString(modelName) arrayOfModelsFromDictionaries:(NSArray *)dataModel error:&initError];
                        }
                    }
                    else if ([dataModel isKindOfClass:[NSDictionary class]]) {
                        if ( [modelName length] > 0 && [NSClassFromString(modelName) isSubclassOfClass:[CommonBaseModel class]]) {
                            dataModel = [[NSClassFromString(modelName) alloc] initWithDictionary:(NSDictionary *)dataModel error:&initError];
                        }
                    }
                    //针对转换映射后的处理
                    if (initError) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            requestFailure(1101, initError.localizedDescription);
                        });
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            requestSuccessed(dataModel);
                        });
                    }
                }
                else {
                    if (baseModel.state==2) {
                        //登录过期
                        //TODO
                        //[UserManager logOut];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            requestFailure(kErrCodeLoginTimeOut, @"请重新登录");
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            requestFailure(1103, baseModel.message);
                        });
                    }
                }
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    requestFailure(1004, @"网络错误");
                });
            }
        });
    }];
}

#pragma mark - POST
+ (void)postObject:(id)object
           apiName:(NSString *)apiName
         modelName:(NSString *)modelName
  requestSuccessed:(RequestSuccessed)requestSuccessed
    requestFailure:(RequestFailure)requestFailure {
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",kResPathBaseUrl,apiName];
    NSData *json = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
    if (TGO_DEBUG_LOG) {
        NSString *str = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        NSLog(@"\nURL: %@\nPOST JSON: %@",urlStr,str);
    }
    
    NSString *postLength = [NSString stringWithFormat:@"%ld", [json length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"POST"];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:kDefaultAppType forHTTPHeaderField:@"User-Agent"];
    [request setValue:kAppVersion forHTTPHeaderField:@"version"];
    [request setValue:kAppSignature forHTTPHeaderField:@"signature"];
    if(kUserToken)[request setValue:kUserToken forHTTPHeaderField:@"token"];
    [request setHTTPBody:json];
    
    if (nil==kUserToken) {
        NSLog(@"Token 不存在");
    }
    if (TGO_DEBUG_LOG) NSLog(@"Token = %@", kUserToken);
    if (TGO_DEBUG_LOG) NSLog(@"request = %@", request);
    
    NSOperationQueue *queue=[[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                id dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                if (TGO_DEBUG_LOG) NSLog(@"dataDic = %@", dataDic);
                
                JSONModelError *initError;
                BaseModel *baseModel = nil;
                if ([dataDic isKindOfClass:[NSDictionary class]]) {
                    baseModel = [[BaseModel alloc] initWithDictionary:dataDic error:&initError];
                }
                else if ([dataDic isKindOfClass:[NSString class]]) {
                    baseModel = [[BaseModel alloc] initWithString:dataDic error:&initError];
                }
                if (TGO_DEBUG_LOG) NSLog(@"message = %@", baseModel.message);
                                if (TGO_DEBUG_LOG) NSLog(@"baseModel = %@", baseModel);
                if (baseModel.state == 1) {  //接口访问成功
                    NSObject *dataModel = baseModel.data;
                    JSONModelError *initError = nil;
                    if ([dataModel isKindOfClass:[NSArray class]]) {
                        if ( [modelName length] > 0 && [NSClassFromString(modelName) isSubclassOfClass:[CommonBaseModel class]]) {
                            dataModel = [NSClassFromString(modelName) arrayOfModelsFromDictionaries:(NSArray *)dataModel error:&initError];
                        }
                    }
                    else if ([dataModel isKindOfClass:[NSDictionary class]]) {
                        if ( [modelName length] > 0 && [NSClassFromString(modelName) isSubclassOfClass:[CommonBaseModel class]]) {
                            dataModel = [[NSClassFromString(modelName) alloc] initWithDictionary:(NSDictionary *)dataModel error:&initError];
                        }
                    }
                    
                    //针对转换映射后的处理
                    if (initError) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            requestFailure(1101, initError.localizedDescription);
                        });
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            requestSuccessed(dataModel);
                        });
                    }
                }
                else {
                    if (baseModel.state==2) {
                        //登录过期
                        [UserManager logOut];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            requestFailure(kErrCodeLoginTimeOut, @"请重新登录");
                        });
                    }else{
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            requestFailure(1103, baseModel.message?:@"服务器错误");
                        });
                    }
                }
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    requestFailure(1004, @"网络错误");
                });
            }
        });
    }];
}




#pragma mark - 最常用的GET和POST

+ (void)getDataWithAPI:(NSString *)apiName
         andArrayParam:(NSArray *)arrayParam
          andDictParam:(NSDictionary *)dictParam
             dataModel:(NSString *)modelName
      requestSuccessed:(RequestSuccessed)requestSuccessed
        requestFailure:(RequestFailure)requestFailure {
	NSString *url = kResPathBaseUrl;
    [self requestByUrl:url withAPI:apiName andArrayParam:arrayParam andDictParam:dictParam andBodyParam:nil dataModel:modelName requestType:RequestTypeGET requestSuccessed:requestSuccessed requestFailure:requestFailure];
}

+ (void)postDataWithAPI:(NSString *)apiName
          andArrayParam:(NSArray *)arrayParam
           andDictParam:(NSDictionary *)dictParam
              dataModel:(NSString *)modelName
       requestSuccessed:(RequestSuccessed)requestSuccessed
         requestFailure:(RequestFailure)requestFailure {
	NSString *url = kResPathBaseUrl;
    [self requestByUrl:url withAPI:apiName andArrayParam:arrayParam andDictParam:dictParam andBodyParam:nil dataModel:modelName requestType:RequestTypePOST requestSuccessed:requestSuccessed requestFailure:requestFailure];
}

+ (void)postBodyDataWithAPI:(NSString *)apiName
              andArrayParam:(NSArray *)arrayParam
               andDictParam:(NSDictionary *)dictParam
               andBodyParam:(NSString *)bodyParam
                  dataModel:(NSString *)modelName
           requestSuccessed:(RequestSuccessed)requestSuccessed
             requestFailure:(RequestFailure)requestFailure {
	NSString *url = kResPathBaseUrl;
    [self requestByUrl:url withAPI:apiName andArrayParam:arrayParam andDictParam:dictParam andBodyParam:bodyParam dataModel:modelName requestType:RequestTypePostBodyData requestSuccessed:requestSuccessed requestFailure:requestFailure];
}

#pragma mark - 自定义url前缀的GET和POST

+ (void)getDataFromUrl:(NSString *)url
               withAPI:(NSString *)apiName
         andArrayParam:(NSArray *)arrayParam
          andDictParam:(NSDictionary *)dictParam
             dataModel:(NSString *)modelName
      requestSuccessed:(RequestSuccessed)requestSuccessed
        requestFailure:(RequestFailure)requestFailure {
	[self requestByUrl:url withAPI:apiName andArrayParam:arrayParam andDictParam:dictParam andBodyParam:nil dataModel:modelName requestType:RequestTypeGET requestSuccessed:requestSuccessed requestFailure:requestFailure];
}

+ (void)postDataToUrl:(NSString *)url
              withAPI:(NSString *)apiName
        andArrayParam:(NSArray *)arrayParam
         andDictParam:(NSDictionary *)dictParam
            dataModel:(NSString *)modelName
     requestSuccessed:(RequestSuccessed)requestSuccessed
       requestFailure:(RequestFailure)requestFailure {
    [self requestByUrl:url withAPI:apiName andArrayParam:arrayParam andDictParam:dictParam andBodyParam:nil dataModel:modelName requestType:RequestTypePOST requestSuccessed:requestSuccessed requestFailure:requestFailure];
}

+ (void)postBodyDataToUrl:(NSString *)url
                  withAPI:(NSString *)apiName
            andArrayParam:(NSArray *)arrayParam
             andDictParam:(NSDictionary *)dictParam
             andBodyParam:(NSString *)bodyParam
                dataModel:(NSString *)modelName
         requestSuccessed:(RequestSuccessed)requestSuccessed
           requestFailure:(RequestFailure)requestFailure {
    [self requestByUrl:url withAPI:apiName andArrayParam:arrayParam andDictParam:dictParam andBodyParam:bodyParam dataModel:modelName requestType:RequestTypePostBodyData requestSuccessed:requestSuccessed requestFailure:requestFailure];
}

#pragma mark - 上传文件

+ (void)uploadImage:(UIImage *)image
              toUrl:(NSString *)url
            withApi:(NSString *)apiName
      andArrayParam:(NSArray *)arrayParam
       andDictParam:(NSDictionary *)dictParam
          dataModel:(NSString *)modelName
       imageQuality:(ImageQuality)quality
   requestSuccessed:(RequestSuccessed)requestSuccessed
     requestFailure:(RequestFailure)requestFailure {
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *picturePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld.jpg", timestamp]];
    UIImage *scaledImage1 = [ImageUtils adjustImage:image toQuality:quality];
    UIImage *scaledImage = [scaledImage1 resizedImage:CGSizeMake(76, 76) interpolationQuality:kCGInterpolationDefault];
    
    [self requestByUrl:url withAPI:apiName andArrayParam:arrayParam andDictParam:dictParam andBodyParam:nil imageData:UIImagePNGRepresentation(scaledImage)
           requestType:RequestTypeUploadFile
      requestSuccessed:^(id responseObject) {
          [[NSFileManager defaultManager] removeItemAtPath:picturePath error:NULL];
          BaseModel *baseModel = (BaseModel *)responseObject;
          if ([baseModel isKindOfClass:NSClassFromString(modelName)]) {
              if (baseModel.state == 1) {  //接口访问成功
                  NSLog(@"success message = %@", baseModel.message);
                  requestSuccessed(baseModel);
              }
              else {
                  requestFailure(1101, baseModel.message);
              }
          }
          else {
              requestFailure(1102, @"本地数据映射错误！");
          }
          
      } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
          [[NSFileManager defaultManager] removeItemAtPath:picturePath error:NULL];
          requestFailure(1103, errorMessage);
      }];
}

#pragma mark - 通用的GET和POST（只返回BaseModel的Data内容）

/**
 *  发起get & post网络请求
 *
 *  @param url              接口前缀 最后的'/'可有可无
 *  @param apiName          方法名称 前面不能有'/'
 *  @param arrayParam       数组参数，用来组装url/param1/param2/param3，参数的顺序很重要
 *  @param dictParam        字典参数，key-value
 *  @param modelName        模型名称字符串
 *  @param requestType      RequestTypeGET 和 RequestTypePOST
 *  @param requestSuccessed 请求成功的回调
 *  @param requestFailure   请求失败的回调
 */
+ (void)requestByUrl:(NSString *)url
             withAPI:(NSString *)apiName
       andArrayParam:(NSArray *)arrayParam
        andDictParam:(NSDictionary *)dictParam
        andBodyParam:(NSString *)bodyParam
           dataModel:(NSString *)modelName
         requestType:(RequestType)requestType
    requestSuccessed:(RequestSuccessed)requestSuccessed
      requestFailure:(RequestFailure)requestFailure {
    [self   requestByUrl:url withAPI:apiName andArrayParam:arrayParam andDictParam:dictParam andBodyParam:bodyParam imageData:nil requestType:requestType
	    requestSuccessed: ^(id responseObject) {
            BaseModel *baseModel = (BaseModel *)responseObject;
            if (baseModel.state == 1) {  //接口访问成功
                NSObject *dataModel = baseModel.data;
                JSONModelError *initError = nil;
                if ([dataModel isKindOfClass:[NSArray class]]) {
                    if ( [modelName length] > 0 && [NSClassFromString(modelName) isSubclassOfClass:[CommonBaseModel class]]) {
                        dataModel = [NSClassFromString(modelName) arrayOfModelsFromDictionaries:(NSArray *)dataModel error:&initError];
                    }
                }
                else if ([dataModel isKindOfClass:[NSDictionary class]]) {
                    if ( [modelName length] > 0 && [NSClassFromString(modelName) isSubclassOfClass:[CommonBaseModel class]]) {
                        dataModel = [[NSClassFromString(modelName) alloc] initWithDictionary:(NSDictionary *)dataModel error:&initError];
                    }
                }
                
                //针对转换映射后的处理
                if (initError) {
                    requestFailure(1101, initError.localizedDescription);
                }
                else {
                    requestSuccessed(dataModel);
                }
            }
            else {
                requestFailure(1103, baseModel.message);
            }
        } requestFailure:requestFailure];
}


#pragma mark - 通用的GET和POST（返回BaseModel的所有内容）

/**
 *  发起get & post & 上传图片 请求
 *
 *  @param url              接口前缀 最后的'/'可有可无
 *  @param apiName          方法名称 前面不能有'/'
 *  @param arrayParam       数组参数，用来组装url/param1/param2/param3，参数的顺序很重要
 *  @param dictParam        字典参数，key-value
 *  @param imageData        图片资源
 *  @param requestType      RequestTypeGET 和 RequestTypePOST
 *  @param requestSuccessed 请求成功的回调
 *  @param requestFailure   请求失败的回调
 */
+ (void)requestByUrl:(NSString *)url
             withAPI:(NSString *)apiName
       andArrayParam:(NSArray *)arrayParam
        andDictParam:(NSDictionary *)dictParam
        andBodyParam:(NSString *)bodyParam
           imageData:(NSData *)imageData
         requestType:(RequestType)requestType
    requestSuccessed:(RequestSuccessed)requestSuccessed
      requestFailure:(RequestFailure)requestFailure {
	//1. url合法性判断
	if (![NSURL URLWithString:url]) {
		requestFailure(1005, [NSString stringWithFormat:@"传递的url[%@]不合法！", url]);
		return;
	}
    
	//2. apiName简单判断
	if ([apiName length] < 1) {
		requestFailure(1006, [NSString stringWithFormat:@"传递的apiName[%@]为空！", apiName]);
		return;
	}
    
	//3. 组装完整的url地址
	AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];   //create new AFHTTPRequestOperationManager
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [manager.requestSerializer setValue:kDefaultAppType forHTTPHeaderField:@"User-Agent"];
    [manager.requestSerializer setValue:kAppVersion forHTTPHeaderField:@"version"];
    [manager.requestSerializer setValue:kAppSignature forHTTPHeaderField:@"signature"];
//    [manager.requestSerializer setValue:[[Login sharedInstance] authorization] forHTTPHeaderField:@"Authorization"];
    //解决返回的Content-Type始终是application/xml问题！
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    //4. 设置请求的加密回调
    //    [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
    //        NSMutableArray *mutablePairs = [NSMutableArray array];
    //        for (AFQueryStringPair *pair in AFQueryStringPairsFromDictionary(parameters)) {
    //            [mutablePairs addObject:[pair URLEncodedStringValueWithEncoding:stringEncoding]];
    //        }
    //
    //        return [mutablePairs componentsJoinedByString:@"&"];
    //    }];
    
	NSString *urlString = [url stringByAppendingFormat:@"%@%@",
	                       ([url hasSuffix:@"/"] ? @"" : @"/"),     //确保url前缀后面有1个字符'/'
	                       ([apiName hasPrefix:@"/"] ? [apiName substringFromIndex:1] : apiName)   //确保apiName前面没有字符'/'
                           ];                                                         //组装后的完整url地址
    
	//5. 组装数组参数
	NSMutableString *newUrlString = [NSMutableString stringWithString:urlString];
	for (NSObject *param in arrayParam) {
		[newUrlString appendString:@"/"];
		[newUrlString appendFormat:@"%@",param];
	}
    
	//6. 发起网络请求
    //   定义返回成功的block
    void (^requestSuccessed1)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"get success! operation = %@\r\nresponseObject = %@", operation, responseObject);
        
        JSONModelError *initError;
        BaseModel *baseModel = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            baseModel = [[BaseModel alloc] initWithDictionary:responseObject error:&initError];
        }
        else if ([responseObject isKindOfClass:[NSString class]]) {
            baseModel = [[BaseModel alloc] initWithString:responseObject error:&initError];
        }
        
        if (baseModel) {
            requestSuccessed(baseModel);
        }
        else {
            if (initError) {
                requestFailure(1001, initError.localizedDescription);
            }
            else {
                requestFailure(1002, @"本地对象映射出错！");
            }
        }
    };
    //   定义返回失败的block
    void (^requestFailure1)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"post failure! operation = %@\r\nerror = %@", operation, error);
        
        if (operation.response.statusCode != 200) {
            [LogManager saveLog:[NSString stringWithFormat:@"请求参数%@", dictParam]];
            [LogManager saveLog:error.localizedDescription];
            if (operation.response.statusCode == 401) {
                requestFailure(1003, @"您还未登录呢！");
//                [[Login sharedInstance] clearLoginData];
            }
            else {
                requestFailure(1004, @"网络错误！");
            }
        }
        else {
            requestFailure(operation.response.statusCode, error.localizedDescription);
        }
    };
    
	NSLog(@"requestType = %d, dictParam = %@", requestType, dictParam);
	if (requestType == RequestTypeGET) {
		NSLog(@"getting data...");
		[manager   GET:newUrlString
		    parameters:dictParam
		       success:requestSuccessed1
		       failure:requestFailure1];
	}
	else if (requestType == RequestTypePOST) {
		NSLog(@"posting data...");
		[manager  POST:newUrlString
		    parameters:dictParam
		       success:requestSuccessed1
		       failure:requestFailure1];
	}
	else if (requestType == RequestTypeUploadFile) {
		NSLog(@"uploading data...");
        
		[manager       POST:newUrlString
                 parameters:dictParam
  constructingBodyWithBlock: ^(id < AFMultipartFormData > formData) {
      [formData appendPartWithFileData:imageData name:@"file" fileName:@"avatar.png" mimeType:@"application/octet-stream"];
  }
                    success:requestSuccessed1
                    failure:requestFailure1];
	}
    else if (requestType == RequestTypePostBodyData) {
        NSLog(@"posting bodydata...");
        NSMutableURLRequest *mutableRequest = [manager.requestSerializer requestWithMethod:@"POST" URLString:newUrlString parameters:nil error:nil];
        mutableRequest.HTTPBody = [bodyParam dataUsingEncoding:manager.requestSerializer.stringEncoding];
        AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:mutableRequest success:requestSuccessed1 failure:requestFailure1];
        [manager.operationQueue addOperation:operation];
    }
}

@end
