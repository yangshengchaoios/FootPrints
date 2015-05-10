//
//  JJAddTextViewController.m
//  Footprints
//
//  Created by tt on 14/11/5.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJAddTextViewController.h"
#import "JJColorSlider.h"
#import "JJTextSticker.h"


@implementation UIView (keyboardAnimationA)

UIViewAnimationOptions curveBOptionsFromCurve(UIViewAnimationCurve curve)
{
    switch (curve)
    {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
        default:
            return curve << 16;
    }
}

+ (void)animateBWithKeyboardNotification:(NSNotification *)note animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    UIViewAnimationOptions curveOptions = curveBOptionsFromCurve([note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]);
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] integerValue] delay:0 options:curveOptions animations:animations completion:completion];
}

@end

#define kToolBarHeight 60
@interface JJAddTextViewController ()<JJStickerViewDelegate>
@property (nonatomic,strong) UIColor *curColor;
@property (nonatomic,strong) UIImageView *orignalImgView;
@property (nonatomic,strong) JJTextSticker *textSticker;
@property (nonatomic, strong) NSArray *fontDatasArray;

@property (strong, nonatomic) UIButton *hideInputBtn;
@property (strong, nonatomic) UITextField *inputView;
@end

@implementation JJAddTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.orignalImgView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    self.orignalImgView.image = [self.delegate doingImage];
    self.orignalImgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.orignalImgView.clipsToBounds = YES;
    self.orignalImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.orignalImgView];
    
    //文字
    /*
    FZLTCXHJW--GB1-0
    HYf9gj
    SentyTEA-4800
    HYr2gj
    KaiTi */
    self.fontDatasArray = @[@"System",@"FZLTCXHJW--GB1-0",@"HYf9gj",@"SentyTEA-4800",@"HYr2gj",@"KaiTi"];
    NSArray *namesArray = @[@"默认",@"线简",@"化蝶",@"新蒂",@"漫步",@"楷文"];
    CGFloat wOffset = 0;
    UIScrollView *fontScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bottomToolsBar.frame), 30)];
    fontScroll.showsHorizontalScrollIndicator = NO;
    [self.bottomToolsBar addSubview:fontScroll];
    for (NSString *fontName in self.fontDatasArray) {
        
        NSInteger index = [self.fontDatasArray indexOfObject:fontName];
        UIFont *font = index==0?[UIFont systemFontOfSize:12]:[UIFont fontWithName:fontName size:12.0f];
        UIButton *fontBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat width = 70;
        fontBtn.frame = CGRectMake(wOffset, 0, width, 30);
        fontBtn.tag = index;
        [fontBtn setTitle:namesArray[index] forState:UIControlStateNormal];
        fontBtn.titleLabel.font = font;
        [fontBtn addTarget:self action:@selector(didChooseFont:) forControlEvents:UIControlEventTouchUpInside];
        [fontScroll addSubview:fontBtn];
        wOffset += (width+10);
    }
    fontScroll.contentSize = CGSizeMake(wOffset, 30);
    
    self.curColor = [UIColor whiteColor];
    WeakSelfType blockSelf = self;
    JJColorSlider *colorSlider = [[JJColorSlider alloc] initWithFrame:CGRectMake(16, 30, 320-32, 30) andValueChangeBlock:^(UIColor *newColor) {
        blockSelf.curColor = newColor;
        [blockSelf.textSticker setColor:newColor];
    }];
    colorSlider.selectedColorView.backgroundColor = [UIColor whiteColor];
    [self.bottomToolsBar addSubview:colorSlider];
    
    
    self.inputView = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    CGRect frame = self.inputView.frame;
    frame.origin.y = SCREEN_HEIGHT;
    self.inputView.frame  = frame;
    self.inputView.text = @"";
    self.inputView.borderStyle = UITextBorderStyleRoundedRect;
    self.inputView.delegate = self;
    self.inputView.returnKeyType = UIReturnKeyDone;
    [self.inputView addTarget:self action:@selector(inputTextDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated  ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}





-(void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat keyboardHeight = SCREEN_HEIGHT-endFrame.origin.y;
    WS(ws);
    
    [UIView animateBWithKeyboardNotification:notification animations:^{
        
        ws.hideInputBtn.alpha = 1;
        CGRect frame = ws.inputView.frame;
        frame.origin.y = SCREEN_HEIGHT-keyboardHeight-frame.size.height;
        if (endFrame.origin.y==SCREEN_HEIGHT) {
            //隐藏
            frame.origin.y = SCREEN_HEIGHT;
            ws.inputView.text = nil;
            ws.hideInputBtn.alpha = 0;
        }else{
            ws.hideInputBtn.alpha = 1;
        }
        
        ws.inputView.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)inputTextDidChange:(UITextField *)field{
    
    self.textSticker.text = field.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
        [self.inputView resignFirstResponder];
    return YES;
}

- (void)beginEdit{
    [self.inputView becomeFirstResponder];
    if (nil==self.hideInputBtn) {
        self.hideInputBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.hideInputBtn.alpha = 0;
        self.hideInputBtn.frame = self.view.bounds;
        [self.hideInputBtn addTarget:self action:@selector(hideInput) forControlEvents:UIControlEventTouchUpInside];
        self.hideInputBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    self.inputView.text = [self.textSticker.text isEqualToString:@"请输入文字"]?nil:self.textSticker.text;
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.inputView];
    [[[UIApplication sharedApplication] keyWindow] insertSubview:self.hideInputBtn belowSubview:self.inputView];
}


- (void)hideInput{
    [self.inputView resignFirstResponder];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a littlduie preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (CGRect)bottomToolsBarFrame{
    
    return CGRectMake(0, CGRectGetHeight(self.view.frame)-kToolBarHeight, CGRectGetWidth(self.view.frame), kToolBarHeight);
}


- (void)selfDidOpen{
    self.textSticker = [[JJTextSticker alloc] initWithFrame:CGRectMake(40, 100, 200, 70)];
    self.textSticker.center = CGPointMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height/2);
//    self.textSticker.delegate = self;
//    [self.textSticker showEditingHandles];
//    [self.textSticker hideDelHandle];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(beginEdit)];
    [self.textSticker addGestureRecognizer:tap];
    [self.contentView addSubview:self.textSticker];
}

- (void)closeSelf{
    
    [self.textSticker hideEditingHandles];
    UIGraphicsBeginImageContextWithOptions(self.contentView.frame.size, NO, 0);  //NO，YES 控制是否透明
    [self.contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.orignalImgView.image = image;
    self.textSticker.hidden = YES;
    [super closeSelf];
}


- (id)editedResult{

    return self.orignalImgView.image;
}


- (void)didChooseFont:(UIButton *)btn{
    
    NSString *fontName = [self.fontDatasArray objectAtIndex:btn.tag];
    [self.textSticker setFont:btn.tag==0?[UIFont systemFontOfSize:14]:[UIFont fontWithName:fontName size:14]];
}


#pragma mark - JJStickerViewDelegate

- (void)stickerViewDidBeginEditing:(JJStickerView *)sticker{
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
