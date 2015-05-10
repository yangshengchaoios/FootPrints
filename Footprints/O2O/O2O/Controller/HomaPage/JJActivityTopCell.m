//
//  JJActivityTopCell.m
//  Footprints
//
//  Created by Jinjin on 14/11/17.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJActivityTopCell.h"

@implementation JJActivityTopCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    WS(ws);
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.contentView).with.insets(UIEdgeInsetsMake(0, 0, 10, 0));
    }];
    
    [self.startLabel.superview mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.width.mas_equalTo(ws.contentView);
        make.bottom.mas_equalTo(ws.contentView).with.offset(-10);
        make.height.mas_equalTo(@25);
    }];
    
    [self.startLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.startLabel.superview).with.insets(UIEdgeInsetsMake(0, 10, 0, 0));
    }];
    [self.countDownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.startLabel.superview).with.insets(UIEdgeInsetsMake(0, 0, 0, 10));;
    }];
    
    self.backgroundColor = kDefaultViewColor;
    self.bgImageView.backgroundColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
