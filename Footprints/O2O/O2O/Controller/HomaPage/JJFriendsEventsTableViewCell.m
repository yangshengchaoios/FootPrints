//
//  JJFriendsEventsTableViewCell.m
//  Footprints
//
//  Created by Jinjin on 14/11/13.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJFriendsEventsTableViewCell.h"

@implementation JJFriendsEventsTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.messageCountLabel.hidden = YES;
    self.messageCountLabel.clipsToBounds = YES;
    self.messageCountLabel.layer.cornerRadius = CGRectGetHeight(self.messageCountLabel.frame)/2;
    
    self.nameLabel.textColor = kDefaultNaviBarColor;
    
    self.avatarVIew.clipsToBounds = YES;
    self.avatarVIew.layer.cornerRadius = CGRectGetHeight(self.avatarVIew.frame)/2;
    
    WS(ws);
    self.realContentView.clipsToBounds = YES;
    self.realContentView.layer.borderWidth = 0.5;
    self.realContentView.layer.borderColor = kDefaultBorderColor.CGColor;
    self.realContentView.layer.cornerRadius = 4;
    [self.realContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.contentView);
    }];
}

- (void)setMessageCount:(NSInteger)count{
    
    NSString *countStr = [NSString stringWithFormat:@"%ld",(long)count];
    if (count>99) {
        countStr = @"99+";
    }
    
    self.messageCountLabel.text = countStr;
    self.messageCountLabel.hidden = count?NO:YES;
    
    CGSize countSize = [countStr boundingRectWithSize:CGSizeMake(100, CGRectGetHeight(self.messageCountLabel.frame)) options:NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:self.messageCountLabel.font} context:nil].size;
    
    self.messageCountLabel.frame = CGRectMake(0, 0, MAX(countSize.width+CGRectGetHeight(self.messageCountLabel.frame)/2, CGRectGetHeight(self.messageCountLabel.frame)), CGRectGetHeight(self.messageCountLabel.frame));
    self.messageCountLabel.center = CGPointMake(12, 14);
}
@end
