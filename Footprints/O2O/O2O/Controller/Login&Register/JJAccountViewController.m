//
//  JJAccountViewController.m
//  Footprints
//
//  Created by tt on 14-10-15.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJAccountViewController.h"
#import "JJRegisterViewController.h"
#import "JJFindPSWViewController.h"
#import "UserManager.h"
#import "InputHelper.h"

@interface JJAccountViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *pswField;
@property (weak, nonatomic) IBOutlet UISwitch *pswSwitcher;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

- (IBAction)forgetPSWBtnDidTap:(id)sender;
- (IBAction)pswSwitcherDidChange:(id)sender;
- (IBAction)loginBtnDidTap:(id)sender;
- (IBAction)registerBtnDidTap:(id)sender;
- (IBAction)backBtnDidTap:(id)sender;
@end

@implementation JJAccountViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self addNotifications];
    [self setupDefaultUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
   
    [super viewWillAppear:animated];
    //    self.navigationController.navigationBarHidden = YES;
    [inputHelper setupInputHelperForView:self.view withDismissType:InputHelperDismissTypeCleanMaskView];
}

- (void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];
    [self.pswField resignFirstResponder];
    [self.userNameField resignFirstResponder];
    
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
    UIBarButtonItem *negativeSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSeperator.width = -20;
    
    self.navigationItem.leftBarButtonItems = @[ negativeSeperator, [[UIBarButtonItem alloc] initWithCustomView:self.backBtn]];
    self.title = @"登录";
}

- (void)addNotifications{
    
    addNObserver(@selector(keyboardDidChangeFrameNotification:), UIKeyboardDidChangeFrameNotification);
}

#pragma mark -
#pragma mark  Methods
- (void)login{
    
    NSString *userName = self.userNameField.text;
    NSString *psw = self.pswField.text;
    
    if (![StringUtils isMobilePhone:userName]) {
        [self showResultThenHide:@"请输入正确的手机号"];
        return;
    }
    if ([StringUtils isEmpty:psw]) {
        [self showResultThenHide:@"请输入密码"];
        return;
    }
    
    [self.pswField resignFirstResponder];
    [self.userNameField resignFirstResponder];
    WeakSelfType blockSelf = self;
    [AFNManager postObject:@{kParamPassword:psw,kParamMemberName:userName}
                   apiName:kResPathLogin modelName:@"JJMemberModel" requestSuccessed:^(id responseObject) {
                       JJMemberModel *model = responseObject;
                       [UserManager saveLoginUser:model];
                       if ([UserManager isLogin]) {
                           [blockSelf gotoHomePage];
                       }else{
                           [blockSelf showResultThenHide:@"登录失败,请稍后再试"];
                       }
                       NSLog(@"%@",responseObject);
                   } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                       [blockSelf showResultThenHide:errorMessage];
                       
                   }];
}


- (void)gotoHomePage{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        postNWithInfo(kShowHomePageNotification, nil);
    }];
}

#pragma mark -
#pragma mark Notifications
- (void)keyboardDidChangeFrameNotification:(NSNotification *)notification{
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    NSLog(@"%@",NSStringFromCGRect(keyboardRect));
}




#pragma mark -
#pragma mark Actions
- (IBAction)forgetPSWBtnDidTap:(id)sender {
    
    [self.pswField resignFirstResponder];
    [self.userNameField resignFirstResponder];
    
    JJFindPSWViewController *findPSWController = [[JJFindPSWViewController alloc] initWithNibName:@"JJFindPSWViewController" bundle:nil];
    [self.navigationController pushViewController:findPSWController animated:YES];
}

- (IBAction)pswSwitcherDidChange:(id)sender {

    self.pswField.secureTextEntry = !self.pswSwitcher.isOn;
}

- (IBAction)loginBtnDidTap:(id)sender {
    [self login];
}

- (IBAction)registerBtnDidTap:(id)sender {
    
    JJRegisterViewController *registerController = [[JJRegisterViewController alloc] initWithNibName:@"JJRegisterViewController" bundle:nil];
    [self.navigationController pushViewController:registerController animated:YES];
}

- (IBAction)backBtnDidTap:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField==self.userNameField) {
        [self.pswField becomeFirstResponder];
    }else if (textField==self.pswField){
        [self login];
    }
    return YES;
}
@end
