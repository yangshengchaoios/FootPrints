//
//  JJRecordView.h
//  Footprints
//
//  Created by Jinjin on 14/12/21.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DidRecord) (void);

@interface JJRecordView : UIView
@property (nonatomic,assign) BOOL playing,recorded;
@property (nonatomic,assign) CGFloat maxTimes;
@property (nonatomic,assign) CGFloat curTimes;
@property (nonatomic,strong) UILabel *title;
@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIButton *deleteBtn;
@property (nonatomic,strong) UIButton *playBtn;
@property (nonatomic,strong) DidRecord didRecord;
- (NSData *)recordData;
- (void)reset;
- (void)setColor:(UIColor *)color;
@end
