//
//  FYCollectionView.m
//  FengYe
//
//  Created by Alan Turing on 2018/3/8.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYCollectionView.h"

#define FirstCollectionViewCellID @"FirstCollectionViewCellID"
#define SecondCollectionViewCellID @"SecondCollectionViewCellID"
#define ThirdCollectionViewCellID @"ThirdCollectionViewCellID"

static NSInteger whichScroll = 0;

@implementation FYCollectionView

- (instancetype) initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *) layout{
    
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
    }
    
    return self;
}

//globle method
+ (NSInteger) whichScroll{
    
    return whichScroll;
}

+ (void) setWhichScroll:(NSInteger) value{
    
    whichScroll = value;
}


//data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    NSInteger nums = 0;

    switch (collectionView.tag) {
        case 0:
            nums = 9;
            break;

        case 1:
            nums = self.mainVC.gCollectionUnitAttr.count;
            break;

        case 2:
            nums = self.mainVC.gLikeUnitAttr.count;
            break;

        default:
            break;
    }

    return nums;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    UICollectionViewCell* cell;
    switch (collectionView.tag) {
        case 0:
            {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:FirstCollectionViewCellID forIndexPath:indexPath];
                cell.backgroundColor = [UIColor whiteColor];
            }
            break;

        case 1:
            {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:SecondCollectionViewCellID forIndexPath:indexPath];
                cell.backgroundColor = [UIColor greenColor];
            }
            break;

        case 2:
            {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:ThirdCollectionViewCellID forIndexPath:indexPath];
                cell.backgroundColor = [UIColor blueColor];
            }
            break;

        default:
            break;
    }


    return cell;
}

//collectionview delegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (collectionView.tag == 0) {
        return CGSizeMake((ScreenWidth - DrawboardLayoutColMargin * 3)/2, 250);
    }
    
    return CGSizeMake(44, 44);
}

//scrollview delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSLog(@"child....");
    
    //identifier which collectionview is scroll
    [FYCollectionView setWhichScroll:scrollView.tag];

    OffsetType type = self.mainVC.offsetType;

    if (scrollView.contentOffset.y <= 0) {
        self.offsetType = OffsetTypeMin;
    } else {
        self.offsetType = OffsetTypeCenter;
    }

    if (type == OffsetTypeMin) {
        scrollView.contentOffset = CGPointZero;
    }
    if (type == OffsetTypeCenter) {
        scrollView.contentOffset = CGPointZero;
    }
    if (type == OffsetTypeMax) {}
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
