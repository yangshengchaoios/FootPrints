//
//  JJActivityViewCell.h
//  Footprints
//
//  Created by Jinjin on 14/11/17.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface JJActivityViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *markView;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *worksLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewsLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *countDownLabel;
@property (weak, nonatomic) IBOutlet UIView *realContent;
@property (weak, nonatomic) IBOutlet UIView *lineView;

@property (assign, nonatomic) ActivityStatus activityStatus;


@end
