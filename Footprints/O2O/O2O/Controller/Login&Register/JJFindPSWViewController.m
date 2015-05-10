//
//  JJFindPSWViewController.m
//  Footprints
//
//  Created by tt on 14-10-17.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJFindPSWViewController.h"
#import <SMS_SDK/SMS_SDK.h>
#import "InputHelper.h"
@interface JJFindPSWViewController (){

    NSString *_checkCode;
    NSInteger _countDown;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *waySegmented;
@property (strong, nonatomic) IBOutlet UIView *byPhoneView;
@property (strong, nonatomic) IBOutlet UIView *byEmailView;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIButton *emailStartBtn;
@property (weak, nonatomic) IBOutlet UIButton *phoneStartBtn;
@property (weak, nonatomic) IBOutlet UITextField *pswField;
@property (weak, nonatomic) IBOutlet UITextField *checkField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UIButton *getCheckBtn;
@property (weak, nonatomic) IBOutlet UILabel *countDownLabel;
@property (weak, nonatomic) IBOutlet UITextField *mailPSWField;
@property (weak, nonatomic) IBOutlet UITextField *mailCheckField;

- (IBAction)getCheckBtnDidTap:(id)sender;

- (IBAction)phoneStartBtnDidTap:(id)sender;

- (IBAction)emailStartBtnDidTap:(id)sender;

- (IBAction)waySegementedDidChange:(id)sender;
@end

@implementation JJFindPSWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
     [self setupDefaultUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
   
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [inputHelper setupInputHelperForView:nil withDismissType:InputHelperDismissTypeCleanMaskView];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [inputHelper setupInputHelperForView:self.view withDismissType:InputHelperDismissTypeCleanMaskView];
    self.navigationController.navigationBarHidden = NO;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)changeToPhone:(BOOL)byPhone{
    
    for (UIView *view in self.view.subviews) {
        if (view.tag==1000) {
            view.hidden = !byPhone;
        }if (view.tag==1001) {
            view.hidden = byPhone;
        }
    }
}


#pragma mark -
#pragma mark Setup Methods
- (void)setupDefaultUI{
    self.view.backgroundColor = kDefaultViewColor;
    self.waySegmented.tintColor = [UIColor whiteColor];
    self.isModifyPhone = self.isModifyPhone;
    
    [self changeToPhone:YES];
    
    WS(ws);
    CGFloat width = SCREEN_WIDTH-50;
    [self.phoneField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@30);
        make.left.mas_equalTo(@25);
        make.size.mas_equalTo(CGSizeMake(width, 36));
    }];
    
    [self.pswField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.phoneField.mas_bottom).with.offset(20);
        make.left.mas_equalTo(@25);
        make.size.mas_equalTo(CGSizeMake(width, 36));
    }];
    
    [self.checkField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.pswField.mas_bottom).with.offset(20);
        make.left.mas_equalTo(@25);
        make.size.mas_equalTo(CGSizeMake(width-100, 36));
    }];
    
    [self.getCheckBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.pswField.mas_bottom).with.offset(20);
        make.right.mas_equalTo(ws.view).with.offset(-25);
        make.size.mas_equalTo(CGSizeMake(90, 36));
    }];
    [self.phoneStartBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.checkField.mas_bottom).with.offset(40);
        make.left.mas_equalTo(@25);
        make.size.mas_equalTo(CGSizeMake(width, 44));
    }];
    

    [self.emailField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@30);
        make.left.mas_equalTo(@25);
        make.size.mas_equalTo(CGSizeMake(width, 36));
    }];
    [self.mailPSWField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.emailField.mas_bottom).with.offset(20);
        make.left.mas_equalTo(@25);
        make.size.mas_equalTo(CGSizeMake(width, 36));
    }];
    [self.mailCheckField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.mailPSWField.mas_bottom).with.offset(20);
        make.right.mas_equalTo(ws.view).with.offset(-25);
        make.size.mas_equalTo(CGSizeMake(width, 36));
    }];
    [self.emailStartBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.mailCheckField.mas_bottom).with.offset(40);
        make.left.mas_equalTo(@25);
        make.size.mas_equalTo(CGSizeMake(width, 44));
    }];

}

