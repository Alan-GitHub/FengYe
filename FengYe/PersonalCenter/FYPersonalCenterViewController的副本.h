//
//  FYPersonalCenterViewController.h
//  FengYe
//
//  Created by Alan Turing on 2018/3/3.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonAttr.h"
#import "FYWorksUnitData.h"

@interface FYPersonalCenterViewController : UIViewController
@property (nonatomic, assign) OffsetType offsetType;

@property(nonatomic, strong) NSMutableArray<FYWorksUnitData*>* gCollectionUnitAttr;
@property(nonatomic, strong) NSMutableArray<FYWorksUnitData*>* gLikeUnitAttr;
@end
