//
//  FYAttentionViewController.m
//  FengYe
//
//  Created by Alan Turing on 2018/3/12.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYAttentionViewController.h"
#import "CommonAttr.h"
#import "FYInterestGroupUnitData.h"
#import <Masonry.h>
#import <UIImageView+WebCache.h>
#import "FYModuleCell.h"
#import "FYInterestingCell.h"
#import "FYUsersCell.h"
#import "FYScrollView.h"
#import <AFNetworking.h>
#import <MJExtension.h>
#import "FYDrawboardCellUnitData.h"
#import "FYUserCellData.h"
#import "FYShowAllInterestCellViewController.h"
#import "FYShowAllDrawboardCellViewController.h"
#import "FYShowAllAttentionUserCellViewController.h"
#import "FYShowDetailDrawboardViewController.h"
#import "FYInterestGroupDetailController.h"

#define InrstGroupMarginIn 8
#define InrstGroupMarginLeft 10
#define InrstGroupMarginRight 10

//Cell 大小
//兴趣
//#define InterestCellSize 120
//#define InterestCellWidth 120
//#define InterestCellHeight 120

//画板
#define DrawboardCellWidth 120
#define DrawboardCellHeight 180

//用户
#define UsersCellWidth 120
#define UsersCellHeight 170

#define InterestCell @"InterestCell"
#define ModuleCell @"ModuleCell"
#define UsersCell @"UsersCell"

@interface FYAttentionViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic, retain) NSMutableArray<FYInterestGroupUnitData*>* interestGroupAttr;
@property(nonatomic, retain) NSMutableArray<FYDrawboardCellUnitData*>* drawboardAttr;
@property(nonatomic, retain) NSMutableArray<FYUserCellData*>* attentionUsersAttr;

@property(nonatomic, retain) UIView* interestGroupBackView;
@property(nonatomic, retain) UIView* drawboardBackView;
@property(nonatomic, retain) UIView* attentionUsersBackView;

@property(nonatomic, retain) UICollectionView* gInterestGroupCollecView;
@property(nonatomic, retain) UICollectionView* gDrawboardCollecView;
@property(nonatomic, retain) UICollectionView* gAttentionUsersCollecView;

@property(nonatomic, retain) FYScrollView* gScrollBackView;
@end

@implementation FYAttentionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.frame = CGRectMake(3*ScreenWidth, 0, ScreenWidth, ScreenHeight-SystemHeight);
    
    FYScrollView* scrollBackView = [[FYScrollView alloc] initWithFrame:self.view.bounds];
    //scrollBackView.backgroundColor = [UIColor redColor];
    scrollBackView.delegate = self;
    self.gScrollBackView = scrollBackView;
    [self.view addSubview:scrollBackView];
    
//    CGFloat offsetY = 0;
//    CGFloat backViewOuterSpacing = 20;
//    offsetY += backViewOuterSpacing;
//
//    [self addInterestGroupBackView:offsetY];
//    offsetY += self.interestGroupBackView.bounds.size.height + backViewOuterSpacing;

//    [self addDrawboardBackView:offsetY];
//    offsetY += self.drawboardBackView.bounds.size.height + backViewOuterSpacing;
//
//    [self addAttentionUsersBackView:offsetY];
//    offsetY += self.attentionUsersBackView.bounds.size.height + backViewOuterSpacing;
    
//    self.gScrollBackView.contentSize = CGSizeMake(ScreenWidth, offsetY);
    [self loadData];
}

- (void) loadThirdCell{

    CGFloat offsetY = 0;
    CGFloat backViewOuterSpacing = 20;
    offsetY += backViewOuterSpacing;

    if (self.interestGroupAttr.count) {
        
        [self addInterestGroupBackView:offsetY];
        offsetY += self.interestGroupBackView.bounds.size.height + backViewOuterSpacing;
    }
    
    if (self.drawboardAttr.count) {
        
        [self addDrawboardBackView:offsetY];
        offsetY += self.drawboardBackView.bounds.size.height + backViewOuterSpacing;
    }
    
    if (self.attentionUsersAttr.count) {
        
        [self addAttentionUsersBackView:offsetY];
        offsetY += self.attentionUsersBackView.bounds.size.height;
    }

    self.gScrollBackView.contentSize = CGSizeMake(ScreenWidth, offsetY);
}

