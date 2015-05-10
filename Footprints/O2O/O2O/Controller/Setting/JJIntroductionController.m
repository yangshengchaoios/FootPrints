//
//  JJIntroductionController.m
//  Footprints
//
//  Created by Jinjin on 14/12/11.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJIntroductionController.h"

@interface JJIntroductionController ()
@property (weak, nonatomic) IBOutlet UIImageView *introductionView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScroll;

@end

@implementation JJIntroductionController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"功能介绍";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    WS(ws);
    CGFloat scale = self.introductionView.image.size.width/self.introductionView.image.size.height;
    CGSize size = CGSizeMake( SCREEN_WIDTH, SCREEN_WIDTH/scale);
    CGRect rect = self.navigationController.navigationBar.frame;
    [self.contentScroll mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(ws.view);
    }];
    [self.introductionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(ws.contentScroll);
        make.left.mas_equalTo(ws.contentScroll);
        make.size.mas_equalTo(size);
    }];
    self.contentScroll.backgroundColor = RGB(122, 122, 122);
    self.contentScroll.contentSize = CGSizeMake(SCREEN_WIDTH, MAX(SCREEN_HEIGHT-rect.size.height-20+1, size.height));
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
