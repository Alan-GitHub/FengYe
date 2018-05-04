//
//  FYInterestGroupDetailController.m
//  FengYe
//
//  Created by Alan Turing on 2018/2/4.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYInterestGroupDetailController.h"
#import "FYWorksUnitData.h"
#import "FYInterestGroupUnitData.h"
#import "CommonAttr.h"
#import <AFNetworking.h>
#import <MJExtension.h>
#import "FYCollectionViewWaterFallLayout.h"
#import "FYDisplayCell.h"
#import <UIImageView+WebCache.h>
#import "FYDetailInfoController.h"
#import "FYInterestGroupDetailData.h"

#define CollectionViewCellID @"InrstGpDetailCollectionViewCellID"

#define InterestGroupSize 100
#define InterestGroupNumbers  6
#define MarginIn 8
#define MarginLeft 10
#define MarginRight 10
#define MarginTop 10

@interface FYInterestGroupDetailController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, retain, readwrite) UICollectionView* collectionView;
@property(nonatomic, retain, readwrite) FYCollectionViewWaterFallLayout* waterFallLayout;
@property(nonatomic, retain) UIScrollView* inrstGroupScrollView;
@property(nonatomic, retain) UILabel* inrstGroupRegardNumsLabel;
@property(nonatomic, retain) UIView* gDisplayRegardUser;

@property(nonatomic, strong) NSMutableArray<FYWorksUnitData*>* worksUnitArrInrstGpDetail;
@property(nonatomic, strong) NSMutableArray<FYInterestGroupUnitData*>* interestGroupUnitArrInrstGpDetail;
@property(nonatomic, strong) FYInterestGroupDetailData* inrstGroupDetailData;
@end

@implementation FYInterestGroupDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    NSLog(@"xxx=%zd", self.index);
    self.navigationItem.title = self.interestGroupUnitData.interestGroupName;
    
    CGFloat offsetY = 0;
    
    UIScrollView* inrstGroupView = [self getInterestGroupView];
    inrstGroupView.frame = CGRectMake(0, -inrstGroupView.bounds.size.height, ScreenWidth, inrstGroupView.bounds.size.height);
    inrstGroupView.backgroundColor = MainBackgroundColor;
    [self.collectionView addSubview:inrstGroupView];
    
    offsetY += inrstGroupView.bounds.size.height;
    
    UIView* inrstGroupInfoView = [self getInterestGroupInfo];
    inrstGroupInfoView.backgroundColor = [UIColor whiteColor];
    inrstGroupInfoView.frame = CGRectMake(0, -offsetY-inrstGroupInfoView.bounds.size.height, ScreenWidth, inrstGroupInfoView.bounds.size.height);
    [self.collectionView addSubview:inrstGroupInfoView];
    
    offsetY += inrstGroupInfoView.bounds.size.height;
    
    [self.view addSubview: self.collectionView];
    self.waterFallLayout.data = self.worksUnitArrInrstGpDetail;
    self.collectionView.contentInset = UIEdgeInsetsMake(offsetY, 0, 0, 0);
    
    [self loadData];
}


- (UIView*) getInterestGroupInfo{
    
    CGFloat spacing = 10;
    CGFloat offsetY = 0;
    
    offsetY += spacing;
    
    UIView* inrstGroupInfoView = [[UIView alloc] init];

    //兴趣组描述信息
    UILabel* inrstGroupDesc = [self getInterestGroupDesc: self.interestGroupUnitData.interestGroupDesc];
    inrstGroupDesc.frame = CGRectMake(0, offsetY, ScreenWidth, inrstGroupDesc.bounds.size.height);
    [inrstGroupInfoView addSubview:inrstGroupDesc];
    
    offsetY += inrstGroupDesc.bounds.size.height + spacing;
    
    //多少人关注了该兴趣组
    UILabel* inrstGroupRegardNums = [self getInterestGroupRegardNums];
    inrstGroupRegardNums.frame = CGRectMake(0, offsetY, ScreenWidth, inrstGroupRegardNums.bounds.size.height);
    [inrstGroupInfoView addSubview:inrstGroupRegardNums];
    
    offsetY += inrstGroupRegardNums.bounds.size.height;

    //关注该兴趣的具体用户
    UIView* usersOfRegard = [self getUsersOfRegardInrstGroup];
    usersOfRegard.frame = CGRectMake(0, offsetY, ScreenWidth, usersOfRegard.bounds.size.height);
    [inrstGroupInfoView addSubview:usersOfRegard];
    
    offsetY += usersOfRegard.bounds.size.height;
    
    inrstGroupInfoView.frame = CGRectMake(0, 0, ScreenWidth, offsetY);
    
    return inrstGroupInfoView;
}

