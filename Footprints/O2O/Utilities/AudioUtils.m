//
//  AudioUtils.m
//  Footprints
//
//  Created by tt on 14/11/6.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "AudioUtils.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <SDWebImage/SDWebImageDownloader.h>
#import "PlayerManager.h"


int recordEncoding;
enum
{
    ENC_AAC = 1,
    ENC_ALAC = 2,
    ENC_IMA4 = 3,
    ENC_ILBC = 4,
    ENC_ULAW = 5,
    ENC_PCM = 6,
} encodingTypes;



@interface AudioUtils()<PlayingDelegate>
{
    NSURL *urlPlay;
    NSString *playingPath;
    NSString *userInfo;
}
@end

static AudioUtils *sharedUitls = nil;
@implementation AudioUtils

- (void)dealloc
{
    
    if([PlayerManager sharedManager].delegate==self)
    {
        [PlayerManager sharedManager].delegate = nil;
    }
}

- (id)init{
    
    self=[super init];
    if (self) {
        
    }
    return self;
}

- (void)playingStoped{
    
    [self performSelectorOnMainThread:@selector(end) withObject:nil waitUntilDone:NO];
}

- (void)end{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PlayAudioDidEndNotification object:userInfo];
    playingPath = nil;
    userInfo = nil;
}

- (BOOL)playAudioAtPath:(NSString *)path andUserInfo:(id)uInfo{

    BOOL playing = NO;
    if ([StringUtils isEmpty:path]) {
        return playing;
    }
    [self stopPlay];
    playingPath = path;
    userInfo = uInfo;
    NSString *docDirPath = [[StorageManager sharedInstance] audioDirectoryPath];
    NSString *filePath = [NSString stringWithFormat:@"%@.spx",[docDirPath stringByAppendingPathComponent:[StringUtils md5FromString:path]]];
    NSData *musicData = [[NSData alloc] initWithContentsOfFile:filePath];
    if (musicData) {
        playing = YES;
        //播放本地音乐
        [PlayerManager sharedManager].delegate = nil;
        [[PlayerManager sharedManager] playAudioWithFileName:filePath delegate:self];
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSString *urlStr = path;
            NSURL *url = [[NSURL alloc]initWithString:urlStr];
            NSData *audioData = [NSData dataWithContentsOfURL:url];
            //将数据保存到本地指定位置
            [audioData writeToFile:filePath atomically:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                postNWithObj(PlayAudioDidStartNotification, userInfo);
                [PlayerManager sharedManager].delegate = nil;
                [[PlayerManager sharedManager] playAudioWithFileName:filePath delegate:self];
            });
        });
        
    }
    return playing;
}

- (void)stopPlay{
    playingPath = nil;
    userInfo = nil;
    [[PlayerManager sharedManager] stopPlaying];
}

- (BOOL)audioPlaying{
    
    return playingPath.length>0;
}

+ (id)sharedAudioUtils{

    if (nil==sharedUitls) {
        sharedUitls = [[AudioUtils alloc] init];
    }
    return sharedUitls;
}

@end
