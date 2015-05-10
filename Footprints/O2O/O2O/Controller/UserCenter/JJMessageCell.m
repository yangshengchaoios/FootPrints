//
//  JJMessageCell.m
//  Footprints
//
//  Created by Jinjin on 14/11/25.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJMessageCell.h"
#import "TimeUtils.h"

#define kTextLeftPadding 54
#define kNameHeight 28
#define kAvatarWidht 36
#define kTextFont [UIFont systemFontOfSize:13]
#define TextPadding 4
#define CotentWidth (200)
#define CELL_BOTTOM_HEIGHT 8
@implementation JJMessageCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    WS(ws);
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws).with.offset(8);
        make.top.mas_equalTo(ws).with.offset(9);
        make.size.mas_equalTo(CGSizeMake(kAvatarWidht, kAvatarWidht));
    }];
 
    self.avatarImageView.avatarView.layer.cornerRadius = kAvatarWidht/2;
    
    [self.activityImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(ws).with.offset(-15);
        make.top.mas_equalTo(ws.avatarImageView);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];

    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(ws.timeLabel.mas_bottom);
        make.left.mas_equalTo(@kTextLeftPadding);
        make.height.mas_equalTo(@20);
        make.width.mas_equalTo(@(CotentWidth));
    }];
    [self.voiceView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(@kTextLeftPadding);
        make.top.mas_equalTo(ws.cellType==MessageCellTypeWithTravel?ws.timeLabel.mas_bottom:ws.nameLabel.mas_bottom);
        make.height.mas_equalTo(@25);
        make.width.mas_equalTo(@150);
    }];
    self.voiceView.layer.borderColor = kDefaultLineColor.CGColor;
    self.voiceView.layer.borderWidth = kDefaultBorderWidth;
    self.voiceView.layer.cornerRadius = 6.0f;
    self.voiceView.backgroundColor = [UIColor whiteColor];
    
    
    
    [self.playBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.voiceView);
    }];
//    [self.playBtn setTitleColor:RGB(39, 129, 155) forState:UIControlStateNormal];
    [self.playBtn setTitleColor:RGB(39, 129, 155) forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:@"icon_high_volume.png"] forState:UIControlStateNormal];
    [self.playBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 11, 0, 0)];
    
    [self.playBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];

    self.contentLabel.font = kTextFont;
    self.nameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.toUserLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    tap.delegate = self;
    [self.contentView addGestureRecognizer:tap];
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
    line.backgroundColor = kDefaultLineColor;
    [self.contentView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(ws.contentView).with.offset(-1);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, kDefaultBorderWidth));
    }];
    
//    UIButton *avatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.contentView addSubview:avatarBtn];
//    [avatarBtn addTarget:self action:@selector(avatarDidTap) forControlEvents:UIControlEventTouchUpInside];
//    [avatarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(_avatarBgImageView);
//    }];
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    BOOL begin = NO;
    if (self.cellType==MessageCellTypeWituToUser) {
        begin = YES;
    }else{
        begin = CGRectContainsPoint(self.avatarImageView.frame, [gestureRecognizer locationInView:self.avatarImageView]);
        
    }
    return begin;
}


- (void)didTap:(UITapGestureRecognizer *)tap{

    if (CGRectContainsPoint(self.avatarImageView.frame, [tap locationInView:self.avatarImageView])) {
        if (self.didTap) {
            self.didTap(self.messageModel.memberId?:self.messageModel.friendMemberId);
        }
    }else{
        if (self.cellDidTap) {
            self.cellDidTap(self.messageModel.memberId?:self.messageModel.friendMemberId,self.messageModel.nickName);
        }
    }
}

- (void)avatarDidTap{
    
   
}


- (IBAction)playBtnDidTap:(id)sender {
    
    if (self.audioDidTap) {
        self.audioDidTap(self.messageModel.msgVoice,self.messageModel.messageId,self);
    }
}


