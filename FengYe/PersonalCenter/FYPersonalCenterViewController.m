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
#import "FYSettingsViewController.h"
#import "uploadModel.h"
#import <SVProgressHUD.h>
#import <MJRefresh.h>
#import "FYDetailPrivateViewController.h"

#define TableViewCell @"TableViewCell"

#define ControlViewHeight 170

#define HeadIconHeight 60

@interface FYPersonalCenterViewController ()<UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property(nonatomic, retain) UITableView* gTableView;
@property(nonatomic, retain) UIScrollView* gScroView;
@property(nonatomic, retain) UIView* gPersonInfo;
@property(nonatomic, retain) UIView* gControlView;

//用户名
@property(nonatomic, retain) UILabel* gUsername;
@property(nonatomic, retain) UILabel* gFans;

@property(nonatomic, retain) UIView* gFourLabelBackView;
@property(nonatomic, retain) UIView* gDrawboard;
@property(nonatomic, retain) UIView* gCollection;
@property(nonatomic, retain) UIView* gLike;
@property(nonatomic, retain) UIView* gAttention;
@property(nonatomic, assign) NSInteger gPrevClicked;

@property(nonatomic, retain) UILabel* gDrawboardNums;
@property(nonatomic, retain) UILabel* gCollectionNums;
@property(nonatomic, retain) UILabel* gLikeNums;
@property(nonatomic, retain) UILabel* gAttentionNums;

@property(nonatomic, retain) NSMutableArray<UIView*>* gMenuAttr;
@property(nonatomic, retain) FYPersonalCenterHeaderData* gHeaderData;

//更换头像
@property(nonatomic, retain) UIImagePickerController* imagePicker;
@property(nonatomic, retain) uploadModel* gModel;
@property(nonatomic, retain) UIImageView* gPersonInfoHeadIcon;

@property(nonatomic, retain) UIButton* gRegardBtn;

@end

@implementation FYPersonalCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:tableView];
    self.gTableView = tableView;
    
    UIView* controlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ControlViewHeight)];
    tableView.tableHeaderView = controlView;
    self.gControlView = controlView;
    
    //添加设置按钮到右上角
    [self addNavRightButton];
    
    //默认选择第一个菜单.
    self.gPrevClicked = 0;
    
    FYDrawboardViewController* drawboardVC = [[FYDrawboardViewController alloc] init];
    drawboardVC.mainVC = self;
    drawboardVC.userName = self.userName;
    [self addChildViewController:drawboardVC];
    
    FYCollectionViewController* collectionVC = [[FYCollectionViewController alloc] init];
    collectionVC.mainVC = self;
    collectionVC.userName = self.userName;
    [self addChildViewController:collectionVC];

    FYLikeViewController* likeVC = [[FYLikeViewController alloc] init];
    likeVC.mainVC = self;
    likeVC.userName = self.userName;
    [self addChildViewController:likeVC];
    
    FYAttentionViewController* attentionVC = [[FYAttentionViewController alloc] init];
    attentionVC.userName = self.userName;
    attentionVC.mainVC = self;
    [self addChildViewController:attentionVC];
    
    self.imagePicker.delegate = self;
    
    //下拉刷新
    self.gTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData];
    }];
    
    [self loadData];
}

- (void) loadData{

    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"PERSONALCENTER";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    
    //其他用户
    if (self.userName.length) {
        paramData[@"otherUser"] = self.userName;
    }
    
    //登录用户
    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
    NSString* username = [userDef objectForKey:@"loginName"];
    paramData[@"loginUser"] = username;
    
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
            self.gHeaderData = [FYPersonalCenterHeaderData mj_objectWithKeyValues:responseObject[@"headerData"]];
            
            //结束刷新
            [self.gTableView.mj_header endRefreshing];
            
            //把登录用户的头像路径存储起来以备使用
            NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
            [userDef setObject:self.gHeaderData.headIconURL forKey:@"headIcon"];
            
            //正确设置关注按钮的状态
            [self regardButtonStatus:self.gHeaderData.isAttention];
            
            //加载视图上半部分数据
            [self setupControlView: self.gControlView];

        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}

