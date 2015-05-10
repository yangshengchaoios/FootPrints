//
//  JJPreviewImageView.h
//  Footprints
//
//  Created by tt on 14/10/30.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JJPreviewImageView;
typedef void(^CloseBlock)(JJPreviewImageView *view);

@interface JJPreviewImageView : UIView


@property (nonatomic,assign) BOOL isEditing;

@property (nonatomic,assign) NSString *imageKey;
@property (nonatomic,strong) UIImageView *imageView;
- (id)initWithFrame:(CGRect)frame andCloseAction:(CloseBlock) closeAction;
@end
