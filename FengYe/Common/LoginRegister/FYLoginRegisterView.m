//
//  HYHLoginRegisterView.m
//  ImitateBaiSi
//
//  Created by Macx on 2017/4/11.
//  Copyright © 2017年 HYH. All rights reserved.
//

#import "FYLoginRegisterView.h"
#import <AFNetworking.h>
#import "CommonAttr.h"

@interface FYLoginRegisterView ()
@property (strong, nonatomic) IBOutlet UIButton *loginRegisterBtn;

//login Data member
@property (weak, nonatomic) IBOutlet UITextField *loginUsername;
@property (weak, nonatomic) IBOutlet UITextField *loginPassword;

//register data member
@property (weak, nonatomic) IBOutlet UITextField *registerUsername;
@property (weak, nonatomic) IBOutlet UITextField *registerPassword;

@end

@implementation FYLoginRegisterView

+ (instancetype)loginView
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] firstObject];
}

+ (instancetype)registerView
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIImage* image = _loginRegisterBtn.currentBackgroundImage;
    
    image = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5  topCapHeight:image.size.height * 0.5];
    
    [_loginRegisterBtn setBackgroundImage:image forState:UIControlStateNormal];
}

- (IBAction)loginBtnClk:(id)sender {
    
    NSString* name = self.loginUsername.text;
    NSString* passwd = self.loginPassword.text;
    NSLog(@"loginBtnClk");
    NSLog(@"loginUsername=%@, loginPassword=%@", name, passwd);
}

- (IBAction)registerBtnClk:(id)sender {
    NSString* name = self.registerUsername.text;
    NSString* passwd = self.registerPassword.text;
    
    NSLog(@"registerBtnClk");
    NSLog(@"registerUsername=%@, registerPassword=%@", name, passwd);
    
//    AFHTTPSessionManager* mgr = [AFHTTPSessionManager manager];
//    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
//    parameters[@"registerName"] = name;
//    parameters[@"registerPassword"] = passwd;
//    NSString* url = @"http://192.168.1.100:8080/FengYeApp/UserController";
//
//    [mgr POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//
//        NSLog(@"sucess...");
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//
//        NSLog(@"failure...");
//    }];
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    //
    parameters[@"ver"] = @"1";
//    parameters[@"service"] = @"RECOMMEND";
    parameters[@"service"] = @"REGISTER";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    //
    paramData[@"registerName"] = name;
    paramData[@"registerPassword"] = passwd;
    
    parameters[@"data"] = paramData;
    
    NSString* url = ServerURL;
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"jsonString=%@", jsonString);
    
    AFURLSessionManager* manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest* req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
    
    req.timeoutInterval = [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"req=%@", req);
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, NSDictionary*  _Nullable responseObject, NSError * _Nullable error) {
        if(!error){
            NSLog(@"Reply JSON: %@", responseObject);
//            NSString* strName = responseObject[@"registerName"];
//            NSString* strPd = responseObject[@"registerPassword"];
            
            //NSLog(@"name=%@, paswd=%@", strName, strPd);
            
        } else{
            //NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}


@end
