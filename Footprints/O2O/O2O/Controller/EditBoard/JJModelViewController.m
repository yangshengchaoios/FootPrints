//
//  JJModelViewController.m
//  Footprints
//
//  Created by Jinjin on 14/12/17.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJModelViewController.h"
//#import "MeituImageEditView.h"
#import "TimeUtils.h"
#import "BMapKit.h"
#import "ImageCropperView.h"

@implementation UIView (keyboardAnimationA)

UIViewAnimationOptions curveAOptionsFromCurve(UIViewAnimationCurve curve)
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

+ (void)animateAWithKeyboardNotification:(NSNotification *)note animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    UIViewAnimationOptions curveOptions = curveAOptionsFromCurve([note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]);
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] integerValue] delay:0 options:curveOptions animations:animations completion:completion];
}

@end

@interface JJModelViewController ()<BMKLocationServiceDelegate>
@property (nonatomic,strong) UIView *editBoard;
@property (nonatomic,strong) UIImageView *transImageView;
@property (nonatomic,strong) UIImageView *bottomImageView;
@property (nonatomic,strong) UIImageView *coverImageView;
//@property (nonatomic,strong) MeituImageEditView *meituView;
@property (strong, nonatomic) ImageCropperView *ronateCropperView;
@property (nonatomic,strong) UIImage *editImage;
@property (nonatomic,strong) NSMutableArray *fields;
@property (nonatomic,strong) NSMutableArray *locationFields;
@property (nonatomic,strong) BMKLocationService* locService;//定位服务
@property (nonatomic,strong) NSString *location;
@property (nonatomic,assign) BOOL locating;
@property (nonatomic,strong) NSArray *items;

@property (assign, nonatomic) NSInteger inputIndex;
@property (strong, nonatomic) UIButton *hideInputBtn;
@property (strong, nonatomic) UITextField *inputView;
@end

