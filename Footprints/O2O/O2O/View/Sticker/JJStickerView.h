//
//  JJStickerView.h
//  Footprints
//
//  Created by tt on 14-10-10.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "JJGripViewBorderView.h"

#define kSPUserResizableViewGlobalInset 9
#define kSPUserResizableViewDefaultMinWidth 48.0
#define kBorderSize 10.0
#define kJJStickerViewControlSize 30.0

@protocol JJStickerViewDelegate;

@interface JJStickerView : UIControl
{
    JJGripViewBorderView *borderView;
}

@property (assign, nonatomic) UIView *contentView;
@property (nonatomic) BOOL preventsPositionOutsideSuperview; //default = YES
@property (nonatomic) BOOL preventsResizing; //default = NO
@property (nonatomic) BOOL preventsDeleting; //default = NO
@property (nonatomic) CGFloat minWidth;
@property (nonatomic) CGFloat minHeight;
@property (nonatomic,assign) CGFloat whScale;

@property (strong, nonatomic) UIImageView *resizingControl;
@property (strong, nonatomic) UIImageView *deleteControl;

@property (strong, nonatomic) id <JJStickerViewDelegate> delegate;

- (void)hideDelHandle;
- (void)showDelHandle;
- (void)hideEditingHandles;
- (void)showEditingHandles;

- (void)didChangeHeight;
@end

@protocol JJStickerViewDelegate <NSObject>
@required
@optional
- (void)stickerViewDidBeginEditing:(JJStickerView *)sticker;
- (void)stickerViewDidEndEditing:(JJStickerView *)sticker;
- (void)stickerViewDidCancelEditing:(JJStickerView *)sticker;
- (void)stickerViewDidClose:(JJStickerView *)sticker;
@end


