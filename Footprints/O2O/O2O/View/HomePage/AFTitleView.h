//
//  AFTitleView.h
//  Whatstock
//
//  Created by Jinjin on 14/12/9.
//  Copyright (c) 2014年 AnnyFun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AFTitleView;
@protocol AFTitleViewDelegate <NSObject>
- (void)titleViewDidTapSearchBtn:(AFTitleView *)titleView;
@end

@interface AFTitleView : UIView
@property (nonatomic,assign) CGSize realSize;
@property (weak, nonatomic) IBOutlet UIImageView *searchbar;
@property (weak, nonatomic) IBOutlet UIImageView *searchIcon;
@property (weak, nonatomic) id<AFTitleViewDelegate> delegate;
- (IBAction)searchBtnDidTap:(id)sender;
@end