@implementation JJModelViewController
- (void)dealloc
{
    self.locService.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = @"模板";
    
    self.transImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    self.transImageView.clipsToBounds = YES;
    self.transImageView.image = [self.delegate doingImage];
    self.transImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.transImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.transImageView];
    
    self.editBoard = [[UIView alloc] initWithFrame:self.contentView.bounds];
    self.editBoard.hidden = YES;
    self.editBoard.clipsToBounds = YES;
    self.editBoard.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:self.editBoard];
    
    
    // Do any additional setup after loading the view.
    self.bottomImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    self.bottomImageView.clipsToBounds = YES;
    self.bottomImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.bottomImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.editBoard addSubview:self.bottomImageView];
    

    self.coverImageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    self.coverImageView.clipsToBounds = YES;
    self.coverImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.editBoard addSubview:self.coverImageView];
    
    [self loadStyleScroll];
    [self chooseIndex:0];
    //定位
    if (nil==self.locService) {
        self.locService  = [[BMKLocationService alloc] init];
    }
    
    self.inputView = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    CGRect frame = self.inputView.frame;
    frame.origin.y = SCREEN_HEIGHT;
    self.inputView.frame  = frame;
    self.inputView.text = @"";
    self.inputView.borderStyle = UITextBorderStyleRoundedRect;
    self.inputView.delegate = self;
    [self.inputView addTarget:self action:@selector(inputTextDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.locService.delegate = self;
    [self startLocation];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    self.locService.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat keyboardHeight = SCREEN_HEIGHT-endFrame.origin.y;
    WS(ws);
    
    [UIView animateAWithKeyboardNotification:notification animations:^{
        
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
    
    UILabel *label = (id)[self.editBoard viewWithTag:self.inputIndex];
    label.text = field.text;
}


- (void)showInputForIndex:(UITapGestureRecognizer *)tap{
    
    [self.inputView becomeFirstResponder];
    self.inputIndex = [tap.view tag];
    if (nil==self.hideInputBtn) {
        self.hideInputBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.hideInputBtn.alpha = 0;
        self.hideInputBtn.frame = self.view.bounds;
        [self.hideInputBtn addTarget:self action:@selector(hideInput) forControlEvents:UIControlEventTouchUpInside];
        self.hideInputBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.inputView];
    [[[UIApplication sharedApplication] keyWindow] insertSubview:self.hideInputBtn belowSubview:self.inputView];
}


- (void)hideInput{
    [self.inputView resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)selfDidOpen{
    
    self.editBoard.hidden = NO;
}

- (void)closeSelf{
    for (UITextField *field in self.fields) {
        [field resignFirstResponder];
    }
    self.transImageView.image = self.editImage;
    self.editBoard.hidden = YES;
    [super closeSelf];
}

- (id)editedResult{
    
    return self.editImage;
//    return self.orignalImgView.image;
}

- (UIImage *)editImage{
    
    if (nil==_editImage) {
        //支持retina高分的关键
        if(UIGraphicsBeginImageContextWithOptions != NULL)
        {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(ceilf(self.editBoard.frame.size.width), self.editBoard.frame.size.height), NO, 0.0);
        } else {
            UIGraphicsBeginImageContext(CGSizeMake(ceilf(self.editBoard.frame.size.width), self.editBoard.frame.size.height));
        }
        //获取图像
        [self.editBoard.layer renderInContext:UIGraphicsGetCurrentContext()];
        _editImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return _editImage;
}

- (CGRect)rectScaleWithRect:(CGRect)rect scale:(CGFloat)scale
{
    if (scale<=0) {
        scale = 1.0f;
    }
    CGRect retRect = CGRectZero;
    retRect.origin.x = floor(rect.origin.x*scale+0.5);
    retRect.origin.y = floor(rect.origin.y*scale+0.5);
    retRect.size.width = floor(rect.size.width*scale+0.5);
    retRect.size.height = floor(rect.size.height*scale+0.5);
    return  retRect;
}



#define kModelHeight 75
#define kItemHeight 40
- (CGRect)bottomToolsBarFrame{
    
    return CGRectMake(0, CGRectGetHeight(self.view.frame)-kModelHeight, CGRectGetWidth(self.view.frame), kModelHeight);
}


- (void)loadStyleScroll{

    if (self.items.count==0) {
        self.items = [NSArray arrayWithContentsOfFile:
                      [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"model_styles.plist"]];
    }
    //添加滤镜效果选择器
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kModelHeight)];
    CGFloat itemWidth = 30;
    CGFloat xOffset = (SCREEN_WIDTH-6*itemWidth)/7;
    CGFloat yOffset = (kModelHeight-kItemHeight)/2.0;
    for (NSInteger index=0; index<self.items.count; index++) {
        
        NSDictionary *item = self.items[index];
        NSString *cover = item[@"cover"];

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(xOffset+index*(itemWidth+xOffset), yOffset, itemWidth, kItemHeight);
        btn.backgroundColor = [UIColor clearColor];
        btn.tag = index;
        [btn setImage:[UIImage imageNamed:cover] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(filterDidChoose:) forControlEvents:UIControlEventTouchUpInside];
        [scroll addSubview:btn];
    }
    scroll.contentSize = CGSizeMake(MAX((itemWidth+xOffset)*self.items.count + xOffset, CGRectGetWidth(scroll.frame)+1), CGRectGetHeight(scroll.frame));
    [self.bottomToolsBar addSubview:scroll];
}

- (void)filterDidChoose:(UIButton *)btn{
    [self chooseIndex:btn.tag];
}

- (void)chooseIndex:(NSInteger)index{
    
    if (index<self.items.count) {
        
        NSDictionary *item = self.items[index];
        [self resetViewByStyle:item[@"styleName"]];
    }
}

- (void)resetViewByStyle:(NSString *)styleName{
    
    NSDictionary *styleDict = [NSDictionary dictionaryWithContentsOfFile:
                               [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:styleName]];
    for (UIView *view in self.editBoard.subviews) {
        if (view != self.bottomImageView && view != self.coverImageView) {
            [view removeFromSuperview];
        }
    }
    
    if (styleDict) {
        
        CGSize superSize = CGSizeFromString([[styleDict objectForKey:@"SuperViewInfo"] objectForKey:@"size"]);
        CGSize realSize = [self getStartFrame].size;
        
        CGFloat scale = realSize.width/superSize.width;
        
        NSArray *subViewArray = [styleDict objectForKey:@"SubViewArray"];
        NSString *bgName = styleDict[@"SuperViewInfo"][@"background"];
        NSString *coverName = styleDict[@"SuperViewInfo"][@"cover"];
        
        self.bottomImageView.image = [UIImage imageNamed:bgName];
        self.coverImageView.image = [UIImage imageNamed:coverName];
        
        for(int j = 0; j < [subViewArray count]; j++)
        {
            
            NSDictionary *subDict = [subViewArray objectAtIndex:j];
            CGRect rect = CGRectZero;
            if ([subDict[@"type"] integerValue]==1) {
                //图片
                UIImage *image = [self.delegate doingImage];
                rect.size = CGSizeFromString(subDict[@"size"]);
                rect.origin = CGPointFromString(subDict[@"origin"]);
                rect = [self rectScaleWithRect:rect scale:scale];
                
                ImageCropperView *imageView = [[ImageCropperView alloc] initWithFrame:rect];
                [imageView setClipsToBounds:YES];
                [imageView setBackgroundColor:[UIColor clearColor]];
                imageView.tag = j;
                //回调或者说是通知主线程刷新，
                [self.editBoard insertSubview:imageView belowSubview:self.coverImageView];
                if (self.ronateCropperView) {
                    [self.ronateCropperView removeFromSuperview];
                }
                self.ronateCropperView = imageView;
                [self.ronateCropperView setup];
                self.ronateCropperView.image = image;
                
                imageView = nil;
            }
            if ([subDict[@"type"] integerValue]==2) {
                //文字
                //默认文字
                NSInteger defaultType = [subDict[@"defaultType"] integerValue]; // 0 文字  1日期文字  2定位文字
                
                NSString *text = subDict[@"default"];  //默认文字
                NSString *fontStr = subDict[@"font"];
                NSArray *rgb = [subDict[@"color"] componentsSeparatedByString:@","];
                UIColor *color = [UIColor blackColor];
                if (rgb.count==4) {
                    color = RGBA([rgb[0] integerValue], [rgb[1] integerValue], [rgb[2] integerValue],[rgb[3] floatValue]);
                }
                
                NSInteger fontSize = ([subDict[@"fontSize"] integerValue] * scale + 0.5);
                UIFont *font = [UIFont fontWithName:fontStr size:fontSize];
                rect.size = CGSizeFromString(subDict[@"size"]);
                rect.origin = CGPointFromString(subDict[@"origin"]);
                rect = [self rectScaleWithRect:rect scale:scale];
                UILabel *field = [[UILabel alloc] initWithFrame:rect];
                field.font = font?:[UIFont systemFontOfSize:fontSize];
                field.text = text;
                field.tag = 10010+j;
                field.textAlignment = [subDict[@"aligent"] integerValue];
                field.textColor = color;
                [self.editBoard addSubview:field];
                if (nil==self.fields) {
                    self.fields = [@[] mutableCopy];
                }
                
                if (defaultType==0) {
                    //普通文字

                }else if (defaultType==1) {
                    //日期文字
                    NSString *formart = subDict[@"formart"];
                    field.text =[TimeUtils timeStringFromDate:[NSDate date] withFormat:formart?:@"yyyy-MM-dd"];
                    
                }else if (defaultType==2){
                    //地址
                    if (self.location) {
                        field.text = self.location;
                    }
                    if (nil==self.locationFields) {
                        self.locationFields = [@[] mutableCopy];
                    }
                    [self.locationFields addObject:field];
                    [self.fields addObject:field];

                    
                    field.userInteractionEnabled = YES;
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInputForIndex:)];
                    [field addGestureRecognizer:tap];
                }
                else if (defaultType==3){
                    //地址
                    [self.fields addObject:field];
                    field.userInteractionEnabled = YES;
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInputForIndex:)];
                    [field addGestureRecognizer:tap];
                }
            }
        }
    }
}


