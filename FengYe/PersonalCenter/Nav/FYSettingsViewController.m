//
//  FYSettingsViewController.m
//  FengYe
//
//  Created by Alan Turing on 2018/4/10.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYSettingsViewController.h"

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
                cell.textLabel.text = @"退出登录";
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
                NSLog(@"关于");
            }
            break;
            
        case 1:
            if (0 == row) {
                NSLog(@"退出");
            }
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
