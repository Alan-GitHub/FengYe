//
//  FYDetailInfoController.m
//  FengYe
//
//  Created by Alan Turing on 2018/1/21.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYDetailInfoController.h"
#import "CommonAttr.h"
#import <UIImageView+WebCache.h>
#import "FYCollectionViewWaterFallLayout.h"
#import <AFNetworking.h>
#import <MJExtension.h>
#import "FYDisplayCell.h"
#import <Masonry.h>


#define CollectionViewCellID @"CollectionViewCellID"

@interface FYDetailInfoController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) UIImageView* image;
@property(nonatomic, strong) NSMutableArray<FYWorksUnitData*>* worksUnitArrDetail;
@property(nonatomic, strong) UICollectionView* collectionView;
@end

@implementation FYDetailInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    CGFloat offsetY = 0;
    CGFloat spacing = 10;
    UIView* detailView = [[UIView alloc] init];
    detailView.backgroundColor = [UIColor whiteColor];
    [self.collectionView addSubview:detailView];
    
    
#if TEST
    UIView* testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 200)];
    testView.backgroundColor = [UIColor redColor];
    [self.collectionView addSubview:testView];
#endif

    //works image
    NSInteger imageHeight = ScreenWidth * self.unitData.picHeight/self.unitData.picWidth;
    
    UIImageView* imageview = [[UIImageView alloc] init];
    imageview.frame = CGRectMake(0, offsetY, ScreenWidth, imageHeight);
    [imageview sd_setImageWithURL:[NSURL URLWithString:self.unitData.picURL] completed:nil];
    [detailView addSubview:imageview];
    
    offsetY += imageHeight + spacing;
    
    //works extentional link
//    UILabel* extenLink = [self getExtenLink:self.unitData.descriptionText];
//    extenLink.frame = CGRectMake(0, offsetY, ScreenWidth, extenLink.bounds.size.height);
//    [detailView addSubview:extenLink];
//
//
//    offsetY += extenLink.bounds.size.height + spacing;
    
    //works description text
    UILabel* label = [self getDescriptionLabel:self.unitData.descriptionText];
    label.frame = CGRectMake(0, offsetY, ScreenWidth, label.bounds.size.height);
    [detailView addSubview: label];
    
    offsetY += label.bounds.size.height + spacing;
    
    //forward/like/comment
    UIView* worksOperView = [self getWorksOperView: self.unitData];
    worksOperView.frame = CGRectMake(0, offsetY, ScreenWidth, worksOperView.bounds.size.height);
    [detailView addSubview:worksOperView];
    
    offsetY += worksOperView.bounds.size.height + spacing;

    UIView* worksOwnerInfo = [self getWorksOwnerInfo:self.unitData];
    worksOwnerInfo.frame = CGRectMake(0, offsetY, ScreenWidth, worksOwnerInfo.bounds.size.height);
    [detailView addSubview:worksOwnerInfo];
    
    offsetY += worksOwnerInfo.bounds.size.height;

    detailView.frame = CGRectMake(0, -offsetY, ScreenWidth, offsetY);
    
    //edgeInset
    self.collectionView.contentInset = UIEdgeInsetsMake(offsetY, 0, 0, 0);
    [self.view addSubview:self.collectionView];
    self.collectionView.contentOffset = CGPointMake(0,  -offsetY);
    
    [self loadData];
}

- (UILabel*) getExtenLink:(NSString*) extenLink{
    
    UILabel* extenLinkLabel = [[UILabel alloc] init];
    extenLinkLabel.numberOfLines = 0;
    
    extenLinkLabel.text = extenLink;

    CGRect rect = extenLinkLabel.bounds;
    rect.size.width = ScreenWidth;
    extenLinkLabel.frame = rect;
    
    [extenLinkLabel sizeToFit];
    
//    extenLinkLabel.backgroundColor = [UIColor grayColor];
    return extenLinkLabel;
}

- (UIView*) getWorksOwnerInfo:(FYWorksUnitData*) unitData{
    
    UIView* worksOwnerInfo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 80)];
//    UIView* worksOwnerInfo = [[UIView alloc] init];
    CGRect rect = worksOwnerInfo.bounds;
    rect.size = CGSizeMake(ScreenWidth, 80);
//    worksOwnerInfo.backgroundColor = [UIColor whiteColor];
    
    //headIcon
    UIImageView* headView = [[UIImageView alloc] init];
