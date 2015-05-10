//
//  JJColorSlider.m
//  Footprints
//
//  Created by tt on 14/10/28.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJColorSlider.h"
#define kPandding 0
@interface JJColorSlider ()

@property (nonatomic,strong) UIColor *selectedColor;

@property (nonatomic,strong) NSArray *colorArray;
@property (nonatomic,strong) UISlider *slider;
@property (nonatomic,strong) UIView *sliderView;
@property (nonatomic,strong) UIView *colorSlider;

@property (nonatomic,strong) ColorChangeBlock changeBlock;
@end

@implementation JJColorSlider

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (self.colorArray.count) {
        CGFloat xOffset = 9+15+kPandding;
        CGFloat height = 6;
        CGFloat yOffset = (CGRectGetHeight(self.frame)-height)/2;
        CGFloat width = (CGRectGetWidth(self.frame)-xOffset-kPandding)/self.colorArray.count;
        CGContextRef context = UIGraphicsGetCurrentContext();
        //左半圆
        [self.colorArray[0] setFill];
        CGContextFillEllipseInRect(context, CGRectMake(xOffset, yOffset, height, height));
        
        for (UIColor *color in self.colorArray) {
            NSInteger index = [self.colorArray indexOfObject:color];
            [color setFill];
            if (index==0) {
                CGContextFillRect(context,  CGRectMake(xOffset+height/2, yOffset, width, height));
            }else if (index==self.colorArray.count-1){
                CGContextFillRect(context,  CGRectMake(xOffset+width*index, yOffset, width-height/2, height));
            }else{
                CGContextFillRect(context,  CGRectMake(xOffset+width*index, yOffset, width, height));
            }
        }
        //右半圆
        [[self.colorArray lastObject] setFill];
        CGContextFillEllipseInRect(context, CGRectMake(xOffset+width*self.colorArray.count-height, yOffset, height, height));
        
        CGContextStrokePath(context);
    }
}

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDefault];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupDefault];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame andValueChangeBlock:(ColorChangeBlock)newColor{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDefault];
        self.changeBlock = newColor;
    }
    return self;
}

- (void)setupDefault{

    self.backgroundColor = [UIColor clearColor];
    self.colorArray = @[RGB(255, 255, 255),
                        RGB(204, 204, 204),
                        RGB(128, 128, 128),
                        RGB(64, 64, 64),
                        RGB(55, 46, 47),
                        RGB(0, 0, 0),
                        RGB(191, 125, 67),
                        RGB(126, 2, 2),
                        RGB(203, 2, 0),
                        RGB(252, 3, 0),
                        RGB(255, 82, 5),
                        RGB(252, 128, 4),
                        RGB(250, 192, 0),
                        RGB(165, 228, 0),
                        RGB(104, 194, 1),
                        RGB(2, 135, 7),
                        RGB(129, 212, 254),
                        RGB(3, 149, 252),
                        RGB(9, 98, 292),
                        RGB(0, 30, 92),
                        RGB(58, 2, 103),
                        RGB(112, 0, 139),
                        RGB(254, 51, 141),
                        RGB(255, 192, 214)];

    self.selectedColorView = [[UIView alloc] initWithFrame:CGRectMake(kPandding,( CGRectGetHeight(self.frame)-15)/2, 16, 16)];
    self.selectedColorView.clipsToBounds = YES;
    self.selectedColorView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.selectedColorView.layer.borderWidth = kDefaultBorderWidth;
    self.selectedColorView.backgroundColor = [UIColor blackColor];
    self.selectedColorView.layer.cornerRadius = 3;
    [self addSubview:self.selectedColorView];
    
    self.sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, CGRectGetHeight(self.frame))];
    self.sliderView.backgroundColor = [UIColor clearColor];
    self.sliderView.hidden = YES;
    self.sliderView.userInteractionEnabled = NO;
    [self addSubview:self.sliderView];
    
    UIImageView *colorRingRound = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Color ring-Round.png"]];
    colorRingRound.frame = CGRectMake(0, CGRectGetHeight(self.sliderView.frame)/2-10/2, 10, 10);
    [self.sliderView addSubview:colorRingRound];
    
    UIImageView *colorSliderBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Color.png"]];
    colorSliderBg.frame = CGRectMake(-5, CGRectGetHeight(self.sliderView.frame)/2-(20 + 10), 20, 22);
    [self.sliderView addSubview:colorSliderBg];
    
    self.colorSlider = [[UIView alloc] initWithFrame:CGRectMake(-5,CGRectGetHeight(self.sliderView.frame)/2-(20 + 10), 20, 20)];
    self.colorSlider.clipsToBounds = YES;
    self.colorSlider.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.colorSlider.layer.borderWidth = kDefaultBorderWidth;
    self.colorSlider.backgroundColor = [UIColor blackColor];
    self.colorSlider.layer.cornerRadius = 3;
    [self.sliderView addSubview:self.colorSlider];
}

- (void)moveToXOffset:(CGFloat)x{
    CGFloat minX = 9+15+kPandding;
    CGFloat maxX = CGRectGetWidth(self.frame)-kPandding;
    CGFloat xLocation = x;
    if (xLocation<minX) {
        xLocation = minX;
    }else if (xLocation>maxX){
        xLocation = maxX;
    }else{
        self.sliderView.hidden = NO;
    }
    self.sliderView.center = CGPointMake(xLocation, CGRectGetHeight(self.frame)/2);
    NSInteger index = ((xLocation-minX)/(CGRectGetWidth(self.frame)-minX-kPandding))*(self.colorArray.count);
    index = MIN(index, self.colorArray.count-1);
    index = MAX(index, 0);
    
    UIColor *newColor = self.colorArray[index];
    self.colorSlider.backgroundColor = newColor;
    self.selectedColorView.backgroundColor = newColor;
    if (self.changeBlock) {
        self.changeBlock(newColor);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch* touch=[touches anyObject];
    [self moveToXOffset:[touch locationInView:self].x];
}

//手指移动时候发出
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch=[touches anyObject];
    [self moveToXOffset:[touch locationInView:self].x];
}
//当手指离开屏幕时候
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.sliderView.hidden = YES;
}
//电话呼入等事件取消时候发出
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.sliderView.hidden = YES;
}
@end
