//
//  JJAddFriendsCell.m
//  Footprints
//
//  Created by Jinjin on 14/11/20.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJAddFriendsCell.h"

@implementation JJAddFriendsCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.cellStyle = AddFriendsCellStyleNormal;
    [self.statusBtn setTitle:nil forState:UIControlStateNormal];

    self.avatarView.iconView.frame = CGRectMake(0, 0, 14, 14);
    self.avatarView.avatarView.layer.cornerRadius = CGRectGetHeight(self.avatarView.frame)/2;
    
    
    WS(ws);
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@4);
        make.left.mas_equalTo(@50);
        make.right.mas_equalTo(ws.mas_right).with.offset(-54);
        make.height.mas_equalTo(@20);
    }];
    
    [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@4);
        make.width.mas_equalTo(@100);
        make.right.mas_equalTo(ws.mas_right).with.offset(-44);
        make.height.mas_equalTo(@20);
    }];
    
    
    self.summryLabel.frame = CGRectMake(50, 22, SCREEN_WIDTH-50-44, 20);
    self.summryLabel.textColor = RGB(99, 99, 99);
    
    [self showBottomLine:YES withInset:UIEdgeInsetsMake(0, 9, 0, 0)];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)statusBtnDidTap:(id)sender {

    if (self.addBlock) {
        self.addBlock(self.cellStyle!=AddFriendsCellStyleDidAdd,self.friendMemberId);
    }
}

- (void)setCellStyle:(AddFriendsCellStyle)cellStyle{
    
    _cellStyle = cellStyle;
    self.statusBtn.hidden = NO;
    self.statusBtn.userInteractionEnabled = YES;
    NSString *title = nil;
    UIImage *img = nil;
    switch (cellStyle) {
        case AddFriendsCellStyleNormal:
            self.statusBtn.userInteractionEnabled = NO;
            self.statusBtn.hidden = YES;
            break;
        case AddFriendsCellStyleAdd:
            title = @"未关注";
            img = [UIImage imageNamed:@"add_friend.png"];
            break;
        case AddFriendsCellStyleDidAdd:
            
            title = @"已关注";
            img = [UIImage imageNamed:@"and_add.png"];
            break;
        case AddFriendsCellStyleSingleAdd:
            img = [UIImage imageNamed:@"icon_unidirectional_concern.png"];
            self.statusBtn.userInteractionEnabled = NO;
            break;
        case AddFriendsCellStyleBothAdd:
            img = [UIImage imageNamed:@"icon_bidirectional_concern.png"];
            self.statusBtn.userInteractionEnabled = NO;
            break;
        default:
            break;
    }
    [self.statusBtn setImage:img forState:UIControlStateNormal];
}
@end