- (void) addAttentionUsersBackView:(CGFloat)offsetY{
    
    CGFloat backViewInnerSpacing = 10;
//    CGFloat usersCellWidth = 120;
//    CGFloat usersCellHeight = 170;
    
    UILabel* usersTitle = [[UILabel alloc] init];
    usersTitle.text = @"用户";
    usersTitle.font = [UIFont systemFontOfSize:17];
    [usersTitle sizeToFit];
    
    UIButton* usersBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [usersBtn setTitle:@"查看全部>" forState:UIControlStateNormal];
    usersBtn.tag = 3;
    [usersBtn addTarget:self action:@selector(lookAllClicked:) forControlEvents:UIControlEventTouchDown];
    usersBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [usersBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [usersBtn sizeToFit];
    usersBtn.frame = CGRectMake(ScreenWidth-usersBtn.bounds.size.width-backViewInnerSpacing, 0, usersBtn.bounds.size.width, usersTitle.bounds.size.height);
    
    UIView* usersTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, usersTitle.bounds.size.height)];
    [usersTitleView addSubview:usersTitle];
    [usersTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(usersTitleView.mas_top).with.offset(0);
        make.left.equalTo(usersTitleView.mas_left).with.offset(backViewInnerSpacing+5);
    }];
    [usersTitleView addSubview:usersBtn];
    
    self.attentionUsersBackView.frame = CGRectMake(0, offsetY, ScreenWidth, usersTitle.bounds.size.height + backViewInnerSpacing + UsersCellHeight + 2 * backViewInnerSpacing);
    self.attentionUsersBackView.backgroundColor = [UIColor clearColor];
    [self.attentionUsersBackView addSubview:usersTitleView];
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(UsersCellWidth, UsersCellHeight);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = backViewInnerSpacing;
    
    UICollectionView *usersColle = [[UICollectionView alloc]initWithFrame:CGRectMake(0, usersTitle.bounds.size.height + backViewInnerSpacing, ScreenWidth, UsersCellHeight + 2*backViewInnerSpacing) collectionViewLayout:layout];
    usersColle.backgroundColor = [UIColor clearColor];
    usersColle.delegate = self;
    usersColle.dataSource = self;
    usersColle.showsHorizontalScrollIndicator = NO;
    [usersColle registerNib:[UINib nibWithNibName:@"FYUsersCell" bundle:nil] forCellWithReuseIdentifier:UsersCell];
    usersColle.contentInset = UIEdgeInsetsMake(backViewInnerSpacing, backViewInnerSpacing, backViewInnerSpacing, backViewInnerSpacing);
    usersColle.tag = 3;
    [self.attentionUsersBackView addSubview:usersColle];
    self.gAttentionUsersCollecView = usersColle;
    
    [self.gScrollBackView addSubview:self.attentionUsersBackView];
    
}

