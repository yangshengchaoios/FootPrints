//
//  JJEditBoardViewController.h
//  Footprints
//
//  Created by tt on 14/10/23.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, EditBoardStyle){
    
    EditBoardStyleHome = 0,
    EditBoardStyleActivity = 1
};

@interface JJEditBoardViewController : BaseViewController
@property (nonatomic,assign) EditBoardStyle boardStyle;
@property (nonatomic,strong) NSString *activityId;
@property (nonatomic,strong) UIImage *img;
@property (nonatomic,assign) CGRect frame;

- (void)openSelf;
@end
