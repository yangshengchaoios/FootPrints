//
//  JJActivityTravelsCell.h
//  Footprints
//
//  Created by Jinjin on 14/11/18.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJActivityTravelItem.h"

typedef void(^ItemDidSelectedBlock)(NSInteger index);
typedef BOOL(^ItemVoteDidchangedBlock)(NSInteger index,BOOL isVote);

@interface JJActivityTravelsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet JJActivityTravelItem *view1;
@property (weak, nonatomic) IBOutlet JJActivityTravelItem *view2;
@property (nonatomic,strong) NSIndexPath *path;
@property (nonatomic,strong) ItemDidSelectedBlock block;
@property (nonatomic,strong) ItemVoteDidchangedBlock changeBlock;

- (void)setTravelsWithData:(NSArray *)datas;

@end
