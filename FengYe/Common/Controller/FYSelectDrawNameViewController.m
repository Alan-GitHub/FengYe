//
//  FYSelectDrawNameViewController.m
//  FengYe
//
//  Created by Alan Turing on 2018/4/14.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYSelectDrawNameViewController.h"
#import "CommonAttr.h"
#import <Masonry.h>
#import "UIView+Frame.h"
#import <AFNetworking.h>

#define SelectDrawName @"SelectDrawName"

@interface FYSelectDrawNameViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation FYSelectDrawNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat Hspacing = 30;
    CGFloat Vspacing = NavigationBarHeight+SystemBarHeight*2;
    CGFloat cancelHeight = 44;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5];
    
    //表后面的背景视图
    UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(Hspacing, Vspacing, ScreenWidth - Hspacing*2, ScreenHeight-Vspacing*2)];
    bgView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:bgView];

    //弹出的表视图
    UITableView* table = [[UITableView alloc] init];
    table.fy_x = 0;
    table.fy_y = 0;
    table.fy_width = bgView.fy_width;
    table.fy_height = bgView.fy_height - cancelHeight;
    //table.layer.maskedCorners = 10;
    table.delegate = self;
    table.dataSource = self;
    [bgView addSubview:table];
    
    //取消操作视图
    UILabel* cancel = [[UILabel alloc] init];
    cancel.text = @"取消";
    cancel.textAlignment = NSTextAlignmentCenter;
    cancel.backgroundColor = [UIColor redColor];
    [bgView addSubview:cancel];
    [cancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(table.mas_bottom).with.offset(0);
        make.left.equalTo(bgView.mas_left).with.offset(0);
        make.bottom.equalTo(bgView.mas_bottom).with.offset(0);
        make.right.equalTo(bgView.mas_right).with.offset(0);
    }];
    cancel.userInteractionEnabled = YES;

    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [cancel addGestureRecognizer:tap];

    
}

- (void) tapAction{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//懒加载
- (NSMutableArray<NSString*>*) drawName{
    
    if (!_drawName) {
        
        _drawName = [NSMutableArray<NSString*> array];
    }
    
    return _drawName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.drawName.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:SelectDrawName];
    if (nil == cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SelectDrawName];
    }
    
    cell.textLabel.text = self.drawName[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //删除选择画板名的界面
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"OPERATION_WORKS_COLLECTION_ACTION";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    
    //取得当前登录用户
    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
    NSString* username = [userDef objectForKey:@"loginName"];
    paramData[@"username"] = username;
    //取得需要采集到登录用户的哪个画板中
    paramData[@"drawName"] = self.drawName[indexPath.row];
    //取得当前作品的数据库路径
    NSRange range = [self.picURL rangeOfString:@"photo/"];
    NSString* pictureUrl = [self.picURL substringFromIndex:(range.location + range.length)];
    paramData[@"picURL"] = pictureUrl;
    //取得图片的描述
    paramData[@"picDesc"] = self.picDesc;
    //取得作品原先属于哪个用户
    paramData[@"originUsername"] = self.originUserName;
    //取得作品原先属于哪个画板
    paramData[@"originDrawName"] = self.originDrawName;
    
    
    
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
            NSInteger forwardNum = [responseObject[@"forwardNum"] integerValue];
            if (retValue > 0) {
                self.updateForwardNum(forwardNum);
            }
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
