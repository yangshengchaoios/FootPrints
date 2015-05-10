//
//  BaseViewController.h
//  SCSDEnterprise
//
//  Created by  YangShengchao on 14-2-13.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//  FORMATED!
//

#import <UIKit/UIKit.h>
#import <BlocksKit/BlocksKit.h>
#import <BlocksKit+UIKit.h>
#import "UITextField+Addition.h"
#import "MBProgressHUD.h"
#import "ViewUtils.h"
#import "ImageUtils.h"
#import "StorageManager.h"

#import "ReachabilityManager.h"
#import "EnumType.h"

#define kAnimationDuration  0.3f

@interface BaseViewController : UIViewController <UITextFieldDelegate>

#pragma mark - 视图切换
@property (nonatomic, strong) NSDictionary *params; //显示该视图控制器的时候传入的参数

@property (nonatomic, strong) UILabel *noDataInfo;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, assign) BackType backType;    //返回类型（是上一级还是侧边栏）默认是pop上一级
@property (nonatomic, assign) BOOL isAppeared;      //当前viewcontroller是否显示（用于控制发送键盘通知时是否需要处理）


#pragma mark - push & pop & dismiss view controller
- (UIViewController *)pushViewController:(NSString *)className;
- (UIViewController *)pushViewController:(NSString *)className withParams:(NSDictionary *)paramDict;
//返回上一级，最多到根
- (UIViewController *)popViewController;
//返回上一级，直到dismiss
- (UIViewController *)backViewController;
//返回到根
- (UIViewController *)popToRootViewController;


#pragma mark - present & dismiss viewcontroller
- (UIViewController *)presentViewController:(NSString *)className;
- (UIViewController *)presentViewController:(NSString *)className withParams:(NSDictionary *)paramDict;
//dismiss on navigationbar（只有在自定义navigationbar上的按钮事件时采用该方法）
- (void)dismissOnPresentedViewController;
//dismiss on presenting（通常情况下用该方法）
- (void)dismissOnPresentingViewController;


#pragma mark - showPhotoViewController
- (UIViewController *)showPhotosWithImage:(UIImage *)image;
- (UIViewController *)showPhotosWithImages:(NSArray *)images;
- (UIViewController *)showPhotosWithImageUrls:(NSArray *)imageUrls atIndex:(NSInteger)index;
- (UIViewController *)showPhotosWithImageUrl:(NSString *)imageUrl;
- (UIViewController *)showPhotosWithImageUrls:(NSArray *)imageUrls;
- (UIViewController *)showPhotosWithImages:(NSArray *)images atIndex:(NSInteger)index;


#pragma mark -  show & hide HUD
- (MBProgressHUD *)showHUDLoadingWithString:(NSString *)hintString;
- (MBProgressHUD *)showHUDLoadingWithStringOnWindow:(NSString *)hintString;
- (MBProgressHUD *)showHUDLoadingWithString:(NSString *)hintString onView:(UIView *)view;

- (void)hideHUDLoading;
- (void)hideHUDLoadingOnWindow;
- (void)hideHUDLoadingOnView:(UIView *)view;

- (void)showResultThenHide:(NSString *)resultString;
- (void)showResultThenHideOnWindow:(NSString *)resultString;
- (void)showResultThenPop:(NSString *)resultString;
- (void)showResultThenPopOnWindow:(NSString *)resultString;
- (void)showResultThenBack:(NSString *)resultString;
- (void)showResultThenBackOnWindow:(NSString *)resultString;
- (void)showResultThenHide:(NSString *)resultString afterDelay:(NSTimeInterval)delay onView:(UIView *)view;


#pragma mark - alert view
- (UIAlertView *)showAlertVieWithMessage:(NSString *)message;
- (UIAlertView *)showAlertViewWithTitle:(NSString *)title andMessage:(NSString *)message;


#pragma mark - Overridden methods 缓存相关
- (NSString *)cacheFilePath;
- (id)cachedObjectByKey:(NSString *)cachedKey;
- (void)saveObjectToCache:(id)object toKey:(NSString *)cachedKey;
- (void)loadCache;


#pragma mark - Overridden methods 业务相关
- (NSArray *)customBarButtonOnNavigationBar:(UIView *)customButton withFixedSpaceWidth:(NSInteger)width;
- (IBAction)backButtonClicked:(id)sender;
- (IBAction)popButtonClicked:(id)sender;
- (IBAction)leftSlideButtonClicked:(id)sender;
- (BOOL)showCustomTitleBarView;
- (void)hideKeyboard;
- (BOOL)willCareKeyboard;
- (void)willLayoutForKeyboardHeight:(CGFloat)keyboardHeight;
- (void)layoutForKeyboardHeight:(CGFloat)keyboardHeight;
- (void)didLayoutForKeyboardHeight:(CGFloat)keyboardHeight;
- (void)networkReachablityChanged:(BOOL)reachable;

@end
