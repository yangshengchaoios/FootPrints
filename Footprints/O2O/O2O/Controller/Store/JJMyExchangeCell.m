//
//  JJMyExchangeCell.m
//  Footprints
//
//  Created by Jinjin on 14/12/3.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJMyExchangeCell.h"

@implementation JJMyExchangeCell

- (void)awakeFromNib {
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.costPointLabel.textColor = [UIColor redColor];
    self.backgroundColor = [UIColor clearColor];
    
    WS(ws);
//    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(ws);
//        make.left.mas_equalTo(ws).with.offset(30);
//        make.bottom.mas_equalTo(ws);
//        make.width.mas_equalTo(@10);
//    }];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws).insets(UIEdgeInsetsMake(27, 25, 3, 25));
    }];
    self.bgView.layer.cornerRadius = 4;
    self.bgView.backgroundColor = [UIColor whiteColor];
    self.bgView.layer.borderColor = kDefaultBorderColor.CGColor;
    self.bgView.layer.borderWidth = kDefaultBorderWidth;
    
    
    [self.exchangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws).with.offset(3);
        make.left.mas_equalTo(@25);
        make.height.mas_equalTo(@24);
        make.width.mas_equalTo(@200);
    }];
    
    self.iconView.layer.cornerRadius = 4;
    self.iconView.clipsToBounds = YES;
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws).with.offset(34);
        make.left.mas_equalTo(ws).with.offset(34);
        make.size.mas_equalTo(CGSizeMake(110, 66));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws).with.offset(47);
        make.left.mas_equalTo(ws.iconView.mas_right).with.offset(16);
        make.right.mas_equalTo(ws).with.offset(-(25+10));
        make.height.mas_equalTo(@20);
    }];
    [self.costPointLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.nameLabel.mas_bottom);
        make.left.mas_equalTo(ws.iconView.mas_right).with.offset(16);
        make.right.mas_equalTo(ws).with.offset(-(25+10));
        make.height.mas_equalTo(@20);
    }];
    self.nameLabel.textColor = RGB(120, 120, 120);
    self.costPointLabel.textColor = RGB(120, 120, 120);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