#pragma mark - BMKLocationServiceDelegate

- (void)startLocation{
    
    if (self.locating) {
        return;
    }
    self.locating = YES;
    [self.locService startUserLocationService];
}

- (void)stopLocation{
    
    self.locating = NO;
    [self.locService stopUserLocationService];
    [self hideHUDLoading];
}




//开始反地理编码
-(void)startReverseGeoCodeSearch:(BMKUserLocation *)userLocation{
    
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){0, 0};
    pt = (CLLocationCoordinate2D){userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude};
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    
    BMKGeoCodeSearch *_geocodesearch = [[BMKGeoCodeSearch alloc]init];
    _geocodesearch.delegate = (id)self;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        if (TGO_DEBUG_LOG) NSLog(@"反geo检索发送成功");
    }
    else
    {
        if (TGO_DEBUG_LOG) NSLog(@"反geo检索发送失败");
    }
}


//反地理编码完成
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == 0) {
        
//        NSString *detail = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",result.addressDetail.province,result.addressDetail.city,result.addressDetail.district,result.addressDetail.streetName,result.addressDetail.streetNumber];
        self.location = result.addressDetail.city;
        for (UITextField *field in self.locationFields) {
            field.text = self.location;
        }
    }
    [self stopLocation];
}

#pragma mark - BMKLocationServiceDelegate
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    
    if (TGO_DEBUG_LOG) NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [self startReverseGeoCodeSearch:userLocation];
    [self stopLocation];
}

- (void)didStopLocatingUser{
    
    if (TGO_DEBUG_LOG) NSLog(@"location stop");
}


/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error{
//    [self stopLocation];
}
@end