- (void) addNavRightButton{
    
    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
    NSString* loginName = [userDef objectForKey:@"loginName"];
    
    if (self.userName.length && ![self.userName isEqualToString:loginName]) { //进入的是别人的个人中心
        
        UIButton *attentionBtn = [UIButton buttonWithType: UIButtonTypeCustom];
        [attentionBtn setTitle:@"+关注" forState:UIControlStateNormal];
        [attentionBtn setTitle:@"✔️" forState:UIControlStateSelected];
        [attentionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        attentionBtn.backgroundColor = [UIColor redColor];
        attentionBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [attentionBtn sizeToFit];
        [attentionBtn addTarget:self action:@selector(regardButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
        self.gRegardBtn = attentionBtn;
        UIBarButtonItem  *attentionBarBtn = [[UIBarButtonItem alloc] initWithCustomView: attentionBtn];
        
        //邮件消息按钮
        UIButton *mailBtn = [UIButton buttonWithType: UIButtonTypeCustom];
        [mailBtn setTitle:@"📧" forState:UIControlStateNormal];
        mailBtn.titleLabel.font = [UIFont systemFontOfSize:20];
        [mailBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [mailBtn sizeToFit];
        [mailBtn addTarget:self action:@selector(mailBarBtnClicked:) forControlEvents: UIControlEventTouchUpInside];
        UIBarButtonItem  *mailBarBtn = [[UIBarButtonItem alloc] initWithCustomView: mailBtn];
        
        self.navigationItem.rightBarButtonItems = @[attentionBarBtn, mailBarBtn];
    
    }else{ //进入了自己的个人中心界面
        
        UIButton *btn = [UIButton buttonWithType: UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"mine-setting-iconN"] forState:UIControlStateNormal];
        [btn sizeToFit];
        [btn addTarget:self action:@selector(settingsButtonClicked) forControlEvents: UIControlEventTouchUpInside];
        
        UIBarButtonItem  *barbtn = [[UIBarButtonItem alloc] initWithCustomView: btn];
        self.navigationItem.rightBarButtonItem = barbtn;
    }
}

- (void) mailBarBtnClicked:(UIButton*) btn{
    
    FYDetailPrivateViewController* detailPrivateVC = [[FYDetailPrivateViewController alloc] init];
    detailPrivateVC.privMsgUsername = self.userName;
    detailPrivateVC.privMsgUserHeadIconUrl = self.gHeaderData.headIconURL;
    [self.navigationController pushViewController:detailPrivateVC animated:YES];
}

- (void) regardButtonStatus:(bool) isChoice{

    self.gRegardBtn.selected = isChoice;
    if (self.gRegardBtn.selected) {
        self.gRegardBtn.backgroundColor = [UIColor lightGrayColor];
    }else{
        self.gRegardBtn.backgroundColor = [UIColor redColor];
    }
}

- (void) regardButtonClicked:(UIButton*) btn{
    
    btn.selected = !btn.selected;
    if (btn.selected) {
        btn.backgroundColor = [UIColor lightGrayColor];
    }else{
        btn.backgroundColor = [UIColor redColor];
    }
    
    //更新数据库
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"USER_REGARD_OR_NOT";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    
    //当前登录用户
    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
    NSString* username = [userDef objectForKey:@"loginName"];
    paramData[@"loginUser"] = username;
    
    //被关注用户
    paramData[@"regardedUser"] = self.userName;
    
    //关注还是取消关注
    paramData[@"regardOrNot"] = [NSString stringWithFormat:@"%zd", btn.selected];
    
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
            NSInteger retValue = [responseObject[@"retCode"] integerValue];
            if (retValue == 0) {
                [SVProgressHUD showErrorWithStatus:@"处理错误"];
            }
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
            [SVProgressHUD showErrorWithStatus:@"网络故障"];
        }
    }] resume];
}

