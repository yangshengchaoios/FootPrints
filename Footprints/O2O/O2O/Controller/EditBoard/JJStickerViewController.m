//
//  JJStickerViewController.m
//  Footprints
//
//  Created by tt on 14/11/4.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJStickerViewController.h"
#import "JJImageSticker.h"

#define kStickerHeight 75
#define kStickerItemHeight 40
#define kStickerItemWidth 30
@interface JJStickerViewController ()<JJStickerViewDelegate>
@property (nonatomic, strong) UIImageView *orignalImgView;
@property (nonatomic,strong) NSArray *stickerNames;

@property (nonatomic, strong) NSMutableArray *stikcerArray;
@property (nonatomic, assign) NSInteger curStikcer;

@property (nonatomic, assign) CGPoint preCenter;
@end

@implementation JJStickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.preCenter = CGPointMake(60, 60);
    self.curStikcer = -1;
    self.stikcerArray = [@[] mutableCopy];
    
    self.stickerNames = @[@"ban.png",
                          @"ear_1.png",
                          @"ear.png",
                          @"glasses.png",
                          @"hat.png",
                          @"ice_cream.png",
                          @"lips.png",
                          @"marvel.png",
                          @"moustache.png",
                          @"snowflake.png",
                          @"watermelon.png"];
    
    //添加滤镜效果选择器
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kStickerHeight)];
    CGFloat xOffset = 15;
    CGFloat itemOffset = 22;
    CGFloat yOffset = 20;
    scroll.backgroundColor = [UIColor clearColor];
    for (NSInteger index=0; index<self.stickerNames.count; index++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(xOffset+index*(kStickerItemWidth+itemOffset), yOffset, kStickerItemWidth, kStickerItemHeight);
        btn.tag = index;
        [btn setImage:[UIImage imageNamed:self.stickerNames[index]] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(stickerDidChoose:) forControlEvents:UIControlEventTouchUpInside];
        [scroll addSubview:btn];
    }
    scroll.contentSize = CGSizeMake(MAX((kStickerItemWidth+itemOffset)*self.stickerNames.count + xOffset*2, CGRectGetWidth(scroll.frame)+1), CGRectGetHeight(scroll.frame));
    [self.bottomToolsBar addSubview:scroll];
    
    self.orignalImgView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    self.orignalImgView.image = [self.delegate doingImage];
    self.orignalImgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.orignalImgView.clipsToBounds = YES;
    self.orignalImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.orignalImgView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(editSticker:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = self.view.bounds;
    [self.contentView addSubview:btn];
    
    self.contentView.clipsToBounds  =  YES;
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

- (CGRect)bottomToolsBarFrame{
    
    return CGRectMake(0, CGRectGetHeight(self.view.frame)-kStickerHeight, CGRectGetWidth(self.view.frame), kStickerHeight);
}

- (id)editedResult{
    
    return self.orignalImgView.image;
}

- (void)selfDidOpen{

}

- (void)closeSelf{

    [self editSticker:nil];
    UIGraphicsBeginImageContextWithOptions(self.contentView.frame.size, NO, 0);  //NO，YES 控制是否透明
    [self.contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.orignalImgView.image = image;
    for (JJStickerView *stick in self.stikcerArray) {
        stick.hidden = YES;
    }
    [super closeSelf];
}

- (void)stickerDidChoose:(UIButton *)btn{
    if (btn.tag<self.stickerNames.count) {
        UIImage *image = [UIImage imageNamed:self.stickerNames[btn.tag]];
        JJImageSticker *imgStikcer = [[JJImageSticker alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
        imgStikcer.delegate = self;
        imgStikcer.image = image;
        imgStikcer.center = self.preCenter;
        [self.contentView addSubview:imgStikcer];
        [self.stikcerArray addObject:imgStikcer];
        self.curStikcer = [self.stikcerArray indexOfObject:imgStikcer];
        
        [self editSticker:imgStikcer];
        
        self.preCenter = CGPointMake(self.preCenter.x+15, self.preCenter.y+15);
        if (self.preCenter.x > (self.view.frame.size.width-60) || self.preCenter.y>(self.view.frame.size.height-60)) {
            self.preCenter = CGPointMake(60, 60);
        }
    }
}

- (void)editSticker:(JJStickerView *)sticker{
    
    if ([sticker isKindOfClass:[JJStickerView class]]) {
        [sticker showEditingHandles];
    }
    for (JJStickerView * s in self.stikcerArray) {
        if (s!=sticker) {
            [s hideEditingHandles];
        }
    }
}

#pragma mark - JJStickerViewDelegate

- (void)stickerViewDidBeginEditing:(JJStickerView *)sticker{
    
    [self editSticker:sticker];
    NSLog(@"stickerViewDidBeginEditing");
}
- (void)stickerViewDidEndEditing:(JJStickerView *)sticker{
    NSLog(@"stickerViewDidEndEditing");
}
- (void)stickerViewDidCancelEditing:(JJStickerView *)sticker{
    NSLog(@"stickerViewDidCancelEditing");
}
- (void)stickerViewDidClose:(JJStickerView *)sticker{
    NSLog(@"stickerViewDidClose");
}


@end
