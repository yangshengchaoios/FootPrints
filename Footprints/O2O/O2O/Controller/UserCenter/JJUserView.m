//
//  JJUserView.m
//  Footprints
//
//  Created by Jinjin on 14/12/2.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJUserView.h"

@interface JJUserView()

@end

@implementation JJUserView

- (id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if(self){
        self.avatarView = [[JJAvatarView alloc] init];
        self.avatarView.avatarView.clipsToBounds = YES;
        self.avatarView.avatarView.layer.cornerRadius = 30;
        [self addSubview:self.avatarView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:self.nameLabel];
        
        self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteBtn.backgroundColor = [UIColor clearColor];
        [self.deleteBtn setImage:[UIImage imageNamed:@"icon_red_less.png"] forState:UIControlStateNormal];
        [self addSubview:self.deleteBtn];
        
        WS(ws);
        CGFloat avatarWidth = MIN(frame.size.height, frame.size.width);
        avatarWidth -= 20;
        [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws);
            make.centerX.mas_equalTo(ws);
            make.size.mas_equalTo(CGSizeMake(avatarWidth, avatarWidth));
        }];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(ws);
            make.top.mas_equalTo(ws.avatarView.mas_bottom);
            make.left.mas_equalTo(ws).with.offset(5);
            make.right.mas_equalTo(ws).with.offset(-5);
            make.height.mas_equalTo(@20);
        }];
        [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.avatarView).with.offset(-10);
            make.left.mas_equalTo(ws.avatarView).with.offset(-10);
            make.size.mas_equalTo(CGSizeMake(25, 25));
        }];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    
    [super setFrame:frame];
    CGFloat avatarWidth = 40;
    WS(ws);
    self.avatarView.avatarView.layer.cornerRadius = avatarWidth/2;
    [self.avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws);
        make.centerX.mas_equalTo(ws);
        make.size.mas_equalTo(CGSizeMake(avatarWidth, avatarWidth));
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
