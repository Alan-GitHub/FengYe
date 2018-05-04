//
//  FYShowDetailDrawboardViewController.h
//  FengYe
//
//  Created by Alan Turing on 2018/4/5.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FYDrawboardCellUnitData.h"

@interface FYShowDetailDrawboardViewController : UIViewController

@property(nonatomic, retain) FYDrawboardCellUnitData* specifyDrawData;
@property(nonatomic, copy) NSString* userName;
@end
