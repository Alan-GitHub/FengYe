//
//  FYShowAllAttentionUserCellViewController.h
//  FengYe
//
//  Created by Alan Turing on 2018/3/24.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FYUserCellData.h"

@interface FYShowAllAttentionUserCellViewController : UIViewController

@property(nonatomic, retain) NSMutableArray<FYUserCellData*>* allAttentionUsersCellAttr;
@property(nonatomic, assign) CGFloat userCellOrigWidth;
@property(nonatomic, assign) CGFloat userCellOrigHeight;
@end
