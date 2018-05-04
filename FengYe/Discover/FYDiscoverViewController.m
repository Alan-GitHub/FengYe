//
//  SecondViewController.m
//  FengYe
//
//  Created by Alan Turing on 2017/12/10.
//  Copyright © 2017年 Alan Turing. All rights reserved.
//

#import "FYDiscoverViewController.h"
#import "FYCollectionViewWaterFallLayout.h"
#import "FYDisplayCell.h"
#import "FYDetailInfoController.h"
#import "FYWorksUnitData.h"
#import <UIImageView+WebCache.h>
#import "CommonAttr.h"
#import <AFNetworking.h>
#import <MJExtension.h>
#import "FYInterestGroupUnitData.h"
#import "FYInterestGroupDetailController.h"

#define DiscoverColleID @"DiscoverColleID"

#define InterestGroupSize 100
#define InterestGroupNumbers  7
#define MarginIn 8
#define MarginLeft 10
#define MarginBottom 20
#define MarginRight 10
#define MarginTop 10


@interface FYDiscoverViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, retain, readwrite) UICollectionView* collectionView;
@property(nonatomic, retain, readwrite) FYCollectionViewWaterFallLayout* waterFallLayout;
@property(nonatomic, retain, readwrite) UIScrollView* inrstGroupView;

@property(nonatomic, strong) NSMutableArray<FYWorksUnitData*>* worksUnitArrDisc;
@property(nonatomic, strong) NSMutableArray<FYInterestGroupUnitData*>* interestGroupUnitArrDisc;
@end

@implementation FYDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGFloat offsetY = 0;
    self.navigationItem.title = @"发现";

    UILabel* titleLabel = [self getTitileLabel];
    titleLabel.frame = CGRectMake(0, -titleLabel.bounds.size.height, ScreenWidth, titleLabel.bounds.size.height);
    [self.collectionView addSubview:titleLabel];
    
    offsetY += titleLabel.bounds.size.height;
    
    UIScrollView* inrstGroupView = [self getInrstGroupView];
    inrstGroupView.frame = CGRectMake(0, -offsetY-inrstGroupView.bounds.size.height, ScreenWidth, inrstGroupView.bounds.size.height);
    [self.collectionView addSubview:inrstGroupView];
    
    offsetY += inrstGroupView.bounds.size.height;

    [self.view addSubview:self.collectionView];
    self.collectionView.contentInset = UIEdgeInsetsMake(offsetY, 0, 0, 0);
    
    self.waterFallLayout.data = self.worksUnitArrDisc;
    
    [self loadData];
}

- (void) loadData{
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"DISCOVER";
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
//          NSLog(@"Reply JSON: %@", responseObject);
            [self.worksUnitArrDisc addObjectsFromArray:[FYWorksUnitData mj_objectArrayWithKeyValuesArray:responseObject[@"worksUnitData"]]];
            
            [self.interestGroupUnitArrDisc addObjectsFromArray:[FYInterestGroupUnitData mj_objectArrayWithKeyValuesArray:responseObject[@"interestGroupUnitData"]]];
            
            [self inrstGroupLoadData];
            [self.collectionView reloadData];
            
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}

//interest group data
- (void) inrstGroupLoadData{
    
    CGFloat imageHeight = 0;
    NSInteger i = 0;
    FYInterestGroupUnitData* inrstGroupUnitData;
    
    for (; i < self.interestGroupUnitArrDisc.count; i++) {
        inrstGroupUnitData = self.interestGroupUnitArrDisc[i];
        
        UIView* inrstGroup = [[UIView alloc] init];
        inrstGroup.frame = CGRectMake(MarginLeft + (InterestGroupSize+MarginIn) * i, MarginTop, InterestGroupSize, InterestGroupSize);
        inrstGroup.backgroundColor = [self randomColor];
        inrstGroup.layer.cornerRadius = 15;
        inrstGroup.clipsToBounds = YES;
        [self.inrstGroupView addSubview:inrstGroup];
        
        
        imageHeight = InterestGroupSize * inrstGroupUnitData.coverImageHeight / inrstGroupUnitData.coverImageWidth;
        UIImageView* imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, InterestGroupSize, imageHeight);
        [imageView sd_setImageWithURL:[NSURL URLWithString:inrstGroupUnitData.coverImageURL]];
        imageView.layer.cornerRadius = 15;
        imageView.layer.masksToBounds = YES;
        [inrstGroup addSubview:imageView];
        
        UILabel* groupName = [[UILabel alloc] initWithFrame:CGRectMake(0, InterestGroupSize*2/3, InterestGroupSize, InterestGroupSize/3)];
        groupName.text = inrstGroupUnitData.interestGroupName;
        groupName.textAlignment = NSTextAlignmentCenter;
        groupName.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.5];
        [inrstGroup addSubview:groupName];
        
        inrstGroup.tag = i;
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(interestGroupClicked:)];
        [inrstGroup addGestureRecognizer:tap];
    }
    
    CGFloat tmpWidth = MarginLeft + (InterestGroupSize + MarginIn) * (i - 1) + InterestGroupSize + MarginRight;
    self.inrstGroupView.contentSize = CGSizeMake(tmpWidth, 0);
}


