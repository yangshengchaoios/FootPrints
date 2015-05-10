//
//  JJActivityDetailViewController.h
//  Footprints
//
//  Created by Jinjin on 14/11/17.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "BaseViewController.h"

@interface JJActivityDetailViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) ActivityModel *model;
@property (nonatomic,assign) ActivityStatus activityStatus;
@end
