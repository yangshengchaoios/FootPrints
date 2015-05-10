//
//  JJCommentViewController.h
//  Footprints
//
//  Created by Jinjin on 14/11/27.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "BaseViewController.h"
#import "DXMessageToolBar.h"
@protocol JJCommentViewDelegate <NSObject>

//- (void)commentViewNeedBack{
//    
//}

@end

@interface JJCommentViewController : BaseViewController
- (void)refresh;

@property (nonatomic,strong) UIViewController *hostViewController;
@property (nonatomic,strong) NSString *travelId;
@property (nonatomic,strong) NSString *showMessageId;

@property (nonatomic,strong) NSString *toNickName;
@property (nonatomic,strong) NSString *toUserId;

@property (nonatomic,strong) DXMessageToolBar *chatToolBar;
- (void)commentToUsername:(NSString *)username andUserId:(NSString *)userId;
@end
