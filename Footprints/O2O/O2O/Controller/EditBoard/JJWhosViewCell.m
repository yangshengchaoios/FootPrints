//
//  JJWhosViewCell.m
//  Footprints
//
//  Created by Jinjin on 15/1/12.
//  Copyright (c) 2015年 JiaJun. All rights reserved.
//

#import "JJWhosViewCell.h"

@implementation JJWhosViewCell

- (void)awakeFromNib {
    // Initialization code
    WS(ws);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    //    self.avatarView.layer.cornerRadius = 20;
    self.chooseBtn.userInteractionEnabled = NO;
    
    [self.chooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws);
        make.right.mas_equalTo(ws).with.offset(-5);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}

- (void)setDetailModel:(BOOL)isShowDetail{

    WS(ws);
    self.detaiTextLabel.hidden = !isShowDetail;
    self.nameLabel.font = isShowDetail?[UIFont systemFontOfSize:14]:[UIFont systemFontOfSize:17];
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(ws.chooseBtn).with.offset(-10);
        if (isShowDetail) {
            make.top.mas_equalTo(ws).with.offset(4);
        }else{
            make.centerY.mas_equalTo(ws);
        }
        make.left.mas_equalTo(@15);
    }];
    
    [self.detaiTextLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(ws.chooseBtn).with.offset(-10);
        make.height.mas_equalTo(@20);
        make.left.mas_equalTo(@15);
        make.top.mas_equalTo(@23);
    }];
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

- (void)setChoosed:(BOOL)choosed{
    
    _choosed = choosed;
    self.chooseBtn.selected = choosed;
}

@end
