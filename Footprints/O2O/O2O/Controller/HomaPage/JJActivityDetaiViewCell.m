//
//  JJActivityDetaiViewCell.m
//  Footprints
//
//  Created by Jinjin on 14/11/17.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJActivityDetaiViewCell.h"

#define kADFont [UIFont systemFontOfSize:12]


@implementation JJActivityDetaiViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.detailLabel.backgroundColor = [UIColor clearColor];
    self.detailLabel.superview.backgroundColor = [UIColor whiteColor];
    self.backgroundColor = kDefaultViewColor;
    self.detailLabel.textColor = RGB(99, 99, 99);
    self.detailLabel.superview.layer.borderWidth = kDefaultBorderWidth;
    self.detailLabel.superview.layer.borderColor = kDefaultBorderColor.CGColor;
    self.detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.detailLabel.font = kADFont;
    
    WS(ws);
    [self.detailLabel.superview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.contentView).with.insets(UIEdgeInsetsMake(10, 10, 10, 10));
    }];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.detailLabel.superview).with.insets(UIEdgeInsetsMake(5, 5, 5, 5));
    }];
    
    
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)heightForText:(NSString *)text{

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize size = [text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-40, 1000000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:kADFont,NSParagraphStyleAttributeName:paragraphStyle.copy} context:nil].size;
    CGFloat height = MAX(ceil(size.height), 30);
    return height+30;
}

@end
