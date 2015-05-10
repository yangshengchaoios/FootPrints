//
//  JJActivityCell.h
//  Footprints
//
//  Created by Jinjin on 14/11/25.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJActivityCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *lineImageVIew;
@property (weak, nonatomic) IBOutlet UILabel *activityTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *activityIcon;
@property (weak, nonatomic) IBOutlet UIImageView *rankingIcon;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
+ (CGFloat)heightForFCPhotoCell:(NSInteger)imgCount;
@property (nonatomic,strong) DetailTravelModel *travelModel;
@end
