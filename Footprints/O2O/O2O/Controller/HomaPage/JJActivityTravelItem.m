//
//  JJActivityTravelItem.m
//  Footprints
//
//  Created by Jinjin on 14/11/19.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJActivityTravelItem.h"

@interface JJActivityTravelItem()
//@property (nonatomic,assign) ActivityTravelItemStyle itemStyle;
//@property (nonatomic,strong) UIImageView *styleImageView;
//@property (nonatomic,strong) UIButton *voteBtn;
//@property (nonatomic,strong) UILabel *voteCountLabel;
//@property (nonatomic,strong) UIImageView *travelImageView;
//@property (nonatomic,strong) UIImageView *avatarImageView;
//@property (nonatomic,strong) UILabel *titleLabel;
//@property (nonatomic,strong) UILabel *timeLabel;
@end

@implementation JJActivityTravelItem

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
             [self setupWithFrame:self.frame];   
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupWithFrame:self.frame];
    }
    return self;
}

- (void)setupWithFrame:(CGRect)frame{
    
    
    self.travelImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.travelImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.travelImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.travelImageView];
    
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-26, frame.size.width, 26)];
    bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:bgView];
    
    self.avatarImageView = [[JJAvatarView alloc] initWithFrame:CGRectMake(5, frame.size.height-23, 20, 20)];
    self.avatarImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    self.avatarImageView.avatarView.layer.cornerRadius = CGRectGetHeight(self.avatarImageView.frame)/2;
    self.avatarImageView.avatarView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.avatarImageView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, frame.size.height-26, frame.size.width-32-25, 16)];
    self.titleLabel.font = [UIFont systemFontOfSize:10];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:self.titleLabel];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, frame.size.height-12, frame.size.width-55, 10)];
    self.timeLabel.font = [UIFont systemFontOfSize:8];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:self.timeLabel];
  
    self.voteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.voteBtn addTarget:self action:@selector(voteBtnDidTap) forControlEvents:UIControlEventTouchUpInside];
    self.voteBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.voteBtn setImage:[UIImage imageNamed:@"icon_praise_black1.png"] forState:UIControlStateNormal];
    [self.voteBtn setImage:[UIImage imageNamed:@"icon_praise_black1_2.png"] forState:UIControlStateSelected];
    self.voteBtn.frame = CGRectMake(frame.size.width-26-20, frame.size.height-26, 26, 26);
//    [self.voteBtn setImageEdgeInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    [self addSubview:self.voteBtn];

    self.voteCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width-20, frame.size.height-26, 20, 26)];
    self.voteCountLabel.textAlignment = NSTextAlignmentCenter;
    self.voteCountLabel.text = @"0";
    self.voteCountLabel.textColor = [UIColor whiteColor];
    self.voteCountLabel.font = [UIFont systemFontOfSize:8];
    self.voteCountLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:self.voteCountLabel];
   
    
    self.itemStyle = ActivityTravelItemStyleNormal;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)voteBtnDidTap{
    if (self.voteBtn.selected) {
        //不能取消投票。。。
        return;
    }
    if (self.changedBlock) {
        self.voteBtn.selected = self.changedBlock(self.voteBtn.selected);
    }
}


- (void)setItemStyle:(ActivityTravelItemStyle)itemStyle{

    _itemStyle = itemStyle;
    if (self.itemStyle==ActivityTravelItemStyleNormal) {
        [self.styleImageView removeFromSuperview];
        self.styleImageView = nil;
    }else{
    
        if (nil==self.styleImageView) {
            self.styleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
            [self addSubview:self.styleImageView];
        }
        self.styleImageView.image = [self getStyleImageForStyle:self.itemStyle];
    }
}

- (UIImage *)getStyleImageForStyle:(ActivityTravelItemStyle)style{
    
    UIImage *img = nil;
    switch (style) {
        case ActivityTravelItemStyleCrown:
            img = [UIImage imageNamed:@"rank1.png"];
//            self.styleImageView.backgroundColor = [UIColor redColor];
            break;
        case ActivityTravelItemStyleDiamond:
            img = [UIImage imageNamed:@"rank2.png"];
//            self.styleImageView.backgroundColor = [UIColor greenColor];
            break;
        case ActivityTravelItemStylePlatinum:
            img = [UIImage imageNamed:@"rank3.png"];
            
//            self.styleImageView.image = img;
            break;
        default:
//            self.styleImageView.backgroundColor = [UIColor clearColor];
            break;
    }
    return img;
}

@end
