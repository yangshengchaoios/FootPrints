//
//  JJAvatarView.m
//  Footprints
//
//  Created by Jinjin on 15/1/22.
//  Copyright (c) 2015年 JiaJun. All rights reserved.
//

#import "JJAvatarView.h"

@implementation JJAvatarView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib{
    //searchbar_1.png
    //searchbar.png
    
    self.backgroundColor = [UIColor clearColor];
}

- (UIImageView *)avatarView{

    WS(ws);
    if (nil==_avatarView) {
        self.avatarView = [[UIImageView alloc] init];
        _avatarView.clipsToBounds = YES;
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_avatarView];
        [self bringSubviewToFront:self.iconView];
        [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(ws);
        }];
    }
    
    return _avatarView;
}

- (UIImageView *)iconView{

    if (nil==_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.clipsToBounds = YES;
        _iconView.hidden = YES;
        [self addSubview:_iconView];
        _iconView.image = [UIImage imageNamed:@"guan.png"];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.frame = CGRectMake(-2, -2, 20, 20);
    }
    
    CGFloat width = MIN(20, self.frame.size.width*0.4);
    width = MAX(width, 12);
    _iconView.frame = CGRectMake(-2, -2, width, width);
    return _iconView;
}

- (JJAvatarView *)init{
    
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        
        WS(ws);
        if (nil==self.avatarView) {
            self.avatarView = [[UIImageView alloc] init];
            self.avatarView.clipsToBounds = YES;
            self.avatarView.contentMode = UIViewContentModeScaleAspectFill;
            [self addSubview:self.avatarView];
            [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(ws);
            }];
        }
        
        if (nil==self.iconView) {
            self.iconView = [[UIImageView alloc] init];
            self.iconView.clipsToBounds = YES;
            self.iconView.hidden = YES;
            [self addSubview:self.iconView];
            self.iconView.image = [UIImage imageNamed:@"guan.png"];
            self.iconView.contentMode = UIViewContentModeScaleAspectFill;
            self.iconView.frame = CGRectMake(-2, -2, 20, 20);
        }
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    
    [super setFrame:frame];
}

- (void)bindUserData:(JJMemberModel *)user{
    [self.avatarView setImageWithURLString:user.headImage placeholderImage:kPlaceHolderImage];
    self.iconView.hidden = user.memberStatus!=MemberStatusOfficer;
}
@end
