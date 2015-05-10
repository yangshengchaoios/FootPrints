//
//  UITextField+Additions.m
//  TGO2
//
//  Created by  YangShengchao on 14-4-11.
//  Copyright (c) 2014年 SCSD_TGO_TEAM. All rights reserved.
//

#import "UITextField+Addition.h"

const char *ObjectTagKey;

@implementation UITextField (Addition)

- (void)setMaxLength:(NSInteger)maxLength {
    objc_setAssociatedObject(self, ObjectTagKey, @(maxLength), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)maxLength {
    return [objc_getAssociatedObject(self, ObjectTagKey) integerValue];
}

@end
