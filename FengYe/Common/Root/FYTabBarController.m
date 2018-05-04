//
//  FYTabBarController.m
//  FengYe
//
//  Created by Alan Turing on 2017/12/10.
//  Copyright © 2017年 Alan Turing. All rights reserved.
//

#import "FYTabBarController.h"
#import "FYRecommendViewController.h"
#import "FYDiscoverViewController.h"
#import "FYMessageViewController.h"
#import "FYPersonalCenterViewController.h"
#import "FYLoginRegisterController.h"

@interface FYTabBarController () <UITabBarControllerDelegate>
//@property(nonatomic, assign) BOOL isLogin;
@end

@implementation FYTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.view.backgroundColor = [UIColor redColor];
//    self.isLogin = false;
    
    self.delegate = self;
}

- (instancetype) init{
    
    if(self=[super init])
    {
        FYRecommendViewController* recommdVC = [[FYRecommendViewController alloc] init];
        UINavigationController* navRecommdVC = [[UINavigationController alloc] initWithRootViewController:recommdVC];
        navRecommdVC.tabBarItem.title = @"推荐";
        [self addChildViewController:navRecommdVC];
        
        FYDiscoverViewController* discoverVC = [[FYDiscoverViewController alloc] init];
        UINavigationController* navDiscoverVC = [[UINavigationController alloc] initWithRootViewController:discoverVC];
        navDiscoverVC.tabBarItem.title = @"发现";
        [self addChildViewController:navDiscoverVC];
        
        FYMessageViewController* messageVC = [[FYMessageViewController alloc] init];
        UINavigationController* navMessageVC = [[UINavigationController alloc] initWithRootViewController:messageVC];
        navMessageVC.tabBarItem.title = @"动态";
        [self addChildViewController:navMessageVC];
        
        FYPersonalCenterViewController* personalCenterVC = [[FYPersonalCenterViewController alloc] init];
        UINavigationController* navPersonalCenterVC = [[UINavigationController alloc] initWithRootViewController:personalCenterVC];
        navPersonalCenterVC.tabBarItem.title = @"个人中心";
        [self addChildViewController:navPersonalCenterVC];
    }
    
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{

//    if (self.childViewControllers.count == 2) {
//
//        //重新添加动态子视图控制器
//        FYMessageViewController* messageVC = [[FYMessageViewController alloc] init];
//        UINavigationController* navMessageVC = [[UINavigationController alloc] initWithRootViewController:messageVC];
//        navMessageVC.tabBarItem.title = @"动态";
//        [self addChildViewController:navMessageVC];
//
//        //重新添加个人中心子视图控制器
//        FYPersonalCenterViewController* personalCenterVC = [[FYPersonalCenterViewController alloc] init];
//        UINavigationController* navPersonalCenterVC = [[UINavigationController alloc] initWithRootViewController:personalCenterVC];
//        navPersonalCenterVC.tabBarItem.title = @"个人中心";
//        [self addChildViewController:navPersonalCenterVC];
//    }
    
    if ([item.title isEqualToString:@"推荐"]) {
        
        NSLog(@"you just now click 推荐");
    }
    else if ([item.title isEqualToString:@"发现"]){
        
        NSLog(@"you just now click 发现");
    }
    else if ([item.title isEqualToString:@"动态"]){
        
        NSLog(@"you just now click 动态");
    }
    else{ //个人中心
        
        NSLog(@"you just now click 个人中心");
    }
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    NSString* btnTitle = viewController.tabBarItem.title;
    if( [btnTitle isEqualToString:@"个人中心"] || [btnTitle isEqualToString:@"动态"] ){  //需要验证是否已经登录
        
        if ([btnTitle isEqualToString:@"个人中心"]) {
            self.tabbarSelectedIndex = 3;
        } else {
            self.tabbarSelectedIndex = 2;
        }

        NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
        Boolean isLogin = [[userDef objectForKey:@"isLogin"] boolValue];
        
        if (!isLogin) { //未登录
            
            //弹出登录框
            FYLoginRegisterController* login = [[FYLoginRegisterController alloc] init];
            [self presentViewController:login animated:YES completion:nil];
            
            return NO;
        } else{//已登录
            return YES;
        }
    }
    
    return YES;
}

@end
