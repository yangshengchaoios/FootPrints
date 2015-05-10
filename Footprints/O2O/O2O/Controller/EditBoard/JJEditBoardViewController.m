//
//  JJEditBoardViewController.m
//  Footprints
//
//  Created by tt on 14/10/23.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJEditBoardViewController.h"
#import "InfColorBarPicker.h"
#import "InfHSBSupport.h"
#import "JJPreviewViewController.h"
#import "JJEditViewController.h"
#import "JJFilterEditViewController.h"
#import "JJStickerViewController.h"
#import "JJDrawViewController.h"
#import "JJAddTextViewController.h"
#import "JJModelViewController.h"
#define kBottomBarHeight 36
#define kTopBarHeight 33

@interface JJEditBoardViewController ()<JJEditViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

//@property (nonatomic,assign) NSInteger  curDoIndex;  //用于记录UnDo的Index
@property (nonatomic,strong) NSMutableArray *reDoArr; //正在编辑中的图片
@property (nonatomic,strong) NSMutableArray *unDoArr; //正在编辑中的图片
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
- (IBAction)backBtnDidTap:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *topToolsBar;
@property (weak, nonatomic) IBOutlet UIButton *changeBgBtn;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong, nonatomic ) InfColorBarPicker* barPicker;
@property (weak, nonatomic) IBOutlet UIView *boardView;
@property (weak, nonatomic) IBOutlet UIView *toolsBar;
@property (weak, nonatomic) IBOutlet UIButton *preBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (strong,nonatomic) NSString *identity;
- (IBAction)changeBgBtnDidTap:(id)sender;

- (IBAction)compelteBtnDidTap:(id)sender;
- (IBAction)nextBtnDidTap:(id)sender;
- (IBAction)preBtnDidTap:(id)sender;

- (IBAction)toolDidTap:(id)sender;
@end

