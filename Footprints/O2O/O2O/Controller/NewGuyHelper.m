//
//  NewGuyHelper.m
//  Footprints
//
//  Created by Jinjin on 15/2/9.
//  Copyright (c) 2015年 JiaJun. All rights reserved.
//

#import "NewGuyHelper.h"

static NewGuyHelper *sharedHelper = nil;

@implementation NewGuyHelper

+ (instancetype)sharedInstance{
    
    if (nil==sharedHelper) {
        sharedHelper = [[NewGuyHelper alloc] init];
    }
    return sharedHelper;
}

+ (void)addNewGuyHelperOnView:(UIView *)view withKey:(NSString *)key andImage:(UIImage *)image{

    [[NewGuyHelper sharedInstance] addNewGuyHelperOnView:view withKey:key andImage:image];
}

- (void)addNewGuyHelperOnView:(UIView *)view withKey:(NSString *)key andImage:(UIImage *)image{
        
    if (key && image) {
        BOOL showed = [[NSUserDefaults standardUserDefaults] boolForKey:key];
        if (YES && !showed) {
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:view.bounds];
            imageView.image = image;
            imageView.userInteractionEnabled = YES;
            [view addSubview:imageView];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeImageView:)];
            [imageView addGestureRecognizer:tap];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (void)removeImageView:(UIGestureRecognizer *)ges{
    
    [UIView animateWithDuration:0.3 animations:^{
        ges.view.alpha = 0 ;
    } completion:^(BOOL finished) {
        [ges.view removeFromSuperview];
    }];
}
@end
