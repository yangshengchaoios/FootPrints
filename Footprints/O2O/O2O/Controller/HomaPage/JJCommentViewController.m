//
//  JJCommentViewController.m
//  Footprints
//
//  Created by Jinjin on 14/11/27.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJCommentViewController.h"
#import "JJMessageCell.h"
#import "MJRefresh.h"
#import "DXMessageToolBar.h"
#import "UploadManager.h"
#import "JJUserCenterViewController.h"
@interface JJCommentViewController ()<UITableViewDataSource,UITableViewDelegate,DXMessageToolBarDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic)  IBOutlet UILabel *statusLabel;
@property (weak,nonatomic) IBOutlet UILabel *noinfoLabel;
@property (nonatomic,assign) NSInteger totalCount;
@property (nonatomic,strong) NSString *playingMessageId;
@property (nonatomic,assign) MessagePlayStatus status;
@end

@implementation JJCommentViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.noinfoLabel.hidden = YES;
    
    [self.view addSubview:self.chatToolBar];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidEnd:) name:PlayAudioDidEndNotification object:nil];
    
    addNObserver(@selector(musicDidDownloadEnd:), PlayAudioDidStartNotification);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    WS(ws);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@0);
        make.left.mas_equalTo(@0);
        make.right.mas_equalTo(ws.view.mas_right);
        make.bottom.mas_equalTo(ws.chatToolBar.mas_top);
    }];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.headerView.frame = CGRectMake(0, -64, SCREEN_WIDTH, 64);
    [self.tableView addSubview:self.headerView];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"JJMessageCell" bundle:nil] forCellReuseIdentifier:@"JJMessageCell"];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(_headerView).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    self.statusLabel.text = @"下拉返回";
    [self refresh:^{
        [ws jumpToNeedShowMessage];
    }];
    
    if (self.toNickName && self.toUserId) {
        [self commentToUsername:self.toNickName andUserId:self.toUserId];
    }
    
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setShowMessageId:(NSString *)showMessageId{
    
    _showMessageId = showMessageId;
    [self jumpToNeedShowMessage];
}

- (void)jumpToNeedShowMessage{
    
    if (self.showMessageId) {
        for (MessageModel *model in self.dataSource) {
            if ([model.messageId isEqualToString:self.showMessageId]) {
            
                NSInteger index = [self.dataSource indexOfObject:model];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [self.tableView  scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                self.showMessageId = nil;
            }
        }
    }
}

- (void)applicationDidEnterBackground{
    
    [_chatToolBar cancelTouchRecord];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (DXMessageToolBar *)chatToolBar
{
    if (_chatToolBar == nil) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationWillTerminateNotification object:nil];
        _chatToolBar = [[DXMessageToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [DXMessageToolBar defaultHeight], self.view.frame.size.width, [DXMessageToolBar defaultHeight])];
        _chatToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        _chatToolBar.delegate = self;
    }
    
    return _chatToolBar;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)reload{
     self.noinfoLabel.hidden = self.dataSource.count>0;
    [self.tableView reloadData];
}

- (void)refresh{
    [self refresh:^{
        
    }];
}

- (void)refresh:(void (^) (void)) complete{
    
    if (self.travelId) {
        WS(ws);
        [AFNManager getObject:@{@"travelId":self.travelId,@"pageIndex":@1,@"pageSize":@(MAX(self.totalCount, 2000))}
                      apiName:@"Index/GetTravelMessage"
                    modelName:@"MessageListModel"
             requestSuccessed:^(id responseObject) {
                 MessageListModel *model = responseObject;
                 ws.totalCount = MAX(model.totalCount+100, 2000);
                 ws.dataSource = [model.datas mutableCopy];
                 [ws reload];
                 
                 if (complete) {
                     complete();
                 }
             } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                 //        [ws showResultThenHide:@""];
             }];
    }
}

