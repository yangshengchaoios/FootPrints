//
//  AudioUtils.h
//  Footprints
//
//  Created by tt on 14/11/6.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
@interface AudioUtils : NSObject
@property (nonatomic,strong) NSString *audioPath;
- (BOOL)playAudioAtPath:(NSString *)path andUserInfo:(id)uInfo;
- (void)stopPlay;
- (BOOL)audioPlaying;
+ (id)sharedAudioUtils;
@end
