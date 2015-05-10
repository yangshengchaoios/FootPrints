//
//  JJActivityDetaiOpenCell.h
//  Footprints
//
//  Created by Jinjin on 14/11/17.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^DidChangeBlock)(BOOL isOpen);

@interface JJActivityDetaiOpenCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *openBtn;
- (IBAction)oepnBtnDidTap:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (nonatomic,readonly) BOOL isOpen;
@property (nonatomic,strong) DidChangeBlock block;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,strong) UIView *bottomLine;
@property (nonatomic,strong) UIImageView *btnIcon;
- (void)setDetailLabelText:(NSString *)text;
+ (CGFloat)heightForText:(NSString *)text isOpen:(BOOL)isOpen;
@end
