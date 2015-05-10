//
//  JJDrawViewController.m
//  Footprints
//
//  Created by tt on 14/11/4.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJDrawViewController.h"
#import "Palette.h"
#import "JJColorSlider.h"
#import <QuartzCore/QuartzCore.h>
#define kToolBarHeight 75
@interface JJDrawViewController (){
    CGPoint MyBeganpoint;
    CGPoint MyMovepoint;
    BOOL begin;
}
@property (nonatomic,strong) Palette *palette;
@property (nonatomic,strong) UIImageView *orignalImgView;
@property (nonatomic,strong) UIColor *curColor;
@property (nonatomic,strong) UIButton *undoBtn;
@property (nonatomic,strong) UIButton *redoBtn;
@property (nonatomic,strong) UIButton *cleanBtn;
@end

@implementation JJDrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = @"涂鸦";
    
    self.orignalImgView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    self.orignalImgView.image = [self.delegate doingImage];
    self.orignalImgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.orignalImgView.clipsToBounds = YES;
    self.orignalImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.orignalImgView];
    
    self.palette = [[Palette alloc] initWithFrame:self.contentView.bounds];
    self.palette.backgroundColor = [UIColor clearColor];
    self.palette.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:self.palette];
    
    self.undoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.undoBtn setImage:[UIImage imageNamed:@"click_previous.png"] forState:UIControlStateHighlighted];
    [self.undoBtn setImage:[UIImage imageNamed:@"previous.png"] forState:UIControlStateNormal];
    [self.undoBtn addTarget:self action:@selector(drawManage:) forControlEvents:UIControlEventTouchUpInside];
    self.undoBtn.frame = CGRectMake(12, 10, 25, 25);
    [self.bottomToolsBar addSubview:self.undoBtn];
    
    self.cleanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cleanBtn setImage:[UIImage imageNamed:@"click_reset.png"] forState:UIControlStateHighlighted];
    [self.cleanBtn setImage:[UIImage imageNamed:@"reset.png"] forState:UIControlStateNormal];
    [self.cleanBtn addTarget:self action:@selector(drawManage:) forControlEvents:UIControlEventTouchUpInside];
    self.cleanBtn.frame = CGRectMake((SCREEN_WIDTH-25)/2, 10, 25, 25);
    [self.bottomToolsBar addSubview:self.cleanBtn];
    
    self.redoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.redoBtn setImage:[UIImage imageNamed:@"click_next.png"] forState:UIControlStateHighlighted];
    [self.redoBtn setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
    [self.redoBtn addTarget:self action:@selector(drawManage:) forControlEvents:UIControlEventTouchUpInside];
    self.redoBtn.frame = CGRectMake(SCREEN_WIDTH-25-12, 10, 25, 25);
    [self.bottomToolsBar addSubview:self.redoBtn];
    
    self.curColor = [UIColor blackColor];
    WeakSelfType blockSelf = self;
    JJColorSlider *colorSlider = [[JJColorSlider alloc] initWithFrame:CGRectMake(20, 38, SCREEN_WIDTH-40, 30) andValueChangeBlock:^(UIColor *newColor) {
        blockSelf.curColor = newColor;
    }];
    [self.bottomToolsBar addSubview:colorSlider];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)selfDidOpen{
    
}


- (CGRect)bottomToolsBarFrame{
    
    return CGRectMake(0, CGRectGetHeight(self.view.frame)-kToolBarHeight, CGRectGetWidth(self.view.frame), kToolBarHeight);
}


- (id)editedResult{
    //支持retina高分的关键
    if(UIGraphicsBeginImageContextWithOptions != NULL)
    {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(ceilf(self.contentView.frame.size.width), self.contentView.frame.size.height), NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(CGSizeMake(ceilf(self.contentView.frame.size.width), self.contentView.frame.size.height));
    }
    //获取图像
    [self.contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)drawManage:(UIButton *)btn{
    
    if (btn==self.undoBtn) {
        [self.palette myLineFinallyRemove];
    }else if (btn==self.redoBtn){
        [self.palette myLineFinallyAdd];
    }else if (btn==self.cleanBtn){
        [self.palette myalllineclear];
    }
}

#pragma mark -
//手指开始触屏开始
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch* touch=[touches anyObject];
    MyBeganpoint=[touch locationInView:self.contentView ];
    if (CGRectContainsPoint(self.contentView.frame, MyBeganpoint)) {
        begin = YES;
        [self.palette Introductionpoint1];
        [self.palette Introductionpoint3:MyBeganpoint];
        [self.palette Introductionpoint4:self.curColor];
        [self.palette Introductionpoint5:1];
    }
}
//手指移动时候发出
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray* MovePointArray=[touches allObjects];
    MyMovepoint=[[MovePointArray objectAtIndex:0] locationInView:self.contentView];
    
    if (CGRectContainsPoint(self.contentView.frame, MyMovepoint) && begin) {
        [self.palette Introductionpoint3:MyMovepoint];
        [self.palette setNeedsDisplay];
    }
}
//当手指离开屏幕时候
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    begin = NO;
    [self.palette Introductionpoint2];
    [self.palette setNeedsDisplay];
}

//电话呼入等事件取消时候发出
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    begin = NO;
    [self.palette Introductionpoint2];
    [self.palette setNeedsDisplay];
}

@end
