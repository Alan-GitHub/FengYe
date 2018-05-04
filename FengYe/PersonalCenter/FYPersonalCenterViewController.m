//
//  FYPersonalCenterViewController.m
//  FengYe
//
//  Created by Alan Turing on 2018/3/3.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYPersonalCenterViewController.h"
#import "CommonAttr.h"
#import <Masonry.h>
#import "FYWorksUnitData.h"
#import "FYCollectionViewWaterFallLayout.h"
#import "FYDisplayCell.h"
#import "FYDrawboardCell.h"
#import "FYDrawboardViewController.h"
#import "FYCollectionViewController.h"
#import "FYLikeViewController.h"
#import "FYAttentionViewController.h"
#import <AFNetworking.h>
#import <MJExtension.h>
#import "FYPersonalCenterHeaderData.h"
#import <UIImageView+WebCache.h>
#import "FYShowAllFansViewController.h"

#define TableViewCell @"TableViewCell"

#define ControlViewHeight 170

#define HeadIconHeight 60

@interface FYPersonalCenterViewController ()<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, retain) UITableView* gTableView;
@property(nonatomic, retain) UIScrollView* gScroView;
@property(nonatomic, retain) UIView* gPersonInfo;
@property(nonatomic, retain) UIView* gControlView;


@property(nonatomic, retain) UIView* gDrawboard;
@property(nonatomic, retain) UIView* gCollection;
@property(nonatomic, retain) UIView* gLike;
@property(nonatomic, retain) UIView* gAttention;
@property(nonatomic, assign) NSInteger gPrevClicked;

@property(nonatomic, retain) NSMutableArray<UIView*>* gMenuAttr;
@property(nonatomic, retain) FYPersonalCenterHeaderData* gHeaderData;

@end

@implementation FYPersonalCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.view.backgroundColor = [UIColor yellowColor];
    
    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
//    tableView.backgroundColor = [UIColor redColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:tableView];
    self.gTableView = tableView;
//    tableView.scrollEnabled = NO;
    
    UIView* controlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ControlViewHeight)];
//    controlView.backgroundColor = [UIColor greenColor];
    tableView.tableHeaderView = controlView;
    self.gControlView = controlView;
    
    //default select the first menu.
    self.gPrevClicked = 0;
    
    FYDrawboardViewController* drawboardVC = [[FYDrawboardViewController alloc] init];
    drawboardVC.mainVC = self;
    [self addChildViewController:drawboardVC];
    
    FYCollectionViewController* collectionVC = [[FYCollectionViewController alloc] init];
    collectionVC.mainVC = self;
    [self addChildViewController:collectionVC];

    FYLikeViewController* likeVC = [[FYLikeViewController alloc] init];
    likeVC.mainVC = self;
    [self addChildViewController:likeVC];
    
    FYAttentionViewController* attentionVC = [[FYAttentionViewController alloc] init];
    attentionVC.mainVC = self;
    [self addChildViewController:attentionVC];
    
    [self loadData];
}

- (void) loadData{

    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"PERSONALCENTER";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    
    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
    NSString* username = [userDef objectForKey:@"loginName"];
    paramData[@"username"] = username;
    
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
//            NSLog(@"Reply JSON: %@", responseObject);
            self.gHeaderData = [FYPersonalCenterHeaderData mj_objectWithKeyValues:responseObject[@"headerData"]];
            [self setupControlView: self.gControlView];
//            NSLog(@"attentionNum: %zd", self.gHeaderData.attentionNum);
//            NSLog(@"collectionNum: %zd", self.gHeaderData.collectionNum);
//            NSLog(@"drawboardNum: %zd", self.gHeaderData.drawboardNum);
//            NSLog(@"fansNum: %zd", self.gHeaderData.fansNum);
//            NSLog(@"likeNum: %zd", self.gHeaderData.likeNum);
//            NSLog(@"headIconURL: %@", self.gHeaderData.headIconURL);
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}


- (void) setupControlView:(UIView*) controlView{
    
    [self addPersonInfoView: controlView];
    
    [self addFourLabelView: controlView];
    
}