- (void)setPlayStatus:(MessagePlayStatus)status{
    
    switch (status) {
        case MessagePlayStatusDownloading:
            [self.playBtn setTitle:@"下载中" forState:UIControlStateNormal];
            break;
        case MessagePlayStatusNormal:
            [self.playBtn setTitle:@"点击播放语音" forState:UIControlStateNormal];
            break;
        case MessagePlayStatusPlaying:
            [self.playBtn setTitle:@"播放中" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (CGFloat)widthForText:(NSString *)text forFont:(UIFont *)font{
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize constraint = CGSizeMake(MAXFLOAT, 100);
     return  [text boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading  attributes:attributes context:nil].size.width;
}

- (void)setCellType:(MessageCellType)cellType{
    
    _cellType = cellType;
    self.toLabel.hidden = cellType==MessageCellTypeWithTravel;
    self.toUserLabel.hidden = cellType==MessageCellTypeWithTravel;
    self.activityImage.hidden = cellType==MessageCellTypeWituToUser;
    if (self.cellType==MessageCellTypeWituToUser) {
        self.toLabel.hidden = [StringUtils isEmpty:self.toUserLabel.text];
    }
    
    
    self.nameLabel.textColor = RGB(39, 129, 155);//(cellType==MessageCellTypeWithTravel)?[UIColor blackColor]:[UIColor redColor];
    self.toUserLabel.textColor = RGB(39, 129, 155);// (cellType==MessageCellTypeWithTravel)?[UIColor blackColor]:[UIColor redColor];
    [self resetLabelFrame];
}

- (void)resetLabelFrame{
    
    WS(ws);
    CGFloat allWidth = kTextLeftPadding;
    CGFloat width = [self widthForText:self.nameLabel.text forFont:self.nameLabel.font];
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (ws.cellType==MessageCellTypeWithTravel) {
            make.right.mas_equalTo(ws.activityImage.mas_left).with.offset(-10);
        }else{
            make.width.mas_equalTo(@(width));
        }
        make.left.mas_equalTo(@kTextLeftPadding);
        make.top.mas_equalTo(ws.contentView);
        make.height.mas_equalTo(@kNameHeight);
    }];
    allWidth += width;
    
    width =[self widthForText:self.toLabel.text forFont:self.toLabel.font];
    [self.toLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.nameLabel);
        make.left.mas_equalTo(ws.nameLabel.mas_right).with.offset(1);
        make.height.mas_equalTo(ws.nameLabel);
        make.width.mas_equalTo(@(width));
    }];
    allWidth += (width+1);
    

    width =[self widthForText:self.toUserLabel.text forFont:self.toUserLabel.font];
    [self.toUserLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(ws.nameLabel);
        make.left.mas_equalTo(ws.toLabel.mas_right).with.offset(1);
        make.height.mas_equalTo(ws.nameLabel);
        make.width.mas_equalTo(@(width));
    }];
    allWidth += (width+4);
    
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (ws.cellType==MessageCellTypeWithTravel) {
            make.centerY.mas_equalTo(ws.nameLabel);
            make.left.mas_equalTo(@(allWidth));
            make.height.mas_equalTo(ws.nameLabel);
            make.right.mas_equalTo(ws.activityImage.mas_left).with.offset(-10);
            
        }else{
            make.right.mas_equalTo(ws.contentView).with.offset(-10);
            make.left.mas_equalTo(ws.avatarImageView.mas_right).with.offset(10);
            make.centerY.mas_equalTo(ws.nameLabel);
            make.height.mas_equalTo(@kNameHeight);
        }
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessageModel:(MessageModel *)messageModel{
    
    _messageModel = messageModel;
    [self.avatarImageView.avatarView setImageWithURLString:messageModel.memberHeadimg placeholderImage:kPlaceHolderImage];
    self.avatarImageView.iconView.hidden = messageModel.memberStatus!=MemberStatusOfficer;
    
    self.nameLabel.text = messageModel.nickName;
    self.toUserLabel.text = messageModel.toNickName;
    if (self.cellType==MessageCellTypeWituToUser) {
        self.toLabel.hidden = [StringUtils isEmpty:messageModel.toNickName];
    }
    self.timeLabel.text = [TimeUtils timeStringFromDate:messageModel.msgDate withFormat:@"MM-dd HH:mm"];
    
    [self.activityImage setImageWithURLString:messageModel.travelImage placeholderImage:nil];

    //contentType
    if (messageModel.msgType == MessageTypeText || messageModel.contentType==2) {
        self.contentLabel.hidden = NO;
        self.voiceView.hidden = YES;
        CGFloat textHeight = 0;
        NSString *text = messageModel.msgContent;
        if (text && text.length>0) {
            textHeight = [text boundingRectWithSize:CGSizeMake(CotentWidth, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:@{NSFontAttributeName:kTextFont} context:nil].size.height+TextPadding*2;
            WS(ws);
            [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(@kTextLeftPadding);
                make.width.mas_equalTo(@CotentWidth);
                make.top.mas_equalTo(ws.cellType==MessageCellTypeWithTravel?ws.nameLabel.mas_bottom:ws.nameLabel.mas_bottom);
                make.height.mas_equalTo(textHeight);
            }];
        }
    }else{
        self.contentLabel.hidden = YES;
        self.voiceView.hidden = NO;
    }
    
    self.contentLabel.text = messageModel.msgContent;
    [self resetLabelFrame];
}

+ (CGFloat)heightForFCPhotoCell:(NSString *)text messageType:(MessageType)type andCellType:(MessageCellType)cellType{
    
    CGFloat contentHeight = 0;
    if (type==MessageTypeText) {
        if (text && text.length>0) {
            contentHeight = [text boundingRectWithSize:CGSizeMake(CotentWidth, 1000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading  attributes:@{NSFontAttributeName:kTextFont} context:nil].size.height+TextPadding*2;
        }
    }
    return MAX((cellType==MessageCellTypeWithTravel?30:30)+contentHeight+CELL_BOTTOM_HEIGHT, 68);
}

@end
