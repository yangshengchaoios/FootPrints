//
//  JJDetailViewController.m
//  Footprints
//
//  Created by Jinjin on 14/11/13.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJDetailViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "JJCommentViewController.h"
#import "JJUserCenterViewController.h"
#import "JJViewActionSheet.h"
#import "JJAccountViewController.h"
#import "UMSocial.h"
#import "JJChooseFriendsController.h"
#import "AudioPlayer.h"

typedef enum {
    ChangeStateNormal = 0,
    ChangeStateUp = 1,
    ChangeStateDown = 2,
    ChangeStateAnimating = 3,
    ChangeStateNotReady = 4,
}ChangeState;

#define kScale 0.9
@interface JJDetailViewController ()<UIGestureRecognizerDelegate,UIActionSheetDelegate,AudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (strong, nonatomic) UIImageView *imageView3;
@property (weak, nonatomic) IBOutlet UIView *showBoardView;
@property (assign, nonatomic) ChangeState changeState;
@property (nonatomic,retain) DetailTravelModel *model;
@property (nonatomic,assign) NSInteger curPage;
@property (nonatomic,strong) JJCommentViewController *commentViewCon;

@property (weak, nonatomic) IBOutlet JJAvatarView *avatarView;
@property (weak, nonatomic) IBOutlet UIView *bootomBarView;
@property (weak, nonatomic) IBOutlet UITextView *introdactionView;
@property (weak, nonatomic) IBOutlet UIView *locationBarView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *footprintsLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewsLabel;
@property (weak, nonatomic) IBOutlet UIButton *speakBtn;
@property (weak, nonatomic) IBOutlet UIButton *musicBtn;
@property (strong, nonatomic) IBOutlet UIButton *moreBtn;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (nonatomic,strong) JJViewActionSheet *sheet;
@property (weak, nonatomic) IBOutlet UIButton *pauseMusicBtn;
@property (nonatomic,assign) CGRect commentsFrame;
@property (nonatomic,assign) BOOL playing;
@property (nonatomic,strong) AudioPlayer* gaAudioPlayer;

- (IBAction)speakBtnDidTap:(id)sender;
- (IBAction)musicBtnDidTap:(id)sender;
- (IBAction)likeBtnDidTap:(id)sender;
- (IBAction)commentBtnDidTap:(id)sender;

@end

@implementation JJDetailViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopMusic:YES];
    if ([[AudioUtils sharedAudioUtils] audioPlaying]) {
        [[AudioUtils sharedAudioUtils] stopPlay];
    }
}

- (void)stopMusic:(BOOL)stop{
    
    if (stop) {
            self.pauseMusicBtn.selected = NO;
        self.playing = NO;
        [self.gaAudioPlayer stop];
        self.gaAudioPlayer.delegate = nil;
        self.gaAudioPlayer = nil;
    }else{
        
        self.pauseMusicBtn.selected = YES;
        if (self.gaAudioPlayer==nil) {
            self.gaAudioPlayer = [[AudioPlayer alloc] init];
            self.gaAudioPlayer.delegate = self;
        }
        
        if ([self.model.backgroundMusic hasPrefix:@"http"]) {
            //播放
            if (!self.playing) {
                [self.gaAudioPlayer play:[NSURL URLWithString:self.model.backgroundMusic]];
            }
        }else{
            [self stopMusic:YES];
        }
    }
}

