//
//  FYMessageViewController.m
//  FengYe
//
//  Created by Alan Turing on 2017/12/10.
//  Copyright © 2017年 Alan Turing. All rights reserved.
//

#import "FYMessageViewController.h"
#import "CommonAttr.h"
#import <Masonry.h>
#import <AFNetworking.h>
#import "FYMessageDynanicCell.h"
#import "FYCommentData.h"
#import <MJExtension.h>
#import <UIImageView+WebCache.h>
#import "FYPersonalCenterViewController.h"
#import "FYMessagePrivateCell.h"
#import "FYDetailPrivateViewController.h"

#define MessageDynamicID @"MessageDynamicID"
#define MessagePrivateID @"MessagePrivateID"

#define CommentUserHeadIconHeight 40
#define Spacing 15

@interface FYMessageViewController ()<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, retain) UIScrollView* gScrollViewBack;
@property(nonatomic, retain) UIButton* gBtnLeft;
@property(nonatomic, retain) UIButton* gBtnRight;
@property(nonatomic, retain) UIView* gBgView;
@property(nonatomic, retain) UIView* gUnderline;

//动态
@property(nonatomic, retain) UITableView* gTable1;
//私信
@property(nonatomic, retain) UITableView* gTable2;

@property(nonatomic, retain) NSMutableArray<FYCommentData*>* msgDynAttr;
@property(nonatomic, retain) NSMutableArray<FYCommentData*>* msgPrivAttr;
@end

@implementation FYMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupTitleBtn];

    [self setupUnderline];

    [self setupScrollView];

    [self setupAllChildVCs];

    [self loadMessageDynamicData];
}

- (void)viewWillAppear:(BOOL)animated{
    
    //从上个控制器返回时，取消动态cell的选中状态
    [self.gTable1 deselectRowAtIndexPath:[self.gTable1 indexPathForSelectedRow] animated:YES];
    
    //从上个控制器返回时，取消私信cell的选中状态
    [self.gTable2 deselectRowAtIndexPath:[self.gTable2 indexPathForSelectedRow] animated:YES];
    
    //标题按钮的下划线位置
    CGRect rect = self.gUnderline.frame;
    if (self.gScrollViewBack.contentOffset.x == 0) {
        rect.origin.x = self.gBtnLeft.frame.origin.x;
        self.gUnderline.frame = rect;
    } else { //1
        rect.origin.x = self.gBtnRight.frame.origin.x;
        self.gUnderline.frame = rect;
    }
}

- (void) loadMessageDynamicData{
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"MESSAGE_DYNAMIC";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    
    //登录用户名
    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
    NSString* username = [userDef objectForKey:@"loginName"];
    paramData[@"username"] = username;
    
    parameters[@"data"] = paramData;
    
    NSString* url = ServerURL;
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //    NSLog(@"jsonString=%@", jsonString);
    
    AFURLSessionManager* manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest* req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
    
    req.timeoutInterval = [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, NSDictionary*  _Nullable responseObject, NSError * _Nullable error) {
        if(!error){
            //NSLog(@"Reply JSON: %@", responseObject);
            [self.msgDynAttr removeAllObjects];
            [self.msgDynAttr addObjectsFromArray:[FYCommentData mj_objectArrayWithKeyValuesArray:responseObject[@"allDynMsg"]]];
            [self.gTable1 reloadData];
            
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}

- (void) loadMessagePrivateData{
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"MESSAGE_PRIVATE";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    
    //登录用户名
    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
    NSString* username = [userDef objectForKey:@"loginName"];
    paramData[@"username"] = username;
    
    parameters[@"data"] = paramData;
    
    NSString* url = ServerURL;
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //    NSLog(@"jsonString=%@", jsonString);
    
    AFURLSessionManager* manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSMutableURLRequest* req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
    
    req.timeoutInterval = [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];

    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, NSDictionary*  _Nullable responseObject, NSError * _Nullable error) {
        if(!error){
            //NSLog(@"Reply JSON: %@", responseObject);
            [self.msgPrivAttr removeAllObjects];
            [self.msgPrivAttr addObjectsFromArray:[FYCommentData mj_objectArrayWithKeyValuesArray:responseObject[@"allPrivMsg"]]];
            [self.gTable2 reloadData];
            
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}

- (void) setupTitleBtn{
    
    UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth/3, 44)];
    self.gBgView = bgView;
    
    UIButton* btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLeft setTitle:@"动态" forState:UIControlStateNormal];
    [btnLeft setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [bgView addSubview:btnLeft];
    [btnLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgView).with.offset(0);
        make.left.equalTo(bgView).with.offset(0);
        make.bottom.equalTo(bgView).with.offset(0);
    }];
    btnLeft.tag = 0;
    [btnLeft addTarget:self action:@selector(titleSelected:) forControlEvents:UIControlEventTouchUpInside];
    self.gBtnLeft = btnLeft;
    
    UIButton* btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRight setTitle:@"私信" forState:UIControlStateNormal];
    [btnRight setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [bgView addSubview:btnRight];
    [btnRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgView).with.offset(0);
        make.left.equalTo(btnLeft.mas_right).with.offset(50);
        make.bottom.equalTo(bgView).with.offset(0);
        make.right.equalTo(bgView).with.offset(0);
    }];
    btnRight.tag = 1;
    [btnRight addTarget:self action:@selector(titleSelected:) forControlEvents:UIControlEventTouchUpInside];
    self.gBtnRight = btnRight;
    
    self.navigationItem.titleView = bgView;
}

