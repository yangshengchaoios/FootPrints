//
//  ViewUtils.m
//  SCSDEnterprise
//
//  Created by  YangShengchao on 14-2-14.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import "ViewUtils.h"
#import <BlocksKit+UIKit.h>
#import "UrlConstants.h"

#define MaxLabelHeight  2000.0f
#define DefaultAnimationInterval    0.2f
#define kAnimationDuration  0.3f

@interface ViewUtils ()

+ (void)showResultThenHide:(NSString *)resultString afterDelay:(NSTimeInterval)delay;

@end

@implementation ViewUtils

+ (UIImageView *)imageViewWithAnimatingImageNames:(NSString *)firstImageName, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *images = [NSMutableArray array];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:firstImageName]];
    
    va_list args;
    va_start(args, firstImageName);
    for (NSString *name = firstImageName; name != nil; name = va_arg(args, id)) {
        UIImage *image = [UIImage imageNamed:name];
        if (image) {
            [images addObject:image];
        }
    }
    va_end(args);
    
    if ([images count] > 0) {
        imageView.animationImages = images;
        imageView.animationDuration = [images count] * DefaultAnimationInterval;
        imageView.animationRepeatCount = -1;
    }
    
    return imageView;
}

+ (void)setAnimationForImageView:(UIImageView *)imageView withImageNames:(NSString *)firstImageName, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *images = [NSMutableArray array];
    va_list args;
    va_start(args, firstImageName);
    for (NSString *name = firstImageName; name != nil; name = va_arg(args, id)) {
        UIImage *image = [UIImage imageNamed:name];
        if (image) {
            [images addObject:image];
        }
    }
    va_end(args);
    
    if ([images count] > 0) {
        imageView.animationImages = images;
        imageView.animationDuration = [images count] * DefaultAnimationInterval;
        imageView.animationRepeatCount = -1;
    }
}

+ (UIAlertView *)showAlertWithTitle:(NSString *)alertTitle andMessage:(NSString *)alertMessage {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
    return alertView;
}

+ (UIAlertView *)showAlertWithTwoButtonsWithTitle:(NSString *)alertTitle andMessage:(NSString *)alertMessage andDelegate:(id<UIAlertViewDelegate>)delegate {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:delegate cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    return alertView;
}

#pragma 图片选择器

