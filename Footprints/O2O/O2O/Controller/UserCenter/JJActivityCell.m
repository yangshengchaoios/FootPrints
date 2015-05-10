//
//  JJActivityCell.m
//  Footprints
//
//  Created by Jinjin on 14/11/25.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJActivityCell.h"
#import "TimeUtils.h"

#define CELL_TOP_HEIGHT 24
#define CELL_BOTTOM_HEIGHT 8
#define IMG_ITEM_WIDTH 60
#define IMG_ITEM_HEIGHT 60
#define IMG_ITEM_OFFSET 10

@implementation JJActivityCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    WS(ws);
    [self.lineImageVIew mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@43);
        make.top.mas_equalTo(ws);
        make.height.mas_equalTo(ws).with.offset(1);
        make.width.mas_equalTo(@20);
    }];
    self.activityTitleLabel.textColor = RGB(40, 40, 40);
    [self.activityTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.lineImageVIew.mas_right).with.offset(10);
        make.top.mas_equalTo(ws).with.offset(0);
        make.height.mas_equalTo(@16);
        make.right.mas_equalTo(ws).with.offset(-10);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.activityTitleLabel);
        make.top.mas_equalTo(ws.activityTitleLabel.mas_bottom).with.offset(2);
        make.height.mas_equalTo(@16);
        make.right.mas_equalTo(ws).with.offset(-10);
    }];
    
    self.dateLabel.textColor = RGB(40, 40, 40);
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@0);
        make.top.mas_equalTo(ws).with.offset(0);
        make.height.mas_equalTo(@16);
        make.right.mas_equalTo(ws.lineImageVIew.mas_left);
    }];
    
    [self.activityIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.activityTitleLabel.mas_right).with.offset(3);
        make.top.mas_equalTo(ws).with.offset(0);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    [self.rankingIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.activityIcon.mas_right).with.offset(5);
        make.top.mas_equalTo(ws).with.offset(0);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#define kImageBaseTag 201231
- (void)setTravelModel:(DetailTravelModel *)travelModel{
    
    _travelModel = travelModel;
    WS(ws);
    NSInteger count = self.travelModel.detailImages.count;
    for (NSInteger index=0;index<9;index++) {
        UIImageView *imageView = (id)[self viewWithTag:index+kImageBaseTag];
        if (index<count) {
            if (nil==imageView) {
                imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
                imageView.clipsToBounds = YES;
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                [self addSubview:imageView];
                [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    [ws makeConstraintsFor:make atIndex:index ofCount:count];
                }];
            }
            else{
                [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    [ws makeConstraintsFor:make atIndex:index ofCount:count];
                }];
            }
            imageView.tag = index+kImageBaseTag;
            DetailImageModel *imgModel = self.travelModel.detailImages[index];
            [imageView sd_setImageWithURL:[NSURL URLWithString:imgModel.imageUrl] placeholderImage:nil];
        }else{
            //释放该位置的图片
            [imageView removeFromSuperview];
        }
    }
    self.activityTitleLabel.text = travelModel.title;
    
    CGFloat width = ceil([self textWidthWithFont:self.activityTitleLabel.font lineBreakMode:self.activityTitleLabel.lineBreakMode forStr:self.activityTitleLabel.text]);
    width = MIN(SCREEN_WIDTH-73-10, width);
    [self.activityTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.lineImageVIew.mas_right).with.offset(10);
        make.top.mas_equalTo(ws).with.offset(0);
        make.height.mas_equalTo(@16);
        make.width.mas_equalTo(@(width));
    }];
    
    NSString *visible = @"";
    switch (self.travelModel.visibleRange) {
        case 0:
        visible = @"私密";
            break;
        case 1:
            visible = @"所有人可见";
            break;
        case 2:
            visible = @"粉丝可见";
            break;
        case 3:
            visible = @"好友可见";
            break;
        case 4:
            visible = @"分组可见";
            break;
        default:
            break;
    }
    
    self.timeLabel.text = [NSString stringWithFormat:@"%@  %@",[TimeUtils timeStringFromDate:self.travelModel.addDate withFormat:@"HH:mm"],visible];
    self.activityIcon.hidden = !travelModel.isJoinActivity;
    self.rankingIcon.hidden = !travelModel.isJoinActivity;
    self.rankingIcon.image = [self getStyleImageForRanking:travelModel.ranking];
}

-(CGFloat)textWidthWithFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode forStr:(NSString *)str{
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize constraint = CGSizeMake(MAXFLOAT, MAXFLOAT);
    CGSize size = [str boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading  attributes:attributes context:nil].size;
    CGFloat height = ceilf(size.width);
    return height;
}


+ (CGFloat)heightForFCPhotoCell:(NSInteger)imgCount{
    
    CGFloat photoViewHeight = (ceil(imgCount/3.0))*(IMG_ITEM_HEIGHT+IMG_ITEM_OFFSET);
    return CELL_TOP_HEIGHT+photoViewHeight+CELL_BOTTOM_HEIGHT+30;
}

- (void)makeConstraintsFor:(MASConstraintMaker *)make atIndex:(NSInteger)index ofCount:(NSInteger)tatolCount{
    
    make.size.mas_equalTo(CGSizeMake(IMG_ITEM_WIDTH, IMG_ITEM_HEIGHT));
    make.left.mas_equalTo(self.timeLabel).with.offset((index%3)*(IMG_ITEM_WIDTH+IMG_ITEM_OFFSET));
    make.top.mas_equalTo(self.timeLabel.mas_bottom).with.offset(8+(index/3)*(IMG_ITEM_HEIGHT+IMG_ITEM_OFFSET));
}


- (UIImage *)getStyleImageForRanking:(NSInteger)ranking{
    
    UIImage *img = nil;
    switch (ranking) {
        case 1:
            img = [UIImage imageNamed:@"rank1.png"];
            break;
        case 2:
            img = [UIImage imageNamed:@"rank2.png"];
            break;
        case 3:
            img = [UIImage imageNamed:@"rank3.png"];
            break;
        default:
            
            break;
    }
    return img;
}

@end