- (void)setCommentsFrame:(CGRect)commentsFrame{
    
    _commentsFrame = commentsFrame;
    self.commentViewCon.view.frame = _commentsFrame;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.moreBtn];
    [self.moreBtn addTarget:self action:@selector(showMore) forControlEvents:UIControlEventTouchUpInside];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [self.showBoardView addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self.showBoardView addGestureRecognizer:tap];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(speakEnd) name:PlayAudioDidEndNotification object:nil];
    
    self.avatarView.avatarView.layer.cornerRadius = CGRectGetHeight(self.avatarView.frame)/2;
    self.introdactionView.textColor = [UIColor whiteColor];
    self.introdactionView.font = [UIFont systemFontOfSize:14];
    
    self.bootomBarView.alpha = 1;
    self.avatarView.superview.alpha = 1;
    
    [self performSelector:@selector(didTap:) withObject:nil afterDelay:1.5];
    
    self.locationBarView.hidden = YES;
    
    UIButton *avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:avatarBtn];
    [avatarBtn addTarget:self action:@selector(avatarDidTap) forControlEvents:UIControlEventTouchUpInside];
    [avatarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(_avatarView);
    }];
    
    
    [self setLocationForViews];
    
    self.changeState = ChangeStateNotReady;
    
    [self refreshModel];
    
    self.commentsFrame = CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    if (self.showMessageId) {
        self.commentsFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    }
    [self addCommentsController];
    
    if (self.toNickName && self.toUserId) {
        [self commentToUsername:self.toNickName andUserId:self.toUserId];
    }
    
    [self makeConstraints];
    
    
    self.imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-23)/2, SCREEN_HEIGHT-64-44, 23, 34)];
    self.imageView3.image = [UIImage imageNamed:@"xs (1).png"];
    [self.view insertSubview:self.imageView3 belowSubview:self.commentViewCon.view];
    self.imageView3.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    
    self.imageView1.frame = [self realFrameForFrame:self.imageView1.frame];
    self.imageView2.frame = [self realFrameForFrame:self.imageView2.frame];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.gaAudioPlayer resume];
    [self addCommentsController];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    self.commentsFrame = self.commentViewCon.view.frame;
    [self.commentViewCon.view removeFromSuperview];
    self.commentViewCon = nil;
    [self.gaAudioPlayer pause];
    if ([[AudioUtils sharedAudioUtils] audioPlaying]) {
        [[AudioUtils sharedAudioUtils] stopPlay];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addCommentsController{

    if (nil==self.commentViewCon) {
        self.commentViewCon = [[JJCommentViewController alloc] initWithNibName:@"JJCommentViewController" bundle:nil];
        self.commentViewCon.travelId = self.travelId;
        self.commentViewCon.hostViewController = self;
        [self.view addSubview:self.commentViewCon.view];
        self.commentViewCon.view.frame = self.commentsFrame;
        
        if (self.showMessageId) {
            self.commentViewCon.showMessageId = self.showMessageId;
        }
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)makeConstraints{
    WS(ws);
    [self.avatarView.superview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@0);
        make.top.mas_equalTo(@0);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 46));
    }];
    
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@7);
        make.top.mas_equalTo(@5);
        make.size.mas_equalTo(CGSizeMake(36, 36));
    }];

    [self.speakBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.avatarView.mas_right).with.offset(5);
        make.top.mas_equalTo(@3);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}


- (void)commentToUsername:(NSString *)username andUserId:(NSString *)userId{
    self.toNickName = username;
    self.toUserId = userId;
    [self.commentViewCon commentToUsername:username andUserId:userId];
}

- (void)bindDataForModel:(DetailTravelModel *)model{

    [self.avatarView.avatarView setImageWithURLString:model.headImage placeholderImage:nil];
    self.avatarView.iconView.hidden = model.memberStatus!=MemberStatusOfficer;
    self.locationBarView.hidden = [StringUtils isEmail:model.location];
    self.locationLabel.text = model.location;
    self.introdactionView.text = model.releaseContent;
    self.commentsLabel.text = [NSString stringWithFormat:@"%i",model.messageCount];
    self.footprintsLabel.text = [NSString stringWithFormat:@"%i",model.praiseCount];
    self.viewsLabel.text = [NSString stringWithFormat:@"%i",model.skimCount];
    self.speakBtn.hidden = model.voice?NO:YES;
    self.likeBtn.selected = model.isPraise;
    self.pauseMusicBtn.hidden = model.backgroundMusic?NO:YES;
    self.pauseMusicBtn.frame = CGRectMake(self.speakBtn.hidden?44:84, 3, 40, 40);
}

