//
//  FYClickForwardViewController.m
//  FengYe
//
//  Created by Alan Turing on 2018/4/15.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYClickForwardViewController.h"
#import "FYModuleCell.h"
#import <UIImageView+WebCache.h>
#import "FYShowDetailDrawboardViewController.h"
#import "CommonAttr.h"
#import <AFNetworking.h>
#import <MJExtension.h>

#define OperViewClickForward @"OperViewClickForward"

//画板
#define DrawboardCellWidth 120
#define DrawboardCellHeight 180

@interface FYClickForwardViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic, retain) NSMutableArray<FYDrawboardCellUnitData*>* allForwardDraw;
@property(nonatomic, retain) UICollectionView* gColleView;
@end

@implementation FYClickForwardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor greenColor];
    
    self.navigationItem.title = @"转采";
    
    CGFloat spacing = 10;
    CGFloat itemWidth = (self.view.bounds.size.width - 3 * spacing)/2;
    CGFloat itemHeight = DrawboardCellHeight * itemWidth/DrawboardCellWidth;
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    UICollectionView* colleView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    colleView.delegate = self;
    colleView.dataSource = self;
    colleView.backgroundColor = MainBackgroundColor;
    colleView.contentInset = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    [colleView registerNib:[UINib nibWithNibName:@"FYModuleCell" bundle:nil] forCellWithReuseIdentifier:OperViewClickForward];
    self.gColleView = colleView;
    
    [self.view addSubview:colleView];
    
    [self loadData];
}

- (void) loadData{
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"OPERATION_WORKS_ALLFORWARD";
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
            [self.allForwardDraw addObjectsFromArray:[FYDrawboardCellUnitData mj_objectArrayWithKeyValuesArray:responseObject[@"allForwards"]]];
            [self.gColleView reloadData];
            
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}

//懒加载
- (NSMutableArray<FYDrawboardCellUnitData*>*) allForwardDraw{
    
    if (_allForwardDraw == nil) {
        
        _allForwardDraw = [NSMutableArray<FYDrawboardCellUnitData*> array];
    }
    
    return _allForwardDraw;
}

//代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.allForwardDraw.count;
}

- (FYModuleCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FYModuleCell* drawboardCell = [collectionView dequeueReusableCellWithReuseIdentifier:OperViewClickForward forIndexPath:indexPath];
    NSInteger index = [indexPath item];
    
    [drawboardCell.coverImage sd_setImageWithURL:[NSURL URLWithString:self.allForwardDraw[index].coverImageURL]];
    drawboardCell.coverImage.contentMode = UIViewContentModeScaleAspectFill;
    
    drawboardCell.drawboardName.text = self.allForwardDraw[index].drawboardName;
    drawboardCell.ownerUserName.text = self.allForwardDraw[index].ownerUserName;
    
    return drawboardCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger index = [indexPath item];
    
    FYShowDetailDrawboardViewController* dbVC = [[FYShowDetailDrawboardViewController alloc] init];
    dbVC.specifyDrawData = self.allForwardDraw[index];
    dbVC.userName = self.allForwardDraw[index].ownerUserName;
    
    [self.navigationController pushViewController:dbVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
