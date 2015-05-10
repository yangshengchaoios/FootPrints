//
//  JJAddressCell.m
//  Footprints
//
//  Created by Jinjin on 14/11/24.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJAddressCell.h"

@implementation JJAddressCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.actionBtn setTitle:nil forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)actionBtnDidTap:(id)sender {
    if (self.block) {
        self.block(self.status,self.friendMemberId,self.phone);
    }
}


- (void)setStatus:(AddressFriendsStatus)status{
    
    _status = status;
    self.actionBtn.enabled = NO;
    UIImage *img = nil;
    switch (status) {
        case AddressFriendsStatuRegister:
            img = [UIImage imageNamed:@"attention.png"];
            self.actionBtn.enabled = YES;
            break;
        case AddressFriendsStatusFriend:
            img = [UIImage imageNamed:@"already_attention.png"];
            self.actionBtn.enabled = NO;
            break;
        case AddressFriendsStatusNotRegister:
            img = [UIImage imageNamed:@"invite.png"];
            self.actionBtn.enabled = YES;
            break;
        default:
            break;
    }
    [self.actionBtn setImage:img forState:UIControlStateNormal];
}
@end
