//
//  JJPreviewViewController.m
//  Footprints
//
//  Created by tt on 14/10/23.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJPreviewViewController.h"
#import "JJPreviewImageView.h"
#import "JJLocationTableViewController.h"
#import "UploadManager.h"
#import "JJMediaViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "JJPreviewViewCell.h"
#import "JJRecordView.h"
#import "JJChooseFriendsController.h"
#import "JJWhosViewController.h"
#import "InputHelper.h"
int recordEncoding;
enum
{
    ENC_AAC = 1,
    ENC_ALAC = 2,
    ENC_IMA4 = 3,
    ENC_ILBC = 4,
    ENC_ULAW = 5,
    ENC_PCM = 6,
} encodingTypes;


static JJPreviewViewController *sharedPreview;
@interface JJPreviewViewController ()<AVAudioRecorderDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UIGestureRecognizerDelegate>
{
    AVAudioRecorder *recorder;
    NSTimer *timer;
    NSURL *urlPlay;
}
@property (nonatomic,strong) BackgroundMusicModel *musicModel;
@property (retain, nonatomic) AVAudioPlayer *avPlay;
@property (nonatomic,strong) NSDate *postDate;
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (nonatomic,strong) NSMutableArray *imagePreViews;
@property (nonatomic,strong) NSMutableArray *imagePreViewFrames;
@property (nonatomic,strong) NSString *choosedGroupId;
@property (weak, nonatomic) IBOutlet UITableView *tableVIew;
@property (nonatomic,assign) BOOL isPreviewEiditing;
@property (weak, nonatomic) IBOutlet UIView *line1;
@property (weak, nonatomic) IBOutlet UIView *line2;
@property (strong, nonatomic) UIView *headerView;

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIButton *addMoreBtn;
@property (weak, nonatomic) IBOutlet UITextView *desTextView;
@property (strong, nonatomic) JJRecordView *speakBtn;
@property (weak, nonatomic) IBOutlet UIImageView *voiceIcon;
@property (weak, nonatomic) IBOutlet UILabel *voiceLengthLabel;
@property (strong, nonatomic) IBOutlet UIView *imageBoardView;
@property (nonatomic,strong) NSString *postTime;
@property (nonatomic,strong) NSString *musicName;
@property (nonatomic,strong) NSString *groupName;

- (IBAction)addMoreBtnDidTap:(id)sender;
- (IBAction)choosePostTimeDidTap:(id)sender;
- (IBAction)chooseGroupDidTap:(id)sender;
- (IBAction)chooseLocationDidTap:(id)sender;
- (IBAction)chooseMuiscDidTap:(id)sender;

- (IBAction)pickTimeDidFinish:(id)sender;
- (IBAction)pickTimeDidCancle:(id)sender;
- (IBAction)sendBtnDidTap:(id)sender;
- (IBAction)backBtnDidTap:(id)sender;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) IBOutlet UIView *datePickerBoard;
@end

@implementation JJPreviewViewController

+ (instancetype)sharedPreview{

    if(nil==sharedPreview){
        sharedPreview = [[JJPreviewViewController alloc] initWithNibName:@"JJPreviewViewController" bundle:nil];
        sharedPreview.groupName = @"公开";
        sharedPreview.choosedGroupId = @"1";
        sharedPreview.imageSourcreDict = [@{} mutableCopy];
        sharedPreview.imageSourcreKeys = [@[] mutableCopy];
    }
    return sharedPreview;
}

+ (void)clean{
    [[JJPreviewViewController sharedPreview] clean];
}

