//
//  FYSettingsViewController.m
//  FengYe
//
//  Created by Alan Turing on 2018/4/10.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYSettingsViewController.h"
#import "FYAbountViewController.h"
#import "FYTabBarController.h"

#define SettingsTableID @"SettingsTableID"

@interface FYSettingsViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation FYSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor greenColor];
    
    self.navigationItem.title = @"设置";
    
    UITableView* table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    table.delegate = self;
    table.dataSource = self;
    
    [self.view addSubview:table];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:SettingsTableID];
    if (nil == cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SettingsTableID];
    }
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    switch (section) {
        case 0:
            if (0 == row) {
                cell.textLabel.text = @"关于枫叶";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
            
        case 1:
            if (0 == row) {
                cell.textLabel.text = @"注销";
            }
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    switch (section) {
        case 0:
            if (0 == row) {
                FYAbountViewController* aboutVC = [[FYAbountViewController alloc] init];
                [self.navigationController pushViewController:aboutVC animated:YES];
            }
            break;
            
        case 1:
            if (0 == row) {
                
                [self logout];
            }
            break;
            
        default:
            break;
    }
}

- (void) logout{

    //初始化对话框
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:@"确认要退出登录吗？" preferredStyle:UIAlertControllerStyleAlert];
    
    //添加确定按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        //1. 清除用户名、密码的存储
        NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
        [userDef removeObjectForKey:@"loginName"];
        [userDef removeObjectForKey:@"loginPassword"];
        [userDef removeObjectForKey:@"isLogin"];
        
        //2. pop到前一个视图控制器
        [self.navigationController popViewControllerAnimated:self];
        
        //3. 跳转到app首页
        FYTabBarController *tabvc =  (FYTabBarController *) [UIApplication sharedApplication].keyWindow.rootViewController;
        tabvc.selectedIndex = 0;
        
        //移除个人中心和动态两个视图控制器
        //1. 先删除个人中心控制器。  删除后，数组会变化，索引自动向前靠拢
        //[tabvc.childViewControllers[3] removeFromParentViewController];
        //2. 后删除动态视图控制器
        //[tabvc.childViewControllers[2] removeFromParentViewController];
    }]];
    
    //添加取消按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    //弹出对话框
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
