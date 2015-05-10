//
//  JJUserInfoViewController.m
//  Footprints
//
//  Created by tt on 14-10-16.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJUserInfoViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UploadManager.h"
#import "InputHelper.h"
@interface JJUserInfoViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIButton *avatarBtn;
@property (weak, nonatomic) IBOutlet UITextField *pswField;
@property (weak, nonatomic) IBOutlet UISwitch *pswSwitcher;
@property (weak, nonatomic) IBOutlet UITextField *nickNameField;
@property (weak, nonatomic) IBOutlet UIButton *maleCheckBtn;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;

@property (strong,nonatomic) NSString *avatarPath;
- (IBAction)avatarBtnDidTap:(id)sender;
- (IBAction)pswSwitcherDidTap:(id)sender;
- (IBAction)maleBtnDidTap:(id)sender;
- (IBAction)startBtnDidTap:(id)sender;

@end

@implementation JJUserInfoViewController

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
    
    self.title = @"设置个人信息";
    
    self.avatarBtn.layer.cornerRadius = CGRectGetWidth(self.avatarBtn.frame)/2;
    //TODO
    self.maleCheckBtn.selected = YES;
}

- (void)addNotifications{
    
    //    addNObserver(@selector(keyboardDidChangeFrameNotification:), UIKeyboardDidChangeFrameNotification);
}


#pragma mark -
#pragma mark Methods
- (void)showImagePicker:(UIImagePickerControllerSourceType) type{
    
    UIImagePickerController *imagepicker = [[UIImagePickerController alloc] init];
    imagepicker.sourceType = type;
    imagepicker.allowsEditing = YES;
    imagepicker.delegate = self;
    imagepicker.allowsEditing = YES;
    imagepicker.mediaTypes = @[(NSString*)kUTTypeImage];
    [self presentViewController:imagepicker animated:YES completion:NULL];
}

- (void)uploadImage:(UIImage *)img{
    
    WeakSelfType blockSelf = self;
    [self showHUDLoadingWithString:@"上传中.."];
    [UploadManager uploadImage:UIImageJPEGRepresentation(img, 1)
                      success:^(id result) {
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
                          NSDictionary *dict = result;
                          if ([dict isKindOfClass:[NSDictionary class]]) {
                              blockSelf.avatarPath = [NSString stringWithFormat:@"/%@",dict[@"url"]];
                              [blockSelf.avatarBtn setImage:img forState:UIControlStateNormal];
                              [blockSelf showResultThenHide:@"上传成功"];
                              
                          }else{
                              [blockSelf showResultThenHide:@"上传失败，请重新尝试"];
                          }
                          NSLog(@"%@",result);
                      } failBlock:^(NSError *error) {
                          [blockSelf.avatarBtn setBackgroundImage:nil forState:UIControlStateNormal];
                          [blockSelf showResultThenHide:@"上传失败，请重新尝试"];
                          NSLog(@"%@",error.localizedDescription);
                      } progressBlock:^(CGFloat percent, long long requestDidSendBytes) {
                          
                      }];
}

- (void)startRegist{

    NSString *psw = self.pswField.text;
    NSString *nickName = self.nickNameField.text;
    
    if ([StringUtils isEmpty:psw]) {
        [self.pswField becomeFirstResponder];
        [self showResultThenHide:@"请输入密码"];
        return;
    }
    if ([StringUtils isEmpty:nickName]) {
        [self.nickNameField becomeFirstResponder];
        [self showResultThenHide:@"请输入昵称"];
        return;
    }
    if ([StringUtils isEmpty:self.avatarPath]) {
        [self showResultThenHide:@"请设置头像"];
        return;
    }
    
    [self showHUDLoadingWithString:@"注册中.."];
    
    WeakSelfType blockSelf = self;
    [AFNManager postObject:@{kParamMemberName:self.phoneNumber,kParamHeadImage:self.avatarPath,kParamPassword:psw,kParamNickName:nickName,kParamSex:self.maleCheckBtn.selected?@"女":@"男"}
                   apiName:kResPathRegister
                 modelName:@"JJMemberModel"
          requestSuccessed:^(id responseObject) {
              NSLog(@"%@",responseObject);
              JJMemberModel *model = responseObject;
              [UserManager saveLoginUser:model];
              if ([UserManager isLogin]) {
                  [blockSelf gotoHomePage];
              }else{
                  [blockSelf showResultThenHide:@"注册失败,请稍后再试"];
              }
          } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                [blockSelf showResultThenHide:@"注册失败，请重新尝试"];
              [blockSelf showResultThenHide:errorMessage];
          }];
}

- (void)gotoHomePage{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
        postNWithInfo(kShowHomePageNotification, nil);
    }];
}

#pragma mark -
#pragma mark Actions
- (IBAction)avatarBtnDidTap:(id)sender {
    
    BOOL isCameraSupport = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (isCameraSupport) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册", nil];
        [actionSheet showInView:self.view];
    }else{
        [self showImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }
}

- (IBAction)pswSwitcherDidTap:(id)sender {
    
    self.pswField.secureTextEntry = !self.pswSwitcher.isOn;
}

- (IBAction)maleBtnDidTap:(id)sender {

    self.maleCheckBtn.selected = !self.maleCheckBtn.selected;
}

- (IBAction)startBtnDidTap:(id)sender {
    
    [self startRegist];
}


#pragma mark -
#pragma mark Delegates
//UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex==0) {//拍照
        [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
    }else if (buttonIndex==1){//相册
        [self showImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }
}

//UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    //获取图片裁剪的图
    UIImage* edit = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.avatarBtn setImage:edit forState:UIControlStateNormal];
    [self uploadImage:edit];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
     [picker dismissViewControllerAnimated:YES completion:NULL];
}

//UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField==self.pswField) {
        [self.nickNameField becomeFirstResponder];
    }else if (textField==self.nickNameField){
        [self startRegist];
    }
    return YES;
}
@end