+ (UIActionSheet *)showImagePickerActionSheetWithDelegate:(id<UINavigationControllerDelegate,
                                                           UIImagePickerControllerDelegate>)delegate
                                            allowsEditing:(BOOL)allowsEditing
                                              singleImage:(BOOL)singleImage
                                         onViewController:(UIViewController *)viewController {
    UIActionSheet *actionSheet = [UIActionSheet bk_actionSheetWithTitle:nil];
    [actionSheet bk_addButtonWithTitle:@"拍摄照片"
                            handler:^{
                                UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
                                if ( ! [UIImagePickerController isSourceTypeAvailable:sourceType]) {
                                    [self showResultThenHide:@"您的设备无法通过此方式获取照片" afterDelay:0.5];
                                    return;
                                }
                                else {
                                    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                                    imagePickerController.delegate = delegate;
                                    imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                                    imagePickerController.allowsEditing = allowsEditing;
                                    imagePickerController.sourceType = sourceType;
                                    [viewController presentViewController:imagePickerController animated:YES completion:nil];
                                }
                            }];
    
    [actionSheet bk_addButtonWithTitle:@"选取照片"
                            handler:^{
                                UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                if ( ! [UIImagePickerController isSourceTypeAvailable:sourceType]) {
                                    [self showResultThenHide:@"您的设备无法通过此方式获取照片" afterDelay:0.5];
                                    return;
                                }
                                else {
                                    if (singleImage) {//选择相册里单张图片
                                        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                                        imagePickerController.delegate = delegate;
                                        imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                                        imagePickerController.allowsEditing = allowsEditing;
                                        imagePickerController.sourceType = sourceType;
                                        [viewController presentViewController:imagePickerController animated:YES completion:nil];
                                    }
                                    else {
                                        //多张图片
                                    }
                                }
                            }];
    
    [actionSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [actionSheet showInView:viewController.view.window];
    return actionSheet;
}

#pragma mark - 图片边框调整

+ (void)makeCircleForImageView:(UIImageView *)imageView {
    imageView.layer.cornerRadius = imageView.bounds.size.width / 2;
    imageView.layer.masksToBounds = YES;
}

+ (void)makeRoundForView:(UIView *)view withRadius:(CGFloat)radius {
    view.layer.cornerRadius = radius;
    view.layer.masksToBounds = YES;
}

+ (UIViewController *)currentViewController {
    UIViewController *rootViewController;
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    if (topWindow.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(topWindow in windows) {
            if (topWindow.windowLevel == UIWindowLevelNormal) {
                break;
            }
        }
    }
    
    UIView *rootView = [[topWindow subviews] lastObject];
    id nextResponder = [rootView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        rootViewController = nextResponder;
    }
    else if ([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil) {
        rootViewController = topWindow.rootViewController;
    }
    else {
        NSLog(@"Could not find a root view controller");
    }
    NSLog(@"root view controller : %@", rootViewController);
    
    UIViewController *currentViewController = rootViewController;
    if ([currentViewController isKindOfClass:[UITabBarController class]]) {
        currentViewController = [(UITabBarController *)currentViewController selectedViewController];
    }
    if ([currentViewController isKindOfClass:[UINavigationController class]]) {     //UIImagePickerController被显示的时候，要注意处理
        currentViewController = [(UINavigationController *)currentViewController visibleViewController];
    }
    NSLog(@"current view controller : %@", currentViewController);
    return currentViewController;
}


+ (void)makeButton:(UIButton *)button withStyle:(ButtonStyle)style {
    if (button.buttonType == UIButtonTypeCustom) {
        if (style == ButtonStyle1) {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [button setBackgroundImage:[ImageUtils ninePathWithImage:[UIImage imageNamed:@"button_bg_normal_1"] insert:6]
                              forState:UIControlStateNormal];
            [button setBackgroundImage:[ImageUtils ninePathWithImage:[UIImage imageNamed:@"button_bg_down_1"] insert:6]
                              forState:UIControlStateHighlighted];
        }
        else if (style == ButtonStyle2) {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [button setBackgroundImage:nil forState:UIControlStateNormal];
            [button setBackgroundImage:[ImageUtils ninePathWithImage:[UIImage imageNamed:@"button_bg_down_2"] insert:10]
                              forState:UIControlStateHighlighted];
        }
        else if (style == ButtonStyle3) {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
            [button setBackgroundImage:[ImageUtils ninePathWithImage:[UIImage imageNamed:@"button_bg_normal_1"] insert:6]
                              forState:UIControlStateNormal];
            [button setBackgroundImage:[ImageUtils ninePathWithImage:[UIImage imageNamed:@"button_bg_normal_1"] insert:6]
                              forState:UIControlStateHighlighted];
        }
        else if (style == ButtonStyle4) {
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setBackgroundImage:[ImageUtils ninePathWithImage:[UIImage imageNamed:@"button_bg_light"] insertTop:8 left:10 bottom:8 right:10]
                              forState:UIControlStateNormal];
        }
        else if (style == ButtonStyle5) {
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            [button setBackgroundImage:nil forState:UIControlStateNormal];
        }
    
    }
    else {
        NSLog(@"can not custom style for button without a UIButtonTypeCustom buttonType");
    }
}

#pragma mark 截图

//返回UIView全屏截图
+ (UIImage *)screenshotFromUIView:(UIView *) aView {
    UIGraphicsBeginImageContext(aView.frame.size);
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    __autoreleasing UIImage *fullImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return fullImage;
}

/**
 *	实现水平方向上左右滑动的动画效果
 *
 *	@param	view	需要做动画的view
 *	@param	subtype	方向 kCATransitionFromRight、kCATransitionFromLeft
 */
+ (void)animateHorizontalSwipe:(UIView *)view withSubType:(NSString *)subtype {
    CATransition *animation = [CATransition animation];
    animation.duration = kAnimationDuration;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFillModeForwards;
    animation.type = kCATransitionPush;
    animation.subtype = subtype;
    [view.layer addAnimation:animation forKey:@"animation"];
}

#pragma mark - Private Methods

+ (void)showResultThenHide:(NSString *)resultString afterDelay:(NSTimeInterval)delay {
    UIViewController *viewController = [self currentViewController];
    
    MBProgressHUD *hud = [MBProgressHUD HUDForView:viewController.view];
    if ( ! hud) {
        hud = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    }
    hud.labelText = resultString;
    hud.mode = MBProgressHUDModeText;
    [hud show:YES];
    [hud hide:YES afterDelay:delay];
}

@end
