//
//  FYDrawboardViewController.h
//  FengYe
//
//  Created by Alan Turing on 2018/3/12.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FYPersonalCenterViewController.h"
#import "FYDrawboardCellUnitData.h"
#import "FYCollectionView.h"

@interface FYDrawboardViewController : UIViewController

@property (nonatomic, assign) OffsetType offsetType;
@property (nonatomic, weak) FYPersonalCenterViewController *mainVC;

@property(nonatomic, retain) FYCollectionView* gDboardColleView;
@property(nonatomic, retain) NSMutableArray<FYDrawboardCellUnitData*>* dataAttr;

@property (nonatomic, copy) NSString* userName;
@end
