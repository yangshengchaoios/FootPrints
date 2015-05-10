//
//  JJGroupCell.m
//  Footprints
//
//  Created by Jinjin on 14/12/1.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJGroupCell.h"

@implementation JJGroupCell

- (void)awakeFromNib {
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    WS(ws);
    
    [self.groupNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws).with.offset(15);
        make.width.mas_equalTo(@(SCREEN_WIDTH *0.5));
        make.centerY.mas_equalTo(ws);
    }];
    
    
    [self.groupMenberModel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(ws).with.offset(-10);
        make.left.mas_equalTo(ws.groupNameLabel.mas_right).with.offset(10);
        make.centerY.mas_equalTo(ws);
    }];
    self.groupMenberModel.textColor = RGB(99, 99, 99);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showBottomLine:(BOOL)show withInset:(UIEdgeInsets)inset{
    
    UIView *line = [self viewWithTag:1001];
    if (nil==line) {
        line = [[UIView alloc] initWithFrame:CGRectMake(9, 44, SCREEN_WIDTH, kDefaultBorderWidth)];
        line.backgroundColor = kDefaultLineColor;
        line.tag = 1001;
        line.autoresizingMask = UIViewAutoresizingNone;
        [self addSubview:line];
    }
    
    CGFloat top = self.frame.size.height-1;
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