- (void)clean{
    self.groupName = @"公开";
    self.choosedGroupId = @"1";
    self.imageSourcreKeys = [@[] mutableCopy];
    self.imageSourcreDict  = [@{} mutableCopy];
    self.musicName = nil;
    self.postDate = nil;
    self.postTime = nil;
    self.groupName = nil;
    self.location = nil;
    self.titleField.text = nil;
    self.desTextView.text = nil;
    [self.speakBtn reset];
    [self reloadImageViews];
    [self.tableVIew reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupDefaultUI];
    self.tableVIew.backgroundColor = [UIColor clearColor];
    self.tableVIew.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.tableVIew registerNib:[UINib nibWithNibName:@"JJPreviewViewCell" bundle:nil] forCellReuseIdentifier:@"JJPreviewViewCell"];
    [self setExtraCellLineHidden:self.tableVIew];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapSelf)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    WS(ws);
    [self.tableVIew mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    [self resetImageViewFrame:NO];
    
    [inputHelper setupInputHelperForView:self.view withDismissType:InputHelperDismissTypeCleanMaskView];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
        [NewGuyHelper addNewGuyHelperOnView:[[UIApplication sharedApplication] keyWindow] withKey:@"NewGuyPreview" andImage:[UIImage imageNamed:SCREEN_HEIGHT>480?@"新_6.png":@"新4_6.png"]];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    BOOL begin = NO;
    if (self.isPreviewEiditing) {
        begin = YES;
        UIView *tapView = gestureRecognizer.view;
        for (UIView *view in self.imagePreViews) {
            if (view==tapView) {
                begin = NO;
                break;
            }
        }
    }
    return begin;
}

- (void)didTapSelf{
    
    self.isPreviewEiditing = NO;
    for (JJPreviewImageView *view in self.imagePreViews) {
        view.isEditing = NO;
    }
}


-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#define kContentPadding 8
- (void)setupDefaultUI{
    self.title = @"发布预览";
    self.view.backgroundColor = kDefaultViewColor;
    //配置左右按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.sendBtn];
    
    WS(ws);
    [self.titleField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.imageBoardView).with.offset(100);
        make.right.mas_equalTo(ws.imageBoardView).with.offset(-10);
        make.top.mas_equalTo(ws.imageBoardView);
        make.height.mas_equalTo(@44);
    }];
    [self.line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ws.imageBoardView);
        make.right.mas_equalTo(ws.imageBoardView);
        make.top.mas_equalTo(ws.imageBoardView).with.offset(44);
        make.height.mas_equalTo(@1);
    }];

    if (nil==self.speakBtn) {
        self.speakBtn = [[JJRecordView alloc] initWithFrame:CGRectMake(0, self.imageBoardView.frame.size.height-45, self.imageBoardView.frame.size.width, 45)];
        [self.imageBoardView addSubview:self.speakBtn];
        [self.speakBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(ws.imageBoardView);
            make.left.mas_equalTo(ws.imageBoardView);
            make.width.mas_equalTo(ws.imageBoardView);
            make.height.mas_equalTo(@45);
        }];
        self.speakBtn.backgroundColor = RGB(212, 212, 212);
        self.speakBtn.layer.cornerRadius = 0;

        self.speakBtn.didRecord = ^(void){
            
        };
    }
    [self.imageBoardView addSubview:self.speakBtn];
    //给顶部ImageBoardView添加边框
    self.imageBoardView.clipsToBounds = YES;
    self.imageBoardView.layer.borderWidth = kDefaultBorderWidth;
    self.imageBoardView.layer.borderColor = RGB(212, 212, 212).CGColor;
    self.line1.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    self.line2.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    

    [self.view addSubview:self.datePickerBoard];
    [self hideDatePicker:YES animation:NO];
    
    [self reloadImageViews];
}


#define kImageViewBaseTag 92012
- (BOOL)addImageSource:(UIImage *)image forKey:(NSString *)key{
    BOOL isAdded = NO;
    if (key && image) { //最多9张
        if (![self.imageSourcreDict objectForKey:key]) {
            if (self.imageSourcreKeys.count<9) {
                isAdded = YES;
                [self.imageSourcreKeys addObject:key];
                [self.imageSourcreDict setObject:image forKey:key];
            }
        }else{
            isAdded = YES;
            [self.imageSourcreDict setObject:image forKey:key];
        }
    }
    return isAdded;
}

