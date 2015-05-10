//
//  LogManager.m
//  TGO2
//
//  Created by  YangShengchao on 14-4-24.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import "LogManager.h"
#import "StorageManager.h"
#import "TimeUtils.h"

@implementation LogManager

+ (void)saveLog:(NSString *)logString {
    NSString *logDirectory = [[StorageManager sharedInstance] documentsDirectoryLogPath];
    NSString *fileName = [TimeUtils fullTimeStringNowWithFormater:@"yyyy-MM-dd"];
    NSString *logFilePath = [logDirectory stringByAppendingPathComponent:fileName];
    NSString *logStringWithTime = [NSString stringWithFormat:@"%@ -> %@\r\n", [TimeUtils fullTimeStringNowWithFormater:@"HH:mm:ss SSS"], logString];
    NSLog(@"logFilePath = %@", logFilePath);
    NSLog(@"logStringWithTime = %@", logStringWithTime);
    
    NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
    if ( ! fh ) {
        [[NSFileManager defaultManager] createFileAtPath:logFilePath contents:nil attributes:nil];
        fh = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
    }
    
    @try {
        [fh seekToEndOfFile];
        [fh writeData:[logStringWithTime dataUsingEncoding:NSUTF8StringEncoding]];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    [fh closeFile];
}

@end
