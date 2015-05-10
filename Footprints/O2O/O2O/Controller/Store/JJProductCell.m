//
//  JJProductCell.m
//  Footprints
//
//  Created by Jinjin on 14/12/3.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJProductCell.h"


#define BottomPadding 10
#define Padding  10

@implementation JJProductCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;

 
    WS(ws);
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.realCotent.backgroundColor = [UIColor whiteColor];
    self.realCotent.layer.borderWidth = kDefaultBorderWidth;
    self.realCotent.clipsToBounds = YES;
    self.realCotent.layer.borderColor = kDefaultBorderColor.CGColor;
    [self.realCotent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws).with.insets(UIEdgeInsetsMake(0, 8, BottomPadding, 8));
    }];
    
    [self.avatarLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.realCotent).with.offset(12);
        make.left.mas_equalTo(ws.realCotent).with.offset(10);
        make.size.mas_equalTo(CGSizeMake(110, 65));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@10);
        make.left.mas_equalTo(ws.avatarLabel.mas_right).with.offset(15);
        make.height.mas_equalTo(@20);
        make.right.mas_equalTo(ws.realCotent).with.offset(-15);
    }];
    
    self.jifenLabel.textColor = [UIColor redColor];
    [self.jifenLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.nameLabel.mas_bottom);
        make.left.mas_equalTo(ws.nameLabel);
        make.height.mas_equalTo(@20);
        make.right.mas_equalTo(ws.nameLabel);
    }];
    
    [self.exchangeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.jifenLabel.mas_bottom).with.offset(5);
        make.centerX.mas_equalTo(ws.jifenLabel);
        make.size.mas_equalTo(CGSizeMake(92, 33));
    }];
    
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.avatarLabel.mas_bottom);
        make.centerX.mas_equalTo(ws.avatarLabel);
        make.width.mas_equalTo(ws.avatarLabel);
        make.height.mas_equalTo(@20);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)exchangeBtnDidTap:(id)sender {

    if (self.exChangeBlock) {
        self.exChangeBlock(self.model);
    }
}
@end
