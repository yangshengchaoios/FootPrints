//
//  JJGroupRemarkController.m
//  Footprints
//
//  Created by Jinjin on 14/12/5.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJGroupRemarkController.h"
#import "JJGroupChooseController.h"

@interface JJGroupRemarkController ()
@property (nonatomic,strong) MemberGroupModel *groupModel;
@property (nonatomic,strong) FriendGroupInfo *fInfo;
- (IBAction)chooseGroupDidTap:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *done;
@property (weak, nonatomic) IBOutlet UIView *namePad;
@property (weak, nonatomic) IBOutlet UIView *groupPad;
@end

@implementation JJGroupRemarkController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"标签及分组";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.done];
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kDefaultBorderWidth)];
    line.backgroundColor = kDefaultLineColor;
    [self.namePad addSubview:line];
    line = [[UIView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, kDefaultBorderWidth)];
    line.backgroundColor = kDefaultLineColor;
    [self.namePad addSubview:line];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kDefaultBorderWidth)];
    line.backgroundColor = kDefaultLineColor;
    [self.groupPad addSubview:line];
    line = [[UIView alloc] initWithFrame:CGRectMake(0, self.groupPad.frame.size.height, SCREEN_WIDTH, kDefaultBorderWidth)];
    line.backgroundColor = kDefaultLineColor;
    [self.groupPad addSubview:line];
    
    
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

- (IBAction)chooseGroupDidTap:(id)sender {
    
    WS(ws);
    JJGroupChooseController *group = [[JJGroupChooseController alloc] initWithNibName:@"JJGroupChooseController" bundle:nil];
    group.groupId = self.groupId;
    group.groupName = self.groupName;
    group.didChoose = ^(MemberGroupModel *groupModel){
        ws.groupModel = groupModel;
        ws.groupName = groupModel.groupName;
        ws.groupId = groupModel.groupId;
        ws.groupLabel.text = groupModel.groupName;
    };
    group.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:group animated:YES];
}

- (IBAction)postEdit{

    [self.remarkLabel resignFirstResponder];
    if (self.memberId) {
        WS(ws);
        NSString *remark = [self.remarkLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSMutableDictionary *dict = [@{} mutableCopy];
        [dict setObject:self.memberId forKey:@"friendMemberId"];
        if (self.groupModel.groupId || self.groupId)  [dict setObject:self.groupModel.groupId?:self.groupId forKey:@"groupId"];
        if (self.groupModel.groupName)  [dict setObject:self.groupModel.groupName forKey:@"groupName"];
        if (![StringUtils isEmpty:remark])  [dict setObject:remark forKey:@"remark"];
        
        
        [AFNManager postObject:dict
                       apiName:@"MemberCenter/EditFriendRemarkAndGroup"
                     modelName:@"BaseModel"
              requestSuccessed:^(id responseObject) {
                  [ws showResultThenBack:@"修改成功"];
              }
                requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    [ws showResultThenHide:errorMessage];
                }];
    }
   
}

- (void)refresh{
    
    if (self.memberId) {
        WS(ws);
        [AFNManager getObject:@{@"friendMemberId":self.memberId} apiName:@"MemberCenter/GetFriendGroupInfo" modelName:@"FriendGroupInfo" requestSuccessed:^(id responseObject) {
            ws.fInfo = responseObject;
            ws.groupLabel.text = ws.fInfo.groupName?:@"未设置分组";
            ws.remarkLabel.text = ws.fInfo.remark;
            ws.groupId = ws.fInfo.groupId;
            ws.groupName = ws.fInfo.groupName;
        } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
            
            [ws showResultThenBack:@"请求错误"];
        }];
    }
}
@end