//    headView.backgroundColor = [UIColor redColor];
//    [headView setImage:[UIImage imageNamed:unitData.headIcon]];
    [headView sd_setImageWithURL:[NSURL URLWithString:unitData.headIcon] completed:nil];
    headView.layer.cornerRadius = 35;
    headView.layer.masksToBounds = YES;
    [worksOwnerInfo addSubview:headView];
    [headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(worksOwnerInfo).with.offset(5);
        make.left.equalTo(worksOwnerInfo).with.offset(10);
        make.bottom.equalTo(worksOwnerInfo).with.offset(-5);
        make.width.mas_equalTo(70);
    }];
    
    //username
    UILabel* username = [[UILabel alloc] init];
    username.text = unitData.owner;
    [username sizeToFit];
    [worksOwnerInfo addSubview:username];
    
    username.font = [UIFont systemFontOfSize:20];
    username.textAlignment = NSTextAlignmentCenter;
//    username.backgroundColor = [UIColor whiteColor];
    
    [username mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headView).with.offset(0);
        make.left.equalTo(headView.mas_right).with.offset(10);
    }];
    
    //templateName
    UILabel* templateName = [[UILabel alloc] init];
    templateName.text = unitData.templateName;
    [templateName sizeToFit];
    [worksOwnerInfo addSubview:templateName];
    
    templateName.font = [UIFont systemFontOfSize:20];
    templateName.textAlignment = NSTextAlignmentCenter;
//    templateName.backgroundColor = [UIColor whiteColor];
    
    [templateName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(headView).with.offset(0);
        make.left.equalTo(headView.mas_right).with.offset(10);
    }];
    
    [worksOwnerInfo sizeToFit];
    return worksOwnerInfo;
}

- (UIView*) getWorksOperView:(FYWorksUnitData*) unitData{
    
    UIView* worksOperView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
//    worksOperView.backgroundColor = [UIColor whiteColor];

    //time
    UILabel* time = [[UILabel alloc] init];
    time.text = [NSString stringWithFormat:@"%zd", unitData.uploadTime];
    [time sizeToFit];
    [worksOperView addSubview:time];

    time.font = [UIFont systemFontOfSize:13];
    time.textAlignment = NSTextAlignmentCenter;
//    time.backgroundColor = [UIColor whiteColor];

    [time mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(worksOperView).with.offset(0);
        make.left.equalTo(worksOperView).with.offset(5);
        make.bottom.equalTo(worksOperView).with.offset(0);
    }];
    
    //forward
    UIView* forwardView = [[UIView alloc] init];
//    forwardView.backgroundColor = [UIColor greenColor];
    [worksOperView addSubview:forwardView];
    [forwardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(time.mas_right).with.offset(20);
        make.top.equalTo(worksOperView).with.offset(0);
        make.bottom.equalTo(worksOperView).with.offset(0);
    }];

    UIButton* forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [forwardBtn setImage:[UIImage imageNamed:@"mainCellShare"] forState:UIControlStateNormal];
//    forwardBtn.backgroundColor = [UIColor redColor];
    [forwardBtn sizeToFit];
    [forwardView addSubview:forwardBtn];
    [forwardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(forwardView).with.offset(0);
        make.left.equalTo(forwardView).with.offset(0);
        make.bottom.equalTo(forwardView).with.offset(0);
    }];

    UILabel* forwardLabel = [[UILabel alloc] init];
    forwardLabel.text = [NSString stringWithFormat:@"%zd", unitData.forwardCount];
//    forwardLabel.backgroundColor = [UIColor grayColor];
    [forwardLabel sizeToFit];
    [forwardView addSubview:forwardLabel];
    [forwardLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(forwardView).with.offset(0);
        make.left.equalTo(forwardBtn.mas_right).with.offset(0);
        make.bottom.equalTo(forwardView).with.offset(0);
    }];

    [forwardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(forwardLabel.mas_right).with.offset(0);
    }];

    //like
    UIView* likeView = [[UIView alloc] init];
//    likeView.backgroundColor = [UIColor greenColor];
    [worksOperView addSubview:likeView];
    [likeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(forwardView.mas_right).with.offset(20);
        make.top.equalTo(worksOperView).with.offset(0);
        make.bottom.equalTo(worksOperView).with.offset(0);
    }];

    UIButton* likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [likeBtn setImage:[UIImage imageNamed:@"mainCellDing"] forState:UIControlStateNormal];
//    likeBtn.backgroundColor = [UIColor redColor];
    [likeBtn sizeToFit];
    [likeView addSubview:likeBtn];
    [likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(likeView).with.offset(0);
        make.left.equalTo(likeView).with.offset(0);
        make.bottom.equalTo(likeView).with.offset(0);
    }];

    UILabel* likeLabel = [[UILabel alloc] init];
    likeLabel.text = [NSString stringWithFormat:@"%zd", unitData.likeCount];
//    likeLabel.backgroundColor = [UIColor grayColor];
    [likeLabel sizeToFit];
    [likeView addSubview:likeLabel];
    [likeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(likeView).with.offset(0);
        make.left.equalTo(likeBtn.mas_right).with.offset(0);
        make.bottom.equalTo(likeView).with.offset(0);
    }];

    [likeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(likeLabel.mas_right).with.offset(0);
    }];
    
    //comment
    UIView* commentView = [[UIView alloc] init];
