//
//  JJCreateGroupController.h
//  Footprints
//
//  Created by Jinjin on 14/12/2.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "BaseViewController.h"

@protocol JJCreateGroupDelegate <NSObject>

- (void)didRemoveUserModel:(ContactMemberModel *)model;
- (void)didSetGroupName:(NSString *)groupName;

@end

@interface JJCreateGroupController : BaseViewController
@property (nonatomic,strong) NSString *groupName;
@property (nonatomic,strong) NSString *groupId;
@property (nonatomic,strong) NSMutableArray *choosedSource;
@property (nonatomic,strong) NSMutableArray *userViews;
@property (nonatomic,weak) id<JJCreateGroupDelegate> delegate;
@end