- (UIScrollView*) getInrstGroupView{
    
    _inrstGroupView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, InterestGroupSize+MarginTop+MarginBottom)];

    _inrstGroupView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
    _inrstGroupView.showsHorizontalScrollIndicator = NO;
    
    return _inrstGroupView;
}

//Add title label
- (UILabel*) getTitileLabel{
    UILabel* titleLabel = [[UILabel alloc] init];
    
    titleLabel.text = @"发现采集";
    titleLabel.font = [UIFont systemFontOfSize:25];

    CGRect rect = titleLabel.bounds;
    rect.size.width = ScreenWidth;
    titleLabel.frame = rect;
    
    [titleLabel sizeToFit];
    titleLabel.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
    
    return titleLabel;
}

//懒加载
- (NSMutableArray*) worksUnitArrDisc{
    if(!_worksUnitArrDisc){
        _worksUnitArrDisc = [NSMutableArray array];
    }
    
    return _worksUnitArrDisc;
}

- (NSMutableArray*) interestGroupUnitArrDisc{
    if(!_interestGroupUnitArrDisc){
        _interestGroupUnitArrDisc = [NSMutableArray array];
    }
    
    return _interestGroupUnitArrDisc;
}

- (UICollectionView*) collectionView{
    if(!_collectionView)
    {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.waterFallLayout];
        _collectionView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerNib:[UINib nibWithNibName:@"FYDisplayCell" bundle:nil] forCellWithReuseIdentifier:DiscoverColleID];
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


- (void) interestGroupClicked:(UITapGestureRecognizer*) sender{
    
    FYInterestGroupDetailController* detail = [[FYInterestGroupDetailController alloc] init];
//    detail.index = sender.view.tag;
    detail.interestGroupUnitData = self.interestGroupUnitArrDisc[sender.view.tag];
    
    [self.navigationController pushViewController:detail animated:NO];
}

//UICollectionView代理和数据源方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.worksUnitArrDisc.count;
}

- (FYDisplayCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FYDisplayCell* cell = (FYDisplayCell*)[collectionView dequeueReusableCellWithReuseIdentifier:DiscoverColleID forIndexPath:indexPath];
    
    FYWorksUnitData* data = self.worksUnitArrDisc[indexPath.item];
    
    [cell.workImage sd_setImageWithURL:[NSURL URLWithString:data.picURL] completed:nil];
    
    //转采数量
    NSString* zhuanCaiTxt = data.forwardCount > 0 ? [NSString stringWithFormat:@"%zd", data.forwardCount] : @"";
    cell.zhuanCaiLabel.text = zhuanCaiTxt;
    
    //喜欢数量
    NSString* loveTxt = data.likeCount > 0 ? [NSString stringWithFormat:@"%zd", data.likeCount] : @"";
    cell.loveLabel.text = loveTxt;
    
    //评论数量
    NSString* commentTxt = data.commentCount > 0 ? [NSString stringWithFormat:@"%zd", data.commentCount] : @"";
    cell.commentLabel.text = commentTxt;

    cell.descriptionLabel.text = data.descriptionText;
    [cell.headerIcon sd_setImageWithURL:[NSURL URLWithString:data.headIcon] completed:nil];
    cell.usernameLabel.text = data.owner;
    cell.workModuleLabel.text = data.templateName;
    
    //re-layout
    [cell layoutIfNeeded];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FYDetailInfoController* detail = [[FYDetailInfoController alloc] init];
    detail.unitData = self.worksUnitArrDisc[indexPath.item];
    detail.hasRecommend = YES;
    
    [self.navigationController pushViewController:detail animated:YES];
}

- (UIColor*) randomColor{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
