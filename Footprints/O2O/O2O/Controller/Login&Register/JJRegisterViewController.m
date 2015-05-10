//
//  JJRegisterViewController.m
//  Footprints
//
//  Created by tt on 14-10-15.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJRegisterViewController.h"
#import "StringUtils.h"
#import "JJUserInfoViewController.h"
#import <SMS_SDK/SMS_SDK.h>
#import "InputHelper.h"
@interface JJRegisterViewController ()<UITextFieldDelegate>{
    
    NSInteger _countDown;
    NSString *_checkCode;
}

@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *checkCodeField;
@property (weak, nonatomic) IBOutlet UIButton *getCodeBtn;
@property (weak, nonatomic) IBOutlet UILabel *countDownLabel;
@property (weak, nonatomic) IBOutlet UIButton *radioCheckBtn;

- (IBAction)getCodeBtnDidTap:(id)sender;
- (IBAction)radioCheckBtnDidTap:(id)sender;
- (IBAction)registerBtnDidTap:(id)sender;
- (IBAction)fileBtnDidTap:(id)sender;
@end

@implementation JJRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupDefaultUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
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
#pragma mark -
#pragma mark Setup Methods
- (void)setupDefaultUI{
    
    self.title = @"手机快速注册";
    //TODO
    CGFloat width = SCREEN_WIDTH-50;
    [self.phoneField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@36);
        make.left.mas_equalTo(@0);
        make.size.mas_equalTo(CGSizeMake(width, 35));
    }];
    [self.checkCodeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@91);
        make.left.mas_equalTo(@0);
        make.size.mas_equalTo(CGSizeMake(width-100, 35));
    }];
}

- (void)addNotifications{
    
//    addNObserver(@selector(keyboardDidChangeFrameNotification:), UIKeyboardDidChangeFrameNotification);
}


#pragma mark -
#pragma mark  Methods
- (void)registerAccount{
    
//    JJUserInfoViewController *userInfoController = [[JJUserInfoViewController alloc] initWithNibName:@"JJUserInfoViewController" bundle:nil];
//    userInfoController.phoneNumber = @"123";
//    [self.navigationController pushViewController:userInfoController animated:YES];
    
    NSString *phone = self.phoneField.text;
    NSString *checkCode = self.checkCodeField.text;
    
    if (![self checkIsValidPhone:phone]) {

        return;
    }
    if (!self.radioCheckBtn.selected) {
        [self showResultThenHide:@"请同意《用户协议》"];
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
            JJUserInfoViewController *userInfoController = [[JJUserInfoViewController alloc] initWithNibName:@"JJUserInfoViewController" bundle:nil];
            userInfoController.phoneNumber = phone;
            [blockSelf.navigationController pushViewController:userInfoController animated:YES];
        }
    }];
}

- (BOOL)checkIsValidPhone:(NSString *)phoneStr{

    BOOL isPhone = [StringUtils isMobilePhone:phoneStr];
    if (!isPhone) {
        [self showResultThenHide:@"请输入正确的手机号"];
    }
    return isPhone;
}

- (void)getCheckCode{
    
    WeakSelfType blockSelf = self;
    [SMS_SDK getVerifyCodeByPhoneNumber:self.phoneField.text
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
    self.getCodeBtn.enabled = YES;
    _countDown = kCountDownTime;
}

#pragma mark -
#pragma mark Actions
- (IBAction)getCodeBtnDidTap:(id)sender {
    if ([self checkIsValidPhone:self.phoneField.text]) {
        [self getCheckCode];
        self.getCodeBtn.enabled = NO;
        _countDown = kCountDownTime;
        [self showCountDown];
    }
}

- (IBAction)radioCheckBtnDidTap:(id)sender {
    
    self.radioCheckBtn.selected = !self.radioCheckBtn.selected;
}

- (IBAction)registerBtnDidTap:(id)sender {
    
    [self checkPhont];
}

- (IBAction)fileBtnDidTap:(id)sender {

}

- (void)checkPhont{
    NSString *phone = self.phoneField.text;
    if (![self checkIsValidPhone:phone]) {
        return;
    }
    WS(ws);
    [AFNManager getObject:@{@"memberName":phone} apiName:@"/LoginRegister/CheckRegisterPhone" modelName:@"BaseModel" requestSuccessed:^(id responseObject) {
        NSDictionary *dict = responseObject;
        if ([dict isKindOfClass:[NSDictionary class]]) {
            if (![[dict objectForKey:@"status"] boolValue]) {
                [ws registerAccount];
            }else{
                [ws showResultThenHide:@"该手机号已经注册"];
            }
        }else{
            [ws registerAccount];
        }
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        NSLog(@"%@",errorMessage);
        [ws registerAccount];
    }];
}


#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField==self.phoneField) {
        [self.checkCodeField becomeFirstResponder];
    }else if (textField==self.checkCodeField){
        [self checkPhont];
    }
    return YES;
}
@end