- (void)refreshModel{
    
    WS(ws);
    [AFNManager getObject:@{@"travelId":self.travelId}
                  apiName:kResPathGetTravel
                modelName:@"DetailTravelModel"
         requestSuccessed:^(id responseObject){
             ws.model = responseObject;
             ws.title = ws.model.title;
             [ws bindDataForModel:responseObject];
             ws.changeState = ChangeStateNormal;
             [ws loadImagesAtIndex:ws.curPage forView:(id)[ws getCurrentDisplayView]];
             
             [ws stopMusic:NO];
             
         } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
             NSLog(@"%@",errorMessage);
             if ([errorMessage isEqualToString:@"足迹已不存在"]) {
                 ws.commentViewCon.view.hidden = YES;
                 [ws showResultThenHide:@"足迹已不存在" afterDelay:0.3 onView:ws.view];
                 [ws.commentViewCon.chatToolBar.inputTextView resignFirstResponder];
                 [ws performSelector:@selector(ddismissSelf) withObject:nil afterDelay:0.3];
             }
         }];
}

- (void)ddismissSelf{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
        [self stopMusic:YES];
        
    }
    
    if (state==AudioPlayerStatePaused) {
        self.playing = NO;
    }
    
    if (state==AudioPlayerStatePlaying) {
        self.playing = YES;
    }
}
-(void) audioPlayer:(AudioPlayer*)audioPlayer didEncounterError:(AudioPlayerErrorCode)errorCode{}
-(void) audioPlayer:(AudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId{}
-(void) audioPlayer:(AudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId{}
-(void) audioPlayer:(AudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(AudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration{}

- (void)loadImagesAtIndex:(NSInteger)index forView:(UIImageView *)imageView{
    
    NSArray *imageModels = [self.model detailImages];
    if (!imageModels.count) {
        return;
    }
    NSInteger modIndex = index%imageModels.count;
    if (modIndex<imageModels.count) {
        DetailImageModel *imgModel = imageModels[modIndex];
        [imageView setImageWithURLString:imgModel.imageUrl placeholderImage:nil];
    }
    
    
    self.imageView3.hidden = modIndex==(imageModels.count-1);
    if (imageModels.count<=1) {
        self.imageView3.hidden = YES;
    }
}


- (UIView *)getCurrentDisplayView{
    
    NSInteger indexOfImageView1 = [self.showBoardView.subviews indexOfObject:self.imageView1];
    NSInteger indexOfImageView2 = [self.showBoardView.subviews indexOfObject:self.imageView2];
    
    return indexOfImageView1<indexOfImageView2?self.imageView1:self.imageView2;
}

- (UIView *)getNextDisPlayView{
    NSInteger indexOfImageView1 = [self.showBoardView.subviews indexOfObject:self.imageView1];
    NSInteger indexOfImageView2 = [self.showBoardView.subviews indexOfObject:self.imageView2];
    
    return indexOfImageView1<indexOfImageView2?self.imageView2:self.imageView1;
}

- (void)setLocationForViews{
    UIView *topView = [self getNextDisPlayView];
    topView.frame = [self realFrameForFrame:CGRectMake(0, -CGRectGetHeight(topView.frame), CGRectGetWidth(topView.frame), CGRectGetHeight(topView.frame))];
}

- (void)didTap:(UITapGestureRecognizer *)tap{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    CGFloat alpha = self.bootomBarView.alpha?0:1;
    WS(ws);
    [UIView animateWithDuration:0.35 animations:^{
        ws.avatarView.superview.alpha = alpha;
        ws.bootomBarView.alpha = alpha;
    }];
}

CGFloat startY = 0;
- (void)didPan:(UIPanGestureRecognizer *)pan{
    
    if (self.changeState==ChangeStateAnimating || self.changeState==ChangeStateNotReady) return;
    
    CGFloat y = [pan locationInView:self.showBoardView].y;
    CGFloat distance = y-startY;
    distance = MAX(distance, -CGRectGetHeight(self.showBoardView.frame));
    distance = MIN(distance, CGRectGetHeight(self.showBoardView.frame));
    UIView *currentDisplayView = [self getCurrentDisplayView];
    UIView *nextDisplayView = [self getNextDisPlayView];
    BOOL isUp = distance<0?YES:NO;
    BOOL isForbidenDrag = (!isUp && self.curPage==0) || self.model.detailImages.count<1;
    BOOL showComment = self.curPage==(self.model.detailImages.count-1);
    
    CGFloat yBase = isUp?CGRectGetHeight(nextDisplayView.frame):-CGRectGetHeight(nextDisplayView.frame);
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        startY = [pan locationInView:self.showBoardView].y;
    }
    else if(pan.state == UIGestureRecognizerStateChanged){
        
        if (isForbidenDrag) {
            distance = MIN(CGRectGetHeight(self.showBoardView.frame)*0.2, distance);
            distance = MAX(-CGRectGetHeight(self.showBoardView.frame)*0.2, distance);
            currentDisplayView.frame = [self realFrameForFrame:CGRectMake(0, distance, CGRectGetWidth(nextDisplayView.frame), CGRectGetHeight(nextDisplayView.frame))];
            return;
        }
        
        
        CGFloat scale = 1- MIN(ABS(distance)/CGRectGetHeight(self.showBoardView.frame), 1)*(1-kScale);
        currentDisplayView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
        
        if (isUp && showComment) {
            
            nextDisplayView.frame = [self realFrameForFrame:CGRectMake(0, -CGRectGetHeight(nextDisplayView.frame), CGRectGetWidth(nextDisplayView.frame), CGRectGetHeight(nextDisplayView.frame))];
            self.commentsFrame = CGRectMake(0, distance+CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
            return;
        }else{
            self.commentsFrame = CGRectMake(0, CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        }
        
        if(isUp && self.changeState!=ChangeStateUp) {
            //上拉换图
            [self loadImagesAtIndex:self.curPage+1 forView:(id)nextDisplayView];
            self.changeState = ChangeStateUp;
        }
        if(!isUp && self.changeState!=ChangeStateDown) {
            //下拉
            [self loadImagesAtIndex:self.curPage-1 forView:(id)nextDisplayView];
            self.changeState = ChangeStateDown;
        }
        nextDisplayView.frame = [self realFrameForFrame:CGRectMake(0, yBase+distance, CGRectGetWidth(nextDisplayView.frame), CGRectGetHeight(nextDisplayView.frame))];
    }
    else if(pan.state == UIGestureRecognizerStateCancelled || pan.state==UIGestureRecognizerStateEnded){
        
        WS(ws);
        self.changeState=ChangeStateAnimating;
        CGFloat moveSacle = ABS(distance)/CGRectGetHeight(self.showBoardView.frame);
        BOOL needChange = moveSacle<0.3?NO:YES;
        
        [UIView animateWithDuration:0.25 animations:^{
            
            if (isUp && showComment) {
                if (!needChange) {
                    //还原
                    currentDisplayView.transform = CGAffineTransformIdentity;
                    ws.commentsFrame = CGRectMake(0, CGRectGetHeight(ws.view.frame), CGRectGetWidth(ws.view.frame), CGRectGetHeight(ws.view.frame));
                }else{
                    //切页
                    currentDisplayView.transform = CGAffineTransformScale(CGAffineTransformIdentity, kScale, kScale);
                    [ws.commentViewCon refresh];
                    ws.commentsFrame = CGRectMake(0, 0, CGRectGetWidth(ws.view.frame), CGRectGetHeight(ws.view.frame));
                }
                return;
            }
            
            if (isForbidenDrag) {
                currentDisplayView.frame = [self realFrameForFrame:CGRectMake(0, 0, CGRectGetWidth(nextDisplayView.frame), CGRectGetHeight(nextDisplayView.frame))];
                currentDisplayView.transform = CGAffineTransformIdentity;
            }else{
                if (!needChange) {
                    //还原
                    currentDisplayView.transform = CGAffineTransformIdentity;
                    nextDisplayView.frame = [self realFrameForFrame:CGRectMake(0, yBase, CGRectGetWidth(nextDisplayView.frame), CGRectGetHeight(nextDisplayView.frame))];
                }else{
                    //切页
                    currentDisplayView.transform = CGAffineTransformScale(CGAffineTransformIdentity, kScale, kScale);
                    nextDisplayView.frame = [self realFrameForFrame:CGRectMake(0, 0, CGRectGetWidth(nextDisplayView.frame), CGRectGetHeight(nextDisplayView.frame))];
                }
            }
        } completion:^(BOOL finished) {
            ws.changeState=ChangeStateNormal;
            currentDisplayView.transform = CGAffineTransformIdentity;
            
            if (isUp && showComment) {
                
                return;
            }else{
                ws.commentsFrame = CGRectMake(0, CGRectGetHeight(ws.view.frame), CGRectGetWidth(ws.view.frame), CGRectGetHeight(ws.view.frame));            }
            
            if (needChange && !isForbidenDrag) {
                
                ws.curPage = (ws.curPage+(isUp?1:-1))%ws.model.detailImages.count;
                currentDisplayView.frame = [self realFrameForFrame:CGRectMake(0, CGRectGetHeight(currentDisplayView.frame), CGRectGetWidth(currentDisplayView.frame), CGRectGetHeight(currentDisplayView.frame))];
                [ws.showBoardView sendSubviewToBack:nextDisplayView];
            }
        }];
       
    }
}

- (CGRect)realFrameForFrame:(CGRect)rect{
    
    CGRect newFrame = rect;
    if (SCREEN_HEIGHT<568) {
        CGFloat width = ((SCREEN_HEIGHT-64)/(568.0-64)) * SCREEN_WIDTH;
        newFrame = CGRectMake((SCREEN_WIDTH-width)/2, rect.origin.y, width, rect.size.height);
    }
    return newFrame;
}

- (void)avatarDidTap{

    JJMemberModel *model = [[JJMemberModel alloc] init];
    model.memberId = self.model.memberId;
    if ([[UserManager loginUserId] isEqualToString:model.memberId]) {
        return;
    }
    JJUserCenterViewController *user = [[JJUserCenterViewController alloc] initWithNibName:@"JJUserCenterViewController" bundle:nil];
    user.isMy = NO;
    user.model = model;
    [user refresh];
    user.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:user animated:YES];
}

- (IBAction)speakBtnDidTap:(id)sender {
    
    if ([[AudioUtils sharedAudioUtils] audioPlaying]) {
        [[AudioUtils sharedAudioUtils] stopPlay];
    }else{
        if (self.model.voice) {
            [[AudioUtils sharedAudioUtils] playAudioAtPath:self.model.voice andUserInfo:nil];
        }
    }
}

- (void)speakEnd{
    
//    if (self.playing) {
//        <#statements#>
//    }
}

- (IBAction)musicBtnDidTap:(id)sender {

    self.pauseMusicBtn.selected = !self.playing;
    (self.playing)?[self.gaAudioPlayer pause]:[self.gaAudioPlayer resume];
}

- (IBAction)likeBtnDidTap:(id)sender {
    
    if (![UserManager isLogin]) {
        [UserManager showLoginOnController:self];
        return;
    }
    
    
    if (self.travelId && !self.model.isPraise) {
        self.likeBtn.selected = YES;
        WS(ws);
        [AFNManager postObject:@{@"travelId":self.travelId}
                       apiName:@"Index/PraiseTravel"
                     modelName:@"BaseModel"
              requestSuccessed:^(id responseObject) {
//                  [ws showResultThenHide:@"点赞成功"];
                  ws.model.isPraise = YES;
                  [ws refreshModel];
              } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                  [ws showResultThenHide:@"点赞失败"];
              }];
    }
}

- (IBAction)commentBtnDidTap:(id)sender {

    WS(ws);
    [UIView animateWithDuration:0.25 animations:^{
        
        [ws.commentViewCon refresh];
        ws.commentsFrame = CGRectMake(0, 0, CGRectGetWidth(ws.view.frame), CGRectGetHeight(ws.view.frame));
    } completion:^(BOOL finished) {
      
    }];
}

- (void)showMore{
    
    if ([self.model.memberId isEqualToString:[UserManager loginUserId]]) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil
                                                  otherButtonTitles:@"删除微秀",self.model.isCollection?@"取消收藏":@"收藏",@"分享",nil];
        sheet.tag = 2;
        [sheet showInView:self.view];
    }else{
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil
                                                  otherButtonTitles:self.model.isCollection?@"取消收藏":@"收藏",@"分享",@"举报",nil];
        sheet.tag = 1;
        [sheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.tag==1) {
        if (buttonIndex!=3 && ![UserManager isLogin]) {
            
            [UserManager showLoginOnController:self];
            return;
        }
        
        if (buttonIndex==0) {
            
            
            WS(ws);
            if(self.model.isCollection){
                //取消收藏
                [AFNManager postObject:@{@"travelId":self.travelId}
                               apiName:@"MemberCenter/MultDeleteCollection"
                             modelName:@"BaseModel"
                      requestSuccessed:^(id responseObject) {
                          [ws showResultThenHide:@"取消收藏成功"];
                          ws.model.isCollection = NO;
                          [ws refreshModel];
                      } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                          
                          [ws showResultThenHide:errorMessage?:@"取消收藏失败"];
                      }];
                
            }
            else{
                [AFNManager postObject:@{@"travelId":self.travelId}
                               apiName:@"Index/CollectionTravel"
                             modelName:@"BaseModel"
                      requestSuccessed:^(id responseObject) {
                          [ws showResultThenHide:@"收藏成功"];
                          ws.model.isCollection = YES;
                          [ws refreshModel];
                      } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                          
                          [ws showResultThenHide:errorMessage?:@"收藏失败"];
                      }];
            }
        }
        
        if (buttonIndex==1) {
            [self showShareSheet];
        }
        if (buttonIndex==2) {
            [self showReportSheet];
        }
        if (buttonIndex==3 && self.model.backgroundMusic) {
            
          
        }
    }
    
    if (actionSheet.tag==2) {

        if (buttonIndex==0) {
            
            WS(ws);
            [AFNManager postObject:@{@"travelId":self.travelId}
                           apiName:@"Index/DeleteTravel"
                         modelName:@"BaseModel"
                  requestSuccessed:^(id responseObject) {
                      [ws showResultThenBack:@"删除成功"];
                  } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                      [ws showResultThenHide:errorMessage?:@"删除失败"];
                  }];
        }
        if (buttonIndex==1) {
            WS(ws);
            if(self.model.isCollection){
                //取消收藏
                [AFNManager postObject:@{@"travelId":self.travelId}
                               apiName:@"MemberCenter/MultDeleteCollection"
                             modelName:@"BaseModel"
                      requestSuccessed:^(id responseObject) {
                          [ws showResultThenHide:@"取消收藏成功"];
                          ws.model.isCollection = NO;
                          [ws refreshModel];
                      } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                          
                          [ws showResultThenHide:errorMessage?:@"取消收藏失败"];
                      }];
                
            }
            else{
                [AFNManager postObject:@{@"travelId":self.travelId}
                               apiName:@"Index/CollectionTravel"
                             modelName:@"BaseModel"
                      requestSuccessed:^(id responseObject) {
                          [ws showResultThenHide:@"收藏成功"];
                          ws.model.isCollection = YES;
                          [ws refreshModel];
                      } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                          
                          [ws showResultThenHide:errorMessage?:@"收藏失败"];
                      }];
            }
        }
        if (buttonIndex==2) {
            [self showShareSheet];
        }
        if (buttonIndex==3 && self.model.backgroundMusic) {
            
           
        }
    }
    
    if (actionSheet.tag==3) {
        
        NSString * category = nil;
        switch (buttonIndex) {
            case 0:
                category = @"色情";
                break;
            case 1:
                category = @"暴力";
                break;
            case 2:
                category = @"政治";
                break;
            case 3:
                category = @"其他";
                break;
            default:
                break;
        }
        
        if (self.travelId && category) {
            WS(ws);
            [AFNManager postObject:@{@"toObjectId":self.travelId,@"toTypeId":@"2",@"category":category}
                           apiName:@"Index/MemberComplaint"
                         modelName:@"BaseModel"
                  requestSuccessed:^(id responseObject) {
                      [ws showResultThenHide:@"举报成功"];
                  } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                      [ws showResultThenHide:@"举报失败"];
                  }];
        }
    }
}

