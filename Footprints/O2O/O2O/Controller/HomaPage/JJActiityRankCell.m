//
//  JJActiityRankCell.m
//  Footprints
//
//  Created by Jinjin on 14/11/18.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJActiityRankCell.h"

@implementation JJActiityRankCell

- (void)awakeFromNib {
    // Initialization code
    self.realContentView.backgroundColor = [UIColor whiteColor];
    self.realContentView.clipsToBounds = YES;
    self.realContentView.layer.borderColor = kDefaultBorderColor.CGColor;
    self.realContentView.layer.borderWidth = kDefaultBorderWidth;
    WS(ws);
    [self.realContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.contentView).with.insets(UIEdgeInsetsMake(10, 10, 10, 10));
    }];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tap.numberOfTapsRequired = 1;
    [self.contentView addGestureRecognizer:tap];
    
    
    CGFloat leftPadding = 65;
    CGFloat width = SCREEN_WIDTH-20-leftPadding;
    CGFloat itemWidth = 60;
    CGFloat rightPadding = 10;
    CGFloat itemOffset = (width-rightPadding-itemWidth*3)/2;
    
    self.view1.backgroundColor = [UIColor clearColor];
    self.view1.center = (CGPointMake(leftPadding + itemWidth/2, 42));
    
    
    self.view2.backgroundColor = [UIColor clearColor];
    self.view2.center = (CGPointMake(leftPadding + itemWidth + itemOffset + itemWidth/2, 42));
    
    
    self.view3.backgroundColor = [UIColor clearColor];
    self.view3.center = (CGPointMake(leftPadding + (itemWidth + itemOffset)*2 + itemWidth/2, 42));
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)didTap:(UITapGestureRecognizer *)tap{
    
    NSArray *views = @[self.view1,self.view2,self.view3];
    for (UIView *view in views) {
        if (!view.hidden && CGRectContainsPoint(view.frame, [tap locationInView:self.contentView])) {
            if (self.block) {
                self.block(view.tag-2000);
            }
        }
    }
}

- (void)setRanksWithData:(NSArray *)datas{
    
    for (NSInteger index=0; index<3; index++) {
        
        UIView *view = [self.contentView viewWithTag:2000+index];
        if (index<datas.count) {
            view.hidden = NO;
            ActivityTravelModel *model = datas[index];
            UIImageView *iconView = (id)[view viewWithTag:1000];
            iconView.clipsToBounds = YES;
            iconView.layer.cornerRadius = iconView.frame.size.width/2;
            UILabel *nameLabel = (id)[view viewWithTag:1001];
            UILabel *rankLabel = (id)[view viewWithTag:1002];
            
            [iconView setImageWithURLString:model.memberHeadimg placeholderImage:nil];
            nameLabel.text = model.memberName;
            rankLabel.text = [NSString stringWithFormat:@"得票: %ld",(long)model.voteCount];
            
        }else{
        
            view.hidden = YES;
        }
    }
}
@end
