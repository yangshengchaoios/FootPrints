//
//  JJFriendsCell.m
//  Footprints
//
//  Created by Jinjin on 14/11/20.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJFriendsCell.h"

@implementation JJFriendsCell

- (void)awakeFromNib {
    // Initialization code]
    self.countLabel.layer.cornerRadius = CGRectGetHeight(self.countLabel.frame)/2;
    
    self.avatarView.iconView.frame = CGRectMake(0, 0, 14, 14);
    self.avatarView.avatarView.layer.cornerRadius = CGRectGetHeight(self.avatarView.frame)/2;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    WS(ws);
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@4);
        make.left.mas_equalTo(@50);
        make.right.mas_equalTo(ws.mas_right).with.offset(-14);
        make.height.mas_equalTo(@20);
    }];
    self.summryLabel.frame = CGRectMake(50, 22, SCREEN_WIDTH-50-44, 20);
    self.summryLabel.textColor = RGB(99, 99, 99);
   
    
    [self showBottomLine:YES withInset:UIEdgeInsetsMake(0, 9, 0, 0)];
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

- (void)setCount:(NSInteger)count{
    
    NSString *countStr = [NSString stringWithFormat:@"%ld",(long)count];
    if (count>99) {
        countStr = @"99+";
    }
    
    self.countLabel.text = countStr;
    self.countLabel.hidden = count?NO:YES;
    
    CGSize countSize = [countStr boundingRectWithSize:CGSizeMake(100, CGRectGetHeight(self.countLabel.frame)) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:self.countLabel.font} context:nil].size;
    
    self.countLabel.frame = CGRectMake(0, 0, MAX(countSize.width+CGRectGetHeight(self.countLabel.frame)/2, CGRectGetHeight(self.countLabel.frame)), CGRectGetHeight(self.countLabel.frame));
    self.countLabel.center = CGPointMake(CGRectGetWidth(self.frame)-10-CGRectGetWidth(self.countLabel.frame)/2, CGRectGetHeight(self.frame)/2);
}

@end
