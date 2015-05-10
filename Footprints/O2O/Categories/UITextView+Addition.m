//
//  UITextView+Addition.m
//  TGO2
//
//  Created by  YangShengchao on 14-4-29.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import "UITextView+Addition.h"

const char *ObjectTagKey;

@implementation UITextView (Addition)

- (void)setMaxLength:(NSInteger)maxLength {
    objc_setAssociatedObject(self, ObjectTagKey, @(maxLength), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)maxLength {
    return [objc_getAssociatedObject(self, ObjectTagKey) integerValue];
}

@end
