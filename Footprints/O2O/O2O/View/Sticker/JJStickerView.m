//
//  JJStickerView.m
//  Footprints
//
//  Created by tt on 14-10-10.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJStickerView.h"
#import <QuartzCore/QuartzCore.h>
#import <math.h>



@interface JJStickerView ()


@property (nonatomic) BOOL preventsLayoutWhileResizing;

@property (nonatomic) float deltaAngle;
@property (nonatomic) CGPoint prevPoint;
@property (nonatomic) CGAffineTransform startTransform;

@property (nonatomic) CGPoint touchStart;

@end

@implementation JJStickerView
@synthesize contentView, touchStart;

@synthesize prevPoint;
@synthesize deltaAngle, startTransform; //rotation
@synthesize resizingControl, deleteControl;
@synthesize preventsPositionOutsideSuperview;
@synthesize preventsResizing;
@synthesize preventsDeleting;
@synthesize minWidth, minHeight;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)singleTap:(UIPanGestureRecognizer *)recognizer
{
    if (NO == self.preventsDeleting) {
        UIView * close = (UIView *)[recognizer view];
        [close.superview removeFromSuperview];
    }
    
    if([_delegate respondsToSelector:@selector(stickerViewDidClose:)]) {
        [_delegate stickerViewDidClose:self];
    }
}

CGFloat last = 0;
-(void)resizeTranslate:(UIPanGestureRecognizer *)recognizer
{
    if ([recognizer state]== UIGestureRecognizerStateBegan){
        prevPoint = self.center;
        
        CGPoint point = [recognizer locationInView:self.superview];
        last = [self distanceFromPointX:prevPoint distanceToPointY:point];
        
        [self setNeedsDisplay];
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged){
        
        CGPoint point = [recognizer locationInView:self.superview];
        CGFloat c = [self distanceFromPointX:prevPoint distanceToPointY:point];
        CGFloat h = self.bounds.size.height+(c-last);
        CGFloat w = self.whScale * h;
        
        self.bounds = CGRectMake(0, 0, w, h);
        
        // Rotation
        float ang = atan2([recognizer locationInView:self.superview].y - self.center.y,
                          [recognizer locationInView:self.superview].x - self.center.x);
        float angleDiff = deltaAngle - ang;
        if (NO == preventsResizing) {
            self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -angleDiff);
        }
        [self setNeedsDisplay];
        last = c;
        
        [self didChangeHeight];
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        prevPoint = [recognizer locationInView:self];
        self.bounds = self.bounds;
        [self setNeedsDisplay];
        
        [self didEndChangeHeight];
    }
}

- (void)didChangeHeight{

}

- (void)didEndChangeHeight {
    
}

-(CGFloat)distanceFromPointX:(CGPoint)start distanceToPointY:(CGPoint)end{
    float distance;
    //下面就是高中的数学，不详细解释了
    CGFloat xDist = (end.x - start.x);
    CGFloat yDist = (end.y - start.y);
    distance = sqrt((xDist * xDist) + (yDist * yDist));
    return distance;
}

- (void)setupDefaultAttributes {
    
    borderView = [[JJGripViewBorderView alloc] initWithFrame:CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset)];
    [borderView setHidden:YES];
    [self addSubview:borderView];
    
    if (kSPUserResizableViewDefaultMinWidth > self.bounds.size.width*0.5) {
        self.minWidth = kSPUserResizableViewDefaultMinWidth;
        self.minHeight = self.bounds.size.height * (kSPUserResizableViewDefaultMinWidth/self.bounds.size.width);
    } else {
        self.minWidth = self.bounds.size.width*0.5;
        self.minHeight = self.bounds.size.height*0.5;
    }
    self.preventsPositionOutsideSuperview = YES;
    self.preventsLayoutWhileResizing = YES;
    self.preventsResizing = NO;
    self.preventsDeleting = NO;
    
    deleteControl = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,
                                                                 kJJStickerViewControlSize, kJJStickerViewControlSize)];
    deleteControl.backgroundColor = [UIColor clearColor];
    deleteControl.image = [UIImage imageNamed:@"the_text_delete.png" ];
    deleteControl.userInteractionEnabled = YES;
    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(singleTap:)];
    [deleteControl addGestureRecognizer:singleTap];
    [self addSubview:deleteControl];
    
    resizingControl = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-kJJStickerViewControlSize,
                                                                   self.frame.size.height-kJJStickerViewControlSize,
                                                                   kJJStickerViewControlSize, kJJStickerViewControlSize)];
    resizingControl.backgroundColor = [UIColor clearColor];
    resizingControl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    resizingControl.userInteractionEnabled = YES;
    resizingControl.image = [UIImage imageNamed:@"the_text_fangda.png" ];
    UIPanGestureRecognizer* panResizeGesture = [[UIPanGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(resizeTranslate:)];
    [resizingControl addGestureRecognizer:panResizeGesture];
    
    
    [self addSubview:resizingControl];
    deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                       self.frame.origin.x+self.frame.size.width - self.center.x);
    borderView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    borderView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
    [borderView setNeedsDisplay];
    
    [self hideEditingHandles];
}

