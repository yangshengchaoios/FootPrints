//
//  JJCollectionCell.h
//  Footprints
//
//  Created by Jinjin on 14/12/12.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JJCollectionCell;
@protocol JJCollectionCellDelegate <NSObject>

@optional
- (void)collectionCellDidCheck:(JJCollectionCell *)cell;
- (void)collectionCellDidUnCheck:(JJCollectionCell *)cell;

- (void)collectionCellWilBeginEdit:(JJCollectionCell *)cell;
- (void)collectionCellDidEndEdit:(JJCollectionCell *)cell;
- (void)collectionCellDidTap:(JJCollectionCell *)cell;
- (void)collectionCellDidSwipToRight:(JJCollectionCell *)cell;
- (void)collectionCellNeedRemove:(JJCollectionCell *)cell;
@end

@interface JJCollectionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet JJAvatarView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contentBgView;
@property (weak, nonatomic) IBOutlet UIView *cView;
@property (nonatomic,weak) id<JJCollectionCellDelegate>delegate;

- (IBAction)checkBtnDidTap:(id)sender;
- (IBAction)deleteBtnDidTap:(id)sender;
- (void)setIsChecking:(BOOL)isChecking  animation:(BOOL) anmation completion:(void (^)(BOOL finished))completion;
- (void)setIsEditing:(BOOL)isEditing  animation:(BOOL) anmation completion:(void (^)(BOOL finished))completion;
@property (nonatomic,assign) BOOL isEditing;
@property (nonatomic,assign) BOOL isChecking;

@property (nonatomic,strong) NSString *dataId;
@property (nonatomic,assign) BOOL isChecked;
@end
