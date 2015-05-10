//
//  BaseViewController.m
//  SCSDEnterprise
//
//  Created by  YangShengchao on 14-2-13.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import "BaseViewController.h"

#define kHudIntervalShort 0.5f
#define kHudIntervalNormal 1.0f
#define kHudIntervalLong 2.0f

#pragma mark - BaseViewController

@interface BaseViewController () <UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIStoryboard *storyBoard;

@end

@implementation BaseViewController

#pragma mark - 重写基类方法

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization

    //----添加网络状态监控功能
    [[ReachabilityManager sharedInstance]
        addObserver:self
         forKeyPath:@"reachable"
            options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
            context:NULL];
  }
  return self;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];

  // TODO:这里需要释放dataModel
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.isAppeared = YES;

  if ([self showCustomTitleBarView]) {
    if (self.navigationController) {
      [self.navigationController setNavigationBarHidden:YES];
      [self.navigationController setToolbarHidden:YES];
    }
//    [self.view bringSubviewToFront:self.titleBarView];
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
//  [MobClick beginLogPageView:NSStringFromClass([self class])];
}

- (void)viewWillDisappear:(BOOL)animated {
//  [MobClick endLogPageView:NSStringFromClass([self class])];
  [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  self.isAppeared = NO;
}

- (void)dealloc {
  NSLog(@"[%@] dealloc......", NSStringFromClass(self.class));
  [[ReachabilityManager sharedInstance] removeObserver:self
                                            forKeyPath:@"reachable"];
//  [[Login sharedInstance] unregisterLoginObserver:self];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  初始化
 */
- (void)viewDidLoad {
  [super viewDidLoad];
  [self loadCache]; //加载本地缓存

  self.view.clipsToBounds = YES;
  UIGestureRecognizer *gestureRecognizer =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(singleTapped:)];
  gestureRecognizer.cancelsTouchesInView = NO;
  gestureRecognizer.delegate = self;
  [self.view addGestureRecognizer:gestureRecognizer];

  if ([self willCareKeyboard]) {
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification
             object:nil];
  }

  //-----在输入框聚焦的情况下按键盘的return键要隐藏键盘
  [self setDelegateOfAllTextFields:self.view];

  //-----获取返回类型参数
  if (self.params[@"backType"]) {
    self.backType = [self.params[@"backType"] integerValue];
  } else {
    self.backType = BackTypePop;
  }

  //设置导航栏
//  if ([self showCustomTitleBarView]) {
//    if (!self.titleBarView) {
//      self.titleBarView = [TitleBarView new];
//      [self.view addSubview:self.titleBarView];
//    }
//    self.titleBarView.hidden = NO;
//  } else {
//    if (self.titleBarView) {
//      self.titleBarView.hidden = YES;
//    }
//  }

  //-----设置返回按钮类型
  if (self.backType == BackTypeSliding) { //设置侧边栏按钮
    if ([self showCustomTitleBarView]) {
      if (!self.backButton) {
        self.backButton =
            [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 50, 44)];
        self.backButton.contentEdgeInsets = UIEdgeInsetsMake(10, 13, 11, 14);
        self.backButton.autoresizingMask =
            UIViewAutoresizingFlexibleBottomMargin;
        self.backButton.backgroundColor = [UIColor clearColor];
        [self.backButton setTitle:nil forState:UIControlStateNormal];
        [self.backButton setImage:[UIImage imageNamed:@"button_leftslide"]
                         forState:UIControlStateNormal];
      }
      [self.backButton addTarget:self
                          action:@selector(leftSlideButtonClicked:)
                forControlEvents:UIControlEventTouchUpInside];
//      [self.titleBarView addSubview:self.backButton];
    } else {
      UIButton *slideButton =
          [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 40)];
      [slideButton addTarget:self
                      action:@selector(leftSlideButtonClicked:)
            forControlEvents:UIControlEventTouchUpInside];
      [slideButton setImageEdgeInsets:UIEdgeInsetsMake(4, -4, 4, 16)];
      [slideButton setImage:[UIImage imageNamed:@"button_leftslide"]
                   forState:UIControlStateNormal];
      slideButton.tintColor = [UIColor blackColor];
      self.navigationItem.hidesBackButton = YES;
      self.navigationItem.leftBarButtonItems =
          [self customBarButtonOnNavigationBar:slideButton
                           withFixedSpaceWidth:-10];
    }
  } else if (self.backType == BackTypePop) { //设置返回按钮
    if ([self showCustomTitleBarView]) {
      if (!self.backButton) {
        self.backButton =
            [[UIButton alloc] initWithFrame:CGRectMake(2, 22, 44, 40)];
        self.backButton.contentEdgeInsets = UIEdgeInsetsMake(4, 0, 4, 12);
        self.backButton.autoresizingMask =
            UIViewAutoresizingFlexibleBottomMargin;
        self.backButton.backgroundColor = [UIColor clearColor];
        [self.backButton setTitle:nil forState:UIControlStateNormal];
        [self.backButton setImage:[UIImage imageNamed:@"button_dismiss"]
                         forState:UIControlStateNormal];
      }
      [self.backButton addTarget:self
                          action:@selector(popButtonClicked:)
                forControlEvents:UIControlEventTouchUpInside];
//      [self.titleBarView addSubview:self.backButton];
    } else {
      UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
      temporaryBarButtonItem.title = @"";
      self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    }
  } else {
    NSAssert(YES, @"self.backType = [%d] 不支持该类型！", self.backType);
    //        NSParameterAssert(self.backType > BackTypePop);//第二种方法
  }
  //-------------END----------------

  //----解决导航条在移出时的延迟问题-----
  self.view.layer.masksToBounds = YES;

  //----解决在ios7环境下viewcontroller内容有20个像素的偏差----
  self.extendedLayoutIncludesOpaqueBars = NO;
  self.edgesForExtendedLayout =
      UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;

  //----设置默认背景颜色
  self.view.backgroundColor = kDefaultViewColor;
    
    //----空数据提示
    [self.noDataInfo removeFromSuperview];
    self.noDataInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    self.noDataInfo.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, MIN(200, CGRectGetHeight(self.view.frame)/2));
    self.noDataInfo.textAlignment = NSTextAlignmentCenter;
    self.noDataInfo.text = @"没有数据";
    self.noDataInfo.textColor = RGB(180, 180, 180);
    self.noDataInfo.hidden = YES;
    [self.view addSubview:self.noDataInfo];
}

