//
//  JJImageSticker.m
//  Footprints
//
//  Created by tt on 14/11/4.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJImageSticker.h"

@implementation JJImageSticker

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        self.minHeight = 20;
        self.minWidth = 20;
        
        imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.clipsToBounds = YES;
//        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.contentView = imageView;

        self.preventsPositionOutsideSuperview = NO;
    }
    return self;
}

- (void)setImage:(UIImage *)image{
    
    _image = image;
    imageView.image = image;
//    [self resetFrame];
}

- (void)resetFrame{
    
//    CGSize imgSize = self.image.size;
    CGPoint center = self.center;
//    self.frame = CGRectInset(CGRectMake(0, 0, (imgSize.width/2)*self.image.scale, (imgSize.height/2)*self.image.scale), 10, 10);
    self.frame = CGRectInset(CGRectMake(0, 0, 80, 80), 10, 10);
    self.center = center;
}

@end
