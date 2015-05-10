//
//  JJActivityDetaiOpenCell.m
//  Footprints
//
//  Created by Jinjin on 14/11/17.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJActivityDetaiOpenCell.h"


@implementation JJActivityDetaiOpenCell

- (void)awakeFromNib {
    // Initialization code
    UIView *bgView = [[UIView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(0, 0, 10, 0))];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.contentView insertSubview:bgView atIndex:0];
    
    self.backgroundColor = kDefaultViewColor;
    self.detailLabel.textColor = RGB(99, 99, 99);
    self.detailLabel.autoresizingMask = UIViewAutoresizingNone;
    
    self.bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, SCREEN_WIDTH, 1)];
    self.bottomLine.backgroundColor = kDefaultBorderColor;
    self.bottomLine.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:self.bottomLine];
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    topLine.backgroundColor = kDefaultBorderColor;
    [self addSubview:topLine];
    
    UIView *btnTopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    btnTopLine.backgroundColor = [kDefaultBorderColor colorWithAlphaComponent:0.9];
    [self.openBtn addSubview:btnTopLine];
    
    self.isOpen = NO;
    self.btnIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_next.png"]];
    self.btnIcon.frame = CGRectMake(SCREEN_WIDTH-13-15, 13, 13, 8);
    [self.openBtn addSubview:self.btnIcon];
    [self.openBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [self.openBtn setTitleColor:RGB(29, 123, 151) forState:UIControlStateNormal];
    self.openBtn.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)oepnBtnDidTap:(id)sender {

    self.isOpen = !self.isOpen;
    
    [self resetFramesWithAnimation:YES];

    if (self.block) {
        self.block(self.isOpen);
    }
}

- (void)setIsOpen:(BOOL)isOpen{
    
    _isOpen = isOpen;
    
    [self.btnIcon setImage:self.isOpen?[UIImage imageNamed:@"btn_up.png"]:[UIImage imageNamed:@"btn_next.png"] ];
    [self.openBtn setTitle:self.isOpen?@"收起":@"展开查看全部" forState:UIControlStateNormal];
}

- (void)setDetailLabelText:(NSString *)text{
    
    self.detailLabel.text = text;
    [self resetFramesWithAnimation:NO];
}

- (void)resetFramesWithAnimation:(BOOL)animation{
    
    [UIView animateWithDuration:animation?0.25:0 animations:^{
//        self.detailLabel.backgroundColor= [UIColor greenColor];
//        self.detailLabel.text = kDefaultText;
        CGSize size = [self.detailLabel.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-30, 1000000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size;
        CGFloat height = size.height;
        height = MAX(ceil(height), 30);
        if (height<60) {
            //只有1行
            self.openBtn.hidden = YES;
            self.detailLabel.frame = CGRectMake(15, 5, SCREEN_WIDTH-30, height);
        }else{
            self.openBtn.hidden = NO;
            if (!self.isOpen) {
                self.detailLabel.frame = CGRectMake(15, 5, SCREEN_WIDTH-30, 75);
            }else{
                self.detailLabel.frame = CGRectMake(15, 5, SCREEN_WIDTH-30, height);
            }
        }
        self.openBtn.frame = CGRectMake(0, self.frame.size.height-CGRectGetHeight(self.openBtn.frame)-10, SCREEN_WIDTH, CGRectGetHeight(self.openBtn.frame));
        self.bottomLine.frame = CGRectMake(0, self.frame.size.height-11, SCREEN_WIDTH, 1);
    }];
}


+ (CGFloat)heightForText:(NSString *)text isOpen:(BOOL)isOpen{

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize size = [text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-30, 1000000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSParagraphStyleAttributeName:paragraphStyle.copy} context:nil].size;
    CGFloat height = size.height;
    height = MAX(ceil(height), 30);
    
    CGFloat labelAllHeihgt = height+10;
    if (height<60) {
        //只有1行
        labelAllHeihgt +=10;
    }else{
        if (!isOpen) {
            labelAllHeihgt = 75+20+33;
        }else{
            labelAllHeihgt = height+20+33;
        }
    }
    return labelAllHeihgt;
}
@end
