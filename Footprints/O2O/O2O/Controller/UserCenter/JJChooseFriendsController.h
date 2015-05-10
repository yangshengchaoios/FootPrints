//
//  JJChooseFriendsController.h
//  Footprints
//
//  Created by Jinjin on 14/12/1.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^DidChooseMember)(ContactMemberModel *model,BOOL isChoose);
typedef void(^DidChooseComplete)(NSArray *members);

@interface JJChooseFriendsController : BaseViewController
@property (nonatomic,assign) BOOL isRecommend;
@property (nonatomic,assign) BOOL isAllFriends;
@property (nonatomic,strong) NSString *recommendMemberId;
@property (nonatomic,strong) DidChooseMember didChooseMember;
@property (nonatomic,strong) DidChooseComplete chooseComplete;

- (void)addDeletedUser:(id)user;
@end
