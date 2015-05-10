//
//  JJAddFriendsCell.h
//  Footprints
//
//  Created by Jinjin on 14/11/20.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AddFriendsCellStyle) {

    AddFriendsCellStyleNormal = 0,
    AddFriendsCellStyleAdd,
    AddFriendsCellStyleDidAdd,
    AddFriendsCellStyleSingleAdd,
    AddFriendsCellStyleBothAdd,
    AddFriendsCellStyleInvite,
};

typedef void(^AddFriendsBlock)(BOOL isAdd,NSString *friendMemberId); //YES add ，NO remove

@interface JJAddFriendsCell : UITableViewCell
- (IBAction)statusBtnDidTap:(id)sender;
- (void)showBottomLine:(BOOL)show withInset:(UIEdgeInsets)inset;
- (void)showTopLine:(BOOL)show withInset:(UIEdgeInsets)inset;

@property (weak, nonatomic) IBOutlet UIButton *statusBtn;
@property (weak, nonatomic) IBOutlet JJAvatarView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *summryLabel;
@property (assign,nonatomic) AddFriendsCellStyle cellStyle;
@property (strong,nonatomic) AddFriendsBlock addBlock;
@property (nonatomic,strong) NSString *friendMemberId;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@end