//获得兴趣组描述信息视图
- (UILabel*) getInterestGroupDesc: (NSString*) str{
    
    UILabel* label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    
    label.text = str;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor grayColor];
    [label sizeToFit];
    
    CGRect rect = label.bounds;
    rect.size.width = ScreenWidth;
    label.bounds = rect;

    return label;
}

//获得关注该兴趣的人头数
- (UILabel*) getInterestGroupRegardNums{
    
    UILabel* label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    
    label.text = @"  ";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:10];
    [label sizeToFit];
    
    CGRect rect = label.bounds;
    rect.size.width = ScreenWidth;
    label.bounds = rect;

    self.inrstGroupRegardNumsLabel = label;
    
    return label;
}

- (UIView*) getUsersOfRegardInrstGroup{
    
    CGFloat marginTop = 10;
//    CGFloat spacing = 10;
    CGFloat headIconSize = 30;
//    CGFloat headIconNums = 6;
    
    UIView* displayRegardUser = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, marginTop*2 + headIconSize)];
//    displayRegardUser.backgroundColor = [UIColorr grayColor];

//    CGFloat offsetX = (ScreenWidth - headIconNums * headIconSize - spacing * (headIconNums - 1))/2;
//
//    for (int i = 0; i < headIconNums; i++) {
//
//        UIImageView* imageView = [[UIImageView alloc] init];
//        imageView.frame = CGRectMake(offsetX + (headIconSize + spacing) * i, marginTop, headIconSize, headIconSize);
//
//        imageView.backgroundColor = [self randomColor];
//        imageView.layer.cornerRadius = headIconSize/2;
//        [displayRegardUser addSubview:imageView];
//    }
    
    self.gDisplayRegardUser = displayRegardUser;
    return displayRegardUser;
}

- (UIScrollView*) getInterestGroupView{
    
    _inrstGroupScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, InterestGroupSize+MarginTop)];

    _inrstGroupScrollView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
    _inrstGroupScrollView.showsHorizontalScrollIndicator = NO;
    
    return _inrstGroupScrollView;
}

- (void) loadData{
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"INTERESTGROUPSELECTED";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    paramData[@"clickedInrstGroupName"] = self.interestGroupUnitData.interestGroupName;

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
            //NSLog(@"Reply JSON: %@", responseObject);
            self.inrstGroupDetailData = [FYInterestGroupDetailData mj_objectWithKeyValues:responseObject[@"groupDetail"]];
            NSLog(@"self.inrstGroupDetailData=%zd", self.inrstGroupDetailData.numsOfRegardUser);
            
            [self.worksUnitArrInrstGpDetail addObjectsFromArray:[FYWorksUnitData mj_objectArrayWithKeyValuesArray:responseObject[@"worksUnitData"]]];
            
            [self.interestGroupUnitArrInrstGpDetail addObjectsFromArray:[FYInterestGroupUnitData mj_objectArrayWithKeyValuesArray:responseObject[@"interestGroupUnitData"]]];
            
            [self specifyInrstGroupLoadData];
            [self inrstGroupLoadData];
            [self.collectionView reloadData];
        
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}

//懒加载
- (FYInterestGroupDetailData*) inrstGroupDetailData{
    if (!_inrstGroupDetailData) {
        _inrstGroupDetailData = [[FYInterestGroupDetailData alloc] init];
    }
    
    return _inrstGroupDetailData;
}

- (NSMutableArray*) worksUnitArrInrstGpDetail{
    if(!_worksUnitArrInrstGpDetail){
        _worksUnitArrInrstGpDetail = [NSMutableArray array];
    }
    
    return _worksUnitArrInrstGpDetail;
}

- (NSMutableArray*) interestGroupUnitArrInrstGpDetail{
    if(!_interestGroupUnitArrInrstGpDetail){
        _interestGroupUnitArrInrstGpDetail = [NSMutableArray array];
    }
    
    return _interestGroupUnitArrInrstGpDetail;
}

- (UICollectionView*) collectionView{
    if(!_collectionView)
    {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.waterFallLayout];
        _collectionView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerNib:[UINib nibWithNibName:@"FYDisplayCell" bundle:nil] forCellWithReuseIdentifier:CollectionViewCellID];
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