- (void) addDrawboardBackView:(CGFloat)offsetY{
    
    CGFloat backViewInnerSpacing = 10;
//    CGFloat drawboardCellWidth = 120;
//    CGFloat drawboardCellHeight = 180;
    
    UILabel* drawboardTitle = [[UILabel alloc] init];
    drawboardTitle.text = @"画板";
    drawboardTitle.font = [UIFont systemFontOfSize:17];
    [drawboardTitle sizeToFit];
    
    UIButton* drawboardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [drawboardBtn setTitle:@"查看全部>" forState:UIControlStateNormal];
    drawboardBtn.tag = 2;
    [drawboardBtn addTarget:self action:@selector(lookAllClicked:) forControlEvents:UIControlEventTouchDown];
    drawboardBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [drawboardBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [drawboardBtn sizeToFit];
    drawboardBtn.frame = CGRectMake(ScreenWidth-drawboardBtn.bounds.size.width-backViewInnerSpacing, 0, drawboardBtn.bounds.size.width, drawboardTitle.bounds.size.height);
    
    UIView* drawboardTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, drawboardTitle.bounds.size.height)];
    [drawboardTitleView addSubview:drawboardTitle];
    [drawboardTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(drawboardTitleView.mas_top).with.offset(0);
        make.left.equalTo(drawboardTitleView.mas_left).with.offset(backViewInnerSpacing+5);
    }];
    [drawboardTitleView addSubview:drawboardBtn];
    
    self.drawboardBackView.frame = CGRectMake(0, offsetY, ScreenWidth, drawboardTitle.bounds.size.height + backViewInnerSpacing + DrawboardCellHeight + 2 * backViewInnerSpacing);
    self.drawboardBackView.backgroundColor = [UIColor clearColor];
    [self.drawboardBackView addSubview:drawboardTitleView];
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(DrawboardCellWidth, DrawboardCellHeight);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = backViewInnerSpacing;
    
    UICollectionView *drawboardColle = [[UICollectionView alloc]initWithFrame:CGRectMake(0, drawboardTitle.bounds.size.height + backViewInnerSpacing, ScreenWidth,DrawboardCellHeight + 2*backViewInnerSpacing) collectionViewLayout:layout];
    drawboardColle.backgroundColor = [UIColor clearColor];
    drawboardColle.delegate = self;
    drawboardColle.dataSource = self;
    drawboardColle.showsHorizontalScrollIndicator = NO;
    [drawboardColle registerNib:[UINib nibWithNibName:@"FYModuleCell" bundle:nil] forCellWithReuseIdentifier:ModuleCell];
    drawboardColle.contentInset = UIEdgeInsetsMake(backViewInnerSpacing, backViewInnerSpacing, backViewInnerSpacing, backViewInnerSpacing);
    drawboardColle.tag = 2;
    [self.drawboardBackView addSubview:drawboardColle];
    self.gDrawboardCollecView = drawboardColle;
    
    [self.gScrollBackView addSubview:self.drawboardBackView];
    
}

- (void) addInterestGroupBackView:(CGFloat)offsetY{
    
    CGFloat backViewInnerSpacing = 10;
    CGFloat interestGroupSize = 120;
    
    UILabel* interestTitle = [[UILabel alloc] init];
    interestTitle.text = @"兴趣";
    interestTitle.font = [UIFont systemFontOfSize:17];
    [interestTitle sizeToFit];
    
    UIButton* interestBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [interestBtn setTitle:@"查看全部>" forState:UIControlStateNormal];
    interestBtn.tag = 1;
    [interestBtn addTarget:self action:@selector(lookAllClicked:) forControlEvents:UIControlEventTouchDown];
    interestBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [interestBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [interestBtn sizeToFit];
    interestBtn.frame = CGRectMake(ScreenWidth-interestBtn.bounds.size.width-backViewInnerSpacing, 0, interestBtn.bounds.size.width, interestTitle.bounds.size.height);
    
    UIView* interestGroupTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, interestTitle.bounds.size.height)];
    [interestGroupTitleView addSubview:interestTitle];
    [interestTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(interestGroupTitleView.mas_top).with.offset(0);
        make.left.equalTo(interestGroupTitleView.mas_left).with.offset(backViewInnerSpacing+5);
    }];
    [interestGroupTitleView addSubview:interestBtn];
    
    self.interestGroupBackView.frame = CGRectMake(0, offsetY, ScreenWidth, interestTitle.bounds.size.height + backViewInnerSpacing + interestGroupSize + 2 * backViewInnerSpacing);
    self.interestGroupBackView.backgroundColor = [UIColor clearColor];
    [self.interestGroupBackView addSubview:interestGroupTitleView];
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(interestGroupSize, interestGroupSize);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = backViewInnerSpacing;
    
    UICollectionView *interestColle = [[UICollectionView alloc]initWithFrame:CGRectMake(0, interestTitle.bounds.size.height + backViewInnerSpacing, ScreenWidth,interestGroupSize + 2*backViewInnerSpacing) collectionViewLayout:layout];
    interestColle.backgroundColor = [UIColor clearColor];
    interestColle.delegate = self;
    interestColle.dataSource = self;
    interestColle.showsHorizontalScrollIndicator = NO;
    [interestColle registerNib:[UINib nibWithNibName:@"FYInterestingCell" bundle:nil] forCellWithReuseIdentifier:InterestCell];
    interestColle.contentInset = UIEdgeInsetsMake(backViewInnerSpacing, backViewInnerSpacing, backViewInnerSpacing, backViewInnerSpacing);
    interestColle.tag = 1;
    [self.interestGroupBackView addSubview:interestColle];
    self.gInterestGroupCollecView = interestColle;
    
    [self.gScrollBackView addSubview:self.interestGroupBackView];
                                       
}

