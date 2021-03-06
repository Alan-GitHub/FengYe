//
//  FYLikeViewController.h
//  FengYe
//
//  Created by Alan Turing on 2018/3/12.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FYPersonalCenterViewController.h"

@interface FYLikeViewController : UIViewController

@property (nonatomic, assign) OffsetType offsetType;
@property (nonatomic, weak) FYPersonalCenterViewController *mainVC;

@property (nonatomic, copy) NSString* userName;
@end
