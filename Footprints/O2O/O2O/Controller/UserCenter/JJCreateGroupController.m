//
//  JJCreateGroupController.m
//  Footprints
//
//  Created by Jinjin on 14/12/2.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJCreateGroupController.h"
#import "JJUserView.h"
#import "JJChooseFriendsController.h"

@interface JJCreateGroupController ()
@property (strong, nonatomic) IBOutlet UIButton *nextStepBtn;
@property (weak, nonatomic) IBOutlet UITextField *nameInput;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScroll;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteGroupBtn;
@property (strong,nonatomic) JJChooseFriendsController *friends;
@property (nonatomic,strong) NSMutableArray *memberInGroup;

@property (weak, nonatomic) IBOutlet UIView *inputPad;
@property (weak, nonatomic) IBOutlet UIView *memberPad;
- (IBAction)addBtnDidTap:(id)sender;
- (IBAction)deleteBtnDidTap:(id)sender;
- (IBAction)nextStepDidTap:(id)sender;
- (IBAction)deleteGroupBtnDidTap:(id)sender;

@end

@implementation JJCreateGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = self.groupId?@"管理标签":@"新建标签";
    self.deleteGroupBtn.hidden = !self.groupId;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.nextStepBtn];
    
    
    self.nameInput.text = self.groupName;
    self.deleteBtn.clipsToBounds = YES;
    self.addBtn.clipsToBounds = YES;
    [self loadUserViews];
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kDefaultBorderWidth)];
    line.backgroundColor = kDefaultLineColor;
    [self.inputPad addSubview:line];
    line = [[UIView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, kDefaultBorderWidth)];
    line.backgroundColor = kDefaultLineColor;
    [self.inputPad addSubview:line];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kDefaultBorderWidth)];
    line.backgroundColor = kDefaultLineColor;
    [self.memberPad addSubview:line];
    line = [[UIView alloc] initWithFrame:CGRectMake(0, self.memberPad.frame.size.height, SCREEN_WIDTH, kDefaultBorderWidth)];
    line.backgroundColor = kDefaultLineColor;
    [self.memberPad addSubview:line];
    WS(ws);
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(ws.memberPad);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 1));
    }];
    
    self.deleteGroupBtn.frame = CGRectMake(20, 210, SCREEN_WIDTH-40, 40);
    self.deleteGroupBtn.layer.cornerRadius = 6;
    
    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)setGroupName:(NSString *)groupName{
    
    _groupName = groupName;
    self.nameInput.text = self.groupName;
}

- (void)refresh{
    
    if (self.groupId) {
        WeakSelfType blockSelf = self;
        [AFNManager getObject:@{@"pageIndex":@(1),@"pageSize":@(2000),@"groupId":self.groupId}
                      apiName:@"MemberCenter/GetMemberGroup"
                    modelName:@"ContactMemberModel" requestSuccessed:^(id responseObject) {
                        
                        if ([responseObject isKindOfClass:[NSArray class]]) {
                            NSArray *array = responseObject;
                            blockSelf.memberInGroup = [array mutableCopy];
                            [blockSelf loadUserViews];
                        }
                        else{
                            [blockSelf showResultThenBack:@"获取失败"];
                        }
                    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                        NSLog(@"%@",errorMessage);
                        [blockSelf showResultThenBack:errorMessage?:@"获取失败"];
                    }];
    }
}

- (void)setChoosedSource:(NSMutableArray *)choosedSource{
    _choosedSource = choosedSource;
    [self loadUserViews];
}

- (void)deleteUserDidTap:(UIButton *)btn{
    
    NSInteger index = btn.tag;
    if (self.memberInGroup) {
        id model = self.groupId?[self.memberInGroup objectAtIndex:index]:[self.choosedSource objectAtIndex:index];
        
        if (nil==self.friends) {
            self.friends = [[JJChooseFriendsController alloc] initWithNibName:@"JJChooseFriendsController" bundle:nil];
        }
        [self.friends addDeletedUser:model];
        [self.memberInGroup removeObject:model];
    }else{
        id model = [self.choosedSource objectAtIndex:index];
        [self.choosedSource removeObjectAtIndex:index];
        [self.delegate didRemoveUserModel:model];
    }
    UIView *view = self.userViews[index];
    [view removeFromSuperview];
    [self.userViews removeObjectAtIndex:index];
    [self resetUserViewFramesWithAnimation:NO];
}

