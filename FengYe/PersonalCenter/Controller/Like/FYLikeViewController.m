//
//  FYLikeViewController.m
//  FengYe
//
//  Created by Alan Turing on 2018/3/12.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYLikeViewController.h"
#import "FYCollectionViewWaterFallLayout.h"
#import "FYCollectionView.h"
#import "FYDisplayCell.h"
#import <AFNetworking.h>
#import <MJExtension.h>
#import <UIImageView+WebCache.h>
#import "FYDetailInfoController.h"

#define ThirdCollectionViewCellID @"ThirdCollectionViewCellID"


@interface FYLikeViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic, retain) FYCollectionView* gColleView;
@property(nonatomic, strong) NSMutableArray<FYWorksUnitData*>* gLikeUnitAttr;
@end

@implementation FYLikeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.frame = CGRectMake(2*ScreenWidth, 0, ScreenWidth, ScreenHeight-SystemHeight);
    
    FYCollectionViewWaterFallLayout* layout = [[FYCollectionViewWaterFallLayout alloc] init];
    layout.data = self.gLikeUnitAttr;
    
    FYCollectionView* colleView = [[FYCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    colleView.delegate = self;
    colleView.dataSource = self;
    colleView.backgroundColor = [UIColor clearColor];
    [colleView registerNib:[UINib nibWithNibName:@"FYDisplayCell" bundle:nil] forCellWithReuseIdentifier:ThirdCollectionViewCellID];
    [self.view addSubview:colleView];
    self.gColleView = colleView;
    
    [self loadData];
}

- (void) loadData{
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"PERSONALCENTER_LIKE";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    
    //加载指定用户的数据 -- 如果没有指定，则加载当前登录用户数据
    if (self.userName.length) {
        paramData[@"username"] = self.userName;
    } else {
        NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
        NSString* username = [userDef objectForKey:@"loginName"];
        paramData[@"username"] = username;
    }
    
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
            [self.gLikeUnitAttr addObjectsFromArray:[FYWorksUnitData mj_objectArrayWithKeyValuesArray:responseObject[@"likeCellData"]]];
            [self.gColleView reloadData];
            
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}

- (NSMutableArray*) gLikeUnitAttr{
    
    if (!_gLikeUnitAttr) {
        _gLikeUnitAttr = [NSMutableArray array];
    }
    
    return _gLikeUnitAttr;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.gLikeUnitAttr.count;
}

- (FYDisplayCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FYDisplayCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:ThirdCollectionViewCellID forIndexPath:indexPath];
 
    FYWorksUnitData* data = self.gLikeUnitAttr[indexPath.item];
    [cell.workImage sd_setImageWithURL:[NSURL URLWithString:data.picURL] completed:nil];
    cell.zhuanCaiLabel.text = [NSString stringWithFormat:@"%zd", data.forwardCount];
    cell.loveLabel.text = [NSString stringWithFormat:@"%zd", data.likeCount];
    cell.commentLabel.text = [NSString stringWithFormat:@"%zd", data.commentCount];
    
    cell.descriptionLabel.text = data.descriptionText;
    [cell.headerIcon sd_setImageWithURL:[NSURL URLWithString:data.headIcon] completed:nil];
    cell.usernameLabel.text = data.owner;
    cell.workModuleLabel.text = data.templateName;
    
    [cell layoutIfNeeded];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FYDetailInfoController* infoVC = [[FYDetailInfoController alloc] init];
    infoVC.unitData = self.gLikeUnitAttr[indexPath.item];
    infoVC.hasRecommend = YES;
    
    [self.navigationController pushViewController:infoVC animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    OffsetType type = self.mainVC.offsetType;
    
    if (scrollView.contentOffset.y <= 0) {
        self.offsetType = OffsetTypeMin;
    } else {
        self.offsetType = OffsetTypeCenter;
    }

    if (type == OffsetTypeMin) {
        scrollView.contentOffset = CGPointZero;
    }
    if (type == OffsetTypeCenter) {
        scrollView.contentOffset = CGPointZero;
    }
    if (type == OffsetTypeMax) {}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
