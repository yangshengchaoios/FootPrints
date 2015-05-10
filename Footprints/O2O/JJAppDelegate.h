//
//  JJAppDelegate.h
//  O2O
//
//  Created by tt on 14-9-17.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/**
 *  检查更新
 *
 *  @param showMessage 是否显示hud提示正在检查
 *  @param skip        是否显示skip按钮
 */
- (void)checkVersion:(BOOL)showMessage andCanSkip:(BOOL)skip;
@end
