//
//  AFTitleView.m
//  Whatstock
//
//  Created by Jinjin on 14/12/9.
//  Copyright (c) 2014年 AnnyFun. All rights reserved.
//

#import "AFTitleView.h"

@interface AFTitleView()<UITextFieldDelegate>

@end

@implementation AFTitleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.realSize = frame.size;
    }
    return self;
}

- (void)awakeFromNib{
    //searchbar_1.png
    //searchbar.png
    self.searchbar.image = [[UIImage imageNamed:@"searchbar_1.png"] stretchableImageWithLeftCapWidth:152 topCapHeight:15];
    self.realSize = self.frame.size;
    
    WS(ws);
    [self.searchbar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws).with.offset(9);
        make.right.mas_equalTo(ws).with.offset(-9);
        make.height.mas_equalTo(@30);
        make.centerY.mas_equalTo(ws);
    }];
    [self.searchIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws).with.offset(17);
        make.size.mas_equalTo(CGSizeMake(15, 15));
        make.centerY.mas_equalTo(ws);
    }];
    
    [self resetSubViewsFrame];
}



- (IBAction)showMenuBtnDidTap:(id)sender{
    
//    self.isExpand = !self.isExpand;
}


- (void)open:(BOOL)isOpenMenu animation:(BOOL)isAnimation{
    
}

#pragma mark - 重置View在navigationbar中得位置
- (void)setFrame:(CGRect)frame{
    
    CGRect newFrame =  frame;
    
    CGFloat height = self.superview.frame.size.height;
    CGFloat width = self.superview.frame.size.width;if (height && width) {
        newFrame = CGRectMake((width-self.realSize.width)/2, (height-self.realSize.height)/2, self.realSize.width, self.realSize.height);
    }
    
    [super setFrame:newFrame];
    [self resetSubViewsFrame];
}

- (void)setBounds:(CGRect)bounds{
    CGRect newFrame = CGRectMake(0, 0, self.realSize.width, self.realSize.height);
    [self setBounds:newFrame];
    [self resetSubViewsFrame];
}

- (void)resetSubViewsFrame{
    
}

- (IBAction)searchBtnDidTap:(id)sender {

    if (self.delegate && [self.delegate respondsToSelector:@selector(titleViewDidTapSearchBtn:)]) {
        [self.delegate titleViewDidTapSearchBtn:self];
    }
}
@end