- (void)showReportSheet{
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"举报原因" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil
                                              otherButtonTitles:@"色情",@"暴力",@"政治",@"其他", nil];
    sheet.tag = 3;
    [sheet showInView:self.view];
}

- (void)showShareSheet{
    
    CGFloat width = SCREEN_WIDTH-16;
    CGFloat itemWidth = 90;
    CGFloat itemHeight = 70;
    CGFloat itemOffset = (width-itemWidth*3)/4;
    CGFloat btnWidth = 40;
    
    NSArray *images = @[[UIImage imageNamed:@"icon_weixin.png"],[UIImage imageNamed:@"icon_weibo-.png"],[UIImage imageNamed:@"aboult.png"]];
    NSArray *titles = @[@"微信朋友圈",@"新浪微博",@"微秀好友"];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, itemHeight)];
    view.backgroundColor = [UIColor clearColor];
    for(int index=0;index<images.count;index++){
        UIView *item = [[UIView alloc] initWithFrame:CGRectMake(itemOffset+(itemWidth+itemOffset)*index, 0, itemWidth, itemHeight)];
        item.backgroundColor = [UIColor clearColor];
        [view addSubview:item];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((itemWidth-btnWidth)/2, 10, btnWidth, btnWidth);
        [btn setImage:images[index] forState:UIControlStateNormal];
        btn.tag = index;
        [btn  addTarget:self action:@selector(shareBtnDidTap:) forControlEvents:UIControlEventTouchUpInside];
        [item addSubview:btn];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, btnWidth+15, itemWidth, itemHeight-btnWidth-15)];
        name.textAlignment = NSTextAlignmentCenter;
        name.textColor = [UIColor grayColor];
        name.font = [UIFont systemFontOfSize:14];
        name.text = titles[index];
        [item addSubview:name];
        
        [view addSubview:item];
    }
    if (self.sheet) {
        [self.sheet removeFromView];
        self.sheet = nil;
    }
    self.sheet = [[JJViewActionSheet alloc] initWithTitle:nil cancelButtonTitle:@"取消" contentView:view];
    [self.sheet showInView:self.navigationController.view];
}

