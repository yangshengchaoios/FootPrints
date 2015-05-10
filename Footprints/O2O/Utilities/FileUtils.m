//
//  FileUtils.m
//  SCSDEnterprise
//
//  Created by  YangShengchao on 14-2-14.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import "FileUtils.h"
#import <UIImage-Resize/UIImage+Resize.h>
#import "ImageUtils.h"

#define kConfigPlistFileName    @"config.plist"

#define kMaxImageWidthDefault   2048

#define kCompressionQualityDefault  0.8f

@interface FileUtils ()


@end


@implementation FileUtils

NSString *_documentDirectoryPath = nil;
NSString *_cacheDirectoryPath = nil;

#pragma mark - File Path
+ (NSString *)documentsDirectory {
    if ( ! _documentDirectoryPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        _documentDirectoryPath = [paths objectAtIndex:0];
    }
    return _documentDirectoryPath;
}

+ (NSString *)tmpDirectory {
    return NSTemporaryDirectory();
}

+ (NSString *)cacheDirectory {
    if ( ! _cacheDirectoryPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _cacheDirectoryPath = [paths objectAtIndex:0];
    }
    return _cacheDirectoryPath;
}

+ (NSString *)subDocumentsPath:(NSString *)subFilepath {
    return [[self documentsDirectory] stringByAppendingPathComponent:subFilepath];
}

+ (NSString *)ensureParentDirectory:(NSString *)filepath {
    NSString *parentDirectory = [filepath stringByDeletingLastPathComponent];
    BOOL isDirectory;
    if (( ! [[NSFileManager defaultManager] fileExistsAtPath:parentDirectory isDirectory:&isDirectory]) || ( ! isDirectory)) {
        [[NSFileManager defaultManager] createDirectoryAtPath:parentDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return filepath;
}

+ (NSString *)ensureDirectory:(NSString *)filepath {
    BOOL isDirectory;
    if (( ! [[NSFileManager defaultManager] fileExistsAtPath:filepath isDirectory:&isDirectory]) || ( ! isDirectory)) {
        [self ensureParentDirectory:filepath];
        [[NSFileManager defaultManager] createDirectoryAtPath:filepath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return filepath;
} 

+ (void)saveImage:(UIImage *)image toFile:(NSString *)filePath {
    [self saveImage:image toFile:filePath maxWidth:kMaxImageWidthDefault];
}

+ (void)saveImage:(UIImage *)image toFile:(NSString *)filePath maxWidth:(CGFloat)maxWidth {
    NSData *imageData;
    UIImage *scaledImage = [image resizedImageToFitInSize:CGSizeMake(maxWidth, maxWidth) scaleIfSmaller:NO];
    // PNG文件体积太大了
    imageData = UIImageJPEGRepresentation(scaledImage, kCompressionQualityDefault);
    
    [self ensureParentDirectory:filePath];
    [imageData writeToFile:filePath atomically:YES];
}

+ (NSString *)saveImageWithTimestampName:(UIImage *)image {
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *picturePath = [[FileUtils tmpDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%lld.jpg", timestamp]];
    [self saveImage:image toFile:picturePath];
    return picturePath;
}

+ (NSString *)convertString:(NSString *)string fromFormat:(NSString *)oldFormat toFormat:(NSString *)newFormat {
    NSDate *date = [self dateFromString:string withFormat:oldFormat];
    return [[self dateFormaterWithFormat:newFormat] stringFromDate:date];
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
    return [[self dateFormaterWithFormat:format] dateFromString:string];
}

#pragma mark - private metholds

+ (NSDateFormatter *)dateFormaterWithFormat:(NSString *)formatString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatString];
    return dateFormatter;
}


@end
