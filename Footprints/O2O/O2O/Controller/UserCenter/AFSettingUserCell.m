//
//  AFSettingUserCell.m
//  Whatstock
//
//  Created by Jinjin on 14/12/14.
//  Copyright (c) 2014年 AnnyFun. All rights reserved.
//

#import "AFSettingUserCell.h"

@implementation AFSettingUserCell
- (void)dealloc
{
    NSLog(@"AFSettingUserCell dealloc");
}

- (void)awakeFromNib {
    // Initialization code
    self.avatarView.layer.cornerRadius = 56/2;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    WS(ws);
    CGFloat left = self.separatorInset.left;
    [self.avatarBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws);
        make.right.mas_equalTo(ws).with.offset(-40);
        make.size.mas_equalTo(CGSizeMake(56, 56));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@(left)).offset(12);
        make.top.mas_equalTo(ws);
        make.bottom.mas_equalTo(ws);
        make.width.mas_equalTo(@80);
    }];
    
    [self.inputField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.nameLabel.mas_right).offset(12);
        make.top.mas_equalTo(ws);
        make.bottom.mas_equalTo(ws);
        make.right.mas_equalTo(ws).with.offset(-30);
    }];
    
    
    [self.checkBoxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.nameLabel.mas_right).offset(12);
        make.centerY.mas_equalTo(ws);
        make.size.mas_equalTo(CGSizeMake(100, 40));
     }];
}

- (IBAction)sexBtnDidTap:(UIButton *)sender {

    sender.selected = YES;
//    if (sender==self.maleBox) {
//        self.femaleBox.selected = NO;
//        self.sexTap(1);
//    }
//    if (sender==self.femaleBox) {
//        self.maleBox.selected = NO;
//        self.sexTap(2);
//    }
}

- (IBAction)avatarBtnDidTap:(id)sender{
    
    if (self.avatarTap) {
        self.avatarTap(self);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showBottomLine:(BOOL)show withInset:(UIEdgeInsets)inset withHeight:(CGFloat)height{
    
    UIView *line = [self viewWithTag:1001];
    if (nil==line) {
        line = [[UIView alloc] initWithFrame:CGRectMake(9, 44, SCREEN_WIDTH, kDefaultBorderWidth)];
        line.backgroundColor = kDefaultLineColor;
        line.tag = 1001;
        line.autoresizingMask = UIViewAutoresizingNone;
        [self addSubview:line];
    }
    
    CGFloat top = height;
    [line mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@(0+inset.left));
        make.top.mas_equalTo(@(top+inset.top));
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 1));
    }];
    line.hidden = !show;
}

- (void)showTopLine:(BOOL)show withInset:(UIEdgeInsets)inset{
    
    
    UIView *line = [self viewWithTag:1002];
    if (nil==line) {
        line = [[UIView alloc] initWithFrame:CGRectMake(9, 44, SCREEN_WIDTH, kDefaultBorderWidth)];
        line.backgroundColor = kDefaultLineColor;
        line.tag = 1002;
        [self addSubview:line];
    }
    [line mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@(0+inset.left));
        make.top.mas_equalTo(@(inset.top));
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 1));
    }];
    line.hidden = !show;
}
@end