- (void)loadUserViews{
    
    for (UIView *view in self.userViews) {
        [view removeFromSuperview];
    }
    self.userViews = [@[] mutableCopy];
    for (ContactMemberModel *model in self.groupId?self.memberInGroup:self.choosedSource) {
        JJUserView *view = [[JJUserView alloc] initWithFrame:CGRectZero];
        [view.avatarView bindUserData:model];
        view.nameLabel.text = model.nickName;
        view.deleteBtn.hidden = YES;
        view.deleteBtn.tag = [self.groupId?self.memberInGroup:self.choosedSource indexOfObject:model];
        [view.deleteBtn addTarget:self action:@selector(deleteUserDidTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.userViews addObject:view];
    }
    [self resetUserViewFramesWithAnimation:NO];
}

- (void)resetUserViewFramesWithAnimation:(BOOL)animation{
    
    NSInteger countPerRow = 4;
    CGFloat padding = 10;
    CGFloat yOffset = 10;
    CGFloat width = (SCREEN_WIDTH-padding*2)/countPerRow;
    CGFloat height = width+5;
    CGFloat btnWidth = 40;
    [UIView animateWithDuration:animation?0.35:0 animations:^{
        for (UIView *view in self.userViews) {
            NSInteger index = [self.userViews indexOfObject:view];
            view.frame = CGRectMake(padding+(index%countPerRow)*width, yOffset+(index/countPerRow)*height, width, height);
            [self.memberPad addSubview:view];
        }
        self.addBtn.frame = CGRectMake(padding+(width-btnWidth)/2+(self.userViews.count%countPerRow)*width, yOffset+(self.userViews.count/countPerRow)*height, btnWidth, btnWidth);
        self.deleteBtn.frame = CGRectMake(padding+(width-btnWidth)/2+((self.userViews.count+1)%countPerRow)*width, yOffset+((self.userViews.count+1)/countPerRow)*height, btnWidth, btnWidth);
    }];

    self.memberPad.frame = CGRectMake(0, 130, SCREEN_WIDTH, CGRectGetMaxY(self.deleteBtn.frame)+5+20);
    self.deleteBtn.hidden = self.userViews.count==0;
    self.addBtn.layer.cornerRadius = btnWidth/2;
    self.deleteBtn.layer.cornerRadius = btnWidth/2;
    
    
    self.deleteGroupBtn.frame = CGRectMake(20,CGRectGetMaxY(self.memberPad.frame)+15, SCREEN_WIDTH-40, 40);
    self.contentScroll.contentSize = CGSizeMake(SCREEN_WIDTH, MAX(CGRectGetMaxY(self.deleteGroupBtn.frame), self.view.frame.size.height+1));
}

- (IBAction)addBtnDidTap:(id)sender {
    
    if (self.groupName) {
        if (nil==self.friends) {
            self.friends = [[JJChooseFriendsController alloc] initWithNibName:@"JJChooseFriendsController" bundle:nil];
        }
        
        WS(ws);
        self.friends.didChooseMember= ^(ContactMemberModel *newModel ,BOOL isChoose){
            
            if (isChoose) {
                [ws.memberInGroup addObject:newModel];
            }else{
                
                NSArray *temp = [ws.memberInGroup copy];
                for (ContactMemberModel *oldmodel in temp) {
                    if ([newModel.memberId isEqualToString:oldmodel.memberId]) {
                        [ws.memberInGroup removeObject:oldmodel];
                    }
                }
            }
            [ws loadUserViews];
            [ws resetUserViewFramesWithAnimation:YES];
        };
        self.friends.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:self.friends animated:YES];
    }else{
        [self.delegate didSetGroupName:self.nameInput.text];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)deleteBtnDidTap:(UIButton *)sender {
  
    BOOL hidden = sender.tag==0?NO:YES;
    for (JJUserView *view in self.userViews) {
        view.deleteBtn.hidden = hidden;
    }
    [sender setTitle:hidden?@"删除":@"完成" forState:UIControlStateNormal];
    sender.tag = hidden?0:1;
}

- (IBAction)deleteGroupBtnDidTap:(id)sender {

    if (self.groupId) {
        WS(ws);
        [AFNManager postObject:@{@"groupId":self.groupId}
                       apiName:@"MemberCenter/DeleteMemberGroup"
                     modelName:@"BaseModel"
              requestSuccessed:^(id responseObject) {
                  [ws showResultThenBack:@"删除成功"];
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    [ws showResultThenHide:errorMessage];
                }];
    }
}

- (IBAction)nextStepDidTap:(id)sender {
    //SaveMemberGroup
    
    WS(ws);
    if (self.groupId) {
        NSString *friendMemberId = @"";
        NSString *groupId = self.groupId;
        NSString *groupName = self.nameInput.text;
        if ([StringUtils isEmpty:groupName]) {
            [self showResultThenHide:@"请输入标签名"];
        }else{
            for (ContactMemberModel *model in self.memberInGroup) {
                if (friendMemberId.length==0) {
                    friendMemberId = model.memberId;
                }else{
                    friendMemberId = [NSString stringWithFormat:@"%@,%@",friendMemberId,model.memberId];
                }
            }
            [AFNManager postObject:@{@"friendMemberId":friendMemberId,@"groupName":groupName,@"groupId":groupId}
                           apiName:@"MemberCenter/MultMemberToGroup"
                         modelName:@"BaseModel"
                  requestSuccessed:^(id responseObject) {
                      [ws showResultThenBack:@"修改成功"];
                      [self.navigationController popViewControllerAnimated:YES];
                  }
                    requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                        [ws showResultThenHide:errorMessage];
                    }];
        
        }
    }
    else{
        NSString *friendMemberId = @"";
        NSString *groupName = self.nameInput.text;
        if ([StringUtils isEmpty:groupName]) {
            [self showResultThenHide:@"请输入标签名"];
        }else{
            for (ContactMemberModel *model in self.choosedSource) {
                if (friendMemberId.length==0) {
                    friendMemberId = model.memberId;
                }else{
                    friendMemberId = [NSString stringWithFormat:@"%@,%@",friendMemberId,model.memberId];
                }
            }
            [AFNManager postObject:@{@"friendMemberId":friendMemberId,@"groupName":groupName}
                           apiName:@"MemberCenter/MultMemberToGroup"
                         modelName:@"BaseModel"
                  requestSuccessed:^(id responseObject) {
                      [ws showResultThenBack:@"创建成功"];
                      UIViewController *controller = self.navigationController.viewControllers[MAX(0, self.navigationController.viewControllers.count-3)];
                      [self.navigationController popToViewController:controller animated:YES];
                  }
                    requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                        [ws showResultThenHide:errorMessage];
                    }];
        }

    }
}


@end