- (void)resetControlFrame{
    
//    kSPUserResizableViewGlobalInset
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupDefaultAttributes];
        self.whScale = self.frame.size.width/self.frame.size.height;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupDefaultAttributes];
    }
    return self;
}

- (void)setContentView:(UIView *)newContentView {
    [contentView removeFromSuperview];
    contentView = newContentView;
    contentView.clipsToBounds = YES;
    contentView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset + kBorderSize, kSPUserResizableViewGlobalInset + kBorderSize);
    contentView.autoresizingMask = UIViewAutoresizingNone;//UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:contentView];
    
    [self bringSubviewToFront:borderView];
    [self bringSubviewToFront:resizingControl];
    [self bringSubviewToFront:deleteControl];
}

- (void)setFrame:(CGRect)newFrame {
    [super setFrame:newFrame];
    
    CGRect newBounds = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
    contentView.frame = CGRectInset(newBounds, kSPUserResizableViewGlobalInset + kBorderSize, kSPUserResizableViewGlobalInset + kBorderSize);
    borderView.frame = CGRectInset(newBounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
    
    [borderView setNeedsDisplay];
}

- (void)setBounds:(CGRect)bounds{
    
    [super setBounds:bounds];
    contentView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset + kBorderSize, kSPUserResizableViewGlobalInset + kBorderSize);
    borderView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
    [borderView setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    touchStart = [touch locationInView:self.superview];
    if([_delegate respondsToSelector:@selector(stickerViewDidBeginEditing:)]) {
        [_delegate stickerViewDidBeginEditing:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if([_delegate respondsToSelector:@selector(stickerViewDidEndEditing:)]) {
        [_delegate stickerViewDidEndEditing:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if([_delegate respondsToSelector:@selector(stickerViewDidCancelEditing:)]) {
        [_delegate stickerViewDidCancelEditing:self];
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touch = [[touches anyObject] locationInView:self.superview];
    [self translateUsingTouchLocation:touch];
    touchStart = touch;
}


- (void)translateUsingTouchLocation:(CGPoint)touchPoint {
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - touchStart.x,
                                    self.center.y + touchPoint.y - touchStart.y);
    if (self.preventsPositionOutsideSuperview) {
        // 确保内容不超出屏幕
        CGFloat midPointX = CGRectGetMidX(self.bounds);
        if (newCenter.x > self.superview.bounds.size.width - midPointX) {
            newCenter.x = self.superview.bounds.size.width - midPointX;
        }
        if (newCenter.x < midPointX) {
            newCenter.x = midPointX;
        }
        CGFloat midPointY = CGRectGetMidY(self.bounds);
        if (newCenter.y > self.superview.bounds.size.height - midPointY) {
            newCenter.y = self.superview.bounds.size.height - midPointY;
        }
        if (newCenter.y < midPointY) {
            newCenter.y = midPointY;
        }
    }
    self.center = newCenter;
}
- (void)hideDelHandle
{
    deleteControl.hidden = YES;
}

- (void)showDelHandle
{
    deleteControl.hidden = NO;
}

- (void)hideEditingHandles
{
    resizingControl.hidden = YES;
    deleteControl.hidden = YES;
    [borderView setHidden:YES];
}

- (void)showEditingHandles
{
    resizingControl.hidden = NO;
    deleteControl.hidden = NO;
    [borderView setHidden:NO];
}


- (BOOL)canBecomeFirstResponder{
    
    return YES;
}

@end
