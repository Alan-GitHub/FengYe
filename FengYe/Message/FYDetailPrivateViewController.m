//
//  FYDetailPrivateViewController.m
//  FengYe
//
//  Created by Alan Turing on 2018/4/21.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYDetailPrivateViewController.h"
#import <AFNetworking.h>
#import "CommonAttr.h"
#import "FYCommentData.h"
#import <MJExtension.h>
#import <UIImageView+WebCache.h>
#import "FYMessagePrivateDetailCell.h"
#import "UIView+Frame.h"
#import "FYPersonalCenterViewController.h"
#import <Masonry.h>
#import <SVProgressHUD.h>

#define MessagePrivateDetailID @"MessagePrivateDetailID"

#define CommentUserHeadIconHeight 40
#define Spacing 10

#define CommentViewHeight 50
#define CommentViewOffsetY (ScreenHeight - SystemBottomHeight - CommentViewHeight)
#define CommentBoxHeight 44
#define SendBtnWidth 50

@interface FYDetailPrivateViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property(nonatomic, retain) UITableView* gTableView;
@property(nonatomic, retain) UITextField* gCommentBox;
@property(nonatomic, retain) UIView* gCommentView;
@property(nonatomic, retain) NSMutableArray<FYCommentData*>* privMsgContent;

@property(nonatomic, assign) NSInteger prevPrivMsgTime;
@end

@implementation FYDetailPrivateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.privMsgUsername;
    self.prevPrivMsgTime = 0;
    
    //添加table视图
    UITableView* table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    table.estimatedRowHeight = 50;
    table.rowHeight = UITableViewAutomaticDimension;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.delegate = self;
    table.dataSource = self;
    self.gTableView = table;
    [self.view addSubview:table];
    
    //添加表尾
    UIView* footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, CommentViewHeight)];
    footView.backgroundColor = [UIColor clearColor];
    table.tableFooterView = footView;
    
    //写私信框的背景视图
    UIView* commentView = [[UIView alloc] initWithFrame:CGRectMake(0, CommentViewOffsetY, ScreenWidth, CommentViewHeight)];
    commentView.backgroundColor = [UIColor whiteColor];
    self.gCommentView = commentView;
    [self.view addSubview:commentView];

    //发送私信的文本输入框
    UITextField* commentBox = [[UITextField alloc] initWithFrame:CGRectMake(0, (CommentViewHeight-CommentBoxHeight)/2, ScreenWidth-SendBtnWidth-10, CommentBoxHeight)];
    commentBox.backgroundColor = MainBackgroundColor;
    commentBox.placeholder = @"写私信";
    commentBox.returnKeyType = UIReturnKeyDone;
//    commentBox.delegate = self;
    self.gCommentBox = commentBox;
    [commentView addSubview:commentBox];
    
    //发送按钮
    UIButton* sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.backgroundColor = [UIColor whiteColor];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [commentView addSubview:sendBtn];
    [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(commentView.mas_top).with.offset(5);
        make.left.equalTo(commentBox.mas_right).with.offset(5);
        make.bottom.equalTo(commentView.mas_bottom).with.offset(-5);
        make.right.equalTo(commentView.mas_right).with.offset(-5);
    }];
    
    //操作键盘
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
        
        CGRect commentViewFrame = self.gCommentView.frame;
        commentViewFrame.origin.y = ScreenHeight - keyboardHeight - CommentViewHeight;
        self.gCommentView.frame = commentViewFrame;
    }
}

- (void) hideKeyboard{
    
    if ([self.gCommentBox isFirstResponder] && UIKeyboardDidShowNotification) {
        
        [self.gCommentBox resignFirstResponder];
        
        CGRect commentViewFrame = self.gCommentView.frame;
        commentViewFrame.origin.y = CommentViewOffsetY;
        self.gCommentView.frame = commentViewFrame;
    }
}

- (void) sendBtnClicked{
    
    if ([self.gCommentBox.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        
        [SVProgressHUD showErrorWithStatus:@"请输入内容！"];
        return;
    }
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"MESSAGE_PRIVATE_DETAIL_REPLY";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    
    //登录用户名
    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
    NSString* loginUsername = [userDef objectForKey:@"loginName"];
    paramData[@"loginUsername"] = loginUsername;
    
    //私信我的某个用户名
    paramData[@"privMsgUsername"] = self.privMsgUsername;
    
    //回复内容
    paramData[@"replyContent"] = self.gCommentBox.text;
    
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
            NSInteger retValue = [responseObject[@"retCode"] integerValue];
            if (retValue) {
                
                FYCommentData* replyContent = [[FYCommentData alloc] init];
                
                NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
                replyContent.myHeadIconUrl = [userDef objectForKey:@"headIcon"];
                replyContent.commentUsername = [userDef objectForKey:@"loginName"];
                replyContent.commentTime = @"2222";
                replyContent.commentContent = paramData[@"replyContent"];
     
                //增加数据到数组中
                [self.privMsgContent addObject:replyContent];
                
                //清空文本框内容
                self.gCommentBox.text = @"";
                [self.gCommentBox resignFirstResponder];
                [self.gTableView reloadData];
            } else{
                [SVProgressHUD showErrorWithStatus:@"处理错误"];
            }
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            [SVProgressHUD showErrorWithStatus:@"网络故障"];
        }
    }] resume];
}

