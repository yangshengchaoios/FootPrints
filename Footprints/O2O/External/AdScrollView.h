//
//  AdScrollView.h
//  广告循环滚动效果
//
//  Created by QzydeMac on 14/12/20.
//  Copyright (c) 2014年 Qzy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UIPageControlShowStyle)
{
    UIPageControlShowStyleNone,//default
    UIPageControlShowStyleLeft,
    UIPageControlShowStyleCenter,
    UIPageControlShowStyleRight,
};

typedef NS_ENUM(NSUInteger, AdTitleShowStyle)
{
    AdTitleShowStyleNone,
    AdTitleShowStyleLeft,
    AdTitleShowStyleCenter,
    AdTitleShowStyleRight,
};

typedef void(^AdDidTapBlock) (NSInteger tapIndex);

@interface AdScrollView : UIScrollView<UIScrollViewDelegate>

@property (strong,nonatomic,readonly)  UIPageControl * pageControl;
@property (strong,nonatomic,readwrite) NSArray * imageNameArray;
@property (strong,nonatomic,readonly)  NSArray * adTitleArray;
@property (assign,nonatomic,readwrite) UIPageControlShowStyle  PageControlShowStyle;
@property (assign,nonatomic,readonly)  AdTitleShowStyle  adTitleStyle;
@property (assign,nonatomic)           NSInteger currentImage;
@property (strong,nonatomic)           AdDidTapBlock didTapBlock;
- (void)setAdTitleArray:(NSArray *)adTitleArray withShowStyle:(AdTitleShowStyle)adTitleStyle;
@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
