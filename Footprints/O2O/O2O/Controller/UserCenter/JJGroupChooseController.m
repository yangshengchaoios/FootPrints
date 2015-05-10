//
//  JJGroupChooseController.m
//  Footprints
//
//  Created by Jinjin on 14/12/5.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJGroupChooseController.h"

#define kGroupBorderColor RGB(107, 183, 255)
#define kGroupItemHeight 26
#define kGroupItemY (60-kGroupItemHeight)/2

@interface JJGroupChooseController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *addNewView;
@property (weak, nonatomic) IBOutlet UITextField *addNewField;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSMutableArray *groupViews;
@property (weak, nonatomic) IBOutlet UIScrollView *groupContent;
@property (weak, nonatomic) IBOutlet UILabel *choosedLabel;
- (IBAction)doneBtnDidTap:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *done;
@property (assign, nonatomic) NSInteger lastIndex;
@property (nonatomic,strong)MemberGroupModel *model;
@end

@implementation JJGroupChooseController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    self.title = @"添加标签";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.done];
    
    self.choosedLabel.text = self.groupName;
    self.choosedLabel.hidden = self.groupName==nil;
    self.choosedLabel.layer.borderColor = kGroupBorderColor.CGColor;
    self.choosedLabel.backgroundColor = kGroupBorderColor;
    self.choosedLabel.layer.borderWidth = kDefaultBorderWidth;
    self.choosedLabel.layer.cornerRadius = kGroupItemHeight/2;
    
    self.addNewField.returnKeyType = UIReturnKeyDone;
    

    [self resetTopLabelFrame];
    
    self.addNewView.layer.cornerRadius = kGroupItemHeight/2;
    self.addNewView.layer.borderWidth = kDefaultBorderWidth;
    self.addNewView.layer.borderColor = kGroupBorderColor.CGColor;
    self.addNewField.delegate = self;
    self.addNewField.textColor = [UIColor blackColor];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.addNewView.superview.frame.size.height-1, SCREEN_WIDTH, kDefaultBorderWidth)];
    line.backgroundColor = kDefaultLineColor;
    [self.addNewView.superview addSubview:line];
    
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

- (void)reload{

    for (UIView *view in self.groupViews) {
        [view removeFromSuperview];
    }
    
    WS(ws);
    self.groupViews = [@[] mutableCopy];
    CGFloat offset = 10;
    NSInteger count = 4;
    CGFloat width = (SCREEN_WIDTH-(count+1)*offset)/count;
    BOOL hasNew = YES;
    for (MemberGroupModel *model in self.dataSource) {
    
        NSInteger index = [self.dataSource indexOfObject:model];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:model.groupName forState:UIControlStateNormal];
        btn.tag = index;
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn setTitleColor:RGB(121, 121, 121) forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        btn.layer.borderWidth = kDefaultBorderWidth;
        btn.clipsToBounds = YES;
        btn.layer.cornerRadius = kGroupItemHeight/2;
        btn.layer.borderColor = RGB(121, 121, 121).CGColor;
        [btn addTarget:self action:@selector(didChoose:) forControlEvents:UIControlEventTouchUpInside];
        [self.groupContent addSubview:btn];
        [self.groupViews addObject:btn];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.groupContent).with.offset((index/count)*(30+offset));
            make.left.mas_equalTo(ws.groupContent).with.offset(offset+(index%count)*(width+offset));
            make.size.mas_equalTo(CGSizeMake(width, kGroupItemHeight));
        }];
    
        if ([self.groupId isEqualToString:model.groupId] || [self.groupName isEqualToString:model.groupName]) {
            btn.selected = YES;
            hasNew = NO;
            btn.layer.borderColor = kGroupBorderColor.CGColor;
            btn.backgroundColor = kGroupBorderColor;
            self.lastIndex = index;
        }
    }
    
    if (hasNew && self.groupName) {
        [self addNewModelForString:self.groupName];
    }
}

- (void)didChoose:(UIButton *)btn{
    
    UIButton *lastBtn = self.groupViews[self.lastIndex];
    lastBtn.selected = NO;
    lastBtn.layer.borderColor = RGB(121, 121, 121).CGColor;
    lastBtn.backgroundColor = [UIColor clearColor];
    
    btn.selected = YES;
    btn.layer.borderColor = kGroupBorderColor.CGColor;
    btn.backgroundColor = kGroupBorderColor;
    
    MemberGroupModel *model = self.dataSource[btn.tag];
    self.model = model;
    self.lastIndex = btn.tag;
    
    self.choosedLabel.text = model.groupName;
    self.choosedLabel.hidden = NO;
    [self resetTopLabelFrame];
}

-(CGFloat)textWidthWithFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode forStr:(NSString *)str{
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize constraint = CGSizeMake(MAXFLOAT, MAXFLOAT);
    CGSize size = [str boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading  attributes:attributes context:nil].size;
    CGFloat height = ceilf(size.width);
    return height;
}


- (void)refresh{
    
    WS(ws);
    [AFNManager getObject:nil
                  apiName:@"MemberCenter/GetMemberGroups"
                modelName:@"MemberGroupModel"
         requestSuccessed:^(id responseObject) {
             ws.dataSource = [responseObject mutableCopy];
             [ws reload];
         } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
         
             [ws showResultThenBack:@"获取分组失败"];
         }];
}
- (IBAction)doneBtnDidTap:(id)sender {
    
    if (self.didChoose) {
        self.didChoose(self.model);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{

    if (![StringUtils isEmpty:textField.text]) {
        
        BOOL canadd = YES;
        for (MemberGroupModel *model in self.dataSource) {
            
            if ([textField.text isEqualToString:model.groupName]) {
                canadd = NO;
                break;
            }
        }
        if (canadd) {
            [self addNewModelForString:textField.text];
            textField.text = nil;
        }else{
        
            [UIAlertView bk_alertViewWithTitle:@"标签已经存在了"];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    [self.addNewField resignFirstResponder];
    return YES;
}

- (void)addNewModelForString:(NSString *)str{

    MemberGroupModel *model = [[MemberGroupModel alloc] init];
    model.groupName = str;
    self.groupName = str;
    self.groupId = nil;
    [self.dataSource addObject:model];
    [self reload];
    
    
    UIButton *lastBtn = self.groupViews[self.lastIndex];
    lastBtn.selected = NO;
    lastBtn.layer.borderColor = RGB(121, 121, 121).CGColor;
    lastBtn.backgroundColor = [UIColor clearColor];
    
    self.lastIndex = self.dataSource.count-1;
    UIButton *btn = self.groupViews[self.lastIndex];
    btn.selected = YES;
    
    btn.layer.borderColor = kGroupBorderColor.CGColor;
    btn.backgroundColor = kGroupBorderColor;
    self.model = model;
    
    self.choosedLabel.text = model.groupName;
    
    [self resetTopLabelFrame];
}

- (void)resetTopLabelFrame{

    CGFloat widht = [self textWidthWithFont:self.choosedLabel.font lineBreakMode:self.choosedLabel.lineBreakMode forStr:self.choosedLabel.text];
    self.choosedLabel.frame = CGRectMake(8, kGroupItemY, widht+16, kGroupItemHeight);
    
    CGFloat xOffset = ([StringUtils isEmpty:self.choosedLabel.text])?8:(CGRectGetMaxX(self.choosedLabel.frame)+10);
    self.addNewView.frame = CGRectMake(xOffset , kGroupItemY, 81, kGroupItemHeight);
}
@end
