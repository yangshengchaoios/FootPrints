//
//  JJPreviewViewController.h
//  Footprints
//
//  Created by tt on 14/10/23.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "BaseViewController.h"


@interface JJPreviewViewController : BaseViewController
@property (nonatomic,strong) NSString *location;
@property (nonatomic,strong) NSString *audioPath;
@property (nonatomic,strong) NSString *activityId;
- (void)reloadImageViews;

@property (nonatomic,strong) NSMutableDictionary *imageSourcreDict;
@property (nonatomic,strong) NSMutableArray *imageSourcreKeys;
+ (instancetype)sharedPreview;
+ (void)clean;

- (BOOL)addImageSource:(UIImage *)image forKey:(NSString *)key;
- (void)removeImageSourceForKey:(NSString *)key;
@end
