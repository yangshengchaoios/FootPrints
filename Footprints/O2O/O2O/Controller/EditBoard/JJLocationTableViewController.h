//
//  JJLocationTableViewController.h
//  Footprints
//
//  Created by tt on 14/10/29.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "BaseViewController.h"
#import "BMapKit.h"

#import <CoreLocation/CoreLocation.h>

typedef void(^CompelteBlock)(BMKPoiInfo *info);

@class JJLocationTableViewController;
@protocol JJLocationTableViewDelegate <NSObject>

- (void)locationTable:(JJLocationTableViewController *)controller didChooseLocation:(BMKPoiInfo *)pinfo;

@end

@interface JJLocationTableViewController : BaseViewController

@property (nonatomic,weak) id<JJLocationTableViewDelegate> delegate;
@property (nonatomic,strong) CompelteBlock compelte;


- (id)initWithDidChooseActions:(CompelteBlock)compelte;
@end
