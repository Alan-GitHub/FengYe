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

#define MessagePrivateDetailID @"MessagePrivateDetailID"

#define CommentUserHeadIconHeight 40
#define Spacing 10

@interface FYDetailPrivateViewController ()

@property(nonatomic, retain) NSMutableArray<FYCommentData*>* privMsgContent;
@end

@implementation FYDetailPrivateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.privMsgUsername;
    
//    self.tableView.estimatedRowHeight = 50;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self loadData];
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
            [self.privMsgContent removeAllObjects];
            [self.privMsgContent addObjectsFromArray:[FYCommentData mj_objectArrayWithKeyValuesArray:responseObject[@"privContent"]]];
            [self.tableView reloadData];
            
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
        
        [msgPrivDetailCell.myUserHeadIcon sd_setImageWithURL:[NSURL URLWithString:privMsg.myHeadIconUrl] completed:nil];
        msgPrivDetailCell.myUserHeadIcon.layer.cornerRadius = CommentUserHeadIconHeight/2;
        msgPrivDetailCell.myUserHeadIcon.layer.masksToBounds = YES;
        
        //添加头像点击事件
        [msgPrivDetailCell.myUserHeadIcon addGestureRecognizer:tap];
        msgPrivDetailCell.myUserHeadIcon.userInteractionEnabled = YES;
        msgPrivDetailCell.myUserHeadIcon.tag = 2;
        
        msgPrivDetailCell.privMsgContent.textAlignment = NSTextAlignmentRight;
    } else{
        
        [msgPrivDetailCell.privMsgUserHeadIcon sd_setImageWithURL:[NSURL URLWithString:self.privMsgUserHeadIconUrl] completed:nil];
        msgPrivDetailCell.privMsgUserHeadIcon.layer.cornerRadius = CommentUserHeadIconHeight/2;
        msgPrivDetailCell.privMsgUserHeadIcon.layer.masksToBounds = YES;
        
        //添加头像点击事件
        [msgPrivDetailCell.privMsgUserHeadIcon addGestureRecognizer:tap];
        msgPrivDetailCell.privMsgUserHeadIcon.userInteractionEnabled = YES;
        msgPrivDetailCell.privMsgUserHeadIcon.tag = 1;
        
        msgPrivDetailCell.privMsgContent.textAlignment = NSTextAlignmentLeft;
    }
    
    //留言时间
    if (indexPath.row % 2 == 0) {
        msgPrivDetailCell.placeholderView1.text = privMsg.commentTime;
        msgPrivDetailCell.placeholderView1.textAlignment = NSTextAlignmentCenter;
        msgPrivDetailCell.placeholderView1.font = [UIFont systemFontOfSize:10];
        msgPrivDetailCell.placeholderView1.textColor = [UIColor lightGrayColor];
    }
    
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

@end
