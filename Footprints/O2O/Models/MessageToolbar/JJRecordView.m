//
//  JJRecordView.m
//  Footprints
//
//  Created by Jinjin on 14/12/21.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJRecordView.h"
#import "RecorderManager.h"
#import "PlayerManager.h"


@interface JJRecordView()<RecordingDelegate, PlayingDelegate>

@property (nonatomic,strong) NSString *filename;
@end

@implementation JJRecordView
- (void)dealloc
{
    
    [self stop];
    if([RecorderManager sharedManager].delegate==self) [RecorderManager sharedManager].delegate = nil;
    if([PlayerManager sharedManager].delegate==self) {
        [PlayerManager sharedManager].delegate = nil;
    }
}

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.maxTimes = 60;
    
        self.bgView = [[UIView alloc] initWithFrame:CGRectZero];
        self.bgView.backgroundColor = RGB(38, 165, 202);
        [self addSubview:self.bgView];
        
        self.clipsToBounds = YES;
        self.title = [[UILabel alloc] initWithFrame:self.bounds];
        self.title.textAlignment = NSTextAlignmentCenter;
        self.title.textColor = [UIColor grayColor];
        self.title.userInteractionEnabled = NO;
        [self addSubview:self.title];
        WS(ws);
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws);
        }];
        
        
        self.layer.borderColor = kDefaultLineColor.CGColor;
        self.layer.borderWidth = kDefaultBorderWidth;
        self.layer.cornerRadius = 6.0f;
        self.backgroundColor = [UIColor whiteColor];
        
        self.title.text = [NSString stringWithFormat:@"按住说话"];
        
        self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteBtn.frame = CGRectMake(frame.size.width-frame.size.height, 0, frame.size.height, frame.size.height);
        [self.deleteBtn addTarget:self action:@selector(deleteRecord) forControlEvents:UIControlEventTouchUpInside];
        self.deleteBtn.hidden = YES;
        [self.deleteBtn setImage:[UIImage imageNamed:@"voice_deleted.png"] forState:UIControlStateNormal];
        [self addSubview:self.deleteBtn];
        [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws).with.offset(0);
            make.top.mas_equalTo(ws);
            make.bottom.mas_equalTo(ws);
            make.width.mas_equalTo(@30);
        }];
        
        self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.playBtn.backgroundColor = [UIColor redColor];
        [self addSubview:self.playBtn];
        [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(ws).with.offset(-30);
            make.top.mas_equalTo(ws);
            make.bottom.mas_equalTo(ws);
            make.left.mas_equalTo(ws);
        }];
        [self.playBtn addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
        [self.playBtn addTarget:self action:@selector(touchEnd) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [self.playBtn addTarget:self action:@selector(touchEnd) forControlEvents:UIControlEventTouchCancel];
    }
    return self;
}


- (void)setColor:(UIColor *)color{

    self.bgView.backgroundColor = color;
    self.layer.borderColor = color.CGColor;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
//    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.frame.size.width*(self.curTimes/self.maxTimes), self.frame.size.height)];
//    [[UIColor blueColor] setFill];
//    [path fill];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.bgView.frame = CGRectMake(0, 0, self.frame.size.width*(self.curTimes/self.maxTimes), self.frame.size.height);
    }];
    
//    [self bringSubviewToFront:self.playBtn];
}


- (void)reset{
    
    [self deleteRecord];
}

-(void)setCurTimes:(CGFloat)curTimes{
    
    _curTimes = curTimes;
    self.title.text = [NSString stringWithFormat:@"%.0f秒",self.curTimes];
    [self setNeedsDisplay];
}


- (void)startRecord{
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [[PlayerManager sharedManager] stopPlaying];
    [RecorderManager sharedManager].delegate = self;
    [[RecorderManager sharedManager] startRecording];
    [self run];
}


- (void)endRecord{

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];    
    [[RecorderManager sharedManager] stopRecording];

    if ([[RecorderManager sharedManager] recordedTimeInterval]>1) {
        //有录音
        self.curTimes = MIN([[RecorderManager sharedManager] recordedTimeInterval], 60);
        self.curTimes = MAX(self.curTimes, 0);
        self.recorded = YES;
        self.deleteBtn.hidden = NO;
    }else{
        //录音太短
        [self deleteRecord];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)deleteRecord{
    [self stop];
    self.recorded = NO;
    self.deleteBtn.hidden = YES;
    self.curTimes = 0;
    self.filename = nil;
    self.title.text = [NSString stringWithFormat:@"按住说话"];
}


- (void)run{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    self.curTimes = MIN(self.curTimes+1, 60);
    self.curTimes = MAX(self.curTimes, 0);
    if (self.curTimes!=self.maxTimes) {
        [self performSelector:@selector(run) withObject:nil afterDelay:1];
    }else{
        [self endRecord];
    }
}

- (void)play{
    self.playing = YES;
    self.title.text = @"播放中";
    [PlayerManager sharedManager].delegate = self;
    [[PlayerManager sharedManager] playAudioWithFileName:self.filename delegate:self];
}

- (void)stop{
    self.playing = NO;
    self.curTimes = self.curTimes;
    
    [[RecorderManager sharedManager] stopRecording];
    [[PlayerManager sharedManager] stopPlaying];
}

- (NSData *)recordData{
    return [NSData dataWithContentsOfFile:self.filename];
}

- (void)touchDown{
    
    if (!self.recorded) {
        [self startRecord];
    }
}

- (void)touchEnd{

    if (!self.recorded) {
        [self endRecord];
        if (self.didRecord) {
            self.didRecord();
        }
    }else{
        if (self.playing) {
            [self stop];
        }else{
            [self play];
        }
    }
}



#pragma mark - Recording & Playing Delegate

- (void)recordingFinishedWithFileName:(NSString *)filePath time:(NSTimeInterval)interval {
    self.recorded = YES;
    self.filename = filePath;
    [self endRecord];
}

- (void)recordingStopped {
//    self.isRecording = NO;
}

- (void)recordingTimeoutWithFileName:(NSString *)filePath time:(NSTimeInterval)interval{}

- (void)recordingFailed:(NSString *)failureInfoString {
    self.recorded = NO;
}

- (void)levelMeterChanged:(float)levelMeter {
    
}

- (void)playingStoped {
    
    self.curTimes = self.curTimes;
//    self.isPlaying = NO;
//    self.consoleLabel.text = [NSString stringWithFormat:@"播放完成: %@", [self.filename substringFromIndex:[self.filename rangeOfString:@"Documents"].location]];
}

@end
