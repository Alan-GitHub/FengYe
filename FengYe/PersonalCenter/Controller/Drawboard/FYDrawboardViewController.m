//
//  FYDrawboardViewController.m
//  FengYe
//
//  Created by Alan Turing on 2018/3/12.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYDrawboardViewController.h"
#import "CommonAttr.h"
#import "FYDrawboardCell.h"
#import <AFNetworking.h>
#import "FYDrawboardCellAdd.h"
#import <MJExtension.h>
#import <UIImageView+WebCache.h>
#import "FYNewDrawboardViewController.h"
#import "FYShowDetailDrawboardViewController.h"


#define FirstCollectionViewCellID @"FirstCollectionViewCellID"
#define DrawboardCellAdd @"DrawboardCellAdd"

@interface FYDrawboardViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation FYDrawboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight-SystemHeight);
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = DrawboardLayoutRowMargin;
    layout.minimumInteritemSpacing = DrawboardLayoutColMargin;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    FYCollectionView* dboardColleView = [[FYCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    dboardColleView.delegate = self;
    dboardColleView.dataSource = self;
    dboardColleView.backgroundColor = [UIColor clearColor];
    [dboardColleView registerNib:[UINib nibWithNibName:@"FYDrawboardCell" bundle:nil] forCellWithReuseIdentifier:FirstCollectionViewCellID];
    [dboardColleView registerNib:[UINib nibWithNibName:@"FYDrawboardCellAdd" bundle:nil] forCellWithReuseIdentifier:DrawboardCellAdd];
    self.gDboardColleView = dboardColleView;
    
    [self.view addSubview:dboardColleView];
    
    [self loadData];
}

- (void) loadData{
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"PERSONALCENTER_DRAWBOARD";
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
            [self.dataAttr addObjectsFromArray:[FYDrawboardCellUnitData mj_objectArrayWithKeyValuesArray:responseObject[@"selfDrawboardCell"]]];
            [self.gDboardColleView reloadData];
            
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}

- (NSMutableArray<FYDrawboardCellUnitData*>*) dataAttr{
    
    if (!_dataAttr) {
        
        _dataAttr = [NSMutableArray<FYDrawboardCellUnitData*> array];
    }
    
    return _dataAttr;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
    NSString* loginName = [userDef objectForKey:@"loginName"];
    
    if (self.userName.length && ![self.userName isEqualToString:loginName]) { //进入的是别人的个人中心
        
        return self.dataAttr.count;
    }else{ //进入了自己的个人中心界面
        
        return self.dataAttr.count + 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger index = [indexPath item];
    
    if (index == self.dataAttr.count) {
        
        NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
        NSString* loginName = [userDef objectForKey:@"loginName"];
        if (self.userName.length && ![self.userName isEqualToString:loginName]) { //进入的是别人的个人中心
            //不需要做任何事。  不用显示添加cell
        }else{ //进入了自己的个人中心界面
        
            FYDrawboardCellAdd* addCell = [collectionView dequeueReusableCellWithReuseIdentifier:DrawboardCellAdd forIndexPath:indexPath];
            return addCell;
        }
    }
    
    FYDrawboardCell* tempCell = [collectionView dequeueReusableCellWithReuseIdentifier:FirstCollectionViewCellID forIndexPath:indexPath];

    NSString* moduleCoverURL = [self.dataAttr[index].coverImageURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [tempCell.moduleCover sd_setImageWithURL:[NSURL URLWithString:moduleCoverURL]];
    tempCell.moduleCover.contentMode = UIViewContentModeScaleAspectFill;
    tempCell.moduleName.text = self.dataAttr[index].drawboardName;
    tempCell.worksNumsInModule.text = [NSString stringWithFormat:@"%ld", self.dataAttr[index].picNums];
    
    return tempCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    return CGSizeMake((ScreenWidth - DrawboardLayoutColMargin * 3)/2, 250);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger index = [indexPath item];
    if (index == self.dataAttr.count) {
        
        FYNewDrawboardViewController* newDboardVC = [[FYNewDrawboardViewController alloc] init];
        newDboardVC.drawboardVC = self;
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:newDboardVC];
        [self presentViewController:nav animated:YES completion:nil];
    } else{
      
        //显示详细画板
        FYShowDetailDrawboardViewController* detailDrawboard = [[FYShowDetailDrawboardViewController alloc] init];
        detailDrawboard.specifyDrawData = self.dataAttr[index];
        detailDrawboard.userName = self.userName;
        [self.navigationController pushViewController:detailDrawboard animated:YES];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

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
