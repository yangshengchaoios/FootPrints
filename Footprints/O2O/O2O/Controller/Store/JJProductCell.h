//
//  JJProductCell.h
//  Footprints
//
//  Created by Jinjin on 14/12/3.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^ExchangeBlock)(GiftProductModel *model);

@interface JJProductCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *realCotent;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *jifenLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarLabel;
@property (weak, nonatomic) IBOutlet UIButton *exchangeBtn;
@property (nonatomic,strong) GiftProductModel *model;
@property (nonatomic,strong) ExchangeBlock exChangeBlock;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
- (IBAction)exchangeBtnDidTap:(id)sender;
@end