- (void)addNotifications{
    
    //    addNObserver(@selector(keyboardDidChangeFrameNotification:), UIKeyboardDidChangeFrameNotification);
}

- (void)setIsModifyPhone:(BOOL)isModifyPhone{
    
        _isModifyPhone = isModifyPhone;
        self.waySegmented.hidden = isModifyPhone;
        self.title = isModifyPhone?@"修改手机号":@"找回密码";
        self.phoneField.placeholder = isModifyPhone?@"请输入登录密码":@"请输入手机号";
        self.pswField.placeholder = isModifyPhone?@"新手机号":@"设置新密码";
        self.navigationItem.titleView = isModifyPhone?nil:self.waySegmented;
}



#pragma mark -
#pragma mark Methods
- (BOOL)checkIsValidPhone:(NSString *)phoneStr{
    
    BOOL isPhone = [StringUtils isMobilePhone:phoneStr];
    if (!isPhone) {
        [self showResultThenHide:@"请输入正确的手机号"];
    }
    return isPhone;
}

- (void)getCheckCode{
    
    WeakSelfType blockSelf = self;
    [SMS_SDK getVerifyCodeByPhoneNumber:self.isModifyPhone?self.pswField.text:self.phoneField.text
                                AndZone:@"86"
                                 result:^(enum SMS_GetVerifyCodeResponseState state) {
                                     /*
                                      SMS_ResponseStateMaxVerifyCode=2,
                                      SMS_ResponseStateGetVerifyCodeTooOften=3
                                      */
                                     if (SMS_ResponseStateGetVerifyCodeFail == state) {
                                         NSLog(@"获取验证码失败");
                                         [blockSelf showResultThenHide:@"请重新获取验证码"];
                                         [blockSelf resetCountDown];
                                     }
                                     else if (SMS_ResponseStateGetVerifyCodeSuccess == state){
                                         NSLog(@"获取验证码成功");
                                         [blockSelf showResultThenHide:@"验证码已发送"];
                                     }else if (SMS_ResponseStateMaxVerifyCode == state){
                                         NSLog(@"获取验证码达到上限");
                                     }else if (SMS_ResponseStateGetVerifyCodeTooOften == state){
                                         NSLog(@"获取验证码太频繁了");
                                         [blockSelf showResultThenHide:@"验证码获取太频繁"];
                                     }
                                 }];

}


- (void)showCountDown{
    
    if (_countDown>=0) {
        self.countDownLabel.text = [NSString stringWithFormat:@"%@",@(_countDown)];
        if (_countDown>0) {
            _countDown--;
            [self performSelector:@selector(showCountDown) withObject:nil afterDelay:1];
        }else{
            [self resetCountDown];
        }
    }
}

- (void)resetCountDown{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showCountDown) object:nil];
    self.countDownLabel.text = [NSString stringWithFormat:@"%@",@(kCountDownTime)];
    self.getCheckBtn.enabled = YES;
    _countDown = kCountDownTime;
}


