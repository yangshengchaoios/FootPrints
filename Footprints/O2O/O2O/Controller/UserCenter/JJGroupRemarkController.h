//
//  JJGroupRemarkController.h
//  Footprints
//
//  Created by Jinjin on 14/12/5.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "BaseViewController.h"

@interface JJGroupRemarkController : BaseViewController

@property (nonatomic,strong) NSString *groupId;
@property (nonatomic,strong) NSString *memberId;
@property (nonatomic,strong) NSString *groupName;
@property (weak, nonatomic) IBOutlet UITextField *remarkLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupLabel;
@end