- (void)removeImageSourceForKey:(NSString *)key{
    if (key) {
        [self.imageSourcreDict removeObjectForKey:key];
        [self.imageSourcreKeys removeObject:key];
    }
}

- (void)reloadImageViews{
    
    for (UIView *view in self.imagePreViews) {
        [view removeFromSuperview];
    }
    
    self.isPreviewEiditing = NO;
    self.imagePreViews  = [@[] mutableCopy];
    self.imagePreViewFrames = [@[] mutableCopy];
    WeakSelfType blockSelf = self;
    for (id key in self.imageSourcreKeys) {
        //TODO 排序
        UIImage *image = [self.imageSourcreDict objectForKey:key];
        JJPreviewImageView *preview = [[JJPreviewImageView alloc] initWithFrame:CGRectZero andCloseAction:^(JJPreviewImageView *view) {
            [blockSelf.imageSourcreKeys removeObject:view.imageKey];
            [blockSelf.imageSourcreDict removeObjectForKey:view.imageKey];
            [blockSelf.imagePreViews removeObject:view];
            [view removeFromSuperview];
            [blockSelf resetImageViewFrame:YES];
        }];
        preview.imageKey = key;
        preview.imageView.image = image;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(previewDidLongPress)];
        [preview addGestureRecognizer:longPress];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragButton:)];
        [preview addGestureRecognizer:pan];
        
        [self.imageBoardView addSubview:preview];
        [self.imagePreViews addObject:preview];
        
    }
    [self resetImageViewFrame:NO];
}

- (void)resetImageViewFrame:(BOOL)animation{
    
    CGFloat titleHeight = 45;
    CGFloat descHeight = CGRectGetHeight(self.inputView.frame);
    
    self.addMoreBtn.hidden = self.imagePreViews.count==9?YES:NO;
    self.imagePreViewFrames = [@[] mutableCopy];
    CGFloat yD = 5;
    CGFloat xOffset = 23;
    CGFloat yOffset = titleHeight+yD;
    CGFloat xD = xOffset;
    CGFloat wh = ceil(((SCREEN_WIDTH-kContentPadding*2) - xOffset*2 - xD*2)/3);
    
    for (UIView *view in self.imagePreViews) {
        NSInteger index = [self.imagePreViews indexOfObject:view];
        view.frame = CGRectMake(xOffset+(index%3)*(wh+xD), yOffset+(index/3)*(yD+wh), wh, wh);
        view.tag = kImageViewBaseTag+index;
        NSString * str = [NSString stringWithFormat:@"%@",NSStringFromCGRect(view.frame)];
        [self.imagePreViewFrames addObject:str];
    }
    
    self.addMoreBtn.frame =  CGRectMake(xOffset+(MIN(self.imagePreViews.count, 8)%3)*(wh+xD), yOffset+(MIN(self.imagePreViews.count, 8)/3)*(yD+wh), wh, wh);
    
    NSInteger count = MIN(ceil((self.imagePreViews.count+1)/3.0), 3);
    CGFloat imagesHeight = count*(wh+yD)+yD;
    CGFloat height = titleHeight+imagesHeight+descHeight;
    
    self.line2.frame = CGRectMake(0, imagesHeight+titleHeight, SCREEN_WIDTH, 1);
    self.imageBoardView.frame = CGRectMake(kContentPadding, kContentPadding, SCREEN_WIDTH-kContentPadding*2, height);
    
    CGFloat allHeight = height+14+kContentPadding;
    
    
    self.tableVIew.tableHeaderView = nil;
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, allHeight)];
    self.headerView.backgroundColor = kDefaultViewColor;
    [self.headerView addSubview:self.imageBoardView];
    self.tableVIew.tableHeaderView = self.headerView;
}

- (void)previewDidLongPress{
    
    if (self.isPreviewEiditing) {
        return;
    }
    self.isPreviewEiditing = YES;
    for (JJPreviewImageView *view in self.imagePreViews) {
        view.isEditing = YES;
    }
}