- (void) setupUnderline{
    
    NSLog(@"setupUnderline");
    
    UIView* underline = [[UIView alloc] init];
    underline.backgroundColor = [UIColor blackColor];
    
    [self.gBgView addSubview:underline];
    
    [underline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.gBtnLeft.mas_left).with.offset(0);
        make.bottom.equalTo(self.gBtnLeft.mas_bottom).with.offset(0);
        make.right.equalTo(self.gBtnLeft.mas_right).with.offset(0);
        make.height.mas_equalTo(2);
    }];
    
    self.gUnderline = underline;
}

- (void) changeUnderline:(NSInteger) tag{
    
    __block CGRect rect = self.gUnderline.frame;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        if (0 == tag) {
            rect.origin.x = self.gBtnLeft.frame.origin.x;
            self.gUnderline.frame = rect;
        } else { //1
            rect.origin.x = self.gBtnRight.frame.origin.x;
            self.gUnderline.frame = rect;
        }
    }];
}

- (void) titleSelected:(UIButton*) send{
    
    [self changeUnderline:send.tag];
    
    [self changeOperationVC:send.tag];
}

- (void) setupScrollView{
    
    UIScrollView* scrollViewBack = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    scrollViewBack.contentSize = CGSizeMake(2 * ScreenWidth, 0);
    scrollViewBack.pagingEnabled = YES;
    scrollViewBack.showsHorizontalScrollIndicator = NO;
    scrollViewBack.delegate = self;
    
    self.gScrollViewBack = scrollViewBack;
    
    [self.view addSubview:scrollViewBack];
}

- (void) setupAllChildVCs{
    
    //消息--动态
    UITableView* table1 = [[UITableView alloc] init];
    table1.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight-64);
    table1.delegate = self;
    table1.dataSource = self;
    table1.tag = 1;
    table1.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.gScrollViewBack addSubview:table1];
    self.gTable1 = table1;
    
    //消息--私信
    UITableView* table2 = [[UITableView alloc] init];
    table2.frame = CGRectMake(ScreenWidth, 0, ScreenWidth, ScreenHeight-64);
    table2.delegate = self;
    table2.dataSource = self;
    table2.tag = 2;
    table2.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.gScrollViewBack addSubview:table2];
    self.gTable2 = table2;
}

- (void) changeOperationVC:(NSInteger) arg{
    
    [UIView animateWithDuration:0.3 animations:^{
        if (0 == arg) {
            
            self.gScrollViewBack.contentOffset = CGPointMake(0, self.gScrollViewBack.contentOffset.y);
        } else { //1
            
            self.gScrollViewBack.contentOffset = CGPointMake(ScreenWidth, self.gScrollViewBack.contentOffset.y);
            [self loadMessagePrivateData];
        }
    }];
}

//懒加载
- (NSMutableArray<FYCommentData*>*) msgDynAttr{
    
    if (!_msgDynAttr) {
        
        _msgDynAttr = [NSMutableArray<FYCommentData*> array];
    }
    
    return _msgDynAttr;
}

