//
//  FYAbountViewController.m
//  FengYe
//
//  Created by Alan Turing on 2018/4/11.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYAbountViewController.h"
#import "UIView+Frame.h"
#import "CommonAttr.h"

@interface FYAbountViewController ()

@end

@implementation FYAbountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //测试
    UILabel* testTXT = [[UILabel alloc] initWithFrame:CGRectMake(0, ScreenHeight/3, ScreenWidth, 50)];
    testTXT.numberOfLines = 0;
    testTXT.text = @"该软件仅仅是用来测试用，并无任何商业价值.😊";
    testTXT.font = [UIFont systemFontOfSize:20];
    testTXT.textAlignment = NSTextAlignmentCenter;
    testTXT.textColor = [UIColor blackColor];
    [self.view addSubview:testTXT];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
