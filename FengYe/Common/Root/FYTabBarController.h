//
//  FYTabBarController.h
//  FengYe
//
//  Created by Alan Turing on 2017/12/10.
//  Copyright © 2017年 Alan Turing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FYTabBarController : UITabBarController
//property
@property(nonatomic, assign) NSInteger tabbarSelectedIndex;

//block
//@property(nonatomic,copy) void (^tabbarSelectedIndex)(NSInteger index);
@end
