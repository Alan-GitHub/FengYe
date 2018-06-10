//
//  FYClickCommentViewController.m
//  FengYe
//
//  Created by Alan Turing on 2018/4/15.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYClickCommentViewController.h"
#import "CommonAttr.h"
#import <Masonry.h>
#import "FYCommentCell.h"
#import <AFNetworking.h>
#import "FYCommentData.h"
#import <MJExtension.h>
#import <UIImageView+WebCache.h>
#import <SVProgressHUD.h>
#import "FYLoginRegisterController.h"
#import "FYTabBarController.h"

#define CommentBoxHeight 44
#define CommentBoxOffsetY (ScreenHeight - SystemBottomHeight - CommentBoxHeight)

#define OperViewClickComment @"OperViewClickComment"

@interface FYClickCommentViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property(nonatomic, retain) UITableView* gTable;
@property(nonatomic, retain) UITextField* gCommentBox;
@property(nonatomic, retain) NSMutableArray<FYCommentData*>* commentMessageAttr;
@end

@implementation FYClickCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"评论";
    
    UITableView* table = [[UITableView alloc] initWithFrame:self.view.bounds];
    table.delegate = self;
    table.dataSource = self;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview: table];
    self.gTable = table;
    
    table.estimatedRowHeight = 50;
    table.rowHeight = UITableViewAutomaticDimension;
    
    //添加表尾
    UIView* footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, CommentBoxHeight*2)];
    footView.backgroundColor = [UIColor clearColor];
    table.tableFooterView = footView;
    
    UITextField* commentBox = [[UITextField alloc] initWithFrame:CGRectMake(0, CommentBoxOffsetY, ScreenWidth, CommentBoxHeight)];
    commentBox.backgroundColor = MainBackgroundColor;
    commentBox.placeholder = @"添加评论";
    commentBox.returnKeyType = UIReturnKeyDone;
    commentBox.delegate = self;
    [self.view addSubview:commentBox];
    self.gCommentBox = commentBox;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard) name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    [self loadData];
}

- (void) showKeyboard:(NSNotification*) notification{
    
    if ([self.gCommentBox isFirstResponder]) {
        
        NSDictionary* userInfo = [notification userInfo];
        NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardRect = [aValue CGRectValue];
        int keyboardHeight = keyboardRect.size.height;
        
        CGRect commentBoxFrame = self.gCommentBox.frame;
        commentBoxFrame.origin.y = ScreenHeight - keyboardHeight - CommentBoxHeight;
        self.gCommentBox.frame = commentBoxFrame;
    }
}

- (void) hideKeyboard{
    
    if ([self.gCommentBox isFirstResponder] && UIKeyboardDidShowNotification) {
        
        [self.gCommentBox resignFirstResponder];
        
        CGRect commentBoxFrame = self.gCommentBox.frame;
        commentBoxFrame.origin.y = CommentBoxOffsetY;
        self.gCommentBox.frame = commentBoxFrame;
    }
}

- (void) loadData{
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"OPERATION_WORKS_ALLCOMMENT";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    
    //取得图片所属用户的用户名
    paramData[@"username"] = self.ownUsername;
    //取得图片所属画板名
    paramData[@"drawName"] = self.ownDrawName;
    //取得当前作品的数据库路径
    NSRange range = [self.picPath rangeOfString:@"photo/"];
    NSString* pictureUrl = [self.picPath substringFromIndex:(range.location + range.length)];
    paramData[@"path"] = pictureUrl;
    
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
            [self.commentMessageAttr addObjectsFromArray:[FYCommentData mj_objectArrayWithKeyValuesArray:responseObject[@"allComments"]]];
            [self.gTable reloadData];
            
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}

- (NSMutableArray<FYCommentData*>*) commentMessageAttr{
    
    if (!_commentMessageAttr) {
        
        _commentMessageAttr = [NSMutableArray<FYCommentData*> array];
    }
    
    return _commentMessageAttr;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.commentMessageAttr.count;
}