- (void) addPersonInfoView: (UIView*) controlView{
    
    //back view
    UIView* personInfo = [[UIView alloc] init];
    [controlView addSubview:personInfo];
    [personInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(controlView.mas_top).with.offset(10);
        make.left.equalTo(controlView.mas_left).with.offset(0);
        make.right.equalTo(controlView.mas_right).with.offset(0);
        make.height.mas_equalTo(HeadIconHeight);
    }];
    personInfo.backgroundColor = [UIColor whiteColor];
    self.gPersonInfo = personInfo;
    
    //head icon view
    UIImageView* imageView = [[UIImageView alloc] init];
    [personInfo addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(personInfo).with.offset(0);
        make.left.equalTo(personInfo.mas_left).with.offset(20);
        make.bottom.equalTo(personInfo.mas_bottom).with.offset(0);
        make.width.equalTo(personInfo.mas_height);
    }];
    imageView.backgroundColor = [UIColor yellowColor];
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.gHeaderData.headIconURL] completed:nil];
    imageView.layer.cornerRadius = HeadIconHeight/2;
    imageView.layer.masksToBounds = YES;
    
    //name label
    UILabel* username = [[UILabel alloc] init];
    [personInfo addSubview:username];
    [username mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_top).with.offset(5);
        make.left.equalTo(imageView.mas_right).with.offset(10);
    }];
    username.text = self.gHeaderData.username;
    username.font = [UIFont systemFontOfSize:20];
    [username sizeToFit];
    
    //fans
    UILabel* fans = [[UILabel alloc] init];
    [personInfo addSubview:fans];
    [fans mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(imageView.mas_bottom).with.offset(-5);
        make.left.equalTo(imageView.mas_right).with.offset(10);
    }];
    fans.text = [NSString stringWithFormat: @"%zd fans >", self.gHeaderData.fansNum] ;
    fans.font = [UIFont systemFontOfSize:13];
    [fans sizeToFit];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedFansLabel:)];
    fans.userInteractionEnabled = YES;
    [fans addGestureRecognizer:tap];
}

