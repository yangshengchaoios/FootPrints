//
//  JJActivityTravelItem.h
//  Footprints
//
//  Created by Jinjin on 14/11/19.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef BOOL (^VoteStateDidChangedBlock)(BOOL isVote); //YES vote ，NO unvote

typedef NS_ENUM(NSInteger, ActivityTravelItemStyle) {
    ActivityTravelItemStyleNormal =0,
    ActivityTravelItemStyleCrown,
    ActivityTravelItemStyleDiamond,
    ActivityTravelItemStylePlatinum
};

@interface JJActivityTravelItem : UIControl
@property (nonatomic,assign) ActivityTravelItemStyle itemStyle;
@property (nonatomic,strong) UIImageView *styleImageView;
@property (nonatomic,strong) UIButton *voteBtn;
@property (nonatomic,strong) UILabel *voteCountLabel;
@property (nonatomic,strong) UIImageView *travelImageView;
@property (nonatomic,strong) JJAvatarView *avatarImageView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) VoteStateDidChangedBlock changedBlock;
@end
