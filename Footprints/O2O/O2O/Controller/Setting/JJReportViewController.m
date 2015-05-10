//
//  JJReportViewController.m
//  Footprints
//
//  Created by Jinjin on 14/12/12.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJReportViewController.h"

@interface JJReportViewController ()<UITextViewDelegate>
- (IBAction)postBtnDidTap:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *postBtn;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@end

@implementation JJReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    WS(ws);
    
    CGFloat padding = -5;
    CGFloat yOffset = 10;
    CGFloat xOffset = 5;
    
    CGFloat height = SCREEN_HEIGHT>500?140:100;
    [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-((xOffset-padding)*2), height));
        make.top.mas_equalTo(@(yOffset-padding));
        make.left.mas_equalTo(@(xOffset-padding));
    }];
    
    [self.bgImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.textView).with.insets(UIEdgeInsetsMake(padding, padding, padding, padding));
    }];
    self.bgImageView.layer.borderWidth = kDefaultBorderWidth;
    self.bgImageView.layer.borderColor = kDefaultBorderColor.CGColor;
 
    [self.countLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.bgImageView.mas_bottom).with.offset(5);
        make.right.mas_equalTo(ws.bgImageView);
        make.size.mas_equalTo(CGSizeMake(200, 20));
    }];
    
    [self.postBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.countLabel.mas_bottom).with.offset(10);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH-48, 40));
        make.left.mas_equalTo(@(24));
    }];
    
    self.title = @"意见反馈";
    self.textView.text = nil;
    self.textView.delegate = self;
    self.countLabel.text = @"您还可以输入50字";
    
//    self.postBtn.backgroundColor = kDefaultBorderColor;
//    self.postBtn.clipsToBounds = YES;
//    self.postBtn.layer.cornerRadius = 6;
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

- (IBAction)postBtnDidTap:(id)sender {
    
    NSString *postText = self.textView.text;
    if ([StringUtils isEmpty:postText]) {
        [self showResultThenHide:@"请先输入内容"];
        return;
    }
    
    [self showHUDLoadingWithString:@"提交中"];
    WS(ws);
    [AFNManager postObject:@{@"feedContent":postText} apiName:@"MemberCenter/AddFeedBack" modelName:@"BaseModel" requestSuccessed:^(id responseObject) {
        [ws showResultThenBack:@"已经收到了您的反馈"];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        [ws showResultThenHide:errorMessage?:@"反馈失败"];
    }];
}

- (void)textViewDidChange:(UITextView *)textView{
     self.countLabel.text = [NSString stringWithFormat:@"您还可以输入%ld字",(long)(50-textView.text.length)];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ((text.length+textView.text.length-range.length)>50) {
        return NO;
    }
    else{
   
        return YES;
    }
}
@end
