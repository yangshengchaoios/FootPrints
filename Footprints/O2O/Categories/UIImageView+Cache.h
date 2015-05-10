//
//  UIImageView+Cache.h
//  SCSDEnterprise
//
//  Created by  YangShengchao on 14-2-13.
//  Copyright (c) 2014年  YangShengchao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface UIImageView (Cache)

/**
 *  自动根据视图大小加载相应的缩略图
 *
 *  autoThumbnail = YES
 *  fadeIn = YES
 */
- (void)setImageWithURLString:(NSString *)urlString placeholderImageName:(NSString *)placeholderImageName;

/**
 *  自动根据视图大小加载相应的缩略图
 *
 *  @param urlString 原始图片地址
 */
- (void)setImageWithURLString:(NSString *)urlString;

/**
 *  自动根据视图大小加载相应的缩略图
 *
 *  autoThumbnail = YES
 *  @param urlString 原始图片地址
 *  @param shouldAnimate 是否执行动画
 */
- (void)setImageWithURLString:(NSString *)urlString withFadeIn:(BOOL)shouldAnimate;

- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)holderImage withFadeIn:(BOOL)shouldAnimate;

/**
 *  
 *  注意：placeholder是图片不是名称
 *
 *  autoThumbnail = YES
 *  fadeIn = NO
 */
- (void)setImageWithURLString:(NSString *)urlString placeholderImage:(UIImage *)holderImage;

/**
 * 加载网络图片
 *
 *  @param urlString 原始图片地址
 *  @param thumbnail 是否使用缩略图
 */
- (void)setImageWithURLString:(NSString *)urlString autoThumbnail:(BOOL)thumbnail;

@end
