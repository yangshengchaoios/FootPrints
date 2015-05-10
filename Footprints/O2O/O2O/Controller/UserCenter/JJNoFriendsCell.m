//
//  JJNoFriendsCell.m
//  Footprints
//
//  Created by Jinjin on 14/11/20.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJNoFriendsCell.h"

@implementation JJNoFriendsCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = RGB(236, 235, 235);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.noLabel.frame = CGRectMake(5, 7, SCREEN_WIDTH-10, 44);
    self.noLabel.layer.borderColor = kDefaultBorderColor.CGColor;
    self.noLabel.layer.borderWidth = kDefaultBorderWidth;
    self.noLabel.textColor = RGB(99, 99, 99);
    self.noLabel.backgroundColor = [UIColor whiteColor];
    self.noLabel.text = @"  暂时没有新粉丝";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
