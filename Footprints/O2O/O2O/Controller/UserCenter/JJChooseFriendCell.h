//
//  JJChooseFriendCell.h
//  Footprints
//
//  Created by Jinjin on 14/12/1.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJChooseFriendCell : UITableViewCell

@property (weak, nonatomic) IBOutlet JJAvatarView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *chooseBtn;
@property (assign,nonatomic) BOOL choosed;
- (void)setChoose:(BOOL)choose;

- (void)showBottomLine:(BOOL)show withInset:(UIEdgeInsets)inset;
- (void)showTopLine:(BOOL)show withInset:(UIEdgeInsets)inset;
@end