- (void) settingsButtonClicked{
    
    FYSettingsViewController* settingsVC = [[FYSettingsViewController alloc] init];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (void) setupControlView:(UIView*) controlView{
    
    [self addPersonInfoView: controlView];
    
    [self addFourLabelView: controlView];
    
}

- (void) addPersonInfoView: (UIView*) controlView{
    
    //back view
    if (!self.gPersonInfo) {
        
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
    }
    
    //head icon view
    if (!self.gPersonInfoHeadIcon) {
        
        UIImageView* imageView = [[UIImageView alloc] init];
        [self.gPersonInfo addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.gPersonInfo).with.offset(0);
            make.left.equalTo(self.gPersonInfo.mas_left).with.offset(20);
            make.bottom.equalTo(self.gPersonInfo.mas_bottom).with.offset(0);
            make.width.equalTo(self.gPersonInfo.mas_height);
        }];
        imageView.backgroundColor = [UIColor clearColor];
        self.gPersonInfoHeadIcon = imageView;
        
        //给用户头像添加点击事件
        NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
        NSString* loginName = [userDef objectForKey:@"loginName"];
        
        if (self.userName.length && ![self.userName isEqualToString:loginName]) { //进入的是别人的个人中心
            //别人的头像，你没有权限修改
        }else{
            
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeHeadIcon)];
            [imageView addGestureRecognizer:tap];
            imageView.userInteractionEnabled = YES;
        }
    }
    //加载网络图片之前，先清除缓存
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDisk];
    NSString* headiconURL = [self.gHeaderData.headIconURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.gPersonInfoHeadIcon sd_setImageWithURL:[NSURL URLWithString:headiconURL] placeholderImage:[UIImage imageNamed:@"defaultUserIcon"] completed:nil];
    self.gPersonInfoHeadIcon.layer.cornerRadius = HeadIconHeight/2;
    self.gPersonInfoHeadIcon.layer.masksToBounds = YES;
 
    //name label
    if (!self.gUsername) {
        
        UILabel* username = [[UILabel alloc] init];
        [self.gPersonInfo addSubview:username];
        [username mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.gPersonInfoHeadIcon.mas_top).with.offset(5);
            make.left.equalTo(self.gPersonInfoHeadIcon.mas_right).with.offset(10);
        }];
        self.gUsername.font = [UIFont systemFontOfSize:20];
        self.gUsername = username;
    }
    self.gUsername.text = self.gHeaderData.username;
    [self.gUsername sizeToFit];
    
    //fans
    if (!self.gFans) {
        
        UILabel* fans = [[UILabel alloc] init];
        [self.gPersonInfo addSubview:fans];
        [fans mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.gPersonInfoHeadIcon.mas_bottom).with.offset(-5);
            make.left.equalTo(self.gPersonInfoHeadIcon.mas_right).with.offset(10);
        }];
        self.gFans = fans;
        self.gFans.font = [UIFont systemFontOfSize:13];
        
        UITapGestureRecognizer* tapFans = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedFansLabel:)];
        fans.userInteractionEnabled = YES;
        [fans addGestureRecognizer:tapFans];
    }
    self.gFans.text = [NSString stringWithFormat: @"%zd fans >", self.gHeaderData.fansNum] ;
    [self.gFans sizeToFit];
}

