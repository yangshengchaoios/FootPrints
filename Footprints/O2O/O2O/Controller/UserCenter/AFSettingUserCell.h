//
//  AFSettingUserCell.h
//  Whatstock
//
//  Created by Jinjin on 14/12/14.
//  Copyright (c) 2014年 AnnyFun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AFSettingUserCell;
typedef void(^AvatarTapBlock)(AFSettingUserCell *cell);
typedef void(^SexTapBlock)(NSInteger sex);
@interface AFSettingUserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *avatarBg;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *avatarBtnDidTap;
@property (nonatomic,strong) AvatarTapBlock avatarTap;
@property (weak, nonatomic) IBOutlet UITextField *inputField;

@property (weak, nonatomic) IBOutlet UIView *checkBoxView;
- (IBAction)sexBtnDidTap:(id)sender;

- (IBAction)avatarBtnDidTap:(id)sender;


- (void)showBottomLine:(BOOL)show withInset:(UIEdgeInsets)inset withHeight:(CGFloat)height;
- (void)showTopLine:(BOOL)show withInset:(UIEdgeInsets)inset;
@end