- (void) addFourLabelView: (UIView*) controlView{
    
    //back view
    UIView* fourLabelBackView = [[UIView alloc] init];
    [controlView addSubview:fourLabelBackView];
    [fourLabelBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.gPersonInfo.mas_bottom).with.offset(40);
        make.left.equalTo(controlView.mas_left).with.offset(0);
        make.bottom.equalTo(controlView.mas_bottom).with.offset(-10);
        make.right.equalTo(controlView.mas_right).with.offset(0);
    }];
    fourLabelBackView.backgroundColor = [UIColor whiteColor];
    
    CGFloat labelSpacing = 10;
    CGFloat labelWidth = (ScreenWidth - labelSpacing * 8)/4;
    
    //draw board view
    UIView* drawboard = [[UIView alloc] init];
    [fourLabelBackView addSubview:drawboard];
    [drawboard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fourLabelBackView.mas_top).with.offset(0);
        make.left.equalTo(fourLabelBackView.mas_left).with.offset(labelSpacing);
        make.bottom.equalTo(fourLabelBackView.mas_bottom).with.offset(0);
        make.width.mas_equalTo(labelWidth);
    }];
    drawboard.backgroundColor = [UIColor lightGrayColor];
    self.gDrawboard = drawboard;
    [self.gMenuAttr addObject:drawboard];
    
    UITapGestureRecognizer* tapDrawBoard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    drawboard.tag = 0;
    [drawboard addGestureRecognizer:tapDrawBoard];
    
    UILabel* drawboardNums = [[UILabel alloc] init];
    [drawboard addSubview:drawboardNums];
    [drawboardNums mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(drawboard.mas_top).with.offset(0);
        make.left.equalTo(drawboard.mas_left).with.offset(0);
        make.right.equalTo(drawboard.mas_right).with.offset(0);
        make.height.mas_equalTo(drawboard.mas_height).multipliedBy(0.5);
    }];
    drawboardNums.backgroundColor = [UIColor clearColor];
    drawboardNums.text = [NSString stringWithFormat:@"%zd", self.gHeaderData.drawboardNum];
    drawboardNums.textAlignment = NSTextAlignmentCenter;
    
    UILabel* drawboardTitle = [[UILabel alloc] init];
    [drawboard addSubview:drawboardTitle];
    [drawboardTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(drawboardNums.mas_bottom).with.offset(0);
        make.left.equalTo(drawboard.mas_left).with.offset(0);
        make.right.equalTo(drawboard.mas_right).with.offset(0);
        make.bottom.equalTo(drawboard.mas_bottom).with.offset(0);
    }];
    drawboardTitle.backgroundColor = [UIColor clearColor];
    drawboardTitle.text = @"画板";
    drawboardTitle.font = [UIFont systemFontOfSize:13];
    drawboardTitle.textAlignment = NSTextAlignmentCenter;

    //collection view
    UIView* collection = [[UIView alloc] init];
    [fourLabelBackView addSubview:collection];
    [collection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fourLabelBackView.mas_top).with.offset(0);
        make.left.equalTo(drawboard.mas_right).with.offset(labelSpacing*2);
        make.bottom.equalTo(fourLabelBackView.mas_bottom).with.offset(0);
        make.width.mas_equalTo(labelWidth);
    }];
    collection.backgroundColor = [UIColor clearColor];
    self.gCollection = collection;
    [self.gMenuAttr addObject:collection];
    
    UITapGestureRecognizer* tapCollection = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    collection.tag = 1;
    [collection addGestureRecognizer:tapCollection];
    
    UILabel* collectionNums = [[UILabel alloc] init];
    [collection addSubview:collectionNums];
    [collectionNums mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(collection.mas_top).with.offset(0);
        make.left.equalTo(collection.mas_left).with.offset(0);
        make.right.equalTo(collection.mas_right).with.offset(0);
        make.height.mas_equalTo(collection.mas_height).multipliedBy(0.5);
    }];
    collectionNums.backgroundColor = [UIColor clearColor];
    collectionNums.text = [NSString stringWithFormat:@"%zd", self.gHeaderData.collectionNum];
    collectionNums.textAlignment = NSTextAlignmentCenter;
    
    UILabel* collectionTitle = [[UILabel alloc] init];
    [collection addSubview:collectionTitle];
    [collectionTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(collectionNums.mas_bottom).with.offset(0);
        make.left.equalTo(collection.mas_left).with.offset(0);
        make.right.equalTo(collection.mas_right).with.offset(0);
        make.bottom.equalTo(collection.mas_bottom).with.offset(0);
    }];
    collectionTitle.backgroundColor = [UIColor clearColor];
    collectionTitle.text = @"采集";
    collectionTitle.font = [UIFont systemFontOfSize:13];
    collectionTitle.textAlignment = NSTextAlignmentCenter;
    
    //like view
    UIView* like = [[UIView alloc] init];
    [fourLabelBackView addSubview:like];
    [like mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fourLabelBackView.mas_top).with.offset(0);
        make.left.equalTo(collection.mas_right).with.offset(labelSpacing*2);
        make.bottom.equalTo(fourLabelBackView.mas_bottom).with.offset(0);
        make.width.mas_equalTo(labelWidth);
    }];
    like.backgroundColor = [UIColor clearColor];
    self.gLike = like;
    [self.gMenuAttr addObject:like];
    
    UITapGestureRecognizer* tapLike = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    like.tag = 2;
    [like addGestureRecognizer:tapLike];

    UILabel* likeNums = [[UILabel alloc] init];
    [like addSubview:likeNums];
    [likeNums mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(like.mas_top).with.offset(0);
        make.left.equalTo(like.mas_left).with.offset(0);
        make.right.equalTo(like.mas_right).with.offset(0);
        make.height.mas_equalTo(like.mas_height).multipliedBy(0.5);
    }];
    likeNums.backgroundColor = [UIColor clearColor];
    likeNums.text = [NSString stringWithFormat:@"%zd", self.gHeaderData.likeNum];
    likeNums.textAlignment = NSTextAlignmentCenter;
    
    UILabel* likeTitle = [[UILabel alloc] init];
    [like addSubview:likeTitle];
    [likeTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(likeNums.mas_bottom).with.offset(0);
        make.left.equalTo(like.mas_left).with.offset(0);
        make.right.equalTo(like.mas_right).with.offset(0);
        make.bottom.equalTo(like.mas_bottom).with.offset(0);
    }];
    likeTitle.backgroundColor = [UIColor clearColor];
    likeTitle.text = @"喜欢";
    likeTitle.font = [UIFont systemFontOfSize:13];
    likeTitle.textAlignment = NSTextAlignmentCenter;
    
    //regard view
    UIView* attention = [[UIView alloc] init];
    [fourLabelBackView addSubview:attention];
    [attention mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fourLabelBackView.mas_top).with.offset(0);
        make.left.equalTo(like.mas_right).with.offset(labelSpacing*2);
        make.bottom.equalTo(fourLabelBackView.mas_bottom).with.offset(0);
        make.width.mas_equalTo(labelWidth);
    }];
    attention.backgroundColor = [UIColor clearColor];
    self.gAttention = attention;
    [self.gMenuAttr addObject:attention];
    
    UITapGestureRecognizer* tapAttention = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    attention.tag = 3;
    [attention addGestureRecognizer:tapAttention];
    
    UILabel* attentionNums = [[UILabel alloc] init];
    [attention addSubview:attentionNums];
    [attentionNums mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(attention.mas_top).with.offset(0);
        make.left.equalTo(attention.mas_left).with.offset(0);
        make.right.equalTo(attention.mas_right).with.offset(0);
        make.height.mas_equalTo(attention.mas_height).multipliedBy(0.5);
    }];
    attentionNums.backgroundColor = [UIColor clearColor];
    attentionNums.text = [NSString stringWithFormat:@"%zd", self.gHeaderData.attentionNum];
    attentionNums.textAlignment = NSTextAlignmentCenter;
    
    UILabel* attentionTitle = [[UILabel alloc] init];
    [attention addSubview:attentionTitle];
    [attentionTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(collectionNums.mas_bottom).with.offset(0);
        make.left.equalTo(attention.mas_left).with.offset(0);
        make.right.equalTo(attention.mas_right).with.offset(0);
        make.bottom.equalTo(attention.mas_bottom).with.offset(0);
    }];
    attentionTitle.backgroundColor = [UIColor clearColor];
    attentionTitle.text = @"关注";
    attentionTitle.font = [UIFont systemFontOfSize:13];
    attentionTitle.textAlignment = NSTextAlignmentCenter;
}

