//
//  JJHomeCollectionViewCell.m
//  Footprints
//
//  Created by Jinjin on 14/11/11.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJHomeCollectionViewCell.h"

@implementation JJHomeCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    self.avatarImageView.avatarView.layer.cornerRadius = CGRectGetWidth(self.avatarImageView.frame)/2;
}

@end
