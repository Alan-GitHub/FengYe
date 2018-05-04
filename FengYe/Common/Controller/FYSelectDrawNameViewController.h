//
//  FYSelectDrawNameViewController.h
//  FengYe
//
//  Created by Alan Turing on 2018/4/14.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FYSelectDrawNameViewController : UIViewController

@property(nonatomic, retain) NSMutableArray<NSString*>* drawName;
@property(nonatomic, copy) NSString* picURL;
@property(nonatomic, copy) NSString* picDesc;
@property(nonatomic, copy) NSString* originUserName;
@property(nonatomic, copy) NSString* originDrawName;

//block
@property(nonatomic,copy) void (^updateForwardNum)(NSInteger forwardNum);
@end