#pragma mark - 私有方法

- (void)singleTapped:(UIGestureRecognizer *)gestureRecognizer {
  [self performSelector:@selector(hideKeyboard) withObject:nil afterDelay:0.1f];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
  NSDictionary *userInfo = [notification userInfo];
  NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
  CGRect keyboardRect = [aValue CGRectValue];
  NSValue *animationDurationValue =
      [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
  NSTimeInterval animationDuration;
  [animationDurationValue getValue:&animationDuration];

  [self willLayoutForKeyboardHeight:keyboardRect.size.height];
  WeakSelfType blockSelf = self;
  [UIView animateWithDuration:animationDuration
      animations:^{
          [blockSelf layoutForKeyboardHeight:keyboardRect.size.height];
      }
      completion:^(BOOL finished) {
          [blockSelf didLayoutForKeyboardHeight:keyboardRect.size.height];
      }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  NSValue *animationDurationValue =
      [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
  NSTimeInterval animationDuration;
  [animationDurationValue getValue:&animationDuration];

  [self willLayoutForKeyboardHeight:0];
  WeakSelfType blockSelf = self;
  [UIView animateWithDuration:animationDuration
      animations:^{ [blockSelf layoutForKeyboardHeight:0]; }
      completion:^(BOOL finished) {
          [blockSelf didLayoutForKeyboardHeight:0];
      }];
}

//递归遍历所有子view中的textfield
- (void)setDelegateOfAllTextFields:(UIView *)view {
  for (UIView *subview in view.subviews) {
    if ([subview isKindOfClass:[UITextField class]]) {
      ((UITextField *)subview).delegate = self;
      [[NSNotificationCenter defaultCenter]
          addObserver:self
             selector:@selector(textFieldChanged:)
                 name:UITextFieldTextDidChangeNotification
               object:(UITextField *)subview];
    } else {
      [self setDelegateOfAllTextFields:subview];
    }
  }
}

#pragma mark - push & pop & dismiss view controller

- (UIViewController *)pushViewController:(NSString *)className {
  return [self pushViewController:className withParams:nil];
}

- (UIViewController *)pushViewController:(NSString *)className
                              withParams:(NSDictionary *)paramDict {
  UIViewController *pushedViewController = nil;

  //第一步：检测是否在storyboard里有布局
  if (!pushedViewController) {
    @try {
      pushedViewController =
          [self.storyBoard instantiateViewControllerWithIdentifier:className];
    }
    @catch (NSException *exception) {
      NSLog(@"class[%@] is not found in storyboard!", className);
    }
    @finally {
    }
  }

  //第二步：检测是否有class文件 同时兼容用xib布局的情况
  if (!pushedViewController) {
    pushedViewController =
        [[NSClassFromString(className) alloc] initWithNibName:nil bundle:nil];
  }
  NSAssert(pushedViewController, @"class[%@] is not exists in this project!",
           className);
  [self hideKeyboard];
  if ([pushedViewController isKindOfClass:[BaseViewController class]]) {
    [(BaseViewController *)pushedViewController
        setParams:[NSDictionary dictionaryWithDictionary:paramDict]];
  }

  pushedViewController.hidesBottomBarWhenPushed = YES;
  [self.navigationController pushViewController:pushedViewController
                                       animated:YES];

  return pushedViewController;
}

/*
 * 返回上一层(最多到根)
 * 都是针对在presenting出来的viewController上操作pop，不是在presented上操作pop
 */
- (UIViewController *)popViewController {
  if (self.navigationController) { //如果有navigationBar
    NSInteger index =
        [self.navigationController.viewControllers indexOfObject:self];
    UIViewController *newTopViewController =
        [self.navigationController.viewControllers
            objectAtIndex:MAX(index - 1, 0)];
    [self.navigationController popViewControllerAnimated:YES];
    return newTopViewController;
  } else { //如果present出来的viewController没有navigationBar，则直接dismiss
    UIViewController *presentingViewController = self.presentingViewController;
    [presentingViewController dismissViewControllerAnimated:YES
                                                 completion:NULL];
    return presentingViewController;
  }
}

/**
 * 返回上一层(自动dismiss根)
 * 都是针对在presenting出来的viewController上操作pop，不是在presented上操作pop
 */
- (UIViewController *)backViewController {
  if (self.navigationController) { //如果有navigationBar
    NSInteger index =
        [self.navigationController.viewControllers indexOfObject:self];
    if (index > 0) { //不是root，就返回上一级
      UIViewController *newTopViewController =
          [self.navigationController.viewControllers
              objectAtIndex:MAX(index - 1, 0)];
      [self.navigationController popViewControllerAnimated:YES];
      return newTopViewController;
    } else { //从当前的viewController中执行dismiss操作
      UIViewController *presentingViewController =
          self.presentingViewController;
      [presentingViewController dismissViewControllerAnimated:YES
                                                   completion:NULL];
      return presentingViewController;
    }
  } else { //如果present出来的viewController没有navigationBar，则直接dismiss
    UIViewController *presentingViewController = self.presentingViewController;
    [presentingViewController dismissViewControllerAnimated:YES
                                                 completion:NULL];
    return presentingViewController;
  }
}

//返回到顶层
- (UIViewController *)popToRootViewController {
  UIViewController *newTopViewController =
      [self.navigationController.viewControllers objectAtIndex:0];
  [self.navigationController popToRootViewControllerAnimated:YES];
  return newTopViewController;
}

#pragma mark - present & dismiss viewcontroller

- (UIViewController *)presentViewController:(NSString *)className {
  return [self presentViewController:className withParams:nil];
}

- (UIViewController *)presentViewController:(NSString *)className
                                 withParams:(NSDictionary *)paramDict {
  UIViewController *viewController = nil;

  //第一步：检测是否在storyboard里有布局
  if (!viewController) {
    @try {
      viewController =
          [self.storyBoard instantiateViewControllerWithIdentifier:className];
    }
    @catch (NSException *exception) {
      NSLog(@"class[%@] is not found in storyboard!", className);
    }
    @finally {
    }
  }

  //第二步：检测是否有class文件 同时兼容用xib布局的情况
  if (!viewController) {
    viewController =
        [[NSClassFromString(className) alloc] initWithNibName:nil bundle:nil];
  }
  NSAssert(viewController, @"class[%@] i`s not exists in this project!",
           className);

  //
  NSLog(@"进入页面:%@", className);
  if ([viewController isKindOfClass:[BaseViewController class]]) {
    [(BaseViewController *)viewController
        setParams:[NSDictionary dictionaryWithDictionary:paramDict]];
  }

  UINavigationController *navigationController = [[UINavigationController alloc]
      initWithRootViewController:viewController];
  navigationController.navigationBar.tintColor = [UIColor blackColor];
  [self presentViewController:navigationController animated:YES completion:nil];

  //--------自定义present出来的navigationBar上的返回按钮
  UIButton *dismissButton =
      [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 40)];
  [dismissButton addTarget:self
                    action:@selector(dismissOnPresentedViewController)
          forControlEvents:UIControlEventTouchUpInside];
  [dismissButton setImageEdgeInsets:UIEdgeInsetsMake(4, -4, 4, 16)];
  [dismissButton setImage:[UIImage imageNamed:@"button_goback"]
                 forState:UIControlStateNormal];
  dismissButton.tintColor = [UIColor blackColor];

  viewController.navigationItem.leftBarButtonItems =
      [self customBarButtonOnNavigationBar:dismissButton
                       withFixedSpaceWidth:-10];
  //--------
  [self hideKeyboard];
  return navigationController;
}

// dismiss on navigationbar（只有在自定义navigationbar上的按钮事件时采用该方法）
- (void)dismissOnPresentedViewController {
  if (self.presentedViewController) {
    [self.presentedViewController dismissViewControllerAnimated:YES
                                                     completion:nil];
  }
}

// dismiss on presenting（通常情况下用该方法）
- (void)dismissOnPresentingViewController {
  if (self.presentingViewController) {
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:nil];
  }
}

#pragma mark - showPhotoViewController

- (UIViewController *)showPhotosWithImage:(UIImage *)image {
  if (!image) {
    return nil;
  }
  return [self showPhotosWithImages:@[ image ]];
}

- (UIViewController *)showPhotosWithImages:(NSArray *)images {
  return [self showPhotosWithImages:images atIndex:0];
}

- (UIViewController *)showPhotosWithImageUrls:(NSArray *)imageUrls
                                      atIndex:(NSInteger)index {
  if (![imageUrls count]) {
    return nil;
  }
  UIViewController *viewController =
      [self pushViewController:@"PhotoViewController"
                    withParams:@{
                      @"imageUrls" : imageUrls,
                      @"index" : @(index)
                    }];
  return viewController;
}

- (UIViewController *)showPhotosWithImageUrl:(NSString *)imageUrl {
  if ([StringUtils isEmpty:imageUrl]) {
    return nil;
  }
  return [self showPhotosWithImageUrls:@[ imageUrl ]];
}

- (UIViewController *)showPhotosWithImageUrls:(NSArray *)imageUrls {
  return [self showPhotosWithImageUrls:imageUrls atIndex:0];
}

- (UIViewController *)showPhotosWithImages:(NSArray *)images
                                   atIndex:(NSInteger)index {
  if (![images count]) {
    return nil;
  }
  UIViewController *viewController =
      [self pushViewController:@"PhotoViewController"
                    withParams:@{
                      @"images" : images,
                      @"index" : @(index)
                    }];
  return viewController;
}

#pragma mark -  show & hide HUD

//在self.view上显示hud
- (MBProgressHUD *)showHUDLoadingWithString:(NSString *)hintString {
  return [self showHUDLoadingWithString:hintString onView:self.view];
}

//在window上显示hud
- (MBProgressHUD *)showHUDLoadingWithStringOnWindow:(NSString *)hintString {
  UIView *view = [UIApplication sharedApplication].keyWindow;
  return [self showHUDLoadingWithString:hintString onView:view];
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

//隐藏self.view上的hud
- (void)hideHUDLoading {
  [self hideHUDLoadingOnView:self.view];
}

//隐藏window上的hud
- (void)hideHUDLoadingOnWindow {
  UIView *view = [UIApplication sharedApplication].keyWindow;
  [self hideHUDLoadingOnView:view];
}

//隐藏hud的通用方法
- (void)hideHUDLoadingOnView:(UIView *)view {
  MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
  [hud hide:YES];
}

//直接隐藏self.view上的hud
- (void)showResultThenHide:(NSString *)resultString {
  [self showResultThenHide:resultString
                afterDelay:kHudIntervalNormal
                    onView:self.view];
}

//直接隐藏window上的hud
- (void)showResultThenHideOnWindow:(NSString *)resultString {
  UIView *view = [UIApplication sharedApplication].keyWindow;
  [self showResultThenHide:resultString
                afterDelay:kHudIntervalNormal
                    onView:view];
}

//延迟隐藏self.view上的hud,返回上一级
- (void)showResultThenPop:(NSString *)resultString {
  [self showResultThenHide:resultString
                afterDelay:kHudIntervalNormal
                    onView:self.view];
  [self performSelector:@selector(popViewController)
             withObject:nil
             afterDelay:kHudIntervalNormal];
}

//延迟隐藏window上的hud后，返回上一级
- (void)showResultThenPopOnWindow:(NSString *)resultString {
  UIView *view = [UIApplication sharedApplication].keyWindow;
  [self showResultThenHide:resultString
                afterDelay:kHudIntervalNormal
                    onView:view];
  [self performSelector:@selector(popViewController)
             withObject:nil
             afterDelay:kHudIntervalNormal];
}

//延迟隐藏self.view上的hud后，并返回上一级或dismiss
- (void)showResultThenBack:(NSString *)resultString {
  [self showResultThenHide:resultString
                afterDelay:kHudIntervalNormal
                    onView:self.view];
  [self performSelector:@selector(backViewController)
             withObject:nil
             afterDelay:kHudIntervalNormal];
}

//延迟隐藏window上的hud后，并返回上一级或dismiss
- (void)showResultThenBackOnWindow:(NSString *)resultString {
  UIView *view = [UIApplication sharedApplication].keyWindow;
  [self showResultThenHide:resultString
                afterDelay:kHudIntervalNormal
                    onView:view];
  [self performSelector:@selector(backViewController)
             withObject:nil
             afterDelay:kHudIntervalNormal];
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

#pragma mark - alert view

- (UIAlertView *)showAlertVieWithMessage:(NSString *)message {
  return [self showAlertViewWithTitle:@"提示" andMessage:message];
}

- (UIAlertView *)showAlertViewWithTitle:(NSString *)title
                             andMessage:(NSString *)message {
  UIAlertView *alertView =
      [UIAlertView bk_alertViewWithTitle:title message:message];
  [alertView bk_setCancelButtonWithTitle:@"确定" handler:nil];
  [alertView show];
  return alertView;
}

#pragma mark - Overridden methods 缓存相关

- (NSString *)cacheFilePath {
  NSString *fileName = [NSString
      stringWithFormat:@"%@.dat", NSStringFromClass(self.class)]; //缓存文件名称
  NSString *filePath =
      [[[StorageManager sharedInstance] cachesDirectoryPathCommon]
          stringByAppendingPathComponent:fileName]; //缓存文件路径
  return filePath;
}

- (id)cachedObjectByKey:(NSString *)cachedKey {
  NSDictionary *cacheInfo = [[StorageManager sharedInstance]
      unarchiveDictionaryFromFilePath:[self cacheFilePath]];
  if ([cacheInfo objectForKey:cachedKey]) {
    return cacheInfo[cachedKey];
  } else {
    return nil;
  }
}

- (void)saveObjectToCache:(id)object toKey:(NSString *)cachedKey {
  if ([StringUtils isEmpty:cachedKey]) {
    return;
  }

  @try {
    BOOL isSuccess = [[StorageManager sharedInstance] archiveDictionary:@{
      cachedKey : object
    } toFilePath:[self cacheFilePath] overwrite:NO];
    if (isSuccess) {
//      NSLog(@"缓存成功！");
    } else {
      NSLog(@"缓存失败！");
    }
  }
  @catch (NSException *exception) {
    NSLog(@"将数组保存至本地缓存时出错！%@",
          exception); //可能是没有在对象里做序列号和反序列化！
  }
  @finally {
  }
}

- (void)loadCache {
}

#pragma mark - Overridden methods 业务相关

/**
 *  返回自定义的在navigationBar上的按钮
 *
 *  @param customButton
 *  @param width        -10
 *
 *  @return
 */
- (NSArray *)customBarButtonOnNavigationBar:(UIView *)customButton
                        withFixedSpaceWidth:(NSInteger)width {
  UIBarButtonItem *leftButtonItem =
      [[UIBarButtonItem alloc] initWithCustomView:customButton];
  UIBarButtonItem *flexSpacer = [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                           target:self
                           action:nil];
  flexSpacer.width = width;
  return [NSArray arrayWithObjects:flexSpacer, leftButtonItem, nil];
}

/**
 *  在自定义navigationBar上的返回按钮点击事件，
 *  返回上一级（如果有导航条最多只返回到根，如果没有导航条就dismiss）
 *
 *  @param sender
 */
- (IBAction)backButtonClicked:(id)sender {
  [self hideKeyboard];
  [self backViewController];
}

/**
 *  返回上一级按钮
 *  如果是rootViewController了，就dismiss
 *
 *  @param sender
 */
- (IBAction)popButtonClicked:(id)sender {
  [self hideKeyboard];
  [self popViewController];
}

/**
 *  点击侧边栏
 *
 *  @param sender
 */
- (IBAction)leftSlideButtonClicked:(id)sender {
  [self hideKeyboard];
  //    if (self.drawerController) {
  //        [self.drawerController toggleDrawerSide:XHDrawerSideLeft
  //        animated:YES completion:nil];
  //    }
}

/**
 *  设置是否显示自定义titleBar
 *  默认不显示
 */
- (BOOL)showCustomTitleBarView {
  return NO;
}

- (void)hideKeyboard {
  [self.view endEditing:YES];
}

- (BOOL)willCareKeyboard {
  return NO;
}

- (void)willLayoutForKeyboardHeight:(CGFloat)keyboardHeight {
}

- (void)layoutForKeyboardHeight:(CGFloat)keyboardHeight {
}

- (void)didLayoutForKeyboardHeight:(CGFloat)keyboardHeight {
}

- (void)networkReachablityChanged:(BOOL)reachable {
  if (!reachable) {
    [self showResultThenHide:@"网络断开了"];
  }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self hideKeyboard];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (textField.maxLength > 0) {
		NSMutableString *newText = [textField.text mutableCopy];
		[newText replaceCharactersInRange:range withString:string]; //兼容从中间插入内容的情况！
		return [newText length] <= textField.maxLength;
	}
	return YES;
}

- (void)textFieldChanged:(NSNotification *)note {
	UITextField *textField = (UITextField *)note.object;
	if (![textField isKindOfClass:[UITextField class]]) {
		return;
	}
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	return YES;
}

#pragma mark - Observe KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	WeakSelfType blockSelf = self;
	if ([keyPath isEqualToString:@"reachable"]) {
		dispatch_async(dispatch_get_main_queue(), ^{
		    BOOL reachable = [ReachabilityManager sharedInstance].reachable;
		    [blockSelf networkReachablityChanged:reachable];
		});
	}
}

@end