- (void)sendTextMessage:(NSString *)message{

    if (![UserManager isLogin] && self.hostViewController) {
        [UserManager showLoginOnController:self.hostViewController];
        return;
    }
    
    if (message && self.travelId) {
        WS(ws);
        /*
         “travelId”:”123123”  //针对足迹ID留言//  必传
         "toMemberId":””//针对人留言id//  选传，只针对足迹时值为””
         "memberId":””//留言人id//  必传
         "messageContent":””//留言内容//  选传
         "messageVoice":””//留言语音//  选传
         "messageType":””//留言类型(1文字 2语音)//  必传
         */
        //@"toMemberId":@""
        NSMutableDictionary *dict = [@{@"travelId":ws.travelId,@"memberId":[UserManager loginUserId],@"messageContent":message,@"messageType":@(1)} mutableCopy];
        if (ws.toUserId) {
            [dict setObject:ws.toUserId forKey:@"toMemberId"];
        }
        [AFNManager postObject:dict
                       apiName:@"Index/TravelMessage"
                     modelName:@"BaseModel"
              requestSuccessed:^(id responseObject) {
                  
                  ws.toUserId = nil;
            [ws refresh:^{
                if (ws.dataSource.count) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:ws.dataSource.count-1 inSection:0];
                    [ws.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
            }];
        } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
            [ws showResultThenHide:errorMessage];
        }];
    }
}


- (void)sendVoiceData:(NSData *)data{
    
    if (data && self.travelId) {
        
        WS(ws);
        [self showHUDLoadingWithString:@"发布中.."];
        [UploadManager uploadFile:data type:@"spx" success:^(id result) {
            /*
             code = 200;
             "image-frames" = 1;
             "image-height" = 424;
             "image-type" = JPEG;
             "image-width" = 640;
             message = ok;
             sign = 688805056e90065638efdccd2e0b7694;
             time = 1413792792;
             url = "test/upload/20141020/96FD0543-CC8A-4495-95E0-A204D9131849";
             */
            NSString *voicePath = result[@"url"]?:@"";
            NSMutableDictionary *dict = [@{@"travelId":ws.travelId,@"memberId":[UserManager loginUserId],@"messageVoice":voicePath,@"messageType":@(2)} mutableCopy];
            if (ws.toUserId) {
                [dict setObject:ws.toUserId forKey:@"toMemberId"];
            }
            [AFNManager postObject:dict
                           apiName:@"Index/TravelMessage"
                         modelName:@"BaseModel"
                  requestSuccessed:^(id responseObject) {
                      ws.toUserId = nil;
                      [ws refresh:^{
                          if (ws.dataSource.count) {
                              NSIndexPath *indexPath = [NSIndexPath indexPathForRow:ws.dataSource.count-1 inSection:0];
                              [ws.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                          }
                      }];
                      [ws hideHUDLoading];
                  } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                      [ws showResultThenHide:@"留言发布失败"];
                  }];
        } failBlock:^(NSError *error) {
            [ws showResultThenHide:@"留言发布失败"];
        } progressBlock:^(CGFloat percent, long long requestDidSendBytes) {
            
        }];
    }else{
        [self showResultThenHide:@"留言发布失败"];
    }
}

// 点击背景隐藏
-(void)keyBoardHidden
{
    [self.chatToolBar endEditing:YES];
}

#pragma mark - DXMessageToolBarDelegate
- (void)inputTextViewWillBeginEditing:(XHMessageTextView *)messageInputTextView{
  
}

- (void)inputTextViewDidEndEditing:(XHMessageTextView *)messageInputTextView{
    
    messageInputTextView.placeHolder = nil;
}

- (void)didSendText:(NSString *)text
{
    if (text && text.length > 0) {
        [self sendTextMessage:text];
    }
}

- (void)didSendVoice:(NSData *)data{
    
    [self sendVoiceData:data];
}