//    commentView.backgroundColor = [UIColor greenColor];
    [worksOperView addSubview:commentView];
    [commentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(likeView.mas_right).with.offset(20);
        make.top.equalTo(worksOperView).with.offset(0);
        make.bottom.equalTo(worksOperView).with.offset(0);
    }];
    
    UIButton* commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentBtn setImage:[UIImage imageNamed:@"mainCellComment"] forState:UIControlStateNormal];
//    commentBtn.backgroundColor = [UIColor redColor];
    [commentBtn sizeToFit];
    [commentView addSubview:commentBtn];
    [commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(commentView).with.offset(0);
        make.left.equalTo(commentView).with.offset(0);
        make.bottom.equalTo(commentView).with.offset(0);
    }];
    
    UILabel* commentLabel = [[UILabel alloc] init];
    commentLabel.text = [NSString stringWithFormat:@"%zd", unitData.commentCount];
//    commentLabel.backgroundColor = [UIColor grayColor];
    [commentLabel sizeToFit];
    [commentView addSubview:commentLabel];
    [commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(commentView).with.offset(0);
        make.left.equalTo(commentBtn.mas_right).with.offset(0);
        make.bottom.equalTo(commentView).with.offset(0);
    }];
    
    [commentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(commentLabel.mas_right).with.offset(0);
    }];
    
    return worksOperView;
}

- (UILabel*) getDescriptionLabel:(NSString*) descriptionText{
    
    UILabel* label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    
    label.text = descriptionText;

    CGRect rect = label.bounds;
    rect.size.width = ScreenWidth;
    label.frame = rect;
    
    [label sizeToFit];
    
    rect = label.bounds;
    rect.origin = CGPointMake(0, -rect.size.height);
    label.frame = rect;
//    CGFloat h = [descriptionText boundingRectWithSize:CGSizeMake(ScreenWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize: 15]} context:nil].size.height;
    
//    label.backgroundColor = [UIColor redColor];
    
    return label;
}



- (void) loadData{
    
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
//                        NSLog(@"Reply JSON: %@", responseObject);
            [self.worksUnitArrDetail addObjectsFromArray:[FYWorksUnitData mj_objectArrayWithKeyValuesArray:responseObject[@"unitData"]]];
            
            [self.collectionView reloadData];
            
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}

- (UIImageView*) image{
    if (!_image) {
        _image = [[UIImageView alloc] init];
    }
    
    return _image;
}

- (NSMutableArray*) worksUnitArrDetail{
    if (!_worksUnitArrDetail) {
        _worksUnitArrDetail = [NSMutableArray array];
    }
    
    return _worksUnitArrDetail;
}

- (UICollectionView*) collectionView{
    if (!_collectionView) {
        
        FYCollectionViewWaterFallLayout* waterFallLayout = [[FYCollectionViewWaterFallLayout alloc] init];
        waterFallLayout.data = self.worksUnitArrDetail;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:waterFallLayout];
        _collectionView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerNib:[UINib nibWithNibName:@"FYDisplayCell" bundle:nil] forCellWithReuseIdentifier:CollectionViewCellID];
    }
    
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    NSLog(@"self.worksUnitArrDetail.count=%zd", self.worksUnitArrDetail.count);
    return self.worksUnitArrDetail.count;
}

- (FYDisplayCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FYDisplayCell* cell = (FYDisplayCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellID forIndexPath:indexPath];

    [cell.workImage sd_setImageWithURL:[NSURL URLWithString:self.worksUnitArrDetail[indexPath.item].picURL] completed:nil];
    cell.zhuanCaiLabel.text = [NSString stringWithFormat:@"%zd", self.worksUnitArrDetail[indexPath.item].forwardCount];
    cell.loveLabel.text = [NSString stringWithFormat:@"%zd", self.worksUnitArrDetail[indexPath.item].likeCount];
    cell.commentLabel.text = [NSString stringWithFormat:@"%zd", self.worksUnitArrDetail[indexPath.item].commentCount];
    
    cell.descriptionLabel.text = self.worksUnitArrDetail[indexPath.item].descriptionText;
    [cell.headerIcon sd_setImageWithURL:[NSURL URLWithString:self.worksUnitArrDetail[indexPath.item].headIcon] completed:nil];
    cell.usernameLabel.text = self.worksUnitArrDetail[indexPath.item].owner;
    cell.workModuleLabel.text = self.worksUnitArrDetail[indexPath.item].templateName;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    FYDetailInfoController* detail = [[FYDetailInfoController alloc] init];
    detail.unitData = self.worksUnitArrDetail[indexPath.item];
    
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
