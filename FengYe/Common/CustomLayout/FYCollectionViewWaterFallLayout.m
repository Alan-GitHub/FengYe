//
//  FYCollectionViewWaterFallLayout.m
//  FengYe
//
//  Created by Alan Turing on 2017/12/11.
//  Copyright © 2017年 Alan Turing. All rights reserved.
//

#import "FYCollectionViewWaterFallLayout.h"

#define colMargin 10
#define rowMargin 10
#define colCount 2

//cell elements
#define Margin 5
#define HeaderIconHeight 40
#define OperationViewHeight 20

@interface FYCollectionViewWaterFallLayout()
//Array -- save multi-col whole height.
@property(nonatomic, strong) NSMutableArray* colsHeight;

//单元格宽度
@property(nonatomic, assign)CGFloat itemColWidth;
@end

@implementation FYCollectionViewWaterFallLayout

- (CGFloat) cellHeight:(NSIndexPath*) index withWidth:(CGFloat)width{
    CGFloat cellHeight = 0;
    
    //buttom-margin-headerIcon-margin-operation-margin-description-margin-workImage
    cellHeight += Margin + HeaderIconHeight + Margin + OperationViewHeight + Margin;

    //description height
    CGSize textMaxSize = CGSizeMake(width, 40);
    cellHeight += (int)[self.data[index.item].descriptionText boundingRectWithSize:textMaxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize: 13]} context:nil].size.height;
    
    cellHeight += width * self.data[index.item].picHeight / self.data[index.item].picWidth;
    
    return cellHeight;
}

- (NSMutableArray*)colsHeight{
    if(!_colsHeight){
        
        NSMutableArray* array = [NSMutableArray array];
        for (int i = 0; i < colCount; i++) {
            //set init colume height
            [array addObject:@(0)];
        }
        _colsHeight = [array mutableCopy];
    }
    
    return _colsHeight;
}

- (void) prepareLayout{
//    NSLog(@"data=%d", self.data.count);
    
    [super prepareLayout];
    self.itemColWidth = (self.collectionView.frame.size.width - (colCount+1)*colMargin) / colCount;
    self.colsHeight = nil;
}

- (CGSize) collectionViewContentSize{
    NSNumber* Ylongest = self.colsHeight[0];
    for (NSInteger i = 0; i < self.colsHeight.count; i++) {
        NSNumber* Ylength = self.colsHeight[i];
        if(Ylongest.floatValue < Ylength.floatValue){
            Ylongest = Ylength;
        }
    }
    
    return CGSizeMake(self.collectionView.frame.size.width, Ylongest.floatValue);
}

- (UICollectionViewLayoutAttributes*) layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewLayoutAttributes* attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    NSNumber* Yshortest = self.colsHeight[0];
    NSInteger shortCol = 0;
    for (NSInteger i = 0; i < self.colsHeight.count; i++) {
        NSNumber* Ylength = self.colsHeight[i];
        if (Yshortest.floatValue > Ylength.floatValue) {
            Yshortest = Ylength;
            shortCol = i;
        }
    }
    //x,y coordinate value
    CGFloat x = (shortCol+1) * colMargin + shortCol * self.itemColWidth;
    CGFloat y = Yshortest.floatValue + rowMargin;
    
    //get cell height
    CGFloat height = 0;
    NSAssert(self.data!=nil, @"should get data to layout...");
    
    height = [self cellHeight:indexPath withWidth:self.itemColWidth];
    attr.frame = CGRectMake(x, y, self.itemColWidth, height);
    self.colsHeight[shortCol] = @(Yshortest.floatValue + rowMargin + height);
    
    return attr;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray* array = [NSMutableArray array];
    NSInteger items = [self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < items; i++) {
        UICollectionViewLayoutAttributes* attr = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i  inSection:0]];
        [array addObject:attr];
    }
    
    return array;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

@end