- (void) addFourLabelView: (UIView*) controlView{
    
    //back view
    if (!self.gFourLabelBackView) {
        
        UIView* fourLabelBackView = [[UIView alloc] init];
        [controlView addSubview:fourLabelBackView];
        [fourLabelBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.gPersonInfo.mas_bottom).with.offset(40);
            make.left.equalTo(controlView.mas_left).with.offset(0);
            make.bottom.equalTo(controlView.mas_bottom).with.offset(-10);
            make.right.equalTo(controlView.mas_right).with.offset(0);
        }];
        fourLabelBackView.backgroundColor = [UIColor whiteColor];
        self.gFourLabelBackView = fourLabelBackView;
    }
    
    CGFloat labelSpacing = 10;
    CGFloat labelWidth = (ScreenWidth - labelSpacing * 8)/4;
    
    //draw board view
    if (!self.gDrawboard) {
        
        UIView* drawboard = [[UIView alloc] init];
        [self.gFourLabelBackView addSubview:drawboard];
        [drawboard mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.gFourLabelBackView.mas_top).with.offset(0);
            make.left.equalTo(self.gFourLabelBackView.mas_left).with.offset(labelSpacing);
            make.bottom.equalTo(self.gFourLabelBackView.mas_bottom).with.offset(0);
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
        self.gDrawboardNums = drawboardNums;
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
    }
    self.gDrawboardNums.text = [NSString stringWithFormat:@"%zd", self.gHeaderData.drawboardNum];

    //collection view
    if (!self.gCollection) {
        
        UIView* collection = [[UIView alloc] init];
        [self.gFourLabelBackView addSubview:collection];
        [collection mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.gFourLabelBackView.mas_top).with.offset(0);
            make.left.equalTo(self.gDrawboard.mas_right).with.offset(labelSpacing*2);
            make.bottom.equalTo(self.gFourLabelBackView.mas_bottom).with.offset(0);
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
        self.gCollectionNums = collectionNums;
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
    }
    self.gCollectionNums.text = [NSString stringWithFormat:@"%zd", self.gHeaderData.collectionNum];
    
    //like view
    if (!self.gLike) {
        
        UIView* like = [[UIView alloc] init];
        [self.gFourLabelBackView addSubview:like];
        [like mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.gFourLabelBackView.mas_top).with.offset(0);
            make.left.equalTo(self.gCollection.mas_right).with.offset(labelSpacing*2);
            make.bottom.equalTo(self.gFourLabelBackView.mas_bottom).with.offset(0);
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
        self.gLikeNums = likeNums;
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
    }
    self.gLikeNums.text = [NSString stringWithFormat:@"%zd", self.gHeaderData.likeNum];
  
    //regard view
    if (!self.gAttention) {
        
        UIView* attention = [[UIView alloc] init];
        [self.gFourLabelBackView addSubview:attention];
        [attention mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.gFourLabelBackView.mas_top).with.offset(0);
            make.left.equalTo(self.gLike.mas_right).with.offset(labelSpacing*2);
            make.bottom.equalTo(self.gFourLabelBackView.mas_bottom).with.offset(0);
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
        self.gAttentionNums = attentionNums;
        attentionNums.textAlignment = NSTextAlignmentCenter;
        
        UILabel* attentionTitle = [[UILabel alloc] init];
        [attention addSubview:attentionTitle];
        [attentionTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(attentionNums.mas_bottom).with.offset(0);
            make.left.equalTo(attention.mas_left).with.offset(0);
            make.right.equalTo(attention.mas_right).with.offset(0);
            make.bottom.equalTo(attention.mas_bottom).with.offset(0);
        }];
        attentionTitle.backgroundColor = [UIColor clearColor];
        attentionTitle.text = @"关注";
        attentionTitle.font = [UIFont systemFontOfSize:13];
        attentionTitle.textAlignment = NSTextAlignmentCenter;
    }
    self.gAttentionNums.text = [NSString stringWithFormat:@"%zd", self.gHeaderData.attentionNum];
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

- (void) clickedFansLabel:(UIGestureRecognizer*) gesture{
    
    FYShowAllFansViewController* fansVC = [[FYShowAllFansViewController alloc] init];
    fansVC.userName = self.userName;
    
    [self.navigationController pushViewController:fansVC animated:YES];
    
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

- (UIImagePickerController*) imagePicker{
    
    if (!_imagePicker) {
        
        _imagePicker = [[UIImagePickerController alloc] init];
    }
    
    return _imagePicker;
}

- (uploadModel*) gModel{
    
    if (!_gModel) {
        
        _gModel = [[uploadModel alloc] init];
    }
    
    return _gModel;
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

//上传头像的处理
//弹出头像选择框
- (void) changeHeadIcon{
    //底部弹出选择照片控制器
    UIAlertController* alertContro = [UIAlertController alertControllerWithTitle:@"" message:@"更换头像" preferredStyle: UIAlertControllerStyleActionSheet];
    
    //从相册选择
    UIAlertAction* photoAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.imagePicker.mediaTypes = @[(NSString*)kUTTypeImage];
        self.imagePicker.allowsEditing = YES;
        
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }];
    
    //从摄像头获取图片
    UIAlertAction* cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            self.imagePicker.allowsEditing = YES;
            
            [self presentViewController:self.imagePicker animated:YES completion:nil];
        } else{
            
            NSLog(@"没有可用的摄像头");
        }
    }];
    
    //取消
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    
    [alertContro addAction:photoAction];
    [alertContro addAction:cameraAction];
    [alertContro addAction:cancelAction];
    
    [self presentViewController:alertContro animated:YES completion:nil];
}

