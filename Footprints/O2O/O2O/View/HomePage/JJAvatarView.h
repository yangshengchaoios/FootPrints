//
//  JJAvatarView.h
//  Footprints
//
//  Created by Jinjin on 15/1/22.
//  Copyright (c) 2015年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJAvatarView : UIView
@property (strong,nonatomic) UIImageView *avatarView;
@property (strong,nonatomic) UIImageView *iconView;

- (void)bindUserData:(JJMemberModel *)user;
@end
