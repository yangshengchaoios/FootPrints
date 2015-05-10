//
//  JJEditPasswordController.m
//  Footprints
//
//  Created by Jinjin on 14/12/9.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJEditPasswordController.h"
#import "InputHelper.h"

@interface JJEditPasswordController ()
@property (weak, nonatomic) IBOutlet UITextField *oldPassword;
@property (weak, nonatomic) IBOutlet UITextField *theNewPassword;
@property (weak, nonatomic) IBOutlet UISwitch *showPasswordSwitcher;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIImageView *pswBG;
@property (weak, nonatomic) IBOutlet UIImageView *oldPSWBg;

- (IBAction)showPasswordSwitchDidTap:(id)sender;
- (IBAction)sureBtnDidTap:(id)sender;
@end

@implementation JJEditPasswordController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.showPasswordSwitcher.on = NO;
    [self showPassword:NO];
    self.title = @"修改密码";
    WS(ws);
    self.oldPSWBg.backgroundColor = [UIColor whiteColor];
    self.oldPSWBg.clipsToBounds = YES;
    self.oldPSWBg.layer.borderWidth = kDefaultBorderWidth;
    self.oldPSWBg.layer.borderColor = kDefaultBorderColor.CGColor;
    self.oldPSWBg.layer.cornerRadius = 6;
    [self.oldPSWBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@25);
        make.top.mas_equalTo(@89);
        make.right.mas_equalTo(ws.view).with.offset(-25);
        make.height.mas_equalTo(@35);
    }];
    [self.oldPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(@(SCREEN_WIDTH-60));
        make.centerY.mas_equalTo(ws.oldPSWBg);
        make.centerX.mas_equalTo(ws.oldPSWBg);
        make.height.mas_equalTo(@30);
    }];
    
    
    self.pswBG.backgroundColor = [UIColor whiteColor];
    self.pswBG.clipsToBounds = YES;
    self.pswBG.layer.borderWidth = kDefaultBorderWidth;
    self.pswBG.layer.borderColor = kDefaultBorderColor.CGColor;
    self.pswBG.layer.cornerRadius = 6;
    [self.pswBG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@25);
        make.top.mas_equalTo(ws.oldPSWBg.mas_bottom).with.offset(10);
        make.right.mas_equalTo(ws.view).with.offset(-25);
        make.height.mas_equalTo(@35);
    }];

    self.showPasswordSwitcher.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [self.showPasswordSwitcher mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.pswBG);
        make.right.mas_equalTo(ws.pswBG).with.offset(-5);
    }];
    
    [self.theNewPassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(30);
        make.centerY.mas_equalTo(ws.pswBG);
        make.right.mas_equalTo(ws.showPasswordSwitcher.mas_left).with.offset(10);
        make.height.mas_equalTo(@30);
    }];
    
    [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.view).with.offset(25);
        make.right.mas_equalTo(ws.view).with.offset(-25);
        make.height.mas_equalTo(@44);
        make.top.mas_equalTo(ws.pswBG.mas_bottom).with.offset(70);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [inputHelper setupInputHelperForView:self.view withDismissType:InputHelperDismissTypeCleanMaskView];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [inputHelper setupInputHelperForView:nil withDismissType:InputHelperDismissTypeCleanMaskView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)showPassword:(BOOL)show{
    
    self.theNewPassword.secureTextEntry = !show;
}

- (IBAction)showPasswordSwitchDidTap:(id)sender {
    [self showPassword:self.showPasswordSwitcher.isOn];
}

- (IBAction)sureBtnDidTap:(id)sender {

    if ([StringUtils isEmpty:self.oldPassword.text]) {
        [self.oldPassword becomeFirstResponder];
        [self showResultThenHide:@"请输入旧密码"];
        return;
    }
    if ([StringUtils isEmpty:self.theNewPassword.text]) {
        [self.theNewPassword becomeFirstResponder];
        [self showResultThenHide:@"请输入新密码"];
        return;
    }
    
    WS(ws);
    [AFNManager postObject:@{@"password":self.oldPassword.text,@"newPassword":self.theNewPassword.text} apiName:@"LoginRegister/EditPassword" modelName:@"BaseModel" requestSuccessed:^(id responseObject) {
        [ws showResultThenBack:@"修改成功"];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        [ws showResultThenHide:errorMessage?:@"修改不成功"];
    }];
}
@end
