//
//  HYHFriendshipLoginRegisterController.m
//  ImitateBaiSi
//
//  Created by Macx on 2017/4/9.
//  Copyright © 2017年 HYH. All rights reserved.
//

#import "FYLoginRegisterController.h"
#import "FYLoginRegisterView.h"

@interface FYLoginRegisterController ()
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leadCons;

@end

@implementation FYLoginRegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSUInteger width = _middleView.bounds.size.width * 0.5;
    NSUInteger height = _middleView.bounds.size.height;
    
    //向middleView 添加loginView
    FYLoginRegisterView* loginView = [FYLoginRegisterView loginView];
    loginView.frame = CGRectMake(0, 0, width, height);
    [self.middleView addSubview:loginView];
    
    //向middleView 添加registerView
    FYLoginRegisterView* registerView = [FYLoginRegisterView registerView];
    registerView.frame = CGRectMake(width, 0, width, height);
    [self.middleView addSubview:registerView];

}
- (IBAction)handleClose:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)SwitchLoginRegister:(UIButton*)sender
{
    sender.selected = !sender.selected;
    
    //平移中间view
    _leadCons.constant = _leadCons.constant == 0? -self.middleView.bounds.size.width * 0.5:0;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
