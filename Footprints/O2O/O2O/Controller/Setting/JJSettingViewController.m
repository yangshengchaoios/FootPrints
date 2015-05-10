//
//  JJSettingViewController.m
//  Footprints
//
//  Created by Jinjin on 14/12/8.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJSettingViewController.h"
#import <SDWebImage/SDImageCache.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <AddressBook/AddressBook.h>
#import "JJEditPasswordController.h"
#import "JJFindPSWViewController.h"
#import "JJAboultViewController.h"
#import "JJBlackListViewController.h"
#import "JJAccountViewController.h"

@interface JJSettingViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *loginOutBtn;
@property (strong, nonatomic) IBOutlet UIButton *backBtn;
@property (strong, nonatomic) IBOutlet UISwitch *friendsSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *autoDownSwitch;

@property (strong, nonatomic) NSArray *titles;
- (IBAction)loginOutBtnDidTap:(id)sender;
- (IBAction)backBtnDidTap:(id)sender;
- (IBAction)switchDidChanged:(id)sender;

@end

@implementation JJSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"设置";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backBtn];
    
    
    self.titles = @[@[@"修改密码",@"更换手机号",@"黑名单"],@[@"清空缓存",@"向我推荐通讯录好友"],@[@"关于"]];
    WS(ws);
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 100, 0);
    self.tableView.contentSize = CGSizeMake(SCREEN_WIDTH, MAX(450, self.view.frame.size.height+1));
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    UIColor *color = RGB(228, 59, 66);
    self.loginOutBtn.layer.cornerRadius = 4;
    self.loginOutBtn.frame = CGRectMake((SCREEN_WIDTH-300)/2, 450, 300, 46);
    self.loginOutBtn.layer.borderColor = color.CGColor;
    self.loginOutBtn.layer.borderWidth = kDefaultBorderWidth;
    self.loginOutBtn.backgroundColor = color;
    [self.tableView addSubview:self.loginOutBtn];

    self.friendsSwitch.center = CGPointMake(SCREEN_WIDTH-35, 22);\
    self.friendsSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"SyncAddressBookFriends"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.loginOutBtn.hidden = ![UserManager isLogin];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginOutBtnDidTap:(id)sender {
    

    [self showResultThenHide:@"已退出登录"];
    [UserManager logOut];
    self.loginOutBtn.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidLoginOut" object:nil userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)backBtnDidTap:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)switchDidChanged:(id)sender {
    
    UISwitch *switcher = (id)sender;
    if (switcher.tag==0) {
        //推荐好友
        if (switcher.isOn) {
            ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
            if (authStatus == kABAuthorizationStatusDenied){
                UIAlertView *av = [[UIAlertView alloc]
                                   initWithTitle:@"授权访问通讯录"
                                   message:@"请到设置>通用>隐私中设置通讯录访问授权."
                                   delegate:nil
                                   cancelButtonTitle:nil
                                   otherButtonTitles:@"好的",nil];
                [av show];
                switcher.on = NO;
            }else{
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SyncAddressBookFriends"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }else{
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"SyncAddressBookFriends"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }else{
        //自动下载
    }
}

#pragma mark - UITableViewDataSource & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger count = 0;
    switch (section) {
        case 0:
            count = 3;
            break;
        case 1:
            count = 2;
            break;
        case 2:
            count = 1;
            break;
            break;
        default:
            break;
    }
    return count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{

    NSString *text = nil;
    if (section==1) {
        text = @"开启后，为你推荐已经开通微秀的手机联系人";
    }
    return text;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.titles[indexPath.section][indexPath.row];
    if (indexPath.section==1) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = indexPath.row==1?UITableViewCellSelectionStyleNone:UITableViewCellSelectionStyleDefault;
        if (indexPath.row==1) {
            [cell addSubview:self.friendsSwitch];
        }
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section==0 && (indexPath.row==1 || indexPath.row==0) && ![UserManager isLogin]) {
        JJAccountViewController *account = [[JJAccountViewController alloc] initWithNibName:@"JJAccountViewController" bundle:nil];
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:account];
        [self presentViewController:navi animated:YES completion:^{
            
        }];
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
            if (indexPath.row==0) {
                
                //修改密码
                JJEditPasswordController *editPass = [[JJEditPasswordController alloc] initWithNibName:@"JJEditPasswordController" bundle:nil];
                [self.navigationController pushViewController:editPass animated:YES];
            }else if (indexPath.row==1) {
                //更换手机号
                JJFindPSWViewController *editPhone = [[JJFindPSWViewController alloc] initWithNibName:@"JJFindPSWViewController" bundle:nil];
                editPhone.isModifyPhone = YES;
                [self.navigationController pushViewController:editPhone animated:YES];
            }else if (indexPath.row==2) {
                //黑名单
                JJBlackListViewController *blackList = [[JJBlackListViewController alloc] initWithNibName:@"JJBlackListViewController" bundle:nil];
                [self.navigationController pushViewController:blackList animated:YES];
            }
            break;
        case 1:
            if (indexPath.row==0) {
                //清空缓存
                [self cleanDisk];
            }
            break;
        case 2:
            //关于
        {
            
            JJAboultViewController *aboult = [[JJAboultViewController alloc] initWithNibName:@"JJAboultViewController" bundle:nil];
            [self.navigationController pushViewController:aboult animated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)cleanDisk{

    [self showHUDLoadingWithString:@"清理中.."];
    WS(ws);
    [[SDImageCache sharedImageCache] cleanDiskWithCompletionBlock:^{
        [ws showResultThenHide:@"清理完成"];
    }];
}

@end
