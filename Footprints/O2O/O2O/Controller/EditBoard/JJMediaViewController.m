//
//  JJMediaViewController.m
//  Footprints
//
//  Created by tt on 14/11/6.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJMediaViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioUtils.h"
#import "JJMusicCell.h"


#import "AudioPlayer.h"

@interface JJMediaViewController ()<UITableViewDataSource,UITableViewDelegate,MPMediaPickerControllerDelegate,AudioPlayerDelegate>

- (IBAction)addMusicBtnDidTap:(id)sender;
@property (nonatomic,strong) NSString *playingMuiscId;
@property (nonatomic,strong) IBOutlet UITableView *table ;
@property (nonatomic,strong) NSMutableArray *musicDatas;
@property (nonatomic,strong) AudioPlayer* audioPlayer;
@end

@implementation JJMediaViewController
- (void)dealloc
{
    NSLog(@"JJMediaViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self.audioPlayer stop];
        self.audioPlayer.delegate = nil;
    self.audioPlayer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
     self.title = @"背景音乐";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayMusic:) name:@"DidPlayMusic" object:nil];
    [self.table registerNib:[UINib nibWithNibName:@"JJMusicCell" bundle:nil] forCellReuseIdentifier:@"JJMusicCell"];
    [self refresh];
    
    self.audioPlayer = [[AudioPlayer alloc] init];
    self.audioPlayer.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithDidChooseActions:(DidChooseBlock)compelte{
    
    self = [super initWithNibName:@"JJMediaViewController" bundle:nil];
    if (self) {
        self.compelte = compelte;
    }
    return self;
}

- (void)didPlayMusic:(NSNotification *)noti{
    
    BackgroundMusicModel *model = noti.object;
    if (model) {
        self.playingMuiscId = model.musicId;
        [self.audioPlayer play:[NSURL URLWithString:model.urlPath]];
    }else{
        self.playingMuiscId = nil;
        [self.audioPlayer stop];
    }
    [self.table reloadData];
}

-(void) audioPlayer:(AudioPlayer*)audioPlayer stateChanged:(AudioPlayerState)state{

    /*
     AudioPlayerStateReady,
     AudioPlayerStateRunning = 1,
     AudioPlayerStatePlaying = (1 << 1) | AudioPlayerStateRunning,
     AudioPlayerStatePaused = (1 << 2) | AudioPlayerStateRunning,
     AudioPlayerStateStopped = (1 << 3),
     AudioPlayerStateError = (1 << 4),
     AudioPlayerStateDisposed = (1 << 5)
     */
    if (state==AudioPlayerStateStopped || state==AudioPlayerStateError || state==AudioPlayerStateDisposed) {
        
        self.playingMuiscId = nil;
        [self.audioPlayer stop];
        [self.table reloadData];
    }
}
-(void) audioPlayer:(AudioPlayer*)audioPlayer didEncounterError:(AudioPlayerErrorCode)errorCode{}
-(void) audioPlayer:(AudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId{}
-(void) audioPlayer:(AudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId{}
-(void) audioPlayer:(AudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(AudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration{}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setModel:(BackgroundMusicModel *)model{
    _model = model;
    [self.table reloadData];
    
}

- (void)refresh{
    if (nil==self.musicDatas) {
        self.musicDatas = [@[] mutableCopy];
    }
    
    WeakSelfType blockSelf = self;
    [AFNManager getObject:@{@"isSelf":@"0"} apiName:kResPathGetBackgroundMusic modelName:@"BackgroundMusicModel" requestSuccessed:^(id responseObject) {
        NSLog(@"%@",responseObject);
        [blockSelf.musicDatas addObjectsFromArray:responseObject];
        [blockSelf.table reloadData];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
         NSLog(@"%@",errorMessage);
    }];
}

- (IBAction)addMusicBtnDidTap:(id)sender{
    
    MPMediaType mediaType = MPMediaTypeMusic;
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:mediaType];
    picker.delegate = self;
    [picker setAllowsPickingMultipleItems:YES];
    picker.prompt = @"请选择背景音乐";
    [self presentViewController:picker animated:YES completion:nil];
}


#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.musicDatas.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JJMusicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JJMusicCell"];
    if (indexPath.row==0) {
        if (self.model==nil) {
            [cell chooseThisCell:YES];
        }else{
            [cell chooseThisCell:NO];
        }
        cell.nameLabel.text = @"不选择背景音乐";
        [cell hideActionBtn:YES];
    }else{
        BackgroundMusicModel *m = self.musicDatas[indexPath.row-1];
        [cell setMuiscModel:m andPlayingId:self.playingMuiscId];
        [cell chooseThisCell:[self.model.musicId isEqualToString:m.musicId]];
        [cell hideActionBtn:NO];
    }
    NSLog(@"%f",cell.checkBox.alpha);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    BackgroundMusicModel *model = nil;
    if (indexPath.row!=0) {
        model = self.musicDatas[indexPath.row-1];
    }
    if (self.compelte) {
        self.compelte(model);
    }
    [self.navigationController popViewControllerAnimated:YES];
}


@end
