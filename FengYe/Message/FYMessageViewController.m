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

@property(nonatomic, retain) UITableView* gTable1;
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
            NSLog(@"111111");
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
    if (tableView.tag == 1) {
        
        FYMessageDynanicCell* msgDynCell = [tableView dequeueReusableCellWithIdentifier:MessageDynamicID];
        if (nil == msgDynCell) {
            
            msgDynCell = [[FYMessageDynanicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MessageDynamicID];
        }
        
        //评论用户的头像
        [msgDynCell.commentUserHeadIcon sd_setImageWithURL:[NSURL URLWithString:self.msgDynAttr[index].commentUserHeadIconUrl] completed:nil];
        msgDynCell.commentUserHeadIcon.layer.cornerRadius = CommentUserHeadIconHeight/2;
        msgDynCell.commentUserHeadIcon.layer.masksToBounds = YES;
        
        //评论用户的用户名
        NSString* str = [NSString stringWithFormat:@"%@ 关注了你", self.msgDynAttr[index].commentUsername];
        msgDynCell.commentUsername.text = str;
        msgDynCell.commentUsername.font = [UIFont systemFontOfSize:12];
        
        //评论时间
        msgDynCell.commentTime.text = self.msgDynAttr[index].commentTime;
        msgDynCell.commentTime.font = [UIFont systemFontOfSize:10];
        msgDynCell.commentTime.textColor = [UIColor lightGrayColor];
        
        //我的头像
        [msgDynCell.myHeadIcon sd_setImageWithURL:[NSURL URLWithString:self.msgDynAttr[index].myHeadIconUrl] completed:nil];
        msgDynCell.myHeadIcon.layer.cornerRadius = CommentUserHeadIconHeight/2;
        msgDynCell.myHeadIcon.layer.masksToBounds = YES;
        
        cell = msgDynCell;
    } else if(tableView.tag == 2){
        
        FYMessagePrivateCell* msgPrivCell = [tableView dequeueReusableCellWithIdentifier:MessagePrivateID];
        if (nil == msgPrivCell) {
            
            msgPrivCell = [[FYMessagePrivateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MessagePrivateID];
        }
        
        //私信用户的头像
        [msgPrivCell.privMsgUserHeadIcon sd_setImageWithURL:[NSURL URLWithString:self.msgPrivAttr[index].commentUserHeadIconUrl] completed:nil];
        msgPrivCell.privMsgUserHeadIcon.layer.cornerRadius = CommentUserHeadIconHeight/2;
        msgPrivCell.privMsgUserHeadIcon.layer.masksToBounds = YES;
        
        //私信用户的用户名
        msgPrivCell.privMsgUsername.text = self.msgPrivAttr[index].commentUsername;
        msgPrivCell.privMsgUsername.font = [UIFont systemFontOfSize:12];
        
        //私信用户的内容
        msgPrivCell.privMsgContent.text = self.msgPrivAttr[index].commentContent;
        msgPrivCell.privMsgContent.font = [UIFont systemFontOfSize:12];
        
        //私信时间
        msgPrivCell.privMsgTime.text = self.msgPrivAttr[index].commentTime;
        msgPrivCell.privMsgTime.font = [UIFont systemFontOfSize:10];
        
        cell = msgPrivCell;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return CommentUserHeadIconHeight + 2 * Spacing;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView.tag == 1) {
        
        FYPersonalCenterViewController* pcVC = [[FYPersonalCenterViewController alloc] init];
        pcVC.userName = self.msgDynAttr[indexPath.row].commentUsername;
        [self.navigationController pushViewController:pcVC animated:YES];
    } else if(tableView.tag == 2){
        
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