- (void) tapAction:(UIGestureRecognizer*) gesture{

    NSInteger index = gesture.view.tag;
    
    if (index == self.gPrevClicked)
        return;
    
    //change color
    UIView* preView = self.gMenuAttr[self.gPrevClicked];
    preView.backgroundColor = [UIColor clearColor];
    
    UIView* selected = self.gMenuAttr[index];
    selected.backgroundColor = [UIColor lightGrayColor];
    
    self.gPrevClicked = index;
    
    //change origin
    CGPoint point = self.gScroView.contentOffset;
    point.x = index * ScreenWidth;
    self.gScroView.contentOffset = point;
    
    [self addViewToScrollView:index];
    
}

- (void) clickedFansLabel:(id) gesture{
    
    FYShowAllFansViewController* fansVC = [[FYShowAllFansViewController alloc] init];
    [self presentViewController:fansVC animated:YES completion:nil];
}

- (void) addViewToScrollView:(NSInteger) index{

//    if (self.gScroView.subviews.count == 4) {
//        return;
//    }

    UIView* goalView = self.childViewControllers[index].view;
    
    for (int i = 0; i < self.gScroView.subviews.count; i++) {
        
        if ([goalView isEqual:self.gScroView.subviews[i]]) {
            
            return;
        }
    }

    [self.gScroView addSubview:goalView];
}

- (NSMutableArray*) gMenuAttr{
    
    if (!_gMenuAttr) {
        _gMenuAttr = [NSMutableArray array];
    }
    
    return _gMenuAttr;
}

- (FYPersonalCenterHeaderData*) gHeaderData{
    
    if (!_gHeaderData) {
        _gHeaderData = [[FYPersonalCenterHeaderData alloc] init];
    }
    
    return _gHeaderData;
}

//delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:TableViewCell];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableViewCell];
    }
    
    //scrollview back
    self.gScroView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-SystemHeight)];
    self.gScroView.contentSize = CGSizeMake(ScreenWidth * 4, self.gScroView.bounds.size.height);
    self.gScroView.showsHorizontalScrollIndicator = NO;
    self.gScroView.scrollEnabled = NO;
    self.gScroView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];;
    [self.gScroView addSubview:self.childViewControllers[0].view];
    [cell addSubview:self.gScroView];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return ScreenHeight - SystemHeight;  //20 + 44 + 49
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    if (scrollView.contentOffset.y >= (scrollView.contentSize.height-scrollView.bounds.size.height + SystemBottomHeight -0.5)) {
        self.offsetType = OffsetTypeMax;
    } else if (scrollView.contentOffset.y <= 0) {
        self.offsetType = OffsetTypeMin;
    } else {
        self.offsetType = OffsetTypeCenter;
    }

    //哪一个子collectionview在滚动
    NSInteger index = self.gPrevClicked;
    OffsetType childOffsetType = 0;

    switch (index) {
        case 0:
            {
                FYDrawboardViewController* vc = self.childViewControllers[0];
                childOffsetType = vc.offsetType;
            }
            break;

        case 1:
            {
                FYCollectionViewController* vc = self.childViewControllers[1];
                childOffsetType = vc.offsetType;
            }
            break;

        case 2:
            {
                FYLikeViewController* vc = self.childViewControllers[2];
                childOffsetType = vc.offsetType;
            }
            break;
            
        case 3:
            {
                FYAttentionViewController* vc = self.childViewControllers[3];
                childOffsetType = vc.offsetType;
            }
            break;

        default:
            break;
    }

    if (childOffsetType == OffsetTypeMin) { }

    if (childOffsetType == OffsetTypeCenter) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentSize.height-scrollView.bounds.size.height + SystemBottomHeight);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