NSInteger tmptag;
//拖动手势的回调方法
-(void)dragButton:(UIPanGestureRecognizer*)pan
{
    
    if (!self.isPreviewEiditing) {
        return;
    }
    
    //NSLog(@"drag");
    //获取手势在该视图上得偏移量
    CGPoint translation = [pan translationInView:self.view];
    
    //一下分别为拖动时的三种状态：开始，变化，结束
    if (pan.state == UIGestureRecognizerStateBegan)
    {
        [self.imageBoardView bringSubviewToFront:pan.view];
        //开始时拖动的view更改透明度
        pan.view.alpha = 0.7;
    }
    else if(pan.state == UIGestureRecognizerStateChanged)
    {
        //使拖动的view跟随手势移动
        pan.view.center = CGPointMake(pan.view.center.x + translation.x,
                                      pan.view.center.y + translation.y);
        [pan setTranslation:CGPointZero inView:self.view];
        
       //遍历9个view看移动到了哪个view区域，使其为选中状态.并更新选中view的tag值，使其永远为最新的
        for (int i = 0; i< self.imagePreViews.count; i++)
        {
            UIButton * btn = self.imagePreViews[i];
            NSString* tmprect = self.imagePreViewFrames[i];
            if (CGRectContainsPoint(CGRectFromString(tmprect), pan.view.center))
            {
                
                tmptag = btn.tag-kImageViewBaseTag;
                return;
            }
            else
            {
            }
        }
    }
    else if (pan.state == UIGestureRecognizerStateEnded)
    {
        //拖动结束的时候，将拖动的view的透明度还原
        pan.view.alpha = 1;
        [UIView animateWithDuration:0.3 animations:^
         {
             //结束时将选中view的边框还原
             UIButton * btn = self.self.imagePreViews[tmptag];
             
             //获取需要交换的两个view的frame，并交换
             NSString * rect1 = self.imagePreViewFrames[btn.tag-kImageViewBaseTag];
             NSString * rect2 = self.imagePreViewFrames[pan.view.tag-kImageViewBaseTag];
             
             pan.view.frame = CGRectFromString(rect1);
             btn.frame = CGRectFromString(rect2);
             
             //并交换其tag值及在数组中得位置
             NSInteger tmp = pan.view.tag;
             pan.view.tag = tmptag+kImageViewBaseTag;
             btn.tag = tmp;
//             NSLog(@"%ld  %ld",(long)pan.view.tag-kImageViewBaseTag,(long)btn.tag-kImageViewBaseTag);
             
             [self.imagePreViews exchangeObjectAtIndex:pan.view.tag-kImageViewBaseTag withObjectAtIndex:btn.tag-kImageViewBaseTag];
             
             [self.imageSourcreKeys exchangeObjectAtIndex:pan.view.tag-kImageViewBaseTag withObjectAtIndex:btn.tag-kImageViewBaseTag];
             
         } completion:^(BOOL finished)
         {
             NSLog(@"已交换");
            
         }];
    }
}

- (void)setPostDate:(NSDate *)postDate{
    
    _postDate = postDate;
    if (nil==postDate) {
        self.postTime = @"立即发送";
    }else{
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm"];
        self.postTime = [format stringFromDate:postDate];
    }
}

- (void)hideDatePicker:(BOOL)hidden animation:(BOOL)animation{
    
    [UIView animateWithDuration:animation?0.2:0 animations:^{
        self.datePickerBoard.frame = CGRectMake(0, CGRectGetHeight(self.view.frame)-(hidden?0:CGRectGetHeight(self.datePickerBoard.frame)),CGRectGetWidth(self.datePickerBoard.frame),CGRectGetHeight(self.datePickerBoard.frame));
    }];
}


- (IBAction)addMoreBtnDidTap:(id)sender {

    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ADDNewEditImage" object:nil];
    }];
}

- (IBAction)choosePostTimeDidTap:(id)sender {

    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.datePicker.minuteInterval = 1;
    
    
    
    NSDate* minDate = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSString *reportDate = [format stringFromDate:minDate];
    NSDate *date = [format dateFromString:reportDate];
    NSDate *maxDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([date timeIntervalSinceReferenceDate] + 24*3600)];
    
    self.datePicker.minimumDate = minDate;
    self.datePicker.maximumDate = maxDate;
    
    self.datePicker.date = self.postDate?self.postDate:minDate;
    
    [self hideDatePicker:NO animation:YES];
}

- (IBAction)chooseGroupDidTap:(id)sender {
 
    JJWhosViewController *whos = [[JJWhosViewController alloc] initWithNibName:@"JJWhosViewController" bundle:nil];
    NSArray *array = [self.choosedGroupId componentsSeparatedByString:@","];
    for (NSString *str in array) {
        [whos.choosedArr addObject:str];
    }
    WS(ws);
    whos.block = ^(NSString *gropId){
        ws.choosedGroupId = gropId;
        if ([gropId isEqualToString:@"1"]) {
                ws.groupName = @"公开";
        }else if ([gropId isEqualToString:@"0"]) {
            ws.groupName = @"私密";
        }else if ([gropId isEqualToString:@"2"]) {
            ws.groupName = @"粉丝";
        }else if ([gropId isEqualToString:@"3"]) {
            ws.groupName = @"好友";
        }else{
        ws.groupName = @"分组好友";
        }
        [ws.tableVIew reloadData];
    };
    
    [self.navigationController pushViewController:whos animated:YES];
}

- (IBAction)chooseLocationDidTap:(id)sender {
    
    WeakSelfType blockSelf = self;
    JJLocationTableViewController *location = [[JJLocationTableViewController alloc] initWithDidChooseActions:^(BMKPoiInfo *info) {
        
        if (nil==info) {
            blockSelf.location = nil;
        }else{
            blockSelf.location = [NSString stringWithFormat:@"%@·%@",info.city,info.name];
        }
        [blockSelf.tableVIew reloadData];
    }];
    [self.navigationController pushViewController:location animated:YES];
}

- (IBAction)chooseMuiscDidTap:(id)sender {
    
    WeakSelfType blockSelf = self;
    JJMediaViewController *media = [[JJMediaViewController alloc] initWithDidChooseActions:^(id music) {
        blockSelf.musicModel = music;
        blockSelf.musicName = music?blockSelf.musicModel.musicName:nil;
        [blockSelf.tableVIew reloadData];
    }];
    media.model = blockSelf.musicModel;
    [self.navigationController pushViewController:media animated:YES];
}

- (IBAction)pickTimeDidFinish:(id)sender {
    self.postDate = self.datePicker.date;
    
    [self.tableVIew reloadData];
    [self hideDatePicker:YES animation:YES];
}

- (IBAction)pickTimeDidCancle:(id)sender {
    
    [self hideDatePicker:YES animation:YES];
}

//延迟隐藏view上hud的通用方法
- (void)showResultThenHide:(NSString *)resultString
                afterDelay:(NSTimeInterval)delay
                    onView:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    }
    hud.labelText = resultString;
    hud.mode = MBProgressHUDModeText;
    [hud show:YES];
    [hud hide:YES afterDelay:delay];
}

//直接隐藏self.view上的hud
- (void)showResultThenHide:(NSString *)resultString {
    [self showResultThenHide:resultString
                  afterDelay:2
                      onView:self.view];
}

//显示hud的通用方法
- (MBProgressHUD *)showHUDLoadingWithString:(NSString *)hintString
                                     onView:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (hud) {
        [hud show:YES];
    } else {
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    }
    hud.labelText = hintString;
    hud.mode = MBProgressHUDModeIndeterminate;
    return hud;
}

- (IBAction)sendBtnDidTap:(id)sender {
    
    
    [self.titleField resignFirstResponder];
    [self.desTextView resignFirstResponder];
    
    if (!self.imageSourcreKeys.count) {
        [self showResultThenHide:@"请添加作品"];
        return;
    }
    
    NSString *title = self.titleField.text;
    if ([StringUtils isEmpty:title]) {
        [self showResultThenHide:@"请添加作品标题"];
        [self.titleField becomeFirstResponder];
        return;
    }
    
    if (self.desTextView.text.length > 5000) {
        [self showResultThenHide:@"描述太长啦，请少于5000字"];
        return;
    }
    
    [self showHUDLoadingWithString:@"发布中.." onView:self.view];

    WeakSelfType blockSelf = self;
    //uploadImage To Upyun
    __block NSMutableArray *imageInfos = [@[] mutableCopy];
    NSArray *array = self.imageSourcreKeys;
    //TODO 排序
    for (id key in array) {
        UIImage *image = self.imageSourcreDict[key];
        
        [UploadManager uploadImage:UIImageJPEGRepresentation(image, 1)
                           success:^(id result) {
                               /*
                                code = 200;
                                "image-frames" = 1;
                                "image-height" = 424;
                                "image-type" = JPEG;
                                "image-width" = 640;
                                message = ok;
                                sign = 688805056e90065638efdccd2e0b7694;
                                time = 1413792792;
                                url = "test/upload/20141020/96FD0543-CC8A-4495-95E0-A204D9131849";
                                */
                               NSDictionary *data = result;
                               NSMutableDictionary *dict = [@{} mutableCopy];
                               [dict setObject:data[@"url"]?:@"" forKey:@"imageUrl"];
                               [dict setObject:data[@"image-width"]?:@"" forKey:@"widthSize"];
                               [dict setObject:data[@"image-height"]?:@"" forKey:@"heightSize"];
                               [dict setObject:@([array indexOfObject:key]) forKey:@"sequences"];
                               [imageInfos addObject:dict];
                               NSLog(@"图片上传成功 %@",dict);
                               if (imageInfos.count==array.count && imageInfos.count) {
                                   //上传图片成功
                                   [blockSelf sendImageInfos:imageInfos];
                               }
                           }
                         failBlock:^(NSError *error) {
                             NSLog(@"图片上传失败 %@",error);
                             [blockSelf sendFail:@"图片上传失败"];
                         }
                     progressBlock:^(CGFloat percent, long long requestDidSendBytes) {
                         NSLog(@"img ...%f",percent);
                     }];
    }
}

