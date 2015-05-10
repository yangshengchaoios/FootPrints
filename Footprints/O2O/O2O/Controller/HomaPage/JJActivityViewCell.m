//
//  JJActivityViewCell.m
//  Footprints
//
//  Created by Jinjin on 14/11/17.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJActivityViewCell.h"

@implementation JJActivityViewCell

- (void)awakeFromNib {
    // Initialization code
    WS(ws);
    self.realContent.clipsToBounds = YES;
    self.realContent.layer.cornerRadius = 4;
    self.realContent.layer.borderColor = kDefaultBorderColor.CGColor;
    self.realContent.layer.borderWidth = kDefaultBorderWidth;
    [self.realContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.contentView);
    }];
    
    self.countDownLabel.superview.backgroundColor = kDefaultBorderColor;
    self.lineView.backgroundColor = kDefaultBorderColor;
    
    UIColor *textColor = RGB(51, 51, 51);
    self.detailLabel.textColor = textColor;
    self.timeLabel.textColor = textColor;
    self.worksLabel.textColor = textColor;
    self.viewsLabel.textColor = textColor;
    self.activityTitleLabel.textColor = textColor;
    self.countDownLabel.textColor = textColor;
    /*
     @property (weak, nonatomic) IBOutlet UILabel *detailLabel;
     @property (weak, nonatomic) IBOutlet UILabel *timeLabel;
     @property (weak, nonatomic) IBOutlet UILabel *worksLabel;
     @property (weak, nonatomic) IBOutlet UILabel *viewsLabel;
     @property (weak, nonatomic) IBOutlet UILabel *activityTitleLabel;
     @property (weak, nonatomic) IBOutlet UILabel *countDownLabel;
     */
}

- (void)setActivityStatus:(ActivityStatus)activityStatus{
    
    if (_activityStatus==activityStatus) {
        return;
    }
    _activityStatus = activityStatus;
    switch (_activityStatus) {
            
        case ActivityStatusVoting:
            self.markView.image = [UIImage imageNamed:@"huodongpingshenzhong.png"];
            break;
        case ActivityStatusEnd:
            self.markView.image = [UIImage imageNamed:@"yijieshu.png"];
            break;
        default:
            self.markView.image = [UIImage imageNamed:@"huodongjinxingzhong.png"];
            break;
    }
}
@end
