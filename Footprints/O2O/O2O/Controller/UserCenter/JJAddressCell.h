//
//  JJAddressCell.h
//  Footprintsv
//
//  Created by Jinjin on 14/11/24.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AddressFriendsStatus) {
    
    AddressFriendsStatusNotRegister = 0,
    AddressFriendsStatusFriend,
    AddressFriendsStatuRegister,
};

typedef void(^AddressCellBlock)(AddressFriendsStatus status,NSString *friendMemberId,NSString *phone);
@interface JJAddressCell : UITableViewCell
@property (nonatomic,strong) NSString *friendMemberId;
@property (nonatomic,strong) NSString *phone;
@property (nonatomic,strong) AddressCellBlock block;
@property (assign,nonatomic) AddressFriendsStatus status;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
- (IBAction)actionBtnDidTap:(id)sender;
@end