- (void)shareBtnDidTap:(UIButton *)btn{
    
    switch (btn.tag) {
        case 0:
        {
            //微信
            [self shareToType:UMShareToWechatTimeline];
        }
            break;
        case 1:
            
            [self shareToType:UMShareToSina];
            break;
        case 2:
            
        {
            JJChooseFriendsController *friends = [[JJChooseFriendsController alloc] initWithNibName:@"JJChooseFriendsController" bundle:nil];
            WS(ws);
            friends.didChooseMember = ^(ContactMemberModel *newModel ,BOOL isChoose){};
            friends.isAllFriends = YES;
            friends.chooseComplete= ^(NSArray *members){
                if (members && ws.travelId) {
                    NSString *friendMemberId = nil;
                    for (ContactMemberModel *member in members) {
                        if (friendMemberId) {
                            friendMemberId = [NSString stringWithFormat:@"%@,%@",friendMemberId,member.memberId];
                        }else{
                            friendMemberId = member.memberId;
                        }
                    }
                    if (friendMemberId) {
                        [AFNManager postObject:@{@"travelId":ws.travelId,@"friendMemberId":friendMemberId}
                                       apiName:@"Index/ShareTravel"
                                     modelName:@"BaseModel"
                              requestSuccessed:^(id responseObject) {
                                  [ws showResultThenHide:@"分享成功"];
                              } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                                  [ws showResultThenHide:@"分享失败"];
                              }];
                    }
                }
            };
            [self.navigationController pushViewController:friends animated:YES];
        }
            break;
            
        default:
            break;
    }
    [self.sheet removeFromView];
    self.sheet = nil;
}

- (void)shareToType:(NSString *) type{

    WS(ws);
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.model.image];
    if (nil==image) {
        DetailImageModel *imgModel = [self.model.detailImages firstObject];
        image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imgModel.imageUrl];
    }
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[type] content:[NSString stringWithFormat:@"快来看看我的作品“%@”",self.model.title] image:image location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
        if (response.responseCode == UMSResponseCodeSuccess) {
            [ws showResultThenHide:@"分享成功"];
        }
    }];
}
@end