- (NSMutableArray<FYCommentData*>*) msgPrivAttr{
    
    if (!_msgPrivAttr) {
        
        _msgPrivAttr = [NSMutableArray<FYCommentData*> array];
    }
    
    return _msgPrivAttr;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger num = 0;
    switch (tableView.tag) {
        case 1:
            num = self.msgDynAttr.count;
            break;
            
        case 2:
            num = self.msgPrivAttr.count;
            break;
            
        default:
            break;
    }
    
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger index = [indexPath row];
    UITableViewCell* cell;
    if (tableView.tag == 1) { //动态
        
        FYMessageDynanicCell* msgDynCell = [tableView dequeueReusableCellWithIdentifier:MessageDynamicID];
        if (nil == msgDynCell) {
            
            msgDynCell = [[FYMessageDynanicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MessageDynamicID];
        }
        
        //评论用户的头像
        NSString* commentUserHeadIconURL = [self.msgDynAttr[index].commentUserHeadIconUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [msgDynCell.commentUserHeadIcon sd_setImageWithURL:[NSURL URLWithString:commentUserHeadIconURL] completed:nil];
        msgDynCell.commentUserHeadIcon.layer.cornerRadius = CommentUserHeadIconHeight/2;
        msgDynCell.commentUserHeadIcon.layer.masksToBounds = YES;
        
        //评论用户的用户名
        NSString* str = [NSString stringWithFormat:@"%@ 关注了你", self.msgDynAttr[index].commentUsername];
        msgDynCell.commentUsername.text = str;
        msgDynCell.commentUsername.font = [UIFont systemFontOfSize:12];
        
        //评论时间
        NSInteger timeValue = [self.msgDynAttr[index].commentTime integerValue];
        msgDynCell.commentTime.text =  [self timeFormatLocal:timeValue];
        msgDynCell.commentTime.font = [UIFont systemFontOfSize:10];
        msgDynCell.commentTime.textColor = [UIColor lightGrayColor];
        
        //我的头像
        NSString* myHeadIconURL = [self.msgDynAttr[index].myHeadIconUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [msgDynCell.myHeadIcon sd_setImageWithURL:[NSURL URLWithString:myHeadIconURL] completed:nil];
        msgDynCell.myHeadIcon.layer.cornerRadius = CommentUserHeadIconHeight/2;
        msgDynCell.myHeadIcon.layer.masksToBounds = YES;
        
        //msgDynCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell = msgDynCell;
    } else if(tableView.tag == 2){ //私信
        
        FYMessagePrivateCell* msgPrivCell = [tableView dequeueReusableCellWithIdentifier:MessagePrivateID];
        if (nil == msgPrivCell) {
            
            msgPrivCell = [[FYMessagePrivateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MessagePrivateID];
        }
        
        //私信用户的头像
        NSString* privMsgUserHeadIconURL = [self.msgPrivAttr[index].commentUserHeadIconUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [msgPrivCell.privMsgUserHeadIcon sd_setImageWithURL:[NSURL URLWithString:privMsgUserHeadIconURL] completed:nil];
        msgPrivCell.privMsgUserHeadIcon.layer.cornerRadius = CommentUserHeadIconHeight/2;
        msgPrivCell.privMsgUserHeadIcon.layer.masksToBounds = YES;
        
        //私信用户的用户名
        msgPrivCell.privMsgUsername.text = self.msgPrivAttr[index].commentUsername;
        msgPrivCell.privMsgUsername.font = [UIFont systemFontOfSize:12];
        
        //私信用户的内容
        msgPrivCell.privMsgContent.text = self.msgPrivAttr[index].commentContent;
        msgPrivCell.privMsgContent.font = [UIFont systemFontOfSize:12];
        
        //私信时间
        NSInteger timeValue = [self.msgPrivAttr[index].commentTime integerValue];
        msgPrivCell.privMsgTime.text = [self timeFormatLocal:timeValue];
        msgPrivCell.privMsgTime.font = [UIFont systemFontOfSize:10];
        
        cell = msgPrivCell;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return CommentUserHeadIconHeight + 2 * Spacing;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag == 1) { //动态
        
        FYPersonalCenterViewController* pcVC = [[FYPersonalCenterViewController alloc] init];
        pcVC.userName = self.msgDynAttr[indexPath.row].commentUsername;
        [self.navigationController pushViewController:pcVC animated:YES];
        
    } else if(tableView.tag == 2){ //私信
        
        FYDetailPrivateViewController* detailPrivateVC = [[FYDetailPrivateViewController alloc] init];
        detailPrivateVC.privMsgUsername = self.msgPrivAttr[indexPath.row].commentUsername;
        detailPrivateVC.privMsgUserHeadIconUrl = self.msgPrivAttr[indexPath.row].commentUserHeadIconUrl;
        [self.navigationController pushViewController:detailPrivateVC animated:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    int arg = self.gScrollViewBack.contentOffset.x == 0? 0 : 1;
    [self changeUnderline:arg];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

