//
//  JJTextSticker.m
//  Footprints
//
//  Created by tt on 14/10/28.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJTextSticker.h"

@implementation JJTextSticker



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont systemFontOfSize:1];
        self.label.textColor = [UIColor whiteColor];

        self.preventsPositionOutsideSuperview = NO;
        self.contentView = self.label;
        
        self.label.font = [self findFontForHeight:self.contentView.bounds.size.height];
        self.backgroundColor = [UIColor clearColor];
        self.text = @"请输入文字";
        [self showEditingHandles];
        [self hideDelHandle];
        
        fontSize = [self.label.font pointSize];
    }
    return self;
}


- (void)didChangeHeight{
    self.label.font = [self findFontForHeight:self.contentView.bounds.size.height];
    fontSize = [self.label.font pointSize];
}

- (void)didEndChangeHeight {
    
    [self resetFrameWithString:self.label.text];
}


- (UIFont *)findFontForHeight:(CGFloat)height{
    
    NSInteger index = 10;
    NSString *str = self.label.text;
    UIFont *font = self.label.font;
    while (++index) {
        CGFloat newHeight = height-index;
        if (newHeight<0) {
            break;
        }
        UIFont *newFont = [font fontWithSize:newHeight];;
        NSDictionary *attributes = @{NSFontAttributeName:newFont};
        CGSize constraint = CGSizeMake(MAXFLOAT, MAXFLOAT);
        CGSize size = [str boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading  attributes:attributes context:nil].size;
        if (size.height<(height-10)) {
            font = newFont;
            break;
        }
    }
    return font;
}

- (void)setFont:(UIFont *)font{
    self.label.font = [font fontWithSize:fontSize];
    _font = self.label.font;
    [self resetFrameWithString:self.label.text];
}

- (void)setColor:(UIColor *)color{
    _color = color;
    self.label.textColor = color;
}

- (void)setText:(NSString *)text{
    _text = text;
    self.label.text = text;
    [self resetFrameWithString:text];
}

- (void)resetFrameWithString:(NSString *)str{
    
    CGSize size = [self string:str WidthWithFont:self.label.font];
    CGFloat width = ceilf(size.width);
    CGFloat height = ceil(size.height);
    width =  MAX(width+20, 60);
    
    
    CGRect frame = CGRectMake(0, 0, width+(kSPUserResizableViewGlobalInset + kBorderSize)*2, height+(kSPUserResizableViewGlobalInset + kBorderSize)*2);
    
    
    CGRect newBounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
    self.label.frame = CGRectInset(newBounds, kSPUserResizableViewGlobalInset + kBorderSize, kSPUserResizableViewGlobalInset + kBorderSize);
    borderView.frame = CGRectInset(newBounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
    
    [borderView setNeedsDisplay];
    
    
    self.whScale = frame.size.width/frame.size.height;
    CGAffineTransform transfrom = self.transform;
    self.transform = CGAffineTransformIdentity;
    CGPoint center = self.center;
    [super setFrame:frame];
    self.center = center;
    self.transform = transfrom;
}

-(CGSize)string:(NSString *)str WidthWithFont:(UIFont *)font{
    NSDictionary *attributes = @{NSFontAttributeName:font};
    CGSize constraint = CGSizeMake(MAXFLOAT, MAXFLOAT);
    CGSize size = [str boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading  attributes:attributes context:nil].size;
    return size;
}
@end
