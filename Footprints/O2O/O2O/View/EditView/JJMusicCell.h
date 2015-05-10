//
//  JJMusicCell.h
//  Footprints
//
//  Created by tt on 14/11/6.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JJMusicCell : UITableViewCell

@property (assign,nonatomic) BOOL playing;
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkBox;
@property (strong,nonatomic) BackgroundMusicModel *muiscModel;

- (void)hideActionBtn:(BOOL)hide;
- (void)chooseThisCell:(BOOL)choose;
- (void)setMuiscModel:(BackgroundMusicModel *)muiscModel andPlayingId:(NSString *)playingId;
@end
