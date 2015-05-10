//
//  Palette.m
//  MyPalette
//
//  Created by xiaozhu on 11-6-23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Palette.h"


@implementation Palette
@synthesize x;
@synthesize y;
- (id)initWithFrame:(CGRect)frame {
    
	NSLog(@"initwithframe");
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        self.curColor = [UIColor blackColor];
    }
    return self;
	
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect 
{
	//NSLog(@"Thes is drawRect ");
	//获取上下文
	CGContextRef context=UIGraphicsGetCurrentContext();
	//设置笔冒
	CGContextSetLineCap(context, kCGLineCapRound);
	//设置画线的连接处　拐点圆滑
	CGContextSetLineJoin(context, kCGLineJoinRound);
	//第一次时候个myallline开辟空间
    
	if (allline==NO)
	{
		myallline=[[NSMutableArray alloc] initWithCapacity:10];
		myallColor=[[NSMutableArray alloc] initWithCapacity:10];
		myallwidth=[[NSMutableArray alloc] initWithCapacity:10];
		allline=YES;
	}
	//画之前线
	if ([myallline count]>0)
	{
		for (int i=0; i<[myallline count]; i++)
		{
            UIColor *color = self.curColor;
			NSArray* tempArray=[NSArray arrayWithArray:[myallline objectAtIndex:i]];
			//----------------------------------------------------------------
			if ([myallColor count]>0)
			{
                color =[myallColor objectAtIndex:i];
				Intsegmentwidth=[[myallwidth objectAtIndex:i]floatValue]+1;
			}
			//-----------------------------------------------------------------
			if ([tempArray count]>1)
			{
				CGContextBeginPath(context);
				CGPoint myStartPoint=[[tempArray objectAtIndex:0] CGPointValue];
				CGContextMoveToPoint(context, myStartPoint.x, myStartPoint.y);
				
				for (int j=0; j<[tempArray count]-1; j++)
				{
					CGPoint myEndPoint=[[tempArray objectAtIndex:j+1] CGPointValue];
					//--------------------------------------------------------
					CGContextAddLineToPoint(context, myEndPoint.x,myEndPoint.y);	
				}
				CGContextSetStrokeColorWithColor(context, [color CGColor]);
				//-------------------------------------------------------
				CGContextSetLineWidth(context, Intsegmentwidth);
				CGContextStrokePath(context);
			}
		}
	}
	//画当前的线
	if ([myallpoint count]>1)
	{
		CGContextBeginPath(context);
		//-------------------------
		//起点
		//------------------------
		CGPoint myStartPoint=[[myallpoint objectAtIndex:0]   CGPointValue];
		CGContextMoveToPoint(context,    myStartPoint.x, myStartPoint.y);
		//把move的点全部加入　数组
		for (int i=0; i<[myallpoint count]-1; i++)
		{
			CGPoint myEndPoint=  [[myallpoint objectAtIndex:i+1] CGPointValue];
			CGContextAddLineToPoint(context, myEndPoint.x,   myEndPoint.y);
		}
		//在颜色和画笔大小数组里面取不相应的值
		UIColor *color =[myallColor lastObject];
		Intsegmentwidth=[[myallwidth lastObject]floatValue]+1;
		
		//-------------------------------------------
		//绘制画笔颜色
		CGContextSetStrokeColorWithColor(context, [color CGColor]);
		CGContextSetFillColorWithColor (context,  [color CGColor]);
		//-------------------------------------------
		//绘制画笔宽度
		CGContextSetLineWidth(context, Intsegmentwidth);
		//把数组里面的点全部画出来
		CGContextStrokePath(context);
	}
}
//===========================================================
//初始化
//===========================================================
-(void)Introductionpoint1
{
	NSLog(@"in init allPoint");
	myallpoint=[[NSMutableArray alloc] initWithCapacity:10];
}
//===========================================================
//把画过的当前线放入　存放线的数组
//===========================================================
-(void)Introductionpoint2
{
    if (myallpoint.count) {
        [myallline addObject:myallpoint];
        myallpoint = nil;
    }
}
//===========================================================
//接收最新的点
//===========================================================
-(void)Introductionpoint3:(CGPoint)sender
{
	NSValue* pointvalue=[NSValue valueWithCGPoint:sender];
	[myallpoint addObject:pointvalue];
}
//===========================================================
//接收颜色segement反过来的值
//===========================================================
-(void)Introductionpoint4:(UIColor *)color
{
    [myallColor addObject:color?:[UIColor blackColor]];
}
//===========================================================
//接收线条宽度按钮反回来的值
//===========================================================
-(void)Introductionpoint5:(int)sender
{
	NSLog(@"Palette sender:%i", sender);
	NSNumber* Numbersender= [NSNumber numberWithInt:sender];
	[myallwidth addObject:Numbersender];
}
//===========================================================
//清屏按钮
//===========================================================
-(void)myalllineclear
{
	if ([myallline count]>0)
	{
		[myallline removeAllObjects];
		[myallColor removeAllObjects];
		[myallwidth removeAllObjects];
		[myallpoint removeAllObjects];
		myallline=[[NSMutableArray alloc] initWithCapacity:10];
		myallColor=[[NSMutableArray alloc] initWithCapacity:10];
		myallwidth=[[NSMutableArray alloc] initWithCapacity:10];
		[self setNeedsDisplay];
	}
}
//===========================================================
//撤销
//===========================================================
-(void)myLineFinallyRemove
{
    if ([myallline count]>0)
	{
        //保存最后的数据
        id  line = [myallline lastObject];
        id  color = [myallColor lastObject];
        id  width = [myallwidth lastObject];
        if (line && color && width) {
            if (nil==myRedoDatas) {
                myRedoDatas = [@[] mutableCopy];
            }
            [myRedoDatas addObject:@{@"line":line,@"color":color,@"width":width}];
        }
        
		[myallline  removeLastObject];
		[myallColor removeLastObject];
        [myallwidth removeLastObject];
        
        NSLog(@"撤消后 数量：%i",myallline.count);
        
        [self setNeedsDisplay];
    }
}

//===========================================================
//反撤销
//===========================================================
-(void)myLineFinallyAdd
{
    if ([myRedoDatas count]>0)
    {
        NSDictionary *data = [myRedoDatas lastObject];
        
        [myallline  addObject:data[@"line"]];
        [myallColor addObject:data[@"color"]];
        [myallwidth addObject:data[@"width"]];
        
        [myRedoDatas removeLastObject];
        NSLog(@"返撤消后 数量：%i",myallline.count);
        
        [self setNeedsDisplay];
    }
}

//===========================================================
//橡皮擦　segmentColor=[[UIColor whiteColor]CGColor];
//===========================================================
//-(void)myrubberseraser
//{
//	segmentColor=[[UIColor whiteColor]CGColor];
//}
-(void)button
{
	NSLog(@"button");
	
	//[self setNeedsDisplay];
}


@end
