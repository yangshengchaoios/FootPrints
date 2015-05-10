//
//  JJColorSlider.h
//  Footprints
//
//  Created by tt on 14/10/28.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ColorChangeBlock)(UIColor *newColor);
@interface JJColorSlider : UIView

@property (nonatomic,strong) UIView *selectedColorView;
- (id)initWithFrame:(CGRect)frame andValueChangeBlock:(ColorChangeBlock)newColor;
@end
