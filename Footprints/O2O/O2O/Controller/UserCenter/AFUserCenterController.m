//
//  AFUserCenterController.m
//  Whatstock
//
//  Created by Jinjin on 14/12/14.
//  Copyright (c) 2014年 AnnyFun. All rights reserved.
//

#import "AFUserCenterController.h"
#import "AFSettingUserCell.h"
#import "UploadManager.h"
#import "TimeUtils.h"
#import <MobileCoreServices/MobileCoreServices.h>


@implementation UIView (keyboardAnimation)

UIViewAnimationOptions curveOptionsFromCurve(UIViewAnimationCurve curve)
{
    switch (curve)
    {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
        default:
            return curve << 16;
    }
}

+ (void)animateWithKeyboardNotification:(NSNotification *)note animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    UIViewAnimationOptions curveOptions = curveOptionsFromCurve([note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]);
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] integerValue] delay:0 options:curveOptions animations:animations completion:completion];
}

@end


@interface AFUserCenterController ()<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableVIew;
@property (strong, nonatomic) IBOutlet UIButton *backBtn;
@property (strong, nonatomic) NSArray *titles;
@property (nonatomic,strong) UIDatePicker *picker;
@property (nonatomic,strong) UIImage *chooseImage;
- (IBAction)backBtnDidTap:(id)sender;


@property (nonatomic,strong) NSString *sex;
@property (nonatomic,strong) NSString *headImage;
@property (nonatomic,strong) NSString *nickName;
@property (nonatomic,strong) NSString *signature;
@property (nonatomic,assign) NSTimeInterval birthDay;
@property (nonatomic,strong) NSString *mail;


@property (assign, nonatomic) NSInteger inputIndex;

@property (nonatomic,strong) UIButton *hideBtn;
@end

