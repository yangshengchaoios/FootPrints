//
//  JJPreviewImageView.m
//  Footprints
//
//  Created by tt on 14/10/30.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJPreviewImageView.h"

@interface JJPreviewImageView ()
@property (nonatomic,strong) UIButton *closeBtn;
@property (nonatomic,strong) CloseBlock closeAction;
@end


@implementation JJPreviewImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setFrame:(CGRect)frame{
    
    [super setFrame:frame];
    self.imageView.frame = self.bounds;
}


- (void)setIsEditing:(BOOL)isEditing{

    _isEditing = isEditing;
    self.closeBtn.hidden = !isEditing;
}


- (id)initWithFrame:(CGRect)frame andCloseAction:(CloseBlock) closeAction{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.imageView];
        
        self.closeAction = closeAction;
        
        self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.closeBtn.frame = CGRectMake(0, 0, 25, 25);
        self.closeBtn.backgroundColor = [UIColor clearColor];
        self.closeBtn.hidden = YES;
        [self.closeBtn setImage:[UIImage imageNamed:@"voice_deleted.png"] forState:UIControlStateNormal];
        [self.closeBtn addTarget:self action:@selector(closeBtnDidTap) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.closeBtn];
    }
    return self;
}

- (void)closeBtnDidTap{
    
    if (self.closeAction) {
        self.closeAction(self);
    }
}

@end
