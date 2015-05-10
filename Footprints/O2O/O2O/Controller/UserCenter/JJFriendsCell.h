//
//  JJFriendsCell.h
//  Footprints
//
//  Created by Jinjin on 14/11/20.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJFriendsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet JJAvatarView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *summryLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

- (void)showBottomLine:(BOOL)show withInset:(UIEdgeInsets)inset;
- (void)showTopLine:(BOOL)show withInset:(UIEdgeInsets)inset;
- (void)setCount:(NSInteger)count;
@end
