//
//  JJActiityRankCell.h
//  Footprints
//
//  Created by Jinjin on 14/11/18.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DidChooseRankBlock)(NSInteger rank);

@interface JJActiityRankCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;
@property (nonatomic,strong) DidChooseRankBlock block;
@property (weak, nonatomic) IBOutlet UIView *realContentView;

- (void)setRanksWithData:(NSArray *)datas;
@end
