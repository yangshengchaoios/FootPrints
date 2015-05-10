//
//  JJHomeCollectionLayout.m
//  Footprints
//
//  Created by Jinjin on 14/11/11.
//  Copyright (c) 2014年 JiaJun. All rights reserved.
//

#import "JJHomeCollectionLayout.h"

#define kYOffset 50


@implementation JJHomeCollectionLayout

-(CGSize)collectionViewContentSize{
    
    if (self.style==0) {
        CGFloat offset = 10;
        CGFloat scale = 640.0/1008;
        CGFloat width = (CGRectGetWidth(self.collectionView.frame)-offset*3)/2;
        CGFloat height = width/scale;
        NSInteger count = [self.collectionView numberOfItemsInSection:0];
        return CGSizeMake(self.collectionView.frame.size.width, MAX(ceil((count/2.0))*(height+offset)+offset+kYOffset+kHeaderOffset, self.collectionView.frame.size.height+1));
    }else if (self.style==1){
        CGFloat offset = 10;
        CGFloat height = 80;
        NSInteger count = [self.collectionView numberOfItemsInSection:0];
        return CGSizeMake(self.collectionView.frame.size.width, MAX(count*(height+offset)+offset+kHeaderOffset, self.collectionView.frame.size.height+1));
    }else if (self.style==3) {//搜索
        CGFloat offset = 10;
        CGFloat scale = 640.0/1008;
        CGFloat width = (CGRectGetWidth(self.collectionView.frame)-offset*3)/2;
        CGFloat height = width/scale;
        NSInteger count = [self.collectionView numberOfItemsInSection:0];
        return CGSizeMake(self.collectionView.frame.size.width, MAX(ceil((count/2.0))*(height+offset)+offset+33, self.collectionView.frame.size.height+1));
    }else{
        CGFloat offset = 10;
        CGFloat height = 110;
        NSInteger count = [self.collectionView numberOfItemsInSection:0];
        return CGSizeMake(self.collectionView.frame.size.width, MAX(count*(height+offset)+offset+kHeaderOffset, self.collectionView.frame.size.height+1));
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (self.style==0) {
        CGFloat offset = 10;
        CGFloat yOffset = kHeaderOffset+offset;
        if (indexPath.row % 2==1) {
            yOffset = kYOffset+kHeaderOffset+offset;
        }
        
        UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath]; //生成空白的attributes对象，其中只记录了类型是cell以及对应的位置是indexPath
        //配置attributes到圆周上
        CGFloat scale = 640.0/1008;
        CGFloat width = (CGRectGetWidth(self.collectionView.frame)-offset*3)/2;
        CGFloat height = width/scale;
        attributes.size = CGSizeMake(width, height);
        CGFloat xOffset = ((indexPath.row%2==0)?1:0) * (width+offset);
        attributes.center = CGPointMake(offset+xOffset+width/2,yOffset+(indexPath.row/2)*(height+offset)+height/2);
        return attributes;
        
    }else if (self.style==1){
        CGFloat offset = 10;
        CGFloat yOffset = kHeaderOffset+offset;
        
        UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath]; //生成空白的attributes对象，其中只记录了类型是cell以及对应的位置是indexPath
        //配置attributes到圆周上
        CGFloat height = 80;
        
        attributes.size = CGSizeMake(self.collectionView.frame.size.width-30, height);
        attributes.center = CGPointMake(self.collectionView.frame.size.width/2,yOffset+indexPath.row*(height+offset)+height/2);
        return attributes;
    }else if (self.style==3) {//搜索
        CGFloat offset = 10;
        CGFloat yOffset = offset+33;
        UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath]; //生成空白的attributes对象，其中只记录了类型是cell以及对应的位置是indexPath
        //配置attributes到圆周上
        CGFloat scale = 640.0/1008;
        CGFloat width = (CGRectGetWidth(self.collectionView.frame)-offset*3)/2;
        CGFloat height = width/scale;
        attributes.size = CGSizeMake(width, height);
        attributes.center = CGPointMake(offset+(indexPath.row%2)*(width+offset)+width/2,yOffset+(indexPath.row/2)*(height+offset)+height/2);
        return attributes;
    }else{
        CGFloat offset = 10;
        CGFloat yOffset = kHeaderOffset+offset;
        
        UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath]; //生成空白的attributes对象，其中只记录了类型是cell以及对应的位置是indexPath
        //配置attributes到圆周上
        CGFloat height = 110;
        
        attributes.size = CGSizeMake(self.collectionView.frame.size.width-30, height);
        attributes.center = CGPointMake(self.collectionView.frame.size.width/2,yOffset+indexPath.row*(height+offset)+height/2);
        return attributes;
    }
}

//用来在一开始给出一套UICollectionViewLayoutAttributes
-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray* attributes = [NSMutableArray array];
    for (NSInteger i=0 ; i<[self.collectionView numberOfItemsInSection:0]; i++) {
        //这里利用了-layoutAttributesForItemAtIndexPath:来获取attributes
        NSIndexPath* indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    return attributes;
}

- (void)setStyle:(NSInteger)style{
    
    if (style!=_style) {
        _style = style;
        [self.collectionView reloadData];
    }
}

@end
