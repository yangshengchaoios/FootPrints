//
//  JJUserCenterViewController.h
//  Footprints
//
//  Created by Jinjin on 14/11/20.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "BaseViewController.h"

@interface JJUserCenterViewController : BaseViewController

@property (nonatomic,assign) BOOL isMy;
@property (nonatomic,strong) JJMemberModel *model;


- (void)refresh;
@end
