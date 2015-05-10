//
//  JJViewActionSheet.m
//  Footprints
//
//  Created by Jinjin on 14/12/16.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJViewActionSheet.h"
@implementation JJViewActionSheet

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)dealloc
{
    NSLog(@"Action Dealloc");
}

- (id)init {
    
    self = [self initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.backgroundColor = [UIColor clearColor];
    
    self.transparentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds))];
    self.transparentView.backgroundColor = [UIColor blackColor];
    self.transparentView.alpha = 0.0f;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFromView)];
    tap.numberOfTapsRequired = 1;
    [self.transparentView addGestureRecognizer:tap];
    
    return self;
}

- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelTitle contentView:(UIView *)view {
    
    self = [self init];
    self.backgroundColor = [UIColor clearColor];
    
    
    if (cancelTitle) {
        self.cancelBtn = [[IBActionSheetButton alloc] initWithAllCornersRounded];
        self.cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:21];
        [self.cancelBtn setTitle:cancelTitle forState:UIControlStateAll];
    
        [self.cancelBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelBtn addTarget:self action:@selector(highlightPressedButton:) forControlEvents:UIControlEventTouchDown];
        [self.cancelBtn addTarget:self action:@selector(unhighlightPressedButton:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchDragExit];
        [self.cancelBtn setIndex:0];
    }
    
    if (view) {
        contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
        contentView.clipsToBounds = YES;
    }
    
    _theContent = view;
    
    [self setUpTheActionSheet];
    return self;
}

- (void)setMaskTo:(UIView*)view
{
    view.backgroundColor = [UIColor whiteColor];
    view.alpha = 0.95;
    UIBezierPath *rounded = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                  byRoundingCorners:UIRectCornerAllCorners
                                                        cornerRadii:CGSizeMake(4.0, 4.0)];
    CAShapeLayer *shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    view.layer.mask = shape;
}

- (void)buttonClicked:(IBActionSheetButton *)button {
    
    [self removeFromView];
}

- (void)highlightPressedButton:(IBActionSheetButton *)button {
    
    [UIView animateWithDuration:0.15f
                     animations:^() {
                         button.alpha = .80f;
                         
                     }];
}

- (void)unhighlightPressedButton:(IBActionSheetButton *)button {
    
    [UIView animateWithDuration:0.3f
                     animations:^() {
                         button.alpha = .95f;
                     }];
    
}

- (void)setUpTheActionSheet {
    
    float height;
    float width;
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        width = CGRectGetWidth([UIScreen mainScreen].bounds);
    } else {
        width = CGRectGetHeight([UIScreen mainScreen].bounds);
    }
    
    CGFloat padding = 8;
    CGFloat padding2 = 10;
    
    
    CGFloat contentHeight = CGRectGetHeight(_theContent.frame)+(padding*2);
    
    // slight adjustment to take into account non-retina devices
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]
        && [[UIScreen mainScreen] scale] == 2.0) {
        
        // setup spacing for retina devices
        height = 44.5;
        if (_theContent) {
            height += contentHeight+padding2*2;
        }
        
        self.frame = CGRectMake(0, 0, width, height);
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        CGPoint pointOfReference = CGPointMake(CGRectGetWidth(self.frame) / 2.0, CGRectGetHeight(self.frame) - 30);
        
        int whereToStop;
        [self addSubview:self.cancelBtn];
        [self.cancelBtn setCenter:pointOfReference];
        [self.cancelBtn setCenter:CGPointMake(pointOfReference.x, pointOfReference.y - 52)];
        pointOfReference = CGPointMake(pointOfReference.x, pointOfReference.y - 52);
        whereToStop = 1 - 2;
        [self addSubview:self.cancelBtn];
        [self.cancelBtn setCenter:CGPointMake(pointOfReference.x, pointOfReference.y - (44.5 * whereToStop))];
    } else {
        
        // setup spacing for non-retina devices
        height = 60.0+45;
        if (_theContent) {
            height += CGRectGetHeight(_theContent.frame)+padding*2+padding2;
        }
        
        self.frame = CGRectMake(0, 0, width, height);
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        CGPoint pointOfReference = CGPointMake(CGRectGetWidth(self.frame) / 2.0, CGRectGetHeight(self.frame) - 30);
        
        [self addSubview:_cancelBtn];
        [_cancelBtn setCenter:pointOfReference];
        [_cancelBtn setCenter:CGPointMake(pointOfReference.x, pointOfReference.y - 52)];
        pointOfReference = CGPointMake(pointOfReference.x, pointOfReference.y - 52);
        
        int whereToStop = 1 - 2;
        [self addSubview:self.cancelBtn];
        [self.cancelBtn setCenter:CGPointMake(pointOfReference.x, pointOfReference.y - (45 * whereToStop))];
    }
    if (_theContent) {
        [self addSubview:contentView];
        [contentView addSubview:_theContent];
        contentView.frame = CGRectMake(8, 0, width-16,contentHeight);
        _theContent.center = CGPointMake(CGRectGetWidth(contentView.frame)/2, CGRectGetHeight(contentView.frame) / 2.0);
        
        [self setMaskTo:contentView];
    }else{
        [contentView removeFromSuperview];
    }
}

