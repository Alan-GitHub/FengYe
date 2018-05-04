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

#define TextFieldHeight 44

#define OperViewClickComment @"OperViewClickComment"

@interface FYClickCommentViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, retain) UITableView* gTable;
@property(nonatomic, retain) NSMutableArray<FYCommentData*>* commentMessageAttr;
@end

@implementation FYClickCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"评论";
    
    UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(0, ScreenHeight - TextFieldHeight - SystemBottomHeight, ScreenWidth, TextFieldHeight)];
    textField.backgroundColor = [UIColor yellowColor];
    textField.placeholder = @"添加评论";
    [self.view addSubview:textField];
    
    UITableView* table = [[UITableView alloc] init];
    table.delegate = self;
    table.dataSource = self;
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview: table];
    [table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(0);
        make.left.equalTo(self.view.mas_left).with.offset(0);
        make.bottom.equalTo(textField.mas_top).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(0);
    }];
    self.gTable = table;
    
    
//    table.estimatedRowHeight = 50;
//    table.rowHeight = UITableViewAutomaticDimension;
    
    [self loadData];
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
            NSLog(@"aaa=%zd", self.commentMessageAttr.count);
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
    [cell.commentUserHeadIcon sd_setImageWithURL:[NSURL URLWithString:self.commentMessageAttr[index].commentUserHeadIconUrl] completed:nil];
    cell.commentUserHeadIcon.layer.cornerRadius = 20;
    cell.commentUserHeadIcon.layer.masksToBounds = YES;
    
    //评论用户的用户名
    cell.commentUsername.text = self.commentMessageAttr[index].commentUsername;
    cell.commentUsername.font = [UIFont systemFontOfSize:10];
    
    //评论内容
    cell.commentText.text = self.commentMessageAttr[index].commentContent;
    cell.commentText.font = [UIFont systemFontOfSize:13];
    
    //评论时间
    cell.commentTime.text = self.commentMessageAttr[index].commentTime;
    cell.commentTime.font = [UIFont systemFontOfSize:10];
    
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//
//
//    return UITableViewAutomaticDimension;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    return 10;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