- (void)playDidEnd:(NSNotification *)noti{
    
    NSString *messageID = (id)noti.object;
    if ([messageID isEqualToString:self.playingMessageId]) {
        self.playingMessageId = nil;
        self.status = MessagePlayStatusNormal;
        [self.tableView reloadData];
    }
}
- (void)musicDidDownloadEnd:(NSNotification *)noti{
    
    NSString *messageID = (id)noti.object;
    if ([messageID isEqualToString:self.playingMessageId]) {
        self.status = MessagePlayStatusPlaying;
        [self.tableView reloadData];
    }
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger count = 0;
    count = self.dataSource.count;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = 0;
    MessageModel *message = self.dataSource[indexPath.row];
    height = [JJMessageCell heightForFCPhotoCell:message.msgContent messageType:message.msgType andCellType:MessageCellTypeWituToUser];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = nil;
    MessageModel *message = self.dataSource[indexPath.row];
    JJMessageCell *mCell = [tableView dequeueReusableCellWithIdentifier:@"JJMessageCell"];
    mCell.messageModel = message;
    mCell.cellType = MessageCellTypeWituToUser;
    
    if ([self.playingMessageId isEqualToString:message.messageId]) {
        [mCell setPlayStatus:self.status];
    }else{
        [mCell setPlayStatus:MessagePlayStatusNormal];
    }
    cell = mCell;
    
    WS(ws);
    mCell.didTap = ^(NSString *memberId){
        JJMemberModel *model = [[JJMemberModel alloc] init];
        model.memberId = memberId;
        if (![[UserManager loginUserId] isEqualToString:model.memberId]) {
            JJUserCenterViewController *user = [[JJUserCenterViewController alloc] initWithNibName:@"JJUserCenterViewController" bundle:nil];
            user.isMy = NO;
            user.model = model;
            [user refresh];
            user.hidesBottomBarWhenPushed = YES;
            
            [ws.hostViewController.navigationController pushViewController:user animated:YES];
        }
    };
    mCell.audioDidTap = ^(NSString *path,NSString *messageId,JJMessageCell *cell){
        
        if (path) {
            if ([ws.playingMessageId isEqualToString:messageId]) {
                //暂停
                ws.status = MessagePlayStatusNormal;
                [cell setPlayStatus:MessagePlayStatusNormal];
                [[AudioUtils sharedAudioUtils] stopPlay];
                ws.playingMessageId = nil;
            }else{
                //播放
                BOOL isPlaying = [[AudioUtils sharedAudioUtils] playAudioAtPath:path andUserInfo:messageId];
                ws.status = isPlaying?MessagePlayStatusPlaying:MessagePlayStatusDownloading;
                [cell setPlayStatus:ws.status];
                ws.playingMessageId = messageId;
            }
            
            [ws.tableView reloadData];
        }
    };
    mCell.cellDidTap = ^(NSString *mid,NSString *mname){
        if ((ws.toNickName && ws.toUserId ) || !mid || !mname) {
            ws.toNickName = nil;
            ws.toUserId = nil;
            ws.chatToolBar.inputTextView.placeHolder = nil;
        }else{
            if (![ws.toUserId isEqualToString:[UserManager loginUserId]]) {
                
                [ws commentToUsername:mname andUserId:mid];
            }
        }
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MessageModel *message = self.dataSource[indexPath.row];
    if (message.nickName) {
        [self commentToUsername:message.nickName andUserId:message.memberId];
    }
}

- (void)commentToUsername:(NSString *)username andUserId:(NSString *)userId{

    if (username) {
        [self.chatToolBar changeToText];
        self.toNickName = username;
        self.toUserId = userId;
        self.chatToolBar.inputTextView.placeHolder = [NSString stringWithFormat:@"回复 :%@",username];
        [self.chatToolBar.inputTextView becomeFirstResponder];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    self.statusLabel.text = (scrollView.contentOffset.y<=-(CGRectGetHeight(self.headerView.frame)))?@"松开返回":@"下拉返回";
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_chatToolBar.inputTextView resignFirstResponder];
    
    if (scrollView.contentOffset.y<=-(CGRectGetHeight(self.headerView.frame))) {
        self.toUserId = nil;
        self.toNickName = nil;
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, SCREEN_HEIGHT, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        }];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    return !CGRectContainsPoint(self.chatToolBar.frame,  [gestureRecognizer locationInView:self.view]);
}
@end