@implementation JJEditBoardViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeSelf) name:@"ADDNewEditImage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanAndBack) name:@"TravalDidSend" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanAndBack) name:@"TravalDidCancle" object:nil];
    [self setupDefaultUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    [NewGuyHelper addNewGuyHelperOnView:[[UIApplication sharedApplication] keyWindow] withKey:@"NewGuyEdit" andImage:[UIImage imageNamed:SCREEN_HEIGHT>480?@"新_5.png":@"新4_5.png"]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setupDefaultUI{
    
    self.reDoArr = [@[] mutableCopy];
    self.unDoArr = [@[] mutableCopy];
    
    self.preBtn.enabled = NO;
    self.nextBtn.enabled = YES;
    
    //初始图片
    self.boardView.frame = self.frame;
    self.bgImageView.image = self.img;

    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = RGB(38, 38, 38);
}

- (void)setBoardStyle:(EditBoardStyle)boardStyle{
    _boardStyle = boardStyle;
    CGFloat barTatolHeight = self.tabBarController.tabBar.frame.size.height+kBottomBarHeight+kTopBarHeight;
    CGFloat scale = 640.0/1008;
    CGFloat contentHeight = SCREEN_HEIGHT-barTatolHeight;
    CGFloat contentWidht = contentHeight*scale;
//    self.backBtn.hidden = boardStyle==EditBoardStyleHome;
    
    self.boardView.frame = CGRectMake((SCREEN_WIDTH-contentWidht)/2, kTopBarHeight, contentWidht, contentHeight);
    [self setBarsHidden:self.toolsBar.frame.size.height<0?YES:NO animation:0 completion:^(BOOL finished) {
        
    }];
}

- (void)addNewPage{
    
    UIImage *newImage = self.img;
    self.identity = [self getRandString];
    [self.unDoArr removeAllObjects];
    [self.reDoArr removeAllObjects];
    [self setCurrentDoImage:newImage];
}

- (NSString *)getRandString{
    char data[30];
    for (int x=0;x<30;data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:30 encoding:NSUTF8StringEncoding];
}

- (void)setNewBgImage:(UIImage *)img{
    
    CGSize imgSize = img.size;
    //245 * 385
    CGFloat scale = 640.0/1008;
    
    CGFloat offset = 10;
    CGFloat othersHeight = kTopBarHeight+kBottomBarHeight+self.tabBarController.tabBar.frame.size.height;
    CGFloat maxWidth = CGRectGetWidth(self.view.frame)-offset*2;
    CGFloat maxHeight = CGRectGetHeight(self.view.frame)-offset*2-othersHeight;
    
    CGFloat width = 0;
    CGFloat height = 0;
    
    if (imgSize.width/imgSize.height >= scale) {
        width = maxWidth;
        height = (int)maxWidth/scale;
    }else{
        height = maxHeight;
        width = (int)maxHeight*scale;
    }
    
    self.bgImageView.image = img;
    self.boardView.frame = CGRectMake((CGRectGetWidth(self.view.frame)-width)/2.0, CGRectGetHeight(self.topToolsBar.frame)+(CGRectGetHeight(self.view.frame)-othersHeight-height)/2, width, height);
}


#pragma mark - Actions
#define kToolViewBaseTag    10000
#define kToolBtnBaseTag     1000
- (IBAction)compelteBtnDidTap:(id)sender {
    
    if (self.identity) {
        JJPreviewViewController *preview = [JJPreviewViewController sharedPreview];
        
       BOOL isAdded = [preview addImageSource:[self doingImage] forKey:self.identity];
        if (!isAdded) {
            [preview showResultThenHide:@"最多添加9张"];
        }
        [preview reloadImageViews];
        UINavigationController *navi =[[UINavigationController alloc] initWithRootViewController:preview];
        [self presentViewController:navi animated:YES completion:^{
        }];
    }
}

- (IBAction)nextBtnDidTap:(id)sender {
    
    if (self.reDoArr.count) {
        
        UIImage *image = [self.reDoArr lastObject];
        [self.reDoArr removeObject:image];
        [self setCurrentDoImage:image];
    }
}

- (IBAction)preBtnDidTap:(id)sender {
    
    if (self.unDoArr.count) {
        UIImage *image = [self.unDoArr lastObject];
        [self.unDoArr removeObject:image];
        
        if (self.bgImageView.image) {
            [self.reDoArr addObject:self.bgImageView.image];
            if (self.reDoArr.count>4) {
                [self.reDoArr removeObjectAtIndex:0];
            }
        }
        self.bgImageView.image = image;
        
        self.preBtn.enabled = self.unDoArr.count;
        self.nextBtn.enabled = self.reDoArr.count;
    }
}


- (IBAction)changeBgBtnDidTap:(id)sender {
}


- (IBAction)toolDidTap:(id)sender {
    
    UIButton *btn = sender;
    NSInteger btnTag = btn.tag-kToolBtnBaseTag;
    
    JJEditViewController *editView = nil;
    //加载编辑view
    switch (btnTag) {
        case 0://文字
        {
            editView = [[JJAddTextViewController alloc] initWithNibName:@"JJEditViewController" bundle:nil];
        }
            break;
        case 1://涂鸦
            editView = [[JJDrawViewController alloc] initWithNibName:@"JJEditViewController" bundle:nil];
            break;
        case 2://剪裁
            editView = [[JJModelViewController alloc] initWithNibName:@"JJEditViewController" bundle:nil];
            break;
        case 3://滤镜
            editView = [[JJFilterEditViewController alloc] initWithNibName:@"JJEditViewController" bundle:nil];
            break;
        case 4://图案
            editView = [[JJStickerViewController alloc] initWithNibName:@"JJEditViewController" bundle:nil];
            break;
        default:
            break;
    }
    if (editView) {
        editView.delegate = self;
        postNWithObj(@"EditViewNeedHideTabBar", nil);
        //关闭上下工具栏动画
        WeakSelfType blockSelf = self;
        [self setBarsHidden:YES animation:0.45 completion:^(BOOL finished) {
            //弹出编辑View的工具栏
            [blockSelf presentViewController:editView animated:NO completion:^{
                 [editView openSelf];
            }];
        }];
    }
}

- (CGRect)toolOpenFrame:(UIView *)tool{
    
    return CGRectMake(CGRectGetMinX(tool.frame), CGRectGetMinY(self.toolsBar.frame)-CGRectGetHeight(tool.frame), CGRectGetWidth(tool.frame), CGRectGetHeight(tool.frame));
}

- (CGRect)toolCloseFrame:(UIView *)tool{
    
    return CGRectMake(CGRectGetMinX(tool.frame), CGRectGetMinY(self.toolsBar.frame), CGRectGetWidth(tool.frame), CGRectGetHeight(tool.frame));
}


- (void)setCurrentDoImage:(UIImage *)img{
    
//    @property (nonatomic,strong) NSMutableArray *doArr;
//    @property (nonatomic,strong) NSMutableArray *orgImageArr;
//    @property (nonatomic,strong) NSMutableArray *resultImageArr;
//    @property (nonatomic,strong) NSMutableArray *bgImageArr;
    if (!img) {
        return;
    }
    
    //Undo +1
    if (self.bgImageView.image) {
        [self.unDoArr addObject:self.bgImageView.image];
        if (self.unDoArr.count>4) {
            [self.unDoArr removeObjectAtIndex:0];
        }
    }
    self.bgImageView.image = img;
    
    self.preBtn.enabled = self.unDoArr.count;
    self.nextBtn.enabled = self.reDoArr.count;
}



#pragma mark - JJPreviewDelegateAndDatasource
- (NSArray *)jjPreviewImageSource{
    return nil;
}

- (void)jjPreviewDidDeleteImageAtIndex:(NSInteger)index{

}


- (void)jjPreviewNeedAddMore{

}

- (void)jjPreviewDidChooseLocation:(NSString *)location{

}

- (void)jjPreviewDidChooseVoice:(NSString *)audioPath{

}


- (void)setBarsHidden:(BOOL)hidden animation:(CGFloat)animation completion:(void (^)(BOOL finished))completion{
    
    //打开上下工具栏动画
    CGFloat showY = CGRectGetHeight(self.view.frame)-kBottomBarHeight-self.tabBarController.tabBar.frame.size.height;
    CGFloat closeY = CGRectGetHeight(self.view.frame);
    
    if (!hidden) {
        self.toolsBar.frame = CGRectMake(0, closeY-self.tabBarController.tabBar.frame.size.height, CGRectGetWidth(self.toolsBar.frame), CGRectGetHeight(self.toolsBar.frame));

    }
    
    [UIView animateWithDuration:animation animations:^{
        self.topToolsBar.frame = CGRectMake(0, hidden?-kTopBarHeight:0, SCREEN_WIDTH, kTopBarHeight);
        self.toolsBar.frame = CGRectMake(0, hidden?closeY:showY, CGRectGetWidth(self.toolsBar.frame), CGRectGetHeight(self.toolsBar.frame));
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}
#pragma mark - JJEditViewController Delegate
- (void)willCloseView:(JJEditViewController *)controler{}

- (void)didClosedView:(JJEditViewController *)controler{
    postNWithObj(@"EditViewNeedShowTabBar", nil);
    [self setBarsHidden:NO animation:0.45 completion:^(BOOL finished) {
        
    }];
}
- (void)didCancleEdit:(JJEditViewController *)controler{}

- (void)didCompletedEdit:(JJEditViewController *)controler withResult:(id)result{
    
    if ([controler isKindOfClass:[JJFilterEditViewController class]]) {
        [self setCurrentDoImage:result];
    }
    if ([controler isKindOfClass:[JJStickerViewController class]]) {
        [self setCurrentDoImage:result];
    }
    if ([controler isKindOfClass:[JJDrawViewController class]]) {
        [self setCurrentDoImage:result];
    }
    if ([controler isKindOfClass:[JJAddTextViewController class]]) {
        [self setCurrentDoImage:result];
    }
    if ([controler isKindOfClass:[JJModelViewController class]]) {
        [self setCurrentDoImage:result];
    }
}
- (CGRect)imageStartFrame{
    return self.boardView.frame;
}
- (CGRect)imageEndFrame{
    return self.boardView.frame;
}
- (UIImage *)originalImage{
    return self.img;
}
- (UIImage *)doingImage{
    return self.bgImageView.image;
}

- (void)openSelf{

    WS(ws);
    [self setBarsHidden:YES animation:NO completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            [ws addNewPage];
            ws.boardStyle = ws.boardStyle;
        }];
        [ws setBarsHidden:NO animation:0.3 completion:^(BOOL finished) {
            
        }];
    }];
}

- (IBAction)backBtnDidTap:(id)sender{
    if (self.identity) {
//        [[JJPreviewViewController sharedPreview] removeImageSourceForKey:self.identity];
    }
    WS(ws);
    UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"返回将失去编辑的内容"];
    [alert bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [alert bk_addButtonWithTitle:@"返回" handler:^{
        [ws cleanAndBack];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TravalDidCancle" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TravalDidCancle" object:nil];
    }];
    [alert show];
}

- (void)cleanAndBack{
    [self closeSelf];
    self.identity = nil;
}


- (void)closeSelf{
    WS(ws);
    [UIView animateWithDuration:0.3 animations:^{
        ws.boardView.frame = ws.frame;
    }];
    [self setBarsHidden:YES animation:0.3 completion:^(BOOL finished) {
        [ws dismissViewControllerAnimated:NO completion:^{
            
        }];
    }];
}
@end
