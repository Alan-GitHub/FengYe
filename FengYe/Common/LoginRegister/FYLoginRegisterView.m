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

    //login data
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"1", @"loginOrRegister", nil];
    [userInfo setValue:name forKey:@"loginName"];
    [userInfo setValue:passwd forKey:@"loginPassword"];
    
    NSNotification* notification = [NSNotification notificationWithName:NotificationLoginOrRegister object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (IBAction)registerBtnClk:(id)sender {
    
    NSString* name = self.registerUsername.text;
    NSString* passwd = self.registerPassword.text;
    
    //register data
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"2", @"loginOrRegister", nil];
    [userInfo setValue:name forKey:@"registerName"];
    [userInfo setValue:passwd forKey:@"registerPassword"];
    
    NSNotification* notification = [NSNotification notificationWithName:NotificationLoginOrRegister object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


@end