- (void)changePSWByPhone{
    
    if (self.isModifyPhone) {
        NSString *phone = self.pswField.text;
        NSString *psw = self.phoneField.text;
        NSString *checkCode = self.checkField.text;
        
        if (![self checkIsValidPhone:phone]) {
            [self showResultThenHide:@"请输入正确手机号"];
            [self.phoneField becomeFirstResponder];
            return;
        }
        if ([StringUtils isEmpty:psw]) {
            [self.pswField becomeFirstResponder];
            [self showResultThenHide:@"请输入密码"];
            return;
        }
        
        [self showHUDLoadingWithString:@"修改中.."];
        WeakSelfType blockSelf = self;
        //验证短信
        [SMS_SDK commitVerifyCode:checkCode result:^(enum SMS_ResponseState state) {
            /*
             SMS_ResponseStateFail = 0,
             SMS_ResponseStateSuccess=1
             */
            if (state == SMS_ResponseStateFail) {
                [blockSelf showResultThenHide:@"请输入正确的验证码"];
            }else if (state == SMS_ResponseStateSuccess){
                [blockSelf changePhone:phone password:psw];
            }
        }];
    }else{
        NSString *phone = self.phoneField.text;
        NSString *psw = self.pswField.text;
        NSString *checkCode = self.checkField.text;
        
        if (![self checkIsValidPhone:phone]) {
            
            [self showResultThenHide:@"请输入正确手机号"];
            [self.phoneField becomeFirstResponder];
            return;
        }
        if ([StringUtils isEmpty:psw]) {
            [self.pswField becomeFirstResponder];
            [self showResultThenHide:@"请输入新密码"];
            return;
        }
        
        [self showHUDLoadingWithString:@"短信验证中.."];
        WeakSelfType blockSelf = self;
        //验证短信
        [SMS_SDK commitVerifyCode:checkCode result:^(enum SMS_ResponseState state) {
            /*
             SMS_ResponseStateFail = 0,
             SMS_ResponseStateSuccess=1
             */
            if (state == SMS_ResponseStateFail) {
                [blockSelf showResultThenHide:@"请输入正确的验证码"];
            }else if (state == SMS_ResponseStateSuccess){
                [blockSelf hideHUDLoading];
                [blockSelf changeAccount:phone password:psw];
            }
        }];
    }
}

- (void)changePSWByEmail{
    
    
    NSString *email = self.emailField.text;
    NSString *psw = self.mailPSWField.text;
    NSString *checkPsw = self.mailCheckField.text;
    if (![StringUtils isEmail:email]) {
        [self.emailField becomeFirstResponder];
        [self showResultThenHide:@"请输入正确的邮箱"];
        return;
    }
    if ([StringUtils isEmpty:psw]) {
        [self.mailPSWField becomeFirstResponder];
        [self showResultThenHide:@"请输入密码"];
        return;
    }
    if (![psw isEqualToString:checkPsw]) {
        [self.mailCheckField becomeFirstResponder];
        [self showResultThenHide:@"两次输入密码不一致"];
        return;
    }
    [self changeAccount:email password:psw];
}

- (void)changePhone:(NSString *)account password:(NSString *)psw{
    
    WeakSelfType blockSelf = self;
    [AFNManager postObject:@{@"newPhone":account,@"password":psw} apiName:@"MemberCenter/ChangeBindingPhone" modelName:@"BaseModel" requestSuccessed:^(id responseObject) {
        
        [blockSelf showResultThenBack:@"修改成功"];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        
        [blockSelf showResultThenHide:errorMessage?:@"修改失败"];
    }];
}

- (void)changeAccount:(NSString *)account password:(NSString *)psw{
    
    WeakSelfType blockSelf = self;
    [AFNManager postObject:psw?@{kParamContactWay:account,kParamNewPassword:psw}:@{kParamContactWay:account}
                   apiName:@"LoginRegister/FindPassword"
                 modelName:@"BaseModel"
          requestSuccessed:^(id responseObject) {
        
        [blockSelf showResultThenBack:@"修改成功"];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        
        [blockSelf showResultThenHide:errorMessage?:@"修改失败"];
    }];
}

#pragma mark -
#pragma mark Actions
- (IBAction)getCheckBtnDidTap:(id)sender {
    
    if ([self checkIsValidPhone:self.isModifyPhone?self.pswField.text:self.phoneField.text]) {
        [self getCheckCode];
        self.getCheckBtn.enabled = NO;
        _countDown = kCountDownTime;
        [self showCountDown];
    }
}

- (IBAction)phoneStartBtnDidTap:(id)sender {
    
    [self changePSWByPhone];
}

- (IBAction)emailStartBtnDidTap:(id)sender {
    [self changePSWByEmail];
}

- (IBAction)waySegementedDidChange:(id)sender {
    

        [self changeToPhone:self.waySegmented.selectedSegmentIndex==0];
}

#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField==self.phoneField) {
        [self.pswField becomeFirstResponder];
    }else if (textField==self.pswField) {
        [self.checkField becomeFirstResponder];
    }
    else if (textField==self.checkField){
        [self changePSWByPhone];
    }
    return YES;
}
@end