- (void) specifyInrstGroupLoadData{
    
    //the user numbers for regard interest group
    NSString* str = [NSString stringWithFormat:@"%zd人已关注该兴趣", self.inrstGroupDetailData.numsOfRegardUser];
    self.inrstGroupRegardNumsLabel.text = str;
    
    //head icon
    CGFloat marginTop = 10;
    CGFloat spacing = 10;
    CGFloat headIconSize = 30;
    
    NSArray* headIconArr = self.inrstGroupDetailData.headIconOfRegardUser;
    CGFloat headIconNums = self.inrstGroupDetailData.headIconOfRegardUser.count;
    
    CGFloat offsetX = (ScreenWidth - headIconNums * headIconSize - spacing * (headIconNums - 1))/2;
    
    for (int i = 0; i < headIconNums; i++) {
        
        UIImageView* imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(offsetX + (headIconSize + spacing) * i, marginTop, headIconSize, headIconSize);
        [imageView sd_setImageWithURL:[NSURL URLWithString:headIconArr[i]] completed:nil];
//        imageView.backgroundColor = [self randomColor];
        imageView.layer.cornerRadius = headIconSize/2;
        imageView.layer.masksToBounds = YES;
        [self.gDisplayRegardUser addSubview:imageView];
    }
}

- (void) inrstGroupLoadData{
    
    CGFloat imageHeight = 0;
    NSInteger i = 0;
    FYInterestGroupUnitData* inrstGroupUnitData;
    
    for (; i < self.interestGroupUnitArrInrstGpDetail.count; i++) {
        inrstGroupUnitData = self.interestGroupUnitArrInrstGpDetail[i];
        
        UIView* inrstGroup = [[UIView alloc] init];
        inrstGroup.frame = CGRectMake(MarginLeft + (InterestGroupSize+MarginIn) * i, MarginTop, InterestGroupSize, InterestGroupSize);
//        inrstGroup.backgroundColor = [self randomColor];
        inrstGroup.layer.cornerRadius = 15;
        [self.inrstGroupScrollView addSubview:inrstGroup];
        
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
    CGFloat tmpWidth = MarginLeft + (InterestGroupSize + MarginIn) * (i-1) + InterestGroupSize + MarginRight;
    self.inrstGroupScrollView.contentSize = CGSizeMake(tmpWidth, 0);
}

//UICollectionView代理和数据源方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.worksUnitArrInrstGpDetail.count;
}

- (FYDisplayCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FYDisplayCell* cell = (FYDisplayCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellID forIndexPath:indexPath];
    [cell.workImage sd_setImageWithURL:[NSURL URLWithString:self.worksUnitArrInrstGpDetail[indexPath.item].picURL] completed:nil];
    
    FYWorksUnitData* unitData = self.worksUnitArrInrstGpDetail[indexPath.item];
    //转采数量
    NSString* zhuanCaiTxt = unitData.forwardCount > 0 ? [NSString stringWithFormat:@"%zd", unitData.forwardCount] : @"";
    cell.zhuanCaiLabel.text = zhuanCaiTxt;
    
    //喜欢数量
    NSString* loveTxt = unitData.likeCount > 0 ? [NSString stringWithFormat:@"%zd", unitData.likeCount] : @"";
    cell.loveLabel.text = loveTxt;
    
    //评论数量
    NSString* commentTxt = unitData.commentCount > 0 ? [NSString stringWithFormat:@"%zd", unitData.commentCount] : @"";
    cell.commentLabel.text = commentTxt;
    
    cell.descriptionLabel.text = self.worksUnitArrInrstGpDetail[indexPath.item].descriptionText;
    [cell.headerIcon sd_setImageWithURL:[NSURL URLWithString:self.worksUnitArrInrstGpDetail[indexPath.item].headIcon] completed:nil];
    cell.usernameLabel.text = self.worksUnitArrInrstGpDetail[indexPath.item].owner;
    cell.workModuleLabel.text = self.worksUnitArrInrstGpDetail[indexPath.item].templateName;
    
    //重新布局cell
    [cell layoutIfNeeded];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FYDetailInfoController* detail = [[FYDetailInfoController alloc] init];
    detail.unitData = self.worksUnitArrInrstGpDetail[indexPath.item];
    
    [self.navigationController pushViewController:detail animated:YES];
}

- (void) interestGroupClicked:(UITapGestureRecognizer*) sender{
    
    FYInterestGroupDetailController* detail = [[FYInterestGroupDetailController alloc] init];
    //    detail.index = sender.view.tag;
    detail.interestGroupUnitData = self.interestGroupUnitArrInrstGpDetail[sender.view.tag];
    
    [self.navigationController pushViewController:detail animated:NO];
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