- (void)showInView:(UIView *)theView {
    
    [theView addSubview:self];
    [theView insertSubview:self.transparentView belowSubview:self];
    
    CGRect theScreenRect = [UIScreen mainScreen].bounds;
    
    float height;
    float x;
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        height = CGRectGetHeight(theScreenRect);
        x = CGRectGetWidth(theView.frame) / 2.0;
        self.transparentView.frame = CGRectMake(self.transparentView.center.x, self.transparentView.center.y, CGRectGetWidth(theScreenRect), CGRectGetHeight(theScreenRect));
    } else {
        height = CGRectGetWidth(theScreenRect);
        x = CGRectGetHeight(theView.frame) / 2.0;
        self.transparentView.frame = CGRectMake(self.transparentView.center.x, self.transparentView.center.y, CGRectGetHeight(theScreenRect), CGRectGetWidth(theScreenRect));
    }
    
    self.center = CGPointMake(x, height + CGRectGetHeight(self.frame) / 2.0);
    self.transparentView.center = CGPointMake(x, height / 2.0);
    
    [UIView animateWithDuration:0.2f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^() {
                         self.transparentView.alpha = 0.4f;
                         if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
                             self.center = CGPointMake(x, (height - 20) - CGRectGetHeight(self.frame) / 2.0);
                         } else {
                             self.center = CGPointMake(x, height - CGRectGetHeight(self.frame) / 2.0);
                         }
                     } completion:^(BOOL finished) {
                         self.visible = YES;
                     }];
}

- (void)removeFromView {
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^() {
                         self.transparentView.alpha = 0.0f;
                         self.center = CGPointMake(CGRectGetWidth(self.frame) / 2.0, CGRectGetHeight([UIScreen mainScreen].bounds) + CGRectGetHeight(self.frame) / 2.0);
                     } completion:^(BOOL finished) {
                         [self.transparentView removeFromSuperview];
                         [self removeFromSuperview];
                         self.visible = NO;
                     }];
}



@end
#pragma mark - IBActionSheetButton

@implementation IBActionSheetButton


- (id)init {
    
    float width;
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        width = CGRectGetWidth([UIScreen mainScreen].bounds);
    } else {
        width = CGRectGetHeight([UIScreen mainScreen].bounds);
    }
    self = [self initWithFrame:CGRectMake(0, 0, width - 16, 44)];
    
    self.backgroundColor = [UIColor whiteColor];
    self.originalBackgroundColor = self.backgroundColor;
    self.titleLabel.font = [UIFont systemFontOfSize:21];
    [self setTitleColor:[UIColor colorWithRed:0.000 green:0.500 blue:1.000 alpha:1.000] forState:UIControlStateAll];
    self.originalTextColor = [UIColor colorWithRed:0.000 green:0.500 blue:1.000 alpha:1.000];
    
    self.alpha = 0.95f;
    
    self.cornerType = IBActionSheetButtonCornerTypeNoCornersRounded;
    
    return self;
}

- (id)initWithTopCornersRounded {
    self = [self init];
    [self setMaskTo:self byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
    self.cornerType = IBActionSheetButtonCornerTypeTopCornersRounded;
    return self;
}

- (id)initWithBottomCornersRounded {
    self = [self init];
    [self setMaskTo:self byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight];
    self.cornerType = IBActionSheetButtonCornerTypeBottomCornersRounded;
    return self;
}

- (id)initWithAllCornersRounded {
    self = [self init];
    [self setMaskTo:self byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight];
    self.cornerType = IBActionSheetButtonCornerTypeAllCornersRounded;
    return self;
}


- (void)setTextColor:(UIColor *)color {
    [self setTitleColor:color forState:UIControlStateAll];
}

- (void)resizeForPortraitOrientation {
    
    self.frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds) - 16, CGRectGetHeight(self.frame));
    
    switch (self.cornerType) {
        case IBActionSheetButtonCornerTypeNoCornersRounded:
            break;
            
        case IBActionSheetButtonCornerTypeTopCornersRounded: {
            [self setMaskTo:self byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
            break;
        }
        case IBActionSheetButtonCornerTypeBottomCornersRounded: {
            [self setMaskTo:self byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight];
            break;
        }
            
        case IBActionSheetButtonCornerTypeAllCornersRounded: {
            [self setMaskTo:self byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight];
            break;
        }
            
        default:
            break;
    }
}

- (void)resizeForLandscapeOrientation {
    self.frame = CGRectMake(0, 0, CGRectGetHeight([UIScreen mainScreen].bounds) - 16, CGRectGetHeight(self.frame));
    
    switch (self.cornerType) {
        case IBActionSheetButtonCornerTypeNoCornersRounded:
            break;
            
        case IBActionSheetButtonCornerTypeTopCornersRounded: {
            [self setMaskTo:self byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight];
            break;
        }
        case IBActionSheetButtonCornerTypeBottomCornersRounded: {
            [self setMaskTo:self byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight];
            break;
        }
            
        case IBActionSheetButtonCornerTypeAllCornersRounded: {
            [self setMaskTo:self byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight];
            break;
        }
            
        default:
            break;
    }
    
}

- (void)setMaskTo:(UIView*)view byRoundingCorners:(UIRectCorner)corners
{
    UIBezierPath *rounded = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                  byRoundingCorners:corners
                                                        cornerRadii:CGSizeMake(4.0, 4.0)];
    CAShapeLayer *shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    view.layer.mask = shape;
}
@end
