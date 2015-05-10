//
//  JJViewActionSheet.h
//  Footprints
//
//  Created by Jinjin on 14/12/16.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>
#define UIControlStateAll UIControlStateNormal & UIControlStateSelected & UIControlStateHighlighted
#define SYSTEM_VERSION_LESS_THAN(version) ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedAscending)
// Define 'button press' effects
typedef NS_ENUM(NSInteger, IBActionSheetButtonResponse) {
    
    IBActionSheetButtonResponseFadesOnPress,
    IBActionSheetButtonResponseReversesColorsOnPress,
    IBActionSheetButtonResponseShrinksOnPress,
    IBActionSheetButtonResponseHighlightsOnPress
};

typedef NS_ENUM(NSInteger, IBActionSheetButtonCornerType) {
    
    IBActionSheetButtonCornerTypeNoCornersRounded,
    IBActionSheetButtonCornerTypeTopCornersRounded,
    IBActionSheetButtonCornerTypeBottomCornersRounded,
    IBActionSheetButtonCornerTypeAllCornersRounded
    
};

@class IBActionSheetButton;
@interface JJViewActionSheet : UIView
{
//    UIView *_contentView;
    UIView *_theContent;
    UIView *contentView;
}

- (void)showInView:(UIView *)theView;
- (void)removeFromView;
- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle contentView:(UIView *)view;
@property (nonatomic) NSString *title;
@property UIView *transparentView;
@property BOOL visible;
@property (nonatomic) IBActionSheetButton *cancelBtn;
@end



#pragma mark - IBActionSheetButton

@interface IBActionSheetButton : UIButton


- (id)initWithTopCornersRounded;
- (id)initWithAllCornersRounded;
- (id)initWithBottomCornersRounded;
- (void)resizeForPortraitOrientation;
- (void)resizeForLandscapeOrientation;
- (void)setTextColor:(UIColor *)color;

@property NSInteger index;
@property IBActionSheetButtonCornerType cornerType;
@property UIColor *originalTextColor, *highlightTextColor;
@property UIColor *originalBackgroundColor, *highlightBackgroundColor;


@end