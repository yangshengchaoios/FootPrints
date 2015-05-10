//
//  JJEditChooseViewController.m
//  Footprints
//
//  Created by Jinjin on 14/12/23.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJEditChooseViewController.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ImageCropperView.h"
#import "JJEditBoardViewController.h"

@interface JJEditChooseViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic,strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic,strong) NSMutableArray *assetsArry;
@property (weak, nonatomic) IBOutlet UIView *albumBoard;
@property (weak, nonatomic) IBOutlet UIScrollView *albumScroll;
@property (weak, nonatomic) IBOutlet UIButton *changeBgBtn;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong, nonatomic) ImageCropperView *ronateCropperView;
@property (weak, nonatomic) IBOutlet UIButton *beginBtn;
@property (strong, nonatomic) NSArray*bgImages;
@property (assign, nonatomic) NSInteger index;
@property (weak, nonatomic) IBOutlet UIButton *openAlbumBtn;
@property (weak, nonatomic) IBOutlet UIImageView *indicatorView;
@property (nonatomic,assign) NSInteger selectedIndex;
- (IBAction)albumBoardSwitcherDidTap:(id)sender;
- (IBAction)changeBgBtnDidTap:(id)sender;
- (IBAction)pickPhotoDidTap:(id)sender;
- (IBAction)takePhotoDidTap:(id)sender;
- (IBAction)beginBtnDidTap:(id)sender;
- (IBAction)backBtnDidTap:(id)sender;

@end

@implementation JJEditChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backBtn.hidden = YES;
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanSelf) name:@"ADDNewEditImage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanSelf) name:@"TravalDidSend" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanSelf) name:@"TravalDidCancle" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismisSelf) name:@"TravalActivityDidJion" object:nil];
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.view.backgroundColor = RGB(38, 38, 38);

    self.indicatorView.frame = CGRectMake(0, 0, 50, 50);
    self.indicatorView.hidden = YES;
    self.indicatorView.layer.borderWidth = 2;
    self.indicatorView.layer.borderColor = RGB(68, 152, 181).CGColor;
    self.selectedIndex = -1;
    
    self.bgImages = @[@"bg1.png",@"bg2.png",@"bg3.jpg",@"bg4.png",@"bg5.jpg",@"bg6.jpg",@"bg7.png",@"bg8.jpg",@"bg9.jpg",@"bg10.jpg"];
    self.index = 0;
    [self setNewBgImage:[UIImage imageNamed:self.bgImages[0]]];
    
    self.ronateCropperView = [[ImageCropperView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.ronateCropperView];
    [self.ronateCropperView setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self setupAssetsLibrary];
    [self hideAlbumBoard:YES withAnimation:NO];
//    [self setBarsHidden:NO animation:0.3 completion:^(BOOL finished) {
    
//    }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
        [NewGuyHelper addNewGuyHelperOnView:[[UIApplication sharedApplication] keyWindow] withKey:@"NewGuyEditChoose" andImage:[UIImage imageNamed:SCREEN_HEIGHT>480?@"新_4.png":@"新4_4.png"]];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [self setBarsHidden:NO animation:0 completion:^(BOOL finished) {
        
    }];
}


- (void)cleanSelf{
    self.selectedIndex=-1;
    self.indicatorView.hidden = YES;
    [self.ronateCropperView reset];
//    [self.ronateCropperView removeFromSuperview];
//    self.ronateCropperView = [[ImageCropperView alloc] initWithFrame:self.contentView.bounds];
//    [self.contentView addSubview:self.ronateCropperView];
//    [self.ronateCropperView setup];
}
- (void)dismisSelf{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setNewBgImage:(UIImage *)img{
    
    CGSize imgSize = img.size;
    //245 * 385
    CGFloat scale = 640.0/1008;
    
    CGFloat offset = 10;
    CGFloat othersHeight = 30+50+self.tabBarController.tabBar.frame.size.height;
    CGFloat maxWidth = SCREEN_WIDTH-offset*2;
    CGFloat maxHeight = SCREEN_HEIGHT-othersHeight;
    
    CGFloat width = 0;
    CGFloat height = 0;
    
    if (imgSize.width/imgSize.height > scale) {
        width = maxWidth;
        height = (int)maxWidth/scale;
    }else{
        height = maxHeight;
        width = (int)maxHeight*scale;
    }
    
    self.bgImageView.image = img;
    self.bgImageView.clipsToBounds = YES;
    self.contentView.frame = CGRectMake((SCREEN_WIDTH-width)/2.0, 30+(maxHeight-height)/2, width, height);
    self.beginBtn.frame = CGRectMake((SCREEN_WIDTH-116)/2, CGRectGetMaxY(self.contentView.frame)+8, 116, 33);
}

- (IBAction)pickPhotoDidTap:(id)sender {
    
    [self showImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
}

- (IBAction)takePhotoDidTap:(id)sender {
    
    BOOL isCameraSupport = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (isCameraSupport) {
        [self showImagePicker:UIImagePickerControllerSourceTypeCamera];
    }else{
        [self showImagePicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }
}



- (IBAction)albumBoardSwitcherDidTap:(id)sender {
    CGFloat openX = CGRectGetWidth(self.view.frame)-CGRectGetWidth(self.albumBoard.frame);
    BOOL isHidden = CGRectGetMinX(self.albumBoard.frame)>openX?YES:NO;
    [self hideAlbumBoard:!isHidden withAnimation:YES];
}

- (IBAction)changeBgBtnDidTap:(id)sender{
    
    self.index = (self.index+1)%10;
    NSString *name = self.bgImages[self.index];
    UIImage *image = [UIImage imageNamed:name];
    NSLog(@"%@,  %@",name,image);
    [self setNewBgImage:image];
}


- (void)hideAlbumBoard:(BOOL)hidden withAnimation:(BOOL)animation{
    
    [self.view bringSubviewToFront:self.albumBoard];
    [self.openAlbumBtn setImage:hidden?[UIImage imageNamed:@"left_slide.png"]:[UIImage imageNamed:@"right_slide.png"] forState:UIControlStateNormal];
    [UIView animateWithDuration:animation?0.3:0 animations:^{
        CGFloat hiddenX = CGRectGetWidth(self.view.frame)-42;
        CGFloat y = 30;
        CGFloat height = SCREEN_HEIGHT-self.tabBarController.tabBar.frame.size.height-y;
        CGFloat openX = CGRectGetWidth(self.view.frame)-CGRectGetWidth(self.albumBoard.frame);
        self.albumBoard.frame = CGRectMake(hidden?hiddenX:openX, y, self.albumBoard.frame.size.width, height);
    }];
}

#define kAlbumPhotoBaseTag 10000
- (void)reloadAlbumPhoto{
    
    for (UIView *view in self.albumScroll.subviews) {
        if (view!=self.indicatorView) {
             [view removeFromSuperview];
        }
    }
    CGFloat yOffset = 13;
    CGFloat height = 0;
    for (NSInteger index=0; index<self.assetsArry.count; index++) {
        ALAsset *asset = self.assetsArry[index];
        UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag= kAlbumPhotoBaseTag+index;
        btn.clipsToBounds = YES;
        [btn setBackgroundImage:image forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(albumPhotoDidChoosed:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(0, yOffset+(yOffset+50)*index, 50, 50);
        height = yOffset*2 +(yOffset+50)*index + 50;
        [self.albumScroll addSubview:btn];
    }
    [self.albumScroll bringSubviewToFront:self.indicatorView];
    
    self.indicatorView.frame = CGRectMake(0, yOffset+(yOffset+50)*self.selectedIndex, 50, 50);
    self.indicatorView.hidden = self.selectedIndex<0;
    self.albumScroll.contentSize = CGSizeMake(50, MAX(height, CGRectGetHeight(self.albumScroll.frame)+1));
}

- (void)albumPhotoDidChoosed:(UIButton *)btn{
    
    NSInteger index = btn.tag-kAlbumPhotoBaseTag;
    if (self.selectedIndex==index) {
        //取消
        self.selectedIndex=-1;
        self.indicatorView.hidden = YES;
        [self.ronateCropperView reset];
    }else{
        //添加
        ALAsset *asset = self.assetsArry[index];
        UIImage *img = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage
                                           scale:asset.defaultRepresentation.scale
                                     orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
        [self didChoosePhoto:img];
        self.selectedIndex=index;
        self.indicatorView.frame = btn.frame;
        self.indicatorView.hidden = NO;
        
        [self.albumScroll bringSubviewToFront:self.indicatorView];
    }
}


- (void)didChoosePhoto:(UIImage *)image{
    
    self.ronateCropperView.image = image;
}


- (void)setupAssetsLibrary{
    
    self.assetsArry = [@[] mutableCopy];
    
    WS(ws);
    // Block called for every asset selected
    void (^selectionBlock)(ALAsset*, NSUInteger, BOOL*) = ^(ALAsset* result,
                                                            NSUInteger index,
                                                            BOOL* innerStop) {
        
        NSString *assetType = [result valueForProperty:ALAssetPropertyType];
        if ([assetType isEqualToString:ALAssetTypePhoto]){
            
            if (result != nil){
                //获取到第一张图片
                NSLog(@"发现照片");
                [ws.assetsArry addObject:result];
            } else {
                NSLog(@"Failed to create the image.");
            }
        }
        
        // do something with the image
    };
    
    // Block called when enumerating asset groups
    void (^enumerationBlock)(ALAssetsGroup*, BOOL*) = ^(ALAssetsGroup* group, BOOL* stop) {
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // Get the photo at the last index
        NSMutableIndexSet* lastPhotoIndexSet = [NSMutableIndexSet indexSet];
        NSInteger maxCount = [group numberOfAssets];
        NSInteger startIndex = maxCount>9 ? (maxCount-9): 0;
        
        for (NSInteger index = maxCount-1; index>=startIndex; index--) {
            [lastPhotoIndexSet addIndex:index];
        }
        [group enumerateAssetsAtIndexes:lastPhotoIndexSet options:0 usingBlock:selectionBlock];
        
        if (ws.assetsArry.count>=9 || [lastPhotoIndexSet count]==0) {
            *stop = YES;
        }
        
        if (nil==group) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ws.assetsArry = [[[ws.assetsArry reverseObjectEnumerator] allObjects] mutableCopy];
                [ws reloadAlbumPhoto];
            });
        }
    };
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [ws.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:enumerationBlock
                         failureBlock:^(NSError* error) {
                             // handle error
                              [ws reloadAlbumPhoto];
                         }];
}


- (void)showImagePicker:(UIImagePickerControllerSourceType) type{
    
    UIImagePickerController *imagepicker = [[UIImagePickerController alloc] init];
    imagepicker.sourceType = type;
    imagepicker.delegate = self;
    imagepicker.allowsEditing = NO;
    imagepicker.mediaTypes = @[(NSString*)kUTTypeImage];
    [self presentViewController:imagepicker animated:YES completion:NULL];
}

#pragma mark -
#pragma mark Delegates
//UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    //获取图片裁剪的图
    UIImage* img = [info objectForKey:UIImagePickerControllerOriginalImage];
     [self didChoosePhoto:img];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)beginBtnDidTap:(id)sender {

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
    
    
    JJEditBoardViewController *edit = [[JJEditBoardViewController alloc] initWithNibName:@"JJEditBoardViewController" bundle:nil];
    edit.img = image;
    edit.frame = self.contentView.frame;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:edit];
    WS(ws);
    [self setBarsHidden:YES animation:0.3 completion:^(BOOL finished) {
        [ws presentViewController:navi animated:NO completion:^{
            
            [edit openSelf];
        }];
    }];
}



- (void)setBarsHidden:(BOOL)hidden animation:(CGFloat)animation completion:(void (^)(BOOL finished))completion{
    
    //打开上下工具栏动画
    CGFloat showY = CGRectGetMaxY(self.contentView.frame)+8;
    CGFloat closeY = CGRectGetHeight(self.view.frame);
    [self hideAlbumBoard:YES withAnimation:YES];
    [UIView animateWithDuration:animation animations:^{
        self.changeBgBtn.superview.frame = CGRectMake(0, hidden?-30:0, SCREEN_WIDTH, 30);
        self.changeBgBtn.userInteractionEnabled = YES;
        self.beginBtn.frame = CGRectMake((SCREEN_WIDTH-116)/2, hidden?closeY:showY, 116, 33);

    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}

- (IBAction)backBtnDidTap:(id)sender {
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
