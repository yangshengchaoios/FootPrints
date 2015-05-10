//
//  JJMessageCell.h
//  Footprints
//
//  Created by Jinjin on 14/11/25.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JJMessageCell;
typedef void(^AvatarDidTapBlack)(NSString *memberId);
typedef void(^CellDidTapBlack)(NSString *memberId,NSString *memberName);
typedef void(^AudioDidTapBlack)(NSString *audioPath,NSString *messageId,JJMessageCell *cell);

typedef NS_ENUM(NSInteger, MessageCellType) {
    
    MessageCellTypeWithTravel = 0,
    MessageCellTypeWituToUser,
};

typedef NS_ENUM(NSInteger, MessagePlayStatus) {
    
    MessagePlayStatusNormal = 0,
    MessagePlayStatusDownloading,
    MessagePlayStatusPlaying
};


@interface JJMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet JJAvatarView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *activityImage;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UILabel *toUserLabel;
@property (weak, nonatomic) IBOutlet UIView *voiceView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
- (IBAction)playBtnDidTap:(id)sender;

+ (CGFloat)heightForFCPhotoCell:(NSString *)text messageType:(MessageType)type andCellType:(MessageCellType)cellType;

@property (nonatomic,assign) MessageCellType cellType;
@property (nonatomic,strong) MessageModel *messageModel;

@property (nonatomic,strong) AvatarDidTapBlack didTap;
@property (nonatomic,strong) AudioDidTapBlack audioDidTap;
@property (nonatomic,strong) CellDidTapBlack cellDidTap;
- (void)setPlayStatus:(MessagePlayStatus)status;
@end
