//
//  JJCollectionCell.m
//  Footprints
//
//  Created by Jinjin on 14/12/12.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJCollectionCell.h"

#define kCellheight 60
@implementation JJCollectionCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentBgView.backgroundColor = [UIColor clearColor];
    self.contentBgView.image = [[UIImage imageNamed:@"frame.png"] stretchableImageWithLeftCapWidth:100 topCapHeight:23];
    self.cView.frame = self.contentView.bounds;
    self.checkBtn.frame = CGRectMake(-30, 0, 30, self.frame.size.height);
    self.deleteBtn.frame = CGRectMake(self.frame.size.width, 0, kCellheight, kCellheight);
    self.avatarView.avatarView.layer.cornerRadius = self.avatarView.frame.size.width/2;
    
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwip:)];
    [self addGestureRecognizer:swip];
    
    swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwip:)];
    swip.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swip];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self.cView addGestureRecognizer:tap];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, kCellheight, SCREEN_WIDTH, kDefaultBorderWidth)];
    line.backgroundColor = kDefaultLineColor;
    [self addSubview:line];
    
//    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    WS(ws);
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.cView).with.offset(10);
        make.centerY.mas_equalTo(ws.cView);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.avatarView.mas_right).with.offset(15);
        make.top.mas_equalTo(@10);
        make.width.mas_equalTo(@150);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.nameLabel.mas_right).with.offset(5);
        make.top.mas_equalTo(ws.nameLabel);
        make.right.mas_equalTo(ws.cView).with.offset(-30);
    }];
    
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.nameLabel);
        make.top.mas_equalTo(ws.nameLabel.mas_bottom).with.offset(5);
        make.right.mas_equalTo(ws.cView).with.offset(-30);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setEditing:(BOOL)editing{
    
    self.isChecking = editing;
//    [super setEditing:editing];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    
    [self setIsChecking:editing animation:YES completion:^(BOOL finished) {
        
    }];
//    [super setEditing:editing animated:animated];
}



- (void)didSwip:(UISwipeGestureRecognizer *)ges{
    
    if (ges.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self.delegate collectionCellWilBeginEdit:self];
    }
    
    if (ges.direction == UISwipeGestureRecognizerDirectionRight && !self.isEditing) {
        [self.delegate collectionCellDidSwipToRight:self];
    }
    
    WS(ws);
    BOOL isEndEditingAnimation = self.isEditing && ges.direction == UISwipeGestureRecognizerDirectionRight;
    [self setIsEditing:ges.direction == UISwipeGestureRecognizerDirectionLeft animation:YES completion:^(BOOL finished) {
        if (isEndEditingAnimation) {
            [ws.delegate collectionCellDidEndEdit:ws];
        }
    }];
}

- (void)didTap:(UITapGestureRecognizer *)tap{
    
    if (!self.isChecking) {
        [self.delegate collectionCellDidTap:self];
    }else{
        [self checkBtnDidTap:nil];
        return;
    }
    
    WS(ws);
    BOOL isEndEditingAnimation = self.isEditing;
    [self setIsEditing:NO animation:YES completion:^(BOOL finished) {
        if (isEndEditingAnimation) {
            [ws.delegate collectionCellDidEndEdit:ws];
        }
    }];
}

- (void)setIsChecking:(BOOL)isChecking{
    [self setIsChecking:isChecking animation:YES completion:NULL];
}

- (void)setIsChecking:(BOOL)isChecking  animation:(BOOL) anmation completion:(void (^)(BOOL finished))completion{
    
    if (isChecking != _isChecking){
        
        _isChecking = isChecking;
        WS(ws);
        
        [UIView animateWithDuration:anmation?0.35:0
                              delay:0
             usingSpringWithDamping:0.75
              initialSpringVelocity:15
                            options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                                
                                CGFloat width = ws.contentView.frame.size.width;
                                CGFloat deleteBtnRight = kCellheight;
                                CGFloat checkingBtnWidht = 30;
                                if (isChecking) {
                                    ws.checkBtn.frame = CGRectMake(0, 0, checkingBtnWidht, ws.frame.size.height);
                                    ws.cView.frame = CGRectMake(checkingBtnWidht, 0, width-checkingBtnWidht, ws.cView.frame.size.height);
                                    ws.deleteBtn.frame = CGRectMake(width, 0, deleteBtnRight, ws.frame.size.height);
                                }
                                else{
                                    ws.checkBtn.frame = CGRectMake(-checkingBtnWidht, 0, checkingBtnWidht, ws.frame.size.height);
                                    ws.cView.frame = CGRectMake(0, 0, width, ws.cView.frame.size.height);
                                    ws.deleteBtn.frame = CGRectMake(width, 0, deleteBtnRight, ws.frame.size.height);
                                }
                            } completion:^(BOOL finished) {
                                if (completion) {
                                    completion(finished);
                                }
                            }];
    }
}


- (void)setIsEditing:(BOOL)isEditing{
    [self setIsEditing:isEditing animation:YES completion:NULL];
}

- (void)setIsEditing:(BOOL)isEditing  animation:(BOOL) anmation completion:(void (^)(BOOL finished))completion{
    
    if (isEditing && self.isChecking) {
        return;
    }
    
    if (_isEditing != isEditing){
        
        _isEditing = isEditing;
        
        
        WS(ws);
        [UIView animateWithDuration:anmation?0.35:0
                              delay:0
             usingSpringWithDamping:0.75
              initialSpringVelocity:15
                            options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                                
                                CGFloat width = ws.contentView.frame.size.width;
                                CGFloat deleteBtnRight = kCellheight;
                                if (isEditing) {
                                    ws.cView.frame = CGRectMake(-deleteBtnRight, 0, ws.cView.frame.size.width, ws.cView.frame.size.height);
                                    ws.deleteBtn.frame = CGRectMake(width-deleteBtnRight, 0, deleteBtnRight, ws.frame.size.height);
                                }
                                else{
                                    ws.cView.frame = CGRectMake(0, 0, ws.cView.frame.size.width, ws.cView.frame.size.height);
                                    ws.deleteBtn.frame = CGRectMake(width, 0, deleteBtnRight, ws.frame.size.height);
                                }
                            } completion:^(BOOL finished) {
                                if (completion) {
                                    completion(finished);
                                }
                            }];
    }
}

- (void)setIsChecked:(BOOL)isChecked{
    
    _isChecked  = isChecked;
    self.checkBtn.selected = self.isChecked;
}

- (IBAction)checkBtnDidTap:(id)sender {
    
    self.isChecked = !self.isChecked;
    if (self.isChecked) {
        [self.delegate collectionCellDidCheck:self];
    }else{
        [self.delegate collectionCellDidUnCheck:self];
    }
}

- (IBAction)deleteBtnDidTap:(id)sender {
    
    [self setIsEditing:NO animation:YES completion:^(BOOL finished) {
        
    }];
    [self.delegate collectionCellNeedRemove:self];
}
@end
