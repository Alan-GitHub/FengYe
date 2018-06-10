//
//  FYClickLikeViewController.m
//  FengYe
//
//  Created by Alan Turing on 2018/4/14.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYClickLikeViewController.h"
#include "FYUserCellData.h"
#include "FYUsersCell.h"
#import <UIImageView+WebCache.h>
#import "CommonAttr.h"
#import <AFNetworking.h>
#import <MJExtension.h>
#import "FYPersonalCenterViewController.h"

//和FYShowAllAttentionUserCellViewController中的cell尺寸保持一致
#define UserCellOrigWidth 120
#define UserCellOrigHeight 170

#define Spacing 10
#define ItemWidth  ((self.view.bounds.size.width - 3 * Spacing)/2)
#define ItemHeight  (UserCellOrigHeight * ItemWidth/UserCellOrigWidth)

#define OperViewClickLike @"OperViewClickLike"


@interface FYClickLikeViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, retain) NSMutableArray<FYUserCellData*>* allLike;
@property(nonatomic, retain) UICollectionView* gColleView;

@end

@implementation FYClickLikeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(ItemWidth, ItemHeight);
    
    UICollectionView* colleView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    colleView.delegate = self;
    colleView.dataSource = self;
    colleView.backgroundColor = MainBackgroundColor;
    colleView.contentInset = UIEdgeInsetsMake(Spacing, Spacing, Spacing, Spacing);
    [colleView registerNib:[UINib nibWithNibName:@"FYUsersCell" bundle:nil] forCellWithReuseIdentifier:OperViewClickLike];
    [self.view addSubview:colleView];
    self.gColleView = colleView;
    
    [self loadData];
}

- (void) loadData{
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"OPERATION_WORKS_ALLLIKE";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    //取得当前作品的数据库路径
    paramData[@"path"] = self.picPath;
    
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
            [self.allLike addObjectsFromArray:[FYUserCellData mj_objectArrayWithKeyValuesArray:responseObject[@"allLikeUsers"]]];
            [self.gColleView reloadData];
            
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}

//懒加载
- (NSMutableArray<FYUserCellData*>*) allLike{
    
    if (!_allLike) {
        
        _allLike = [NSMutableArray<FYUserCellData*> array];
    }
    
    return _allLike;
}

//代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.allLike.count;
}

- (FYUsersCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FYUsersCell* fansCell = [collectionView dequeueReusableCellWithReuseIdentifier:OperViewClickLike forIndexPath:indexPath];
    NSInteger index = [indexPath item];
    
    NSString* userHeadIconURL = [self.allLike[index].userHeadIcon stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [fansCell.userHeadIcon sd_setImageWithURL:[NSURL URLWithString:userHeadIconURL]];
    fansCell.userHeadIcon.layer.cornerRadius = (ItemWidth - 60) / 2;
    fansCell.userHeadIcon.layer.masksToBounds = YES;
    fansCell.userName.text = self.allLike[index].userName;
    
    NSString* fansStr = [NSString stringWithFormat:@"%zd 粉丝", self.allLike[index].fansNums];
    fansCell.fansNums.text = fansStr;
    
    return fansCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FYPersonalCenterViewController* pcVC = [[FYPersonalCenterViewController alloc] init];
    pcVC.userName = self.allLike[indexPath.item].userName;
    
    [self.navigationController pushViewController:pcVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
