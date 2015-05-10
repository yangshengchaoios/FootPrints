//
//  ViewUtils.h
//  SCSDEnterprise
//
//  Created by  YangShengchao on 14-2-14.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <BlocksKit/BlocksKit.h>

#import "ImageUtils.h"
#import <MBProgressHUD/MBProgressHUD.h>

typedef enum {
    ButtonStyle1,   //灰色带边框圆角矩形图片背景
    ButtonStyle2,   //正常状态无背景，按下后灰色无边框圆角矩形图片背景
    ButtonStyle3,   //灰色带边框圆角矩形图片背景，正常状态与按下状态背景一致
    ButtonStyle4,   //半透明泡泡图片背景
    ButtonStyle5    //无背景图片，白色文字
} ButtonStyle;

@interface ViewUtils : NSObject

+ (UIImageView *)imageViewWithAnimatingImageNames:(NSString *)firstImageName, ... NS_REQUIRES_NIL_TERMINATION;
+ (void)setAnimationForImageView:(UIImageView *)imageView withImageNames:(NSString *)firstImageName, ... NS_REQUIRES_NIL_TERMINATION;

+ (UIAlertView *)showAlertWithTitle:(NSString *)alertTitle andMessage:(NSString *)alertMessage;
+ (UIAlertView *)showAlertWithTwoButtonsWithTitle:(NSString *)alertTitle andMessage:(NSString *)alertMessage andDelegate:(id<UIAlertViewDelegate>)delegate;

+ (UIActionSheet *)showImagePickerActionSheetWithDelegate:(id<UINavigationControllerDelegate,
                                                           UIImagePickerControllerDelegate>)delegate
                                            allowsEditing:(BOOL)allowsEditing
                                              singleImage:(BOOL)singleImage
                                         onViewController:(UIViewController *)viewController;

+ (void)makeCircleForImageView:(UIImageView *)imageView;
+ (void)makeRoundForView:(UIView *)view withRadius:(CGFloat)radius;

+ (UIViewController *)currentViewController;

+ (UIImage *)screenshotFromUIView:(UIView *) aView;

+ (void)animateHorizontalSwipe:(UIView *)view withSubType:(NSString *)subtype;

# pragma mark - Huanrun

+ (void)makeButton:(UIButton *)button withStyle:(ButtonStyle)style;


@end