@implementation AFUserCenterController
- (void)dealloc
{
    NSLog(@"AFUserCenterController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.title = @"我的资料";//[UserModel curUserName];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backBtn];
    
    self.tableVIew.backgroundColor = [UIColor clearColor];
    [self.tableVIew registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableVIew.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableVIew registerNib:[UINib nibWithNibName:@"AFSettingUserCell" bundle:nil] forCellReuseIdentifier:@"AFSettingUserCell"];
    self.titles = @[@"头像",@"昵称",@"个性签名",@"我的邮箱",@"性别",@"生日"];
    
    
    self.hideBtn = [[UIButton alloc] initWithFrame:self.view.bounds];
    [self.hideBtn addTarget:self action:@selector(hideAction) forControlEvents:UIControlEventTouchUpInside];
    
    JJMemberModel *user = self.user;
    self.sex = user.sex;
    self.headImage = user.headImage;
    self.nickName = user.nickName;
    self.signature = user.signature;
    self.birthDay = user.birthday;
    self.mail = user.email;
    
    [self refreshUserData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

-(void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat keyboardHeight = SCREEN_HEIGHT-endFrame.origin.y;
    WS(ws);
    [UIView animateWithKeyboardNotification:notification animations:^{
        ws.tableVIew.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-keyboardHeight-64);
    } completion:^(BOOL finished) {
        
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger count = 6;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger count = 45;
    if (indexPath.row==0) {
        count = 75;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AFSettingUserCell *sCell = [tableView dequeueReusableCellWithIdentifier:@"AFSettingUserCell"];
    sCell.nameLabel.text = self.titles[indexPath.row];
    sCell.avatarView.hidden = YES;
    sCell.checkBoxView.hidden = YES;
    sCell.avatarTap = NULL;
    sCell.inputField.userInteractionEnabled = NO;
    sCell.inputField.tag = indexPath.row;
    [sCell.inputField addTarget:self action:@selector(inputTextDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
    [sCell.inputField addTarget:self action:@selector(inputTextDidChangeEnd:) forControlEvents:UIControlEventEditingDidEnd];
    
    JJMemberModel *user = self.user;
    if (indexPath.row==0) {
        sCell.avatarView.hidden = NO;
        WS(ws);
        sCell.avatarTap = ^(AFSettingUserCell *tapCell){
            [ws takePhoto];
        };
        //TODO 替换PlaceHolder Image
        if (self.chooseImage) {
            sCell.avatarView.image = self.chooseImage;
        }else{
            [sCell.avatarView sd_setImageWithURL:[NSURL URLWithString:user.headImage] placeholderImage:nil];
        }
    }else if(indexPath.row==1){
        sCell.inputField.text = user.nickName;
        sCell.inputField.userInteractionEnabled = YES;
    }else if(indexPath.row==2){
        sCell.inputField.text = user.signature;
        sCell.inputField.placeholder = @"未设置";
        sCell.inputField.userInteractionEnabled = YES;
    }else if(indexPath.row==3){
        sCell.inputField.text = user.email;
        sCell.inputField.placeholder = @"未设置";
        sCell.inputField.userInteractionEnabled = YES;
    }else if(indexPath.row==4){
        sCell.checkBoxView.hidden = NO;
        if ([user.sex rangeOfString:@"男"].location != NSNotFound) {
           sCell.inputField.text = @"男";
        }
       else if ([user.sex rangeOfString:@"女"].location != NSNotFound) {
           sCell.inputField.text = @"女";
       }else{
           sCell.inputField.text = @"未知";
       }
    }
    else if(indexPath.row==5){
        sCell.inputField.text = [TimeUtils timeStringFromTimeStamp:[NSString stringWithFormat:@"%f",user.birthday] withFormat:@"yyyy-MM-dd"];
        sCell.inputField.placeholder = @"未设置";
    }
    
    sCell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.row==0 || indexPath.row==5 || indexPath.row==4) {
        //应用推荐
        sCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.row==0) {
        [sCell showTopLine:YES withInset:UIEdgeInsetsZero];
    }else{
        [sCell showTopLine:NO withInset:UIEdgeInsetsZero];
    }
    [sCell showBottomLine:YES withInset:UIEdgeInsetsMake(0, 0, 0, 0) withHeight:indexPath.row==0?74:44];
    return sCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
    WS(ws);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row==0) {
        [self takePhoto];
    }else if(indexPath.row==1){
    }else if(indexPath.row==2){
    }else if(indexPath.row==3){

    }else if(indexPath.row==4){
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女", nil];
        [sheet showInView:self.view];
        
    }else if(indexPath.row==5){
        if (nil==self.picker) {
            self.picker = [[UIDatePicker alloc] init];
            self.picker.datePickerMode = UIDatePickerModeDate;
            NSDate* minDate = [TimeUtils dateFromString:@"1930-01-01 00:00:00" withFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate* maxDate = [NSDate date];
            self.picker.minimumDate = minDate;
            self.picker.maximumDate = maxDate;
            self.picker.backgroundColor = [UIColor whiteColor];
            CGRect frame = self.picker.frame;
            frame.origin.y = SCREEN_HEIGHT;
            self.picker.frame = frame;
            [self.picker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged ];
            [self.view addSubview:self.picker];
        }
        
        UIButton *hideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        hideBtn.alpha = 0;
        hideBtn.frame = self.view.bounds;
        [hideBtn addTarget:self action:@selector(hidePicker:) forControlEvents:UIControlEventTouchUpInside];
        hideBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [self.view bringSubviewToFront:self.picker];
        [self.view insertSubview:hideBtn belowSubview:self.picker];
        NSDate* seleted = self.birthDay?[NSDate dateWithTimeIntervalSince1970:self.birthDay]:[TimeUtils dateFromString:@"1990-01-01" withFormat:@"yyyy-MM-dd"];
        [self.picker setDate:seleted animated:YES];
        [UIView animateWithDuration:0.3 animations:^{
            hideBtn.alpha = 1;
            CGRect frame = ws.picker.frame;
            frame.origin.y = ws.view.frame.size.height-frame.size.height;
            ws.picker.frame = frame;
        }];
    }
}

- (IBAction)backBtnDidTap:(id)sender {
   //修改资料
    if ([StringUtils isEmpty:self.nickName]) {
        [self showResultThenHide:@"请输入昵称"];
        return;
    }
    if (self.nickName.length>10) {
        [self showResultThenHide:@"昵称须10个字符内"];
        return;
    }
    if (self.signature.length>50) {
        [self showResultThenHide:@"签名须50个字符内"];
        return;
    }
    if (![StringUtils isEmpty:self.mail] && ![StringUtils isEmail:self.mail]) {
        [self showResultThenHide:@"请输入正确的邮箱"];
        return;
    }
    
    [self.tableVIew reloadData];
    
    WS(ws);
    NSMutableDictionary *data = [@{} mutableCopy];
    if (self.sex) [data setObject:self.sex forKey:@"sex"]; else [data setObject:@"" forKey:@"sex"];
    if (self.nickName) [data setObject:self.nickName forKey:@"nickName"]; else [data setObject:@"" forKey:@"nickName"];
    if (self.birthDay) [data setObject:@(self.birthDay) forKey:@"birthday"]; else [data setObject:@"" forKey:@"birthday"];
    if (self.mail) [data setObject:self.mail forKey:@"email"]; else [data setObject:@"" forKey:@"email"];
    if (self.signature) [data setObject:self.signature forKey:@"signature"];
    [self showHUDLoadingWithString:@"修改中.."];
    [AFNManager postObject:data apiName:@"MemberCenter/UpdateMemberInfo" modelName:@"BaseModel" requestSuccessed:^(id responseObject) {
        [ws showResultThenHide:@"修改成功"];
        [ws refreshUserData];
        [ws.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@1 afterDelay:1];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        [ws showResultThenHide:errorMessage?:@"修改失败"];
    }];
}

- (void)inputTextDidBegin:(UITextField *)field{
    
    [self.view addSubview:self.hideBtn];
}

- (void)inputTextDidChangeEnd:(UITextField *)field{
   
    [self.hideBtn removeFromSuperview];
    JJMemberModel *user = self.user;
    switch (field.tag) {
        case 1:
            self.nickName = field.text?:@"";
            user.nickName = self.nickName;
            break;
        case 2:
            self.signature = field.text?:@"";
            user.signature = self.signature;
            break;
        case 3:
            self.mail = field.text?:@"";
            user.email = self.mail;
            break;
            
        default:
            break;
    }
    [self.tableVIew reloadData];
}

- (void)hideAction{
    [self.tableVIew reloadData];
}

- (void)dateChanged:(UIDatePicker *)picker{
 
    self.birthDay = [picker.date timeIntervalSince1970];
    self.user.birthday = self.birthDay;
    [self.tableVIew reloadData];
}

- (void)hidePicker:(UIButton *)btn{

    WS(ws);
    [UIView animateWithDuration:0.3 animations:^{
        btn.alpha = 0;
        CGRect frame = ws.picker.frame;
        frame.origin.y = ws.view.frame.size.height;
        ws.picker.frame = frame;
    } completion:^(BOOL finished) {
        [btn removeFromSuperview];
    }];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)takePhoto{
    BOOL isCameraSupport = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (isCameraSupport) {
        WS(ws);
        [UIAlertView bk_showAlertViewWithTitle:@"请选择" message:nil cancelButtonTitle:@"取消" otherButtonTitles:@[@"拍照",@"相册"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex==1) {
                [ws showImagePicker:UIImagePickerControllerSourceTypeCamera];
            }else if(buttonIndex==2){
                [ws showImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
            }
        }];
    }else{
        [self showImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }
}

- (void)showImagePicker:(UIImagePickerControllerSourceType) type{
    
    UIImagePickerController *imagepicker = [[UIImagePickerController alloc] init];
    imagepicker.sourceType = type;
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
                           NSString *head = dict[@"url"];
                           if (head) {
                               blockSelf.headImage = head;
                               [AFNManager postObject:@{@"memberHead":blockSelf.headImage} apiName:@"LoginRegister/ChangeHeadimg" modelName:@"BaseModel" requestSuccessed:^(id responseObject) {
                                   [blockSelf showResultThenHide:@"修改成功"];
                                   [blockSelf refreshUserData];
                               } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                                   [blockSelf showResultThenHide:@"修改失败"];
                               }];
                           }else{
                               [blockSelf showResultThenHide:@"上传失败，请重新尝试"];
                           }
                           NSLog(@"%@",result);
                       } failBlock:^(NSError *error) {
                           [blockSelf showResultThenHide:@"上传失败，请重新尝试"];
                           NSLog(@"%@",error.localizedDescription);
                       } progressBlock:^(CGFloat percent, long long requestDidSendBytes) {
                           NSLog(@"%f",percent);
                       }];
}

- (void)refreshUserData{
    
    WS(ws);
    
    [AFNManager getObject:@{@"memberId":self.user.memberId} apiName:kResPathGetMemberInfo modelName:@"JJMemberModel" requestSuccessed:^(id responseObject) {
        
        [UserManager saveLoginUser:responseObject];
        ws.user = responseObject;
        [ws.tableVIew reloadData];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    //获取图片裁剪的图
    UIImage *editImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (editImage.size.width*editImage.scale>300 || editImage.size.height*editImage.scale>300) {
        self.chooseImage = [self reSizeImage:editImage toSize:CGSizeMake(300, 300)];
    }else{
        self.chooseImage = editImage;
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self uploadImage:editImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize{
    
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
        JJMemberModel *user = self.user;
    if (buttonIndex==0) {
        self.sex = @"男";
        user.sex = self.sex;
    }
    if (buttonIndex==1) {
        self.sex = @"女";
        user.sex = self.sex;
    }
    [[self tableVIew] reloadData];
}
@end
