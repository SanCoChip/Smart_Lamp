//
//  MyCollectionLayout.m
//  testDemo
//
//  Created by iOS开发本-(梁乾) on 16/6/14.
//  Copyright © 2016年 SIBAT. All rights reserved.
//

#import "MyCollectionLayout.h"
//屏幕的宽高
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH  [UIScreen mainScreen].bounds.size.height

#define widhtFor10 10.0 * [UIScreen mainScreen].bounds.size.width / 414
#define heightFor10  10.0 * [UIScreen mainScreen].bounds.size.height / 736
#define itemW (ScreenW - widhtFor10 * 4) / 3

@interface MyCollectionLayout ()
@property (nonatomic, strong) NSMutableArray * attsArray;

@end

@implementation MyCollectionLayout
- (NSMutableArray *)attsArray
{
    if (!_attsArray) {
        _attsArray = [NSMutableArray array];
    }
    return _attsArray;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    [self.attsArray removeAllObjects];
    
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.attsArray addObject:attrs];
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.attsArray;
}

/**
 * 这个方法需要返回indexPath位置对应cell的布局属性
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // item的位置
    
    CGFloat X = widhtFor10 + (itemW + widhtFor10) * (indexPath.row % 3);
    CGFloat Y = heightFor10 * 2 + (4+itemW + heightFor10*2-4) * (indexPath.row / 3
);
    
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attrs.frame = CGRectMake(X, Y, itemW, itemW);
    
    return attrs;
}

@end
