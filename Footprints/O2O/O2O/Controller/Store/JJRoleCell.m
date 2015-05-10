//
//  JJRoleCell.m
//  Footprints
//
//  Created by Jinjin on 14/12/3.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJRoleCell.h"

@implementation JJRoleCell

- (void)awakeFromNib {
    // Initialization code

    self.selectionStyle = UITableViewCellSelectionStyleNone;

    self.scoreLabel.textColor = [UIColor redColor];
    
    WS(ws);
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@7);
        make.left.mas_equalTo(@15);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.iconImageView.mas_right).with.offset(15);
        make.right.mas_equalTo(ws).with.offset(-65);;
        make.height.mas_equalTo(@20);
        make.centerY.mas_equalTo(ws);
    }];
    [self.scoreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.iconImageView.mas_right).with.offset(5);
        make.right.mas_equalTo(ws).with.offset(-10);;
        make.height.mas_equalTo(@20);
        make.centerY.mas_equalTo(ws);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
