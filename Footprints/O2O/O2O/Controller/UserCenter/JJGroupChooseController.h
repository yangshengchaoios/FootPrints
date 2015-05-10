//
//  JJGroupChooseController.h
//  Footprints
//
//  Created by Jinjin on 14/12/5.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^DidChooseGroup) (MemberGroupModel *group);
@interface JJGroupChooseController : BaseViewController
@property (nonatomic,strong) NSString *groupId;

@property (nonatomic,strong) NSString *groupName;

@property (nonatomic,strong) DidChooseGroup didChoose;
@end
