//
//  JJWhosViewCell.h
//  Footprints
//
//  Created by Jinjin on 15/1/12.
//  Copyright (c) 2015年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJWhosViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detaiTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *chooseBtn;
@property (assign,nonatomic) BOOL choosed;

- (void)setDetailModel:(BOOL)isShowDetail;

- (void)showBottomLine:(BOOL)show withInset:(UIEdgeInsets)inset;
- (void)showTopLine:(BOOL)show withInset:(UIEdgeInsets)inset;
@end