- (void) loadData{
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"MESSAGE_PRIVATE_DETAIL";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    
    //登录用户名
    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
    NSString* loginUsername = [userDef objectForKey:@"loginName"];
    paramData[@"loginUsername"] = loginUsername;
    
    //私信我的某个用户名
    paramData[@"privMsgUsername"] = self.privMsgUsername;
    
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
            [self.privMsgContent removeAllObjects];
            [self.privMsgContent addObjectsFromArray:[FYCommentData mj_objectArrayWithKeyValuesArray:responseObject[@"privContent"]]];
            [self.gTableView reloadData];
            
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}

//懒加载
- (NSMutableArray<FYCommentData*>*) privMsgContent{
    
    if (!_privMsgContent) {
        
        _privMsgContent = [NSMutableArray<FYCommentData*> array];
    }
    
    return _privMsgContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.privMsgContent.count;
}

- (FYMessagePrivateDetailCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FYCommentData* privMsg = self.privMsgContent[indexPath.row];
    
    //获取登录用户名
    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
    NSString* loginUsername = [userDef objectForKey:@"loginName"];
    
    FYMessagePrivateDetailCell* msgPrivDetailCell = [tableView dequeueReusableCellWithIdentifier:MessagePrivateDetailID];
    if (nil == msgPrivDetailCell) {
        
        msgPrivDetailCell = [[FYMessagePrivateDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MessagePrivateDetailID];
    }
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedHeadIcon:)];
    
    
    //留言用户头像
    if ([privMsg.commentUsername isEqualToString:loginUsername]) {
        NSString* headiconURL = [privMsg.myHeadIconUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [msgPrivDetailCell.myUserHeadIcon sd_setImageWithURL:[NSURL URLWithString:headiconURL] completed:nil];
        msgPrivDetailCell.myUserHeadIcon.layer.cornerRadius = CommentUserHeadIconHeight/2;
        msgPrivDetailCell.myUserHeadIcon.layer.masksToBounds = YES;
        
        //添加头像点击事件
        [msgPrivDetailCell.myUserHeadIcon addGestureRecognizer:tap];
        msgPrivDetailCell.myUserHeadIcon.userInteractionEnabled = YES;
        msgPrivDetailCell.myUserHeadIcon.tag = 2;
        
        msgPrivDetailCell.privMsgContent.textAlignment = NSTextAlignmentRight;
    } else{
        
        NSString* headiconURL = [self.privMsgUserHeadIconUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [msgPrivDetailCell.privMsgUserHeadIcon sd_setImageWithURL:[NSURL URLWithString:headiconURL] completed:nil];
        msgPrivDetailCell.privMsgUserHeadIcon.layer.cornerRadius = CommentUserHeadIconHeight/2;
        msgPrivDetailCell.privMsgUserHeadIcon.layer.masksToBounds = YES;
        
        //添加头像点击事件
        [msgPrivDetailCell.privMsgUserHeadIcon addGestureRecognizer:tap];
        msgPrivDetailCell.privMsgUserHeadIcon.userInteractionEnabled = YES;
        msgPrivDetailCell.privMsgUserHeadIcon.tag = 1;
        
        msgPrivDetailCell.privMsgContent.textAlignment = NSTextAlignmentLeft;
    }
    
    //留言时间
    NSInteger timeValue = [privMsg.commentTime integerValue];
    if ( (timeValue - self.prevPrivMsgTime) / 1000 / 60 > 2) {
        
        msgPrivDetailCell.placeholderView1.text = [self timeFormatLocal:timeValue];
        msgPrivDetailCell.placeholderView1.textAlignment = NSTextAlignmentCenter;
        msgPrivDetailCell.placeholderView1.font = [UIFont systemFontOfSize:10];
        msgPrivDetailCell.placeholderView1.textColor = [UIColor lightGrayColor];
    }
    self.prevPrivMsgTime = timeValue;
    
    //留言内容
    msgPrivDetailCell.privMsgContent.text = privMsg.commentContent;
    
    return msgPrivDetailCell;
}

- (void) clickedHeadIcon:(UIGestureRecognizer*) tap{
    
    NSString* username = @"";
    
    if (tap.view.tag == 1) { //留言用户
        
        username = self.privMsgUsername;
    } else if(tap.view.tag == 2) { //我
        
        NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
        username = [userDef objectForKey:@"loginName"];
    }
    
    FYPersonalCenterViewController* pcVC = [[FYPersonalCenterViewController alloc] init];
    pcVC.userName = username;
    [self.navigationController pushViewController:pcVC animated:YES];
}

#pragma UITextField 代理方法

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (NSString*) timeFormatLocal:(NSInteger) timeInMillis{
    
    //获取当前时间
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970] * 1000;
    long long nowTimeInMillis = [[NSNumber numberWithDouble:nowTime] longLongValue];
    
    //当前时间与作品上传时间的差值
    long long howLong = nowTimeInMillis - timeInMillis;
    
    NSString* timeStr = nil;
    
    if (howLong / 1000 > 0 && howLong / 1000 < 60) {  //单位秒
        
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

@end
