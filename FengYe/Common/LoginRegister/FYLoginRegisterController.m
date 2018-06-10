//
//  HYHFriendshipLoginRegisterController.m
//  ImitateBaiSi
//
//  Created by Macx on 2017/4/9.
//  Copyright © 2017年 HYH. All rights reserved.
//

#import "FYLoginRegisterController.h"
#import "FYLoginRegisterView.h"
#import "CommonAttr.h"
#import <AFNetworking.h>
#import "FYTabBarController.h"
#import <SVProgressHUD.h>

@interface FYLoginRegisterController ()
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leadCons;

@end

@implementation FYLoginRegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoginOrRegisterNotification:) name:NotificationLoginOrRegister object:nil];
    
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
    
    //block
//    FYTabBarController *tabvc =  (FYTabBarController *) [UIApplication sharedApplication].keyWindow.rootViewController;
//    tabvc.tabbarSelectedIndex = ^(NSInteger index) {
//        tabvc.selectedIndex = index;
//    };

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


- (void) handleLoginOrRegisterNotification:(NSNotification*) notification{
    
    int tag = [[notification.userInfo objectForKey:@"loginOrRegister"] intValue];
    switch (tag) {
        case 1: //登录
            {
                NSString* loginName = [notification.userInfo objectForKey:@"loginName"];
                NSString* loginPassword = [notification.userInfo objectForKey:@"loginPassword"];
                
                [self handleLoginReqWithUsername:loginName andPassword:loginPassword];
            }
            break;
            
        case 2: //注册
            {
                NSString* registerName = [notification.userInfo objectForKey:@"registerName"];
                NSString* registerPassword = [notification.userInfo objectForKey:@"registerPassword"];
                //deal with login req
                NSInteger ret = [self handleRegisterReqWithUsername:registerName andPassword:registerPassword];
            }
            break;
            
        default:
            break;
    }
}

- (void) handleLoginReqWithUsername:(NSString*)name andPassword:(NSString*)passwd{
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    //
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"LOGIN";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    //
    paramData[@"loginName"] = name;
    paramData[@"loginPassword"] = passwd;
    
    parameters[@"data"] = paramData;
    
    NSString* url = ServerURL;
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //NSLog(@"jsonString=%@", jsonString);
    
    AFURLSessionManager* manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest* req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
    
    req.timeoutInterval = [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, NSDictionary*  _Nullable responseObject, NSError * _Nullable error) {
        if(!error){
            //NSLog(@"Reply JSON: %@", responseObject);
            int value = [[responseObject objectForKey:@"loginStatus"] intValue];
            
            if (1 == value) { //login successful
                
                NSUserDefaults* userdef = [NSUserDefaults standardUserDefaults];
                [userdef setObject:name forKey:@"loginName"];
                [userdef setObject:passwd forKey:@"loginPassword"];
                [userdef setObject:@"true" forKey:@"isLogin"];
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
                FYTabBarController *tabvc =  (FYTabBarController *) [UIApplication sharedApplication].keyWindow.rootViewController;
                if (tabvc.tabbarSelectedIndex == 3) {
                    tabvc.selectedIndex = 3;
                } else {
                    tabvc.selectedIndex = 2;
                }
            } else{
                
                switch (value) {
                    case -1:
                        [SVProgressHUD showErrorWithStatus:@"用户名不存在"];
                        break;
                        
                    case -2:
                        [SVProgressHUD showErrorWithStatus:@"密码错误"];
                        break;
                        
                    default:
                        [SVProgressHUD showErrorWithStatus:@"登录发生未知错误"];
                        break;
                }
            }
            
        } else{
            
        }
    }] resume];
    
    return;
}

- (NSInteger) handleRegisterReqWithUsername:(NSString*)name andPassword:(NSString*)passwd{
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    //公共信息
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"REGISTER";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    
    //注册信息
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    paramData[@"registerName"] = name;
    paramData[@"registerPassword"] = passwd;
    
    parameters[@"data"] = paramData;
    
    NSString* url = ServerURL;
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    AFURLSessionManager* manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest* req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
    
    req.timeoutInterval = [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, NSDictionary*  _Nullable responseObject, NSError * _Nullable error) {
        if(!error){
            //NSLog(@"Reply JSON: %@", responseObject);
            NSInteger retValue = [responseObject[@"retValue"] integerValue];
            if (1 == retValue) { //注册成功
                
                [SVProgressHUD showInfoWithStatus:@"注册成功"];
                
                NSMutableDictionary* loginInfo = [NSMutableDictionary dictionary];
                loginInfo[@"name"] = name;
                loginInfo[@"password"] = passwd;
                [self performSelector:@selector(loginAfterRegister:) withObject:loginInfo afterDelay:1.0];
             
            } else{ //注册失败
                switch (retValue) {
                    case -1:
                        [SVProgressHUD showErrorWithStatus:@"注册失败!"];
                        break;
                        
                    case -2:
                        [SVProgressHUD showErrorWithStatus:@"用户名已经存在，请换个用户名试试"];
                        break;
                        
                    default:
                        [SVProgressHUD showErrorWithStatus:@"注册发生未知错误!"];
                        break;
                }
            }
        } else{
            [SVProgressHUD showErrorWithStatus:@"应用通信发生未知错误"];
        }
    }] resume];
    
    return 0;
}

- (void) loginAfterRegister:(NSDictionary*)loginInfo {
    
    NSUserDefaults* userdef = [NSUserDefaults standardUserDefaults];
    [userdef setObject:loginInfo[@"name"] forKey:@"loginName"];
    [userdef setObject:loginInfo[@"password"] forKey:@"loginPassword"];
    [userdef setObject:@"true" forKey:@"isLogin"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    FYTabBarController *tabvc =  (FYTabBarController *) [UIApplication sharedApplication].keyWindow.rootViewController;
    tabvc.selectedIndex = 3;
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NotificationLoginOrRegister object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
