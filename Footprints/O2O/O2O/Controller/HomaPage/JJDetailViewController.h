//
//  JJDetailViewController.h
//  Footprints
//
//  Created by Jinjin on 14/11/13.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "BaseViewController.h"

@interface JJDetailViewController : BaseViewController
@property (nonatomic,strong) NSString *travelId;
@property (nonatomic,strong) NSString *showMessageId;
@property (nonatomic,strong) NSString *toNickName;
@property (nonatomic,strong) NSString *toUserId;
- (void)commentToUsername:(NSString *)username andUserId:(NSString *)userId;
@end
