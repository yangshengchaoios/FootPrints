//
//  UIImageView+Cache.m
//  SCSDEnterprise
//
//  Created by  YangShengchao on 14-2-13.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import "UIImageView+Cache.h"
#import "UrlConstants.h"
#import "StringUtils.h"
#import "ImageUtils.h"
#import <UIImage-Categories/UIImage+Resize.h>

static UIColor *lightestGray;

static NSString *qqImageDomain = @"qpic.cn";
static NSString *homePath;

@interface UIImage(UIImageScale)
-(UIImage*)getSubImage:(CGRect)rect;
-(UIImage*)scaleToSize:(CGSize)size;
@end

@implementation UIImage(UIImageScale)

//截取部分图像
-(UIImage*)getSubImage:(CGRect)rect
{
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    return smallImage;
}

//等比例缩放 //注意：此方法会导致UIImageView的contentMode不起作用
-(UIImage*)scaleToSize:(CGSize)size
{
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    
    float verticalRadio = size.height*1.0/height;
    float horizontalRadio = size.width*1.0/width;
    
    float radio = 1;
    if(verticalRadio>1 && horizontalRadio>1)
    {
        radio = MIN(verticalRadio, horizontalRadio); //verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;
    }
    else
    {
        radio = MAX(verticalRadio, horizontalRadio); //verticalRadio < horizontalRadio ? verticalRadio : horizontalRadio;
    }
    
    width = width*radio;
    height = height*radio;
    
    int xPos = (size.width - width)/2;
    int yPos = (size.height-height)/2;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(xPos, yPos, width, height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}
@end

@interface UIImageView (CachePrivate)

- (void)setImageWithURLString:(NSString *)urlString placeholderImageName:(NSString *)placeholderImageName autoThumbnail:(BOOL)thumbnail;
- (void)setImageWithURLString:(NSString *)urlString
         placeholderImageName:(NSString *)placeholderImageName
             placeholderImage:(UIImage *)placeholderImage
                autoThumbnail:(BOOL)thumbnail
                   withFadeIn:(BOOL)shouldAnimate;

@end

@implementation UIImageView (Cache)

- (void)setImageWithURLString:(NSString *)urlString placeholderImageName:(NSString *)placeholderImageName {
    [self setImageWithURLString:urlString placeholderImageName:placeholderImageName autoThumbnail:YES];
}

- (void)setImageWithURLString:(NSString *)urlString {
    [self setImageWithURLString:urlString autoThumbnail:NO];
}

- (void)setImageWithURLString:(NSString *)urlString withFadeIn:(BOOL)shouldAnimate {
    [self setImageWithURLString:urlString
           placeholderImageName:nil
               placeholderImage:nil
                  autoThumbnail:YES
                     withFadeIn:shouldAnimate];
}

- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)holderImage withFadeIn:(BOOL)shouldAnimate {
    [self setImageWithURLString:urlString
           placeholderImageName:nil
               placeholderImage:holderImage
                  autoThumbnail:YES
                     withFadeIn:shouldAnimate];
}

- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)holderImage {
    [self setImageWithURLString:urlString
           placeholderImageName:nil
               placeholderImage:holderImage
                  autoThumbnail:YES
                     withFadeIn:NO];
}

- (void)setImageWithURLString:(NSString *)urlString autoThumbnail:(BOOL)thumbnail {
    [self setImageWithURLString:urlString placeholderImageName:nil autoThumbnail:thumbnail];
}

#pragma mark - Private

- (void)setImageWithURLString:(NSString *)urlString placeholderImageName:(NSString *)placeholderImageName autoThumbnail:(BOOL)thumbnail {
    [self setImageWithURLString:urlString
           placeholderImageName:placeholderImageName
               placeholderImage:nil
                  autoThumbnail:thumbnail
                     withFadeIn:NO];
}

- (void)setImageWithURLString:(NSString *)urlString
         placeholderImageName:(NSString *)placeholderImageName
             placeholderImage:(UIImage *)placeholderImage
                autoThumbnail:(BOOL)thumbnail
                   withFadeIn:(BOOL)shouldAnimate {
    if ( ! lightestGray) {
        lightestGray = [UIColor colorWithWhite:0.97f alpha:1.0f];
    }
    NSURL *url;
    
    if ( ! homePath) {
        homePath = NSHomeDirectory();
    }
    if ([urlString rangeOfString:homePath].length) {
        url = [NSURL fileURLWithPath:urlString];
    }
    else {
        NSString *newUrlString = urlString;
        if ([newUrlString rangeOfString:@"http"].location == NSNotFound) {     //简单判断是否外部地址
            if ( ! [urlString hasPrefix:[StringUtils resBaseUrl]]) {
                NSInteger fitWidth = (thumbnail ? [ImageUtils fitThumbnailWidthForImageBounds:self.bounds] : NSIntegerMax);
                if (fitWidth == NSIntegerMax) {
                    newUrlString = [StringUtils fullPathWithPicturePath:urlString];
                }
                else {
                    newUrlString = [StringUtils thumbnailPathFromOriginPath:urlString wantedWidth:fitWidth];
                }
            }
        }
        else {
            //QQ的CDN图片地址http://app.qpic.cn/mblogpic/92848d792b83f81134a8，需要末尾添加斜杠
            if ([newUrlString rangeOfString:qqImageDomain].location != NSNotFound) {
                newUrlString = [newUrlString stringByAppendingString:@"/320"];
            }
        }
        
        self.image = nil;
        self.clipsToBounds = YES;
        self.contentMode = UIViewContentModeCenter;
        self.backgroundColor = lightestGray;
        
        url = [NSURL URLWithString:newUrlString];
    }
    if ( ! placeholderImage) {
        if ( ! placeholderImageName || ! [UIImage imageNamed:placeholderImageName]) {
            placeholderImage = [UIImage imageNamed:@"image_placeholder"];
        }
        else {
            placeholderImage = [UIImage imageNamed:placeholderImageName];
        }
    }
    if ( ! url) {
        self.image = placeholderImage;
        return;
    }
        
    WeakSelfType blockSelf = self;
    [self sd_setImageWithURL:url
            placeholderImage:placeholderImage
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                       if ( ! error) {
                           blockSelf.contentMode = UIViewContentModeScaleAspectFill;
                           NSInteger screenScale = (NSInteger)[[UIScreen mainScreen] scale];
                           CGSize imageSize = blockSelf.bounds.size;
                           imageSize = CGSizeMake(screenScale * imageSize.width, screenScale * imageSize.height);
                           blockSelf.image = image;
                           
                           /*                        blockSelf.image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill
                            bounds:imageSize
                            interpolationQuality:kCGInterpolationDefault];
                            */
                           blockSelf.backgroundColor = [UIColor clearColor];
                           if (shouldAnimate) {
                               blockSelf.alpha = 0.1f;
                               [UIView animateWithDuration:0.5f
                                                     delay:0
                                                   options:UIViewAnimationOptionCurveEaseIn
                                                animations:^{
                                                    blockSelf.alpha = 1.0f;
                                                }
                                                completion:^(BOOL finished) {
                                                    
                                                }];
                           }
                       }
                   }];
}

@end