- (void) loadData{
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"PERSONALCENTER_ATTENTION";
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

            [self.interestGroupAttr addObjectsFromArray:[FYInterestGroupUnitData mj_objectArrayWithKeyValuesArray:responseObject[@"interestGroupUnitData"]]];
            [self.drawboardAttr addObjectsFromArray:[FYDrawboardCellUnitData mj_objectArrayWithKeyValuesArray:responseObject[@"drawboardUnitData"]]];
            [self.attentionUsersAttr addObjectsFromArray:[FYUserCellData mj_objectArrayWithKeyValuesArray:responseObject[@"userCellData"]]];
            
            //加载用户关注的兴趣／画板／用户数据
            [self loadThirdCell];
            
            [self.gInterestGroupCollecView reloadData ];
            [self.gDrawboardCollecView reloadData ];
            [self.gAttentionUsersCollecView reloadData ];
            
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}

- (NSMutableArray*) interestGroupAttr{
    
    if (_interestGroupAttr == nil) {
        _interestGroupAttr = [NSMutableArray array];
    }
    
    return _interestGroupAttr;
}

- (NSMutableArray*) drawboardAttr{
    
    if (_drawboardAttr == nil) {
        _drawboardAttr = [NSMutableArray array];
    }
    
    return _drawboardAttr;
}

- (NSMutableArray*) attentionUsersAttr{
    
    if (_attentionUsersAttr == nil) {
        _attentionUsersAttr = [NSMutableArray array];
    }
    
    return _attentionUsersAttr;
}

- (UIView*) interestGroupBackView{
    
    if (_interestGroupBackView == nil) {
        _interestGroupBackView = [[UIView alloc] init];
    }
    
    return _interestGroupBackView;
}

- (UIView*) drawboardBackView{
    
    if (_drawboardBackView == nil) {
        _drawboardBackView = [[UIView alloc] init];
    }
    
    return _drawboardBackView;
}

- (UIView*) attentionUsersBackView{
    
    if (_attentionUsersBackView == nil) {
        _attentionUsersBackView = [[UIView alloc] init];
    }
    
    return _attentionUsersBackView;
}


