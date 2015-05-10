//
//  JJGroupCell.h
//  Footprints
//
//  Created by Jinjin on 14/12/1.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJGroupCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *groupMenberModel;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
- (void)showBottomLine:(BOOL)show withInset:(UIEdgeInsets)inset;
- (void)showTopLine:(BOOL)show withInset:(UIEdgeInsets)inset;
@end