- (FYCommentCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger index = [indexPath row];
    
    FYCommentCell* cell = [tableView dequeueReusableCellWithIdentifier:OperViewClickComment];
    if (nil == cell) {
        
        cell = [[FYCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:OperViewClickComment];
    }

    //评论用户的头像
    NSString* headiconURL = [self.commentMessageAttr[index].commentUserHeadIconUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [cell.commentUserHeadIcon sd_setImageWithURL:[NSURL URLWithString:headiconURL] completed:nil];
    cell.commentUserHeadIcon.layer.cornerRadius = 20;
    cell.commentUserHeadIcon.layer.masksToBounds = YES;
    
    //评论用户的用户名
    cell.commentUsername.text = self.commentMessageAttr[index].commentUsername;
    cell.commentUsername.font = [UIFont systemFontOfSize:10];
    
    //评论内容
    cell.commentText.text = self.commentMessageAttr[index].commentContent;
    cell.commentText.font = [UIFont systemFontOfSize:13];
    
    //评论时间
    cell.commentTime.text = [self timeFormatLocal: [self.commentMessageAttr[index].commentTime integerValue]];
    cell.commentTime.font = [UIFont systemFontOfSize:10];
    
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"OPERATION_WORKS_ADDCOMMENT";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    
    //取得图片所属用户的用户名
    paramData[@"ownUser"] = self.ownUsername;
    //取得图片所属画板名
    paramData[@"ownDrawboard"] = self.ownDrawName;
    //取得当前作品的数据库路径
    NSRange range = [self.picPath rangeOfString:@"photo/"];
    NSString* pictureUrl = [self.picPath substringFromIndex:(range.location + range.length)];
    paramData[@"path"] = pictureUrl;
    
    //评论内容
    paramData[@"commentContent"] = textField.text;
    //评论者--当前登录用户
    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
    NSString* username = [userDef objectForKey:@"loginName"];
    paramData[@"commentUser"] = username;
    
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
            NSLog(@"Reply JSON: %@", responseObject);
            NSInteger retValue = [responseObject[@"retCode"] integerValue];

            if (retValue) {
                
                FYCommentData* commentData = [[FYCommentData alloc] init];
                
                NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
                commentData.commentUserHeadIconUrl = [userDef objectForKey:@"headIcon"];
                commentData.commentUsername = [userDef objectForKey:@"loginName"];
                commentData.commentContent = textField.text;
                commentData.commentTime = responseObject[@"commentTime"];
          
                //增加数据到数组中
                [self.commentMessageAttr addObject:commentData];
                
                //清空文本框内容
                textField.text = @"";
                [textField resignFirstResponder];
                [self.gTable reloadData];
            } else {
                [SVProgressHUD showErrorWithStatus:@"处理错误"];
            }
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            [SVProgressHUD showErrorWithStatus:@"网络故障"];
        }
    }] resume];

    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
    Boolean isLogin = [[userDef objectForKey:@"isLogin"] boolValue];
    
    if (!isLogin) { //未登录
        
        //隐藏键盘 调整frame
        [textField resignFirstResponder];
        CGRect commentBoxFrame = self.gCommentBox.frame;
        commentBoxFrame.origin.y = CommentBoxOffsetY;
        self.gCommentBox.frame = commentBoxFrame;
        
        //登录后进入个人中心页
        FYTabBarController *tabvc =  (FYTabBarController *) [UIApplication sharedApplication].keyWindow.rootViewController;
        tabvc.tabbarSelectedIndex = 3;
            
        //弹出登录框
        FYLoginRegisterController* login = [[FYLoginRegisterController alloc] init];
        [self presentViewController:login animated:YES completion:nil];

        return NO;
    }

    return true;
}

- (NSString*) timeFormatLocal:(NSInteger) timeInMillis{
    //获取当前时间
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970] * 1000;
    long long nowTimeInMillis = [[NSNumber numberWithDouble:nowTime] longLongValue];
    
    //当前时间与作品上传时间的差值
    long long howLong = nowTimeInMillis - timeInMillis;
    NSString* timeStr = nil;
    
    if (howLong < 1000) {
        
        timeStr = [NSString stringWithFormat:@"1秒之前"];
    }else if (howLong / 1000 > 0 && howLong / 1000 < 60) {  //单位秒
        
        timeStr = [NSString stringWithFormat:@"%zd秒之前", howLong / 1000];
    } else if (howLong / 1000 / 60 > 0 && howLong / 1000 / 60 < 60){ //单位分钟
        
        timeStr = [NSString stringWithFormat:@"%zd分钟之前", howLong / 1000 / 60];
    } else if (howLong / 1000 / 60 / 60 > 0 && howLong / 1000 / 60 / 60 < 24){ //单位小时
        
        timeStr = [NSString stringWithFormat:@"%zd小时之前", howLong / 1000 / 60 / 60];
    } else if (howLong / 1000 / 60 / 60 / 24 > 0 && howLong / 1000 / 60 / 60 / 24 < 30){ //单位天
        
        timeStr = [NSString stringWithFormat:@"%zd天之前", howLong / 1000 / 60 / 60 / 24];
    } else if (howLong / 1000 / 60 / 60 / 24 / 30 > 0 && howLong / 1000 / 60 / 60 / 24 / 30 < 12){ //单位月
        
        timeStr = [NSString stringWithFormat:@"%zd个月之前", howLong / 1000 / 60 / 60 / 24 / 30];
    } else if (howLong / 1000 / 60 / 60 / 24 / 30 / 12 > 0){ //单位年
        
        timeStr = [NSString stringWithFormat:@"%zd年之前", howLong / 1000 / 60 / 60 / 24 / 30 / 12];
    }
    
    return timeStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
