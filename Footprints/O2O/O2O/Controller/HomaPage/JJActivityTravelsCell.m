//
//  JJActivityTravelsCell.m
//  Footprints
//
//  Created by Jinjin on 14/11/18.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJActivityTravelsCell.h"
#import "TimeUtils.h"
@implementation JJActivityTravelsCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat offset = 8;
    CGFloat scale = 640.0/1008;
    CGFloat width = (SCREEN_WIDTH-offset*3)/2;
    CGFloat height = width/scale;
    self.view1.frame = CGRectMake(8, 0, width, height);
    self.view2.frame = CGRectMake(16+width, 0, width, height);
    self.view1.tag = 2000;
    self.view2.tag = 2001;
    [self.view1 addTarget:self action:@selector(itemDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self.view2 addTarget:self action:@selector(itemDidTap:) forControlEvents:UIControlEventTouchUpInside];
    WeakSelfType blockSelf = self;
    self.view1.changedBlock = ^(BOOL isVote){
        
        return blockSelf.changeBlock(blockSelf.path.row*2,isVote);
    };
    self.view2.changedBlock = ^(BOOL isVote){
        return blockSelf.changeBlock(blockSelf.path.row*2+1,isVote);
    };
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)itemDidTap:(JJActivityTravelItem *)item{
    
    if (self.block) {
        self.block(self.path.row*2+(item.tag-2000));
    }
}

- (void)setTravelsWithData:(NSArray *)datas{
    
    for (NSInteger index=0; index<2; index++) {
        
        JJActivityTravelItem *view = (id)[self.contentView viewWithTag:2000+index];
        if (index<datas.count) {
            view.hidden = NO;
            ActivityTravelModel *model = datas[index];
            view.voteBtn.selected = model.isVote;
            view.voteCountLabel.text = [NSString stringWithFormat:@"%ld",model.voteCount];
            [view.travelImageView setImageWithURLString:model.travelImage placeholderImage:nil];
            [view.avatarImageView.avatarView setImageWithURLString:model.memberHeadimg placeholderImage:nil];
            view.avatarImageView.iconView.hidden = model.memberStatus!=MemberStatusOfficer;
            view.titleLabel.text = model.travelTitle;
            view.timeLabel.text = [TimeUtils timeStringFromDate:model.joinDate withFormat:@"MM-dd HH:mm:ss"];
        }else{
            view.hidden = YES;
        }
    }
}

@end
