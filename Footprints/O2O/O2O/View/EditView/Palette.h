//
//  Palette.h
//  MyPalette
//
//  Created by xiaozhu on 11-6-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Palette : UIView
{
    BOOL allline;
	float x;
	float y;
	//-------------------------
	float           Intsegmentwidth;
	//-------------------------
	NSMutableArray* myallpoint;
	NSMutableArray* myallline;
	NSMutableArray* myallColor;
	NSMutableArray* myallwidth;
    
    NSMutableArray* myRedoDatas;
	
}
@property float x;
@property float y;

@property (nonatomic,strong) UIColor *curColor;

-(void)Introductionpoint1;
-(void)Introductionpoint2;
-(void)Introductionpoint3:(CGPoint)sender;
-(void)Introductionpoint4:(UIColor *)color;
-(void)Introductionpoint5:(int)sender;

//=====================================
-(void)myalllineclear;
-(void)myLineFinallyRemove;
//===========================================================
//反撤销
//===========================================================
-(void)myLineFinallyAdd;
//-(void)myrubbereraser;
@end
