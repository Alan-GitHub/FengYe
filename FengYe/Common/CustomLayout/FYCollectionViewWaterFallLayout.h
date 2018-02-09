//
//  FYCollectionViewWaterFallLayout.h
//  FengYe
//
//  Created by Alan Turing on 2017/12/11.
//  Copyright © 2017年 Alan Turing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FYWorksUnitData.h"

@interface FYCollectionViewWaterFallLayout : UICollectionViewFlowLayout
@property(nonatomic, strong) NSArray<FYWorksUnitData*>* data;
@end


