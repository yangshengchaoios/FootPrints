//
//  JJEditViewController.h
//  Footprints
//
//  Created by tt on 14/11/3.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "BaseViewController.h"

@class JJEditViewController;
@protocol JJEditViewDelegate <NSObject>

- (void)willCloseView:(JJEditViewController *)controler;
- (void)didClosedView:(JJEditViewController *)controler;
- (void)didCancleEdit:(JJEditViewController *)controler;
- (void)didCompletedEdit:(JJEditViewController *)controler withResult:(id)result;
- (CGRect)imageStartFrame;
- (CGRect)imageEndFrame;
- (UIImage *)originalImage;
- (UIImage *)doingImage;
@end

@interface JJEditViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *topToolsBar;
@property (weak, nonatomic) IBOutlet UIView *bottomToolsBar;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (nonatomic,assign) id<JJEditViewDelegate> delegate;
- (void)openSelf;
- (void)closeSelf;
- (void)selfDidOpen;
- (CGRect)bottomToolsBarFrame;
- (void)setEditImage:(UIImage *)img;
- (CGRect)getStartFrame;
- (id)editedResult;
@end