- (IBAction)backBtnDidTap:(id)sender {
    WS(ws);
    UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:@"退出发布将失去发布内容"];
    [alert bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [alert bk_addButtonWithTitle:@"退出" handler:^{
        [ws clean];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TravalDidCancle" object:nil];
        [ws.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
    [alert show];
}



- (void)sendImageInfos:(NSArray *)imageInfos{
    NSString *memberId = [UserManager loginUserId]; //Check
    NSString *title = self.titleField.text; //Check;
    NSString *releaseContent = self.desTextView.text;//Check
    NSArray *detailImages = imageInfos;
    NSString *groupId = self.choosedGroupId?:@"1";
    NSString *location = [self.location isEqualToString:@"关闭"]?nil:self.location;
    NSString *backgroundMusic = self.musicModel.urlPath;
    NSNumber *regularTime = @((long)((self.postDate?[self.postDate timeIntervalSince1970]:[[NSDate date] timeIntervalSince1970])));
    
    NSMutableDictionary *dict = [@{} mutableCopy];
    [dict setObject:memberId forKey:@"memberId"];
    [dict setObject:title forKey:@"title"];
    [dict setObject:releaseContent forKey:@"releaseContent"];
    [dict setObject:detailImages forKey:@"detailImages"];
    [dict setObject:groupId forKey:@"groupId"];
    if (location) [dict setObject:location forKey:@"location"];
    if (backgroundMusic) [dict setObject:backgroundMusic forKey:@"backgroundMusic"];
    [dict setObject:regularTime forKey:@"regularTime"];
    
    
    WeakSelfType blockSelf = self;
    //UploadVoice
    NSData *voiceData = [self.speakBtn recordData];
    if (voiceData){
        [UploadManager uploadFile:voiceData type:@"spx" success:^(id result) {
            /*
             code = 200;
             "image-frames" = 1;
             "image-height" = 424;
             "image-type" = JPEG;
             "image-width" = 640;
             message = ok;
             sign = 688805056e90065638efdccd2e0b7694;
             time = 1413792792;
             url = "test/upload/20141020/96FD0543-CC8A-4495-95E0-A204D9131849";
             */
            NSLog(@"%@",result);
            NSDictionary *data = result;
            NSString *voice = data[@"url"];
            if (voice) [dict setObject:voice forKey:@"voice"];
            [blockSelf postDataDict:dict];
        } failBlock:^(NSError *error) {
            [blockSelf sendFail:@"语音上传失败"];
        } progressBlock:^(CGFloat percent, long long requestDidSendBytes) {
            
        }];
    }else{
        [self postDataDict:dict];
    }
}

- (void)sendFail:(NSString *)reason{
    
    WS(ws);
    UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:reason?[NSString stringWithFormat:@"由于%@的原因，发布失败",reason]:@"发布失败"];
    [alert bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [alert bk_addButtonWithTitle:@"重发" handler:^{
        [ws sendBtnDidTap:nil];
    }];
    [alert show];
}


- (void)postDataDict:(NSDictionary *)dict {
    
    WeakSelfType blockSelf = self;
    [AFNManager postObject:dict
                   apiName:kResPathSaveTravel
                 modelName:@"BaseModel"
          requestSuccessed:^(id responseObject) {
        NSLog(@"发布成功 %@",responseObject);
        
        if (blockSelf.activityId) {
            //需要投稿。。
            NSString *travelId = responseObject;
            [blockSelf joinActivity:travelId];
        }else{
            [blockSelf showResultThenHide:@"发布成功"];
            [blockSelf clean];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TravalDidSend" object:nil];
            [blockSelf dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        [blockSelf sendFail:errorMessage?:nil];
    }];
}

- (void)joinActivity:(NSString *)travelId{
    
    if (!travelId) {
        [self sendFail:nil];
    }
    WeakSelfType blockSelf = self;
    [AFNManager postObject:@{@"activityId":self.activityId,@"travelId":travelId} apiName:kResPathParticipationActivity modelName:@"BaseModel" requestSuccessed:^(id responseObject) {
        NSLog(@"发布成功 %@",responseObject);
        [blockSelf clean];
        [blockSelf showResultThenHide:@"发布成功"];
        
        UIViewController *controller = blockSelf.presentingViewController;
        [blockSelf dismissViewControllerAnimated:YES completion:^{
            [controller dismissViewControllerAnimated:NO completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TravalActivityDidJion" object:nil];
            }];
        }];
    } requestFailure:^(NSInteger errorCode, NSString *errorMessage) {
        [blockSelf sendFail:errorMessage?:nil];
    }];
}

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    JJPreviewViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JJPreviewViewCell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"背景音乐";
            cell.secLabel.text = self.musicName?:@"未选择";
            break;
        case 1:
            cell.textLabel.text = @"自动定位";
              cell.secLabel.text = self.location?:@"未选择";
            break;
        case 2:
            cell.textLabel.text = @"可见范围";
            cell.secLabel.text = self.groupName;
            break;
        case 3:
            cell.textLabel.text = @"定时发送";
            cell.secLabel.text = self.postTime;
            cell.accessoryType = UITableViewCellAccessoryNone;
            break;
            
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [self chooseMuiscDidTap:nil];
            break;
        case 1:
            [self chooseLocationDidTap:nil];
            break;
        case 2:
            [self chooseGroupDidTap:nil];
            break;
        case 3:
            [self choosePostTimeDidTap:nil];
            break;
            
        default:
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

@end
