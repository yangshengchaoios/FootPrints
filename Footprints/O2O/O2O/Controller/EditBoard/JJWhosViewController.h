//
//  JJWhosViewController.h
//  Footprints
//
//  Created by Jinjin on 15/1/12.
//  Copyright (c) 2015年 JiaJun. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^ChoosedBlock)(NSString *groupId);
@interface JJWhosViewController : BaseViewController
@property (nonatomic,strong) ChoosedBlock block;
@property (nonatomic,strong) NSMutableArray *choosedArr;
@end
