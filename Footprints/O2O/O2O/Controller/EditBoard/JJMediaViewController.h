//
//  JJMediaViewController.h
//  Footprints
//
//  Created by tt on 14/11/6.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^DidChooseBlock)(id music);
@interface JJMediaViewController : BaseViewController

@property (nonatomic,strong) DidChooseBlock compelte;
@property (nonatomic,strong) BackgroundMusicModel *model;
- (id)initWithDidChooseActions:(DidChooseBlock)compelte;
@end
