//
//  JJExchangeViewController.m
//  Footprints
//
//  Created by Jinjin on 14/12/3.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJExchangeViewController.h"

#define kFieldWidth (SCREEN_WIDTH-50)
#define kFieldHeigh 35
#define kFieldPadding 10

@interface JJExchangeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageVIew;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *ensurePhoneField;
@property (weak, nonatomic) IBOutlet UITextField *wangwangField;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIButton *postBtn;

@end

@implementation JJExchangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view from its nib.
    self.model = self.model;
    self.hidesBottomBarWhenPushed = YES;
    self.title = @"积分兑换";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setModel:(GiftProductModel *)model{

    _model = model;
    self.ensurePhoneField.hidden = YES;
    self.wangwangField.hidden = YES;
    self.addressField.hidden = YES;
    self.nameField.hidden = YES;
    self.phoneField.hidden = NO;
    
    [self.iconImageVIew setImageWithURLString:self.model.giftImage placeholderImage:nil];
    
    WS(ws);
   
    
    [self.iconImageVIew mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.view).with.offset(18);
        make.centerX.mas_equalTo(ws.view);
        make.size.mas_equalTo(CGSizeMake(304, 138));
    }];
    
    CGFloat offset = kFieldPadding;
    switch (model.giftType) {
        case GiftTypeHuaFei:
        {
            self.ensurePhoneField.hidden = NO;
            [self.phoneField mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(ws.iconImageVIew.mas_bottom).with.offset(34);
                make.centerX.mas_equalTo(ws.view);
                make.size.mas_equalTo(CGSizeMake(kFieldWidth, kFieldHeigh));
            }];
            [self.ensurePhoneField mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(ws.iconImageVIew.mas_bottom).with.offset(34+kFieldHeigh+kFieldPadding);
                make.centerX.mas_equalTo(ws.view);
                make.size.mas_equalTo(CGSizeMake(kFieldWidth, kFieldHeigh));
            }];
            offset = 34+kFieldHeigh+kFieldPadding+kFieldHeigh+15;
        }
            break;
        case GiftTypeYouHuiQuan:
        {
            self.wangwangField.hidden = NO;
            [self.wangwangField mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(ws.iconImageVIew.mas_bottom).with.offset(34);
                make.centerX.mas_equalTo(ws.view);
                make.size.mas_equalTo(CGSizeMake(kFieldWidth, kFieldHeigh));
            }];
            [self.phoneField mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(ws.iconImageVIew.mas_bottom).with.offset(34+kFieldHeigh+kFieldPadding);
                make.centerX.mas_equalTo(ws.view);
                make.size.mas_equalTo(CGSizeMake(kFieldWidth, kFieldHeigh));
            }];
            
            offset = 34+kFieldHeigh+kFieldPadding+kFieldHeigh+15;
        }
            break;
        case GiftTypeShiWu:
        {
            self.nameField.hidden = NO;
            self.addressField.hidden = NO;
            [self.addressField mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(ws.iconImageVIew.mas_bottom).with.offset(34);
                make.centerX.mas_equalTo(ws.view);
                make.size.mas_equalTo(CGSizeMake(kFieldWidth, kFieldHeigh));
            }];
            [self.phoneField mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(ws.iconImageVIew.mas_bottom).with.offset(34+kFieldHeigh+kFieldPadding);
                make.centerX.mas_equalTo(ws.view);
                make.size.mas_equalTo(CGSizeMake(kFieldWidth, kFieldHeigh));
            }];
            
            [self.nameField mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(ws.iconImageVIew.mas_bottom).with.offset(34+kFieldHeigh+kFieldPadding+kFieldHeigh+kFieldPadding);
                make.centerX.mas_equalTo(ws.view);
                make.size.mas_equalTo(CGSizeMake(kFieldWidth, kFieldHeigh));
            }];
            
            offset = 34+kFieldHeigh+kFieldPadding+kFieldHeigh+kFieldPadding+kFieldHeigh+15;
        }
            break;
            
        default:
            break;
    }
    
    [self.postBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.iconImageVIew.mas_bottom).with.offset(offset);
        make.centerX.mas_equalTo(ws.view);
        make.size.mas_equalTo(CGSizeMake(kFieldWidth, kFieldHeigh));
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

- (IBAction)postBtnDidTap:(id)sender {
    
    NSString *phone = [self.phoneField text];
    
    NSString *ensurePhone = [self.ensurePhoneField text];
    NSString *giftId = self.model.giftId;
    NSString *accountId = self.wangwangField.text;
    NSString *adress = self.addressField.text;
    NSString *trueName = self.nameField.text;
    
    if (giftId) {
        
        if (![StringUtils isMobilePhone:phone]) {
            [self showResultThenHide:@"请输入正确的手机号码"];
            return;
        }
        
        if (self.model.giftType == GiftTypeHuaFei && ![ensurePhone isEqualToString:phone]) {
            [self showResultThenHide:@"手机号不一致"];
            return;
        }
        
        if (self.model.giftType == GiftTypeYouHuiQuan && [StringUtils isEmpty:accountId]) {
            [self showResultThenHide:@"请输入旺旺ID"];
            return;
        }
        
        if (self.model.giftType == GiftTypeShiWu && [StringUtils isEmpty:adress]) {
            [self showResultThenHide:@"请输入地址"];
            return;
        }
        
        if (self.model.giftType == GiftTypeShiWu && [StringUtils isEmpty:trueName]) {
            [self showResultThenHide:@"请输入姓名"];
            return;
        }
        
        
        WS(ws);
        [UIAlertView bk_showAlertViewWithTitle:@"确认兑换？" message:nil cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex==1) {
                [ws showHUDLoadingWithString:@"兑换中.."];
                NSMutableDictionary *dict = [@{} mutableCopy];
                if (phone) [dict setObject:phone forKey:@"phone"];
                if (giftId) [dict setObject:giftId forKey:@"giftId"];
                if (![StringUtils isEmpty:accountId]) [dict setObject:accountId forKey:@"accountId"];
                if (![StringUtils isEmpty:adress]) [dict setObject:adress forKey:@"adress"];
                if (![StringUtils isEmpty:trueName]) [dict setObject:trueName forKey:@"trueName"];
                [AFNManager postObject:dict apiName:@"MemberCenter/ExchangeProduct" modelName:nil requestSuccessed:^(id responseObject) {
                    [ws showResultThenBack:@"兑换成功"];
                } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
                    [ws showResultThenHide:errorMessage?:@"兑换失败"];
                }];
            }
        }];
    }
}
@end
