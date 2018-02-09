//
//  FirstViewController.m
//  FengYe
//
//  Created by Alan Turing on 2017/12/10.
//  Copyright © 2017年 Alan Turing. All rights reserved.
//

#import "FYRecommendViewController.h"
#import "FYCollectionViewWaterFallLayout.h"
#import "FYDisplayCell.h"
#import "FYDetailInfoController.h"
#import "CommonAttr.h"
#import <AFNetworking.h>
#import <MJExtension.h>
#import "FYWorksUnitData.h"
#import <UIImageView+WebCache.h>

#define CollectionViewCellID @"CollectionViewCellID"


@interface FYRecommendViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,UISearchBarDelegate>
@property(nonatomic, retain, readwrite) UICollectionView* collectionView;
@property(nonatomic, retain, readwrite) FYCollectionViewWaterFallLayout* waterFallLayout;

//@property(nonatomic, strong) NSArray* heightArr;
@property(nonatomic, strong) NSMutableArray<FYWorksUnitData*>* worksUnitArr;
@end

@implementation FYRecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    self.view.backgroundColor = [UIColor redColor];
    
    //search bar
    [self addSearchBar];
    
    //collectionView
    [self.view addSubview:self.collectionView];
    self.waterFallLayout.data = self.worksUnitArr;
    
    [self loadData];
}

- (void) loadData{
    
#if TEST
    FYWorksUnitData* data = [[FYWorksUnitData alloc] init];
  
    //data.picURL = @"0.bmp";
    data.picWidth = 320;
    data.picHeight = 480;
    
    data.uploadTime = 20180201;
    data.forwardCount = 5;
    data.likeCount = 5;
    data.commentCount = 5;
    
    data.descriptionText = @"adjflskdlfjlskdioiuoiuoiuojkhkuiouiouuiuijkhkjhgjgjuyuytuytujhkl";
    //data.headIcon = @"/Users/alanturing/Desktop/FengYe/FengYe/TestImage/1.bmp";
    data.templateName = @"ss";
    data.owner = @"alan";

    [self.worksUnitArr addObject:data];
    return;
#endif
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];

    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"RECOMMEND";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";

    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    paramData[@"count"] = @"15";
    
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
    
//    NSLog(@"req=%@", req);
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, NSDictionary*  _Nullable responseObject, NSError * _Nullable error) {
        if(!error){
//            NSLog(@"Reply JSON: %@", responseObject);
             [self.worksUnitArr addObjectsFromArray:[FYWorksUnitData mj_objectArrayWithKeyValuesArray:responseObject[@"unitData"]]];

            [self.collectionView reloadData];
            
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}

- (void) addSearchBar{
    UISearchBar* searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 44)];
    searchBar.delegate = self;
    [searchBar setPlaceholder:@"搜索枫叶🍁"];
    [searchBar setTintColor:[UIColor redColor]];
    UIBarButtonItem* buttonItem = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
    self.navigationItem.rightBarButtonItem = buttonItem;
}

//懒加载
- (NSMutableArray*) worksUnitArr{
    if(!_worksUnitArr){
        _worksUnitArr = [NSMutableArray array];
    }
    
    return _worksUnitArr;
}

- (UICollectionView*) collectionView{
    if(!_collectionView)
    {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.waterFallLayout];
        _collectionView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerNib:[UINib nibWithNibName:@"FYDisplayCell" bundle:nil] forCellWithReuseIdentifier:CollectionViewCellID];
//        [_collectionView registerClass:[FYDisplayCell class] forCellWithReuseIdentifier:CollectionViewCellID];
    }
    
    return _collectionView;
}

- (FYCollectionViewWaterFallLayout*) waterFallLayout{
    
    if(!_waterFallLayout)
    {
        _waterFallLayout = [[FYCollectionViewWaterFallLayout alloc] init];
    }
    
    return _waterFallLayout;
}

//UICollectionView代理和数据源方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return self.worksUnitArr.count;
}

- (FYDisplayCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FYDisplayCell* cell = (FYDisplayCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellID forIndexPath:indexPath];

    FYWorksUnitData* data = self.worksUnitArr[indexPath.item];
    
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
    
//    NSLog(@"11");
    FYDetailInfoController* detail = [[FYDetailInfoController alloc] init];
    detail.unitData = self.worksUnitArr[indexPath.item];
    
    [self.navigationController pushViewController:detail animated:YES];
}

//UISearchBar代理
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"here implement search interface...");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

//- (UIColor*) randomColor{
//    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
//    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
//    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
//    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
//}
