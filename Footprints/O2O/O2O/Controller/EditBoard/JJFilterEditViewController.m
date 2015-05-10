//
//  JJFilterEditViewController.m
//  Footprints
//
//  Created by tt on 14/11/3.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJFilterEditViewController.h"
#import "IFVideoCamera.h"

#define kFilterHeight 85
#define kFilterItemWidth 40
#define kFilterItemHeight 54

@interface JJFilterEditViewController ()

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *names;
@property (nonatomic, strong) NSMutableArray *filterImage;
@property (nonatomic, strong) UIImageView *orignalImgView;
@end

@implementation JJFilterEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.items = @[@"Original",
                   @"CILinearToSRGBToneCurve",
                   @"CIPhotoEffectChrome",
                   @"CIPhotoEffectFade",
                   @"CIPhotoEffectInstant",
                   @"CIPhotoEffectMono",
                   @"CIPhotoEffectProcess",
                   @"CIPhotoEffectTransfer",
                   @"CISRGBToneCurveToLinear",
                   ];
    
    self.names = @[@"原始",
                   @"淡雅",
                   @"云端",
                   @"候鸟",
                   @"碧波",
                   @"黑白",
                   @"Mono",
                   @"流年",
                   @"哥特风",
                   ];
    
    [self performSelectorInBackground:@selector(getFilterImage) withObject:nil];
    
    self.orignalImgView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    self.orignalImgView.image = [self.delegate doingImage];
    self.orignalImgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.orignalImgView.clipsToBounds = YES;
    self.orignalImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.orignalImgView];
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

- (void)getFilterImage{
    
    self.filterImage = [@[] mutableCopy];
    UIImage *image = [[self.delegate doingImage] resizedImage:CGSizeMake(90, 120) interpolationQuality:kCGInterpolationDefault];//[UIImage imageNamed:@"0_thumbnail.png"];
    if (image) {
        [self.filterImage addObject:image];
        for (NSInteger index=1; index<self.items.count; index++) {
            UIImage *fliterImage = [self fliterImage:image atIndex:index];
           if(fliterImage) [self.filterImage addObject:fliterImage];
        }
    }
    
    [self performSelectorOnMainThread:@selector(addFilterScroll) withObject:nil waitUntilDone:YES];
}

- (void)addFilterScroll{

    //添加滤镜效果选择器
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kFilterHeight)];
    CGFloat xOffset = 15;
    scroll.showsHorizontalScrollIndicator = NO;
    CGFloat itemOffset = 15;
    CGFloat yOffset = (kFilterHeight-kFilterItemHeight)/2.0-8;
    scroll.backgroundColor = [UIColor clearColor];
    for (NSInteger index=0; index<self.items.count; index++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(xOffset+index*(kFilterItemWidth+itemOffset), yOffset, kFilterItemWidth, kFilterItemHeight);
        [btn setImage:self.filterImage[index] forState:UIControlStateNormal];
        btn.tag = index;
        [btn addTarget:self action:@selector(filterDidChoose:) forControlEvents:UIControlEventTouchUpInside];
        [scroll addSubview:btn];
        
        UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(btn.frame.origin.x, yOffset+kFilterItemHeight, kFilterItemWidth, kFilterHeight-(yOffset+kFilterItemHeight))];
        lable.font = [UIFont systemFontOfSize:10];
        lable.text = self.names[index];
        lable.textColor = [UIColor whiteColor];
        lable.textAlignment = NSTextAlignmentCenter;
        [scroll addSubview:lable];
    }
    scroll.contentSize = CGSizeMake((kFilterItemWidth+itemOffset)*(self.items.count-1)+kFilterItemWidth+ xOffset*2, CGRectGetHeight(scroll.frame));
    [self.bottomToolsBar addSubview:scroll];
}

- (void)selfDidOpen{

}



- (id)editedResult{
    
    return self.orignalImgView.image;
}

- (CGRect)bottomToolsBarFrame{
    
    return CGRectMake(0, CGRectGetHeight(self.view.frame)-kFilterHeight, CGRectGetWidth(self.view.frame), kFilterHeight);
}

- (void)filterDidChoose:(UIButton *)btn{
    
    if (btn.tag==0) {
        self.orignalImgView.image = [self.delegate doingImage];
    }else{
        self.orignalImgView.image = [self fliterImage:[self.delegate doingImage] atIndex:btn.tag];
    }
}

- (UIImage *)fliterImage:(UIImage *)image atIndex:(NSInteger)index{
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    
    CIFilter *filter = [CIFilter filterWithName:self.items[index]
                                  keysAndValues:kCIInputImageKey, ciImage, nil];
    [filter setDefaults];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:[outputImage extent]];
    UIImage *fliterImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return fliterImage;
}


#pragma mark - Video Camera Delegate


@end
