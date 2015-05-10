//
//  JJActivityDetaiViewCell.h
//  Footprints
//
//  Created by Jinjin on 14/11/17.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJActivityDetaiViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
+ (CGFloat)heightForText:(NSString *)text;
@end
