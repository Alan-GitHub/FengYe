//
//  FYShowAllDrawboardCellViewController.h
//  FengYe
//
//  Created by Alan Turing on 2018/3/24.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FYDrawboardCellUnitData.h"

@interface FYShowAllDrawboardCellViewController : UIViewController

@property(nonatomic, retain) NSMutableArray<FYDrawboardCellUnitData*>* allDrawboardCellAttr;
@property(nonatomic, assign) CGFloat drawboardCellOrigWidth;
@property(nonatomic, assign) CGFloat drawboardCellOrigHeight;
@end
