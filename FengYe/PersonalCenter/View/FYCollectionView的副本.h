//
//  FYCollectionView.h
//  FengYe
//
//  Created by Alan Turing on 2018/3/8.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FYPersonalCenterViewController.h"
#import "CommonAttr.h"

@interface FYCollectionView : UICollectionView <UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) OffsetType offsetType;
@property (nonatomic, weak) FYPersonalCenterViewController *mainVC;


+ (NSInteger) whichScroll;
+ (void) setWhichScroll:(NSInteger)value;
@end
