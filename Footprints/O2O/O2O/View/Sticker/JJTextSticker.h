//
//  JJTextSticker.h
//  Footprints
//
//  Created by tt on 14/10/28.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJStickerView.h"


@interface JJTextSticker : JJStickerView<UIGestureRecognizerDelegate,UITextFieldDelegate>
{
    CGFloat fontSize;
}
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) NSString *text;
@property (nonatomic,strong) UIFont *font;
@property (nonatomic,strong) UIColor *color;

@end