- (void) lookAllClicked:(UIButton*) btn{
    
    switch (btn.tag) {
        case 1:  //兴趣组查看全部
            {
                FYShowAllInterestCellViewController* interestGroupVC = [[FYShowAllInterestCellViewController alloc] init];
                interestGroupVC.allInterestCellAttr = self.interestGroupAttr;
                [self.navigationController pushViewController:interestGroupVC animated:YES];
            }
            break;
            
        case 2:  //画板查看全部
            {
                FYShowAllDrawboardCellViewController* drawboardVC = [[FYShowAllDrawboardCellViewController alloc] init];
                drawboardVC.allDrawboardCellAttr = self.drawboardAttr;
                drawboardVC.drawboardCellOrigWidth = DrawboardCellWidth;
                drawboardVC.drawboardCellOrigHeight = DrawboardCellHeight;
                [self.navigationController pushViewController:drawboardVC animated:YES];
            }
            break;
            
        case 3:  //关注用户查看全部
            {
                FYShowAllAttentionUserCellViewController* attentionUserVC = [[FYShowAllAttentionUserCellViewController alloc] init];
                attentionUserVC.allAttentionUsersCellAttr = self.attentionUsersAttr;
                attentionUserVC.userCellOrigWidth = UsersCellWidth;
                attentionUserVC.userCellOrigHeight = UsersCellHeight;
                [self.navigationController pushViewController:attentionUserVC animated:YES];
            }
            break;
            
        default:
            break;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    switch (collectionView.tag) {
        case 1:
            return self.interestGroupAttr.count;
            break;
            
        case 2:
            return self.drawboardAttr.count;
            break;
            
        case 3:
            return self.attentionUsersAttr.count;
            break;
            
        default:
            break;
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell* cell;
    NSInteger index = [indexPath item];
    
    switch (collectionView.tag) {
        case 1:  //兴趣组
            {
                FYInterestingCell* inrstCell = [collectionView dequeueReusableCellWithReuseIdentifier:InterestCell forIndexPath:indexPath];
                
                inrstCell.interestGroupName.text = self.interestGroupAttr[index].interestGroupName;
                NSString* coverImageURL = [self.interestGroupAttr[index].coverImageURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                [inrstCell.coverImage sd_setImageWithURL:[NSURL URLWithString:coverImageURL]];
                inrstCell.coverImage.contentMode = UIViewContentModeScaleAspectFill;
                
                cell = inrstCell;
            }
            break;
            
        case 2: //画板
            {
                FYModuleCell* drawboardCell = [collectionView dequeueReusableCellWithReuseIdentifier:ModuleCell forIndexPath:indexPath];
                
                NSString* coverImageURL = [self.drawboardAttr[index].coverImageURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                [drawboardCell.coverImage sd_setImageWithURL:[NSURL URLWithString:coverImageURL]];
                drawboardCell.coverImage.contentMode = UIViewContentModeScaleAspectFill;
                
                drawboardCell.drawboardName.text = self.drawboardAttr[index].drawboardName;
                drawboardCell.ownerUserName.text = self.drawboardAttr[index].ownerUserName;
                
                cell = drawboardCell;
            }
            break;
            
        case 3:  //关注用户
            {
                FYUsersCell* userCell = [collectionView dequeueReusableCellWithReuseIdentifier:UsersCell forIndexPath:indexPath];
                
                NSString* userHeadIconURL = [self.attentionUsersAttr[index].userHeadIcon stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                [userCell.userHeadIcon sd_setImageWithURL:[NSURL URLWithString:userHeadIconURL]];
                userCell.userHeadIcon.layer.cornerRadius = (UsersCellWidth - 60) / 2;
                userCell.userHeadIcon.layer.masksToBounds = YES;
                userCell.userName.text = self.attentionUsersAttr[index].userName;
                
                NSString* fansStr = [NSString stringWithFormat:@"%zd 粉丝", self.attentionUsersAttr[index].fansNums];
                userCell.fansNums.text = fansStr;
                
                cell = userCell;
            }
            break;
            
        default:
            break;
    }
    
    cell.layer.cornerRadius = 5;
    cell.layer.masksToBounds = YES;
 
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger index = [indexPath item];
    
    switch (collectionView.tag) {
        case 1:  //兴趣组
        {
            FYInterestGroupDetailController* detail = [[FYInterestGroupDetailController alloc] init];
            detail.interestGroupUnitData = self.interestGroupAttr[index];
            
            [self.navigationController pushViewController:detail animated:NO];
        }
            break;
            
        case 2: //画板
        {
            FYShowDetailDrawboardViewController* dbVC = [[FYShowDetailDrawboardViewController alloc] init];
            dbVC.specifyDrawData = self.drawboardAttr[index];
            dbVC.userName = self.drawboardAttr[index].ownerUserName;
            
            [self.navigationController pushViewController:dbVC animated:YES];
        }
            break;
            
        case 3:  //关注用户
            {
                FYPersonalCenterViewController* pcVC = [[FYPersonalCenterViewController alloc] init];
                pcVC.userName = self.attentionUsersAttr[index].userName;
                
                [self.navigationController pushViewController:pcVC animated:YES];
            }
            break;
            
        default:
            break;
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView.tag == 1 || scrollView.tag == 2 || scrollView.tag == 3) {
        return;
    }
    
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
