//
//  JJMusicCell.m
//  Footprints
//
//  Created by tt on 14/11/6.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJMusicCell.h"

@implementation JJMusicCell

- (void)awakeFromNib {
    // Initialization code
    
    self.actionBtn.frame = CGRectMake(0, (CGRectGetHeight(self.frame)-44)/2, 44, 44);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)hideActionBtn:(BOOL)hide{
    
    self.actionBtn.hidden = hide;
    self.nameLabel.frame = CGRectMake(hide?10:60, (CGRectGetHeight(self.frame)-40)/2, 200, 40);
}

- (void)chooseThisCell:(BOOL)choose{

    [UIView animateWithDuration:0.2 animations:^{
        self.checkBox.alpha = choose?1:0;
    }];
}

- (IBAction)actionBtnDidTap:(id)sender {

    if (self.playing) {
        //停止
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidPlayMusic" object:nil];
    }else{
        //开始
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DidPlayMusic" object:self.muiscModel];
    }
    self.playing = !self.playing;
}

- (void)setMuiscModel:(BackgroundMusicModel *)muiscModel andPlayingId:(NSString *)playingId{
    
    self.muiscModel = muiscModel;
    self.nameLabel.text = [NSString stringWithFormat:@"%@",self.muiscModel.musicName];
    self.playing = [playingId isEqualToString:self.muiscModel.musicId];
}

- (void)setPlaying:(BOOL)playing{

    _playing = playing;
    
    [self.actionBtn setImage:self.playing?[UIImage imageNamed:@"time_out.png"]:[UIImage imageNamed:@"begin.png"] forState:UIControlStateNormal];
}


@end