//UIImagePickerController 代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //获取用户选择的是照片还是视频
    NSString* mediaType = info[UIImagePickerControllerMediaType];
    
    //如果是照片
    if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
        
        //获取编辑后的照片
        UIImage* tempImage = info[UIImagePickerControllerEditedImage];
        
        if (tempImage) {
            
            if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
                
                //将照片存入相册
                UIImageWriteToSavedPhotosAlbum(tempImage, self, nil, nil);
            }
            
            //获取图片名称
            //NSString* imageName = [NSString stringWithFormat:@"%@_headicon_head.jpg", self.gHeaderData.username];  //去服务器端组装成这个样子
            NSString* imageName = @"headicon_head.jpg";
            
            //压缩图片为60 * 60
            tempImage = [self imageWithImageSimple:tempImage scaledToSize:CGSizeMake(60, 60)];
            
            //将图片存入缓存
            [self saveImage:tempImage toCachePath:[PHOTOCACHEPATH stringByAppendingPathComponent:imageName]];
            
            //赋值uploadModel
            self.gModel.path = [PHOTOCACHEPATH stringByAppendingPathComponent:imageName];
            self.gModel.name = imageName;
            self.gModel.type = @"image";
            self.gModel.isUploaded = NO;
            
            //上传图片
            [self uploadImageBaseModel:self.gModel];
        }
    }
    else{ //其他。-- 视频
        
        NSLog(@"其他。-- 视频");
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void) uploadImageBaseModel:(uploadModel*) model{
    
    //获取文件的后缀名
    NSString* extension = [model.name componentsSeparatedByString:@"."].lastObject;
    
    //设置mimeType
    NSString* mimeType;
    if ([model.type isEqualToString:@"image"]) {
        
        mimeType = [NSString stringWithFormat:@"image/%@", extension];
    } else{ //视频
        
        mimeType = [NSString stringWithFormat:@"video/%@", extension];
    }
    
    //创建AFHTTPSessionManager
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    
    //设置响应文件类型为JSON类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //初始化requestSerializer
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = nil;
    
    //设置timeout
    [manager.requestSerializer setTimeoutInterval:20.0];
    
    //设置请求头类型
    [manager.requestSerializer setValue:@"form/data" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setStringEncoding: NSUTF8StringEncoding];
    
    //设置请求头， 授权码
    //[manager.requestSerializer setValue:@"" forHTTPHeaderField:@"Authentication"];
    
    //上传服务器接口
    NSString* url = ServerURL;
    
    //参数
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    
    //用户名
    paramData[@"username"] = self.gHeaderData.username;
    paramData[@"picType"] = @"PicTypeHeadIcon";
    
    parameters[@"data"] = paramData;
    
    //开始上传
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSError* error;
        BOOL ret = [formData appendPartWithFileURL:[NSURL fileURLWithPath:model.path] name:model.name fileName:model.name mimeType:mimeType error:&error];
        
        if (!ret) {
            
            NSLog(@"appendPartWithFileURL error: %@", error);
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        NSLog(@"上传进度: %f", uploadProgress.fractionCompleted);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        //NSLog(@"成功返回: %@", responseObject);
        NSInteger ret = [responseObject[@"retCode"] integerValue];
        if (ret > 0) {

            [self.gPersonInfoHeadIcon setImage:[UIImage imageWithContentsOfFile:self.gModel.path]];
        }
        
        self.gModel.isUploaded = YES;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"上传失败: %@", error);
        model.isUploaded = NO;
    }];
}

//工具方法
- (void) saveImage:(UIImage*) image toCachePath:(NSString*) path{
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:PHOTOCACHEPATH]) {

        [fileManager createDirectoryAtPath:PHOTOCACHEPATH withIntermediateDirectories:YES attributes:nil error:nil];
    }else{

    }
    
    [UIImageJPEGRepresentation(image, 1) writeToFile:path atomically:YES];
}

//压缩图片
- (UIImage*) imageWithImageSimple:(UIImage*) image scaledToSize:(CGSize) newSize{
    
    //开启image上下文，画布大小为目标大小
    UIGraphicsBeginImageContext(newSize);
    
    //把原图片画在目标画布上
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    //获取目标画布上的图片
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //结束image上下文， 释放资源
    UIGraphicsEndImageContext();
    
    //返回画布上的图片
    return newImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
