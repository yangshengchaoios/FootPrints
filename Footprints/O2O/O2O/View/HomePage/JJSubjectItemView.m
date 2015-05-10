//
//  JJSubjectItemView.m
//  Footprints
//
//  Created by tt on 14-10-17.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJSubjectItemView.h"

@interface JJSubjectItemView()

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *readTitleLabel;
@property (nonatomic,strong) UILabel *readCountLabel;
@property (nonatomic,strong) UILabel *timeLabel;

@property (nonatomic,strong) UIImageView *iconImageView;
@property (nonatomic,strong) UIImageView *mainImageView;

@property (nonatomic,strong) UIImageView *bottomToolBar;
@end

@implementation JJSubjectItemView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.bottomToolBar.frame = CGRectMake(0, CGRectGetHeight(rect)-40, CGRectGetWidth(rect), 40);
}


- (void)setupDefaultUI{

    self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    self.iconImageView.clipsToBounds = YES;
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.iconImageView.layer.cornerRadius = CGRectGetWidth(self.iconImageView.frame)/2;
    [self addSubview:self.iconImageView];
    
    
    
    self.mainImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.mainImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.mainImageView];
    
    
    self.bottomToolBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self addSubview:self.bottomToolBar];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 20)];
    [self.bottomToolBar addSubview:self.titleLabel];
    
    self.readTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 50, 20)];
    self.readTitleLabel.text = @"阅读数:";
    [self.bottomToolBar addSubview:self.readTitleLabel];
    
    self.readCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, CGRectGetWidth(self.frame)-50, 20)];
    self.readCountLabel.text = @"0";
    [self.bottomToolBar addSubview:self.readCountLabel];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.frame), 20)];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.text = @"08-26 19:30";
    [self.bottomToolBar addSubview:self.timeLabel];
}

@end
