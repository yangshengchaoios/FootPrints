//
//  JJEditViewController.m
//  Footprints
//
//  Created by tt on 14/11/3.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJEditViewController.h"

@interface JJEditViewController ()

- (IBAction)completeBtnDidTap:(id)sender;
- (IBAction)cancleBtnDidTap:(id)sender;

@end

@implementation JJEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.contentView.frame = [self.delegate imageStartFrame];
    self.topToolsBar.frame = CGRectMake(0, -CGRectGetHeight(self.topToolsBar.frame), CGRectGetWidth(self.topToolsBar.frame), CGRectGetHeight(self.topToolsBar.frame));
    self.bottomToolsBar.frame = CGRectMake(0,  CGRectGetHeight(self.view.frame), CGRectGetWidth([self bottomToolsBarFrame]), CGRectGetHeight([self bottomToolsBarFrame]));
    
    self.view.backgroundColor = RGB(38, 38, 38);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)setEditImage:(UIImage *)img{

}


- (id)editedResult{
    
    return nil;
}



- (CGRect)getStartFrame{
    //245 * 385
    CGFloat scale = 640.0/1008;
    CGFloat offset = 0;
    CGFloat bottom = 0;
    CGFloat othersHeight = CGRectGetHeight(self.topToolsBar.frame)+CGRectGetHeight(self.bottomToolsBar.frame)+bottom;
    CGFloat maxWidth = CGRectGetWidth(self.view.frame)-offset*2;
    CGFloat maxHeight = CGRectGetHeight(self.view.frame)-offset*2-othersHeight;
    
    CGFloat width = 0;
    CGFloat height = 0;
    
    width = maxWidth;
    height = (int)maxWidth/scale;
    if (height>maxHeight) {
        height = maxHeight;
        width = (int)maxHeight*scale;
    }
    return CGRectMake(floor((CGRectGetWidth(self.view.frame)-width)/2.0), floor(CGRectGetHeight(self.topToolsBar.frame)+(CGRectGetHeight(self.view.frame)-othersHeight-height)/2), floor(width), floor(height));
}

- (CGRect)bottomToolsBarFrame{
    
    return CGRectMake(0, CGRectGetHeight(self.view.frame)-50, CGRectGetWidth(self.view.frame), 50);
}

- (void)selfDidOpen{}

- (void)openSelf{
    WeakSelfType blockSelf = self;
    [UIView animateWithDuration:0.45 animations:^{
        blockSelf.contentView.frame = [blockSelf getStartFrame];
        blockSelf.topToolsBar.frame = CGRectMake(0, 0, CGRectGetWidth(blockSelf.topToolsBar.frame), CGRectGetHeight(blockSelf.topToolsBar.frame));
        blockSelf.bottomToolsBar.frame = [blockSelf bottomToolsBarFrame];
    } completion:^(BOOL finished) {
        [blockSelf selfDidOpen];
    }];
}

- (void)closeSelf{
    
    WeakSelfType blockSelf = self;
    [UIView animateWithDuration:0.45 animations:^{
        blockSelf.topToolsBar.frame = CGRectMake(0, -CGRectGetHeight(blockSelf.topToolsBar.frame), CGRectGetWidth(blockSelf.topToolsBar.frame), CGRectGetHeight(blockSelf.topToolsBar.frame));
        blockSelf.bottomToolsBar.frame = CGRectMake(0, CGRectGetHeight(blockSelf.view.frame)+CGRectGetHeight(blockSelf.bottomToolsBar.frame), CGRectGetWidth(blockSelf.bottomToolsBar.frame), CGRectGetHeight(blockSelf.bottomToolsBar.frame));
        blockSelf.contentView.frame = [blockSelf.delegate imageEndFrame];
        
    } completion:^(BOOL finished) {
        [blockSelf dismissViewControllerAnimated:NO completion:^{
            if (blockSelf.delegate && [blockSelf.delegate respondsToSelector:@selector(didClosedView:)]) {
                [blockSelf.delegate didClosedView:blockSelf];
            }
        }];
    }];
}

- (IBAction)completeBtnDidTap:(id)sender {
 
    if (self.delegate && [self.delegate respondsToSelector:@selector(willCloseView:)]) {
        [self.delegate willCloseView:self];
    }
    //TODO 生成图片
    [self closeSelf];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCompletedEdit: withResult:)]) {
        [self.delegate didCompletedEdit:self withResult:[self editedResult]];
    }
}

- (IBAction)cancleBtnDidTap:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willCloseView:)]) {
        [self.delegate willCloseView:self];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCancleEdit:)]) {
        [self.delegate didCancleEdit:self];
    }
    
    [self closeSelf];
}

@end
