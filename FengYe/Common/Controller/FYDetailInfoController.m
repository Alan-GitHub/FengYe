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
#import "UIView+Frame.h"
#import "FYPersonalCenterViewController.h"
#import "FYClickLikeViewController.h"
#import "FYSelectDrawNameViewController.h"
#import "FYClickForwardViewController.h"
#import "FYClickCommentViewController.h"


#define CollectionViewCellID @"CollectionViewCellID"

@interface FYDetailInfoController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) UIImageView* image;
@property(nonatomic, strong) NSMutableArray<FYWorksUnitData*>* worksUnitArrDetail;
@property(nonatomic, strong) UICollectionView* collectionView;

@property(nonatomic, retain) UILabel* gLikeLabel;
@property(nonatomic, retain) UILabel* gForwardLabel;

//为了采集图片功能
@property(nonatomic, retain) NSMutableArray<NSString*>* drawName;
@end

@implementation FYDetailInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addLikeAndCollecBtn];

    CGFloat offsetY = 0;
    CGFloat spacing = 10;
    
    UIView* detailView = [[UIView alloc] init];
    detailView.backgroundColor = [UIColor whiteColor];
    [self.collectionView addSubview:detailView];

    //works image
    NSInteger imageHeight = ScreenWidth * self.unitData.picHeight/self.unitData.picWidth;
    
    UIImageView* imageview = [[UIImageView alloc] init];
    imageview.frame = CGRectMake(0, offsetY, ScreenWidth, imageHeight);
    [imageview sd_setImageWithURL:[NSURL URLWithString:self.unitData.picURL] completed:nil];
    [detailView addSubview:imageview];
    
    offsetY += imageHeight + spacing;
    
    //works description text
    UILabel* label = [self getDescriptionLabel:self.unitData.descriptionText];
    label.frame = CGRectMake(0, offsetY, ScreenWidth, label.bounds.size.height);
    [detailView addSubview: label];
    
    offsetY += label.bounds.size.height;
    
    //forward/like/comment
    UIView* worksOperView = [self getWorksOperView: self.unitData];
    worksOperView.frame = CGRectMake(0, offsetY, ScreenWidth, worksOperView.bounds.size.height);
    [detailView addSubview:worksOperView];
    
    offsetY += worksOperView.bounds.size.height;

    //作品所属的用户信息
    UIView* worksOwnerInfo = [self getWorksOwnerInfo:self.unitData];
    worksOwnerInfo.frame = CGRectMake(0, offsetY, ScreenWidth, worksOwnerInfo.bounds.size.height);
    [detailView addSubview:worksOwnerInfo];

    offsetY += worksOwnerInfo.bounds.size.height;
    
    //评论框  点击整个colle下移的问题暂时无法解决。  先去掉
//    UITextField* textF = [[UITextField alloc] initWithFrame:CGRectMake(spacing, offsetY, ScreenWidth - spacing*2, 40)];
//    textF.placeholder = @"发表评论...";
//    textF.backgroundColor = [UIColor yellowColor];
//    [detailView addSubview:textF];
//    offsetY += textF.bounds.size.height + spacing;
    
    
    //推荐采集 四个字标题
    if (self.hasRecommend) {
        
        UILabel* recomColle = [[UILabel alloc] init];
        recomColle.text = @"推荐采集";
        recomColle.font = [UIFont systemFontOfSize:13];
        recomColle.backgroundColor = [UIColor clearColor];
        [recomColle sizeToFit];
        
        UIView* recomColleView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, ScreenWidth, recomColle.bounds.size.height + 2*spacing)];
        recomColleView.backgroundColor = MainBackgroundColor;
        [recomColleView addSubview:recomColle];
        [recomColle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(recomColleView.mas_bottom).with.offset(0);
            make.left.equalTo(recomColleView.mas_left).with.offset(spacing);
        }];
        [detailView addSubview:recomColleView];
        offsetY += recomColleView.bounds.size.height;
    } else{
        
        UIView* fillView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, ScreenWidth, 100)];
        fillView.backgroundColor = MainBackgroundColor;
        [detailView addSubview:fillView];
        offsetY += fillView.bounds.size.height;
    }

    detailView.frame = CGRectMake(0, -offsetY, ScreenWidth, offsetY);
    
    //edgeInset
    self.collectionView.contentInset = UIEdgeInsetsMake(offsetY, 0, 0, 0);
    //此处可以解决一个bug -- inset.top超过一定值时，top上面的一部分在刚进入该页面时将不会显示出来
    self.collectionView.contentOffset = CGPointMake(0, -offsetY);
    [self.view addSubview:self.collectionView];
    
    //加载数据
    if (self.hasRecommend) {
        
        [self loadData];
    }
    
}

- (void) addLikeAndCollecBtn{
    
    //喜欢按钮
    UIButton *likeBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    [likeBtn setTitle:@"♡" forState:UIControlStateNormal];
    [likeBtn setTitle:@"❤️" forState:UIControlStateSelected];
    [likeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [likeBtn sizeToFit];
    likeBtn.tag = 1;
    [likeBtn addTarget:self action:@selector(LikeBtnClicked:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem  *likeBarBtn = [[UIBarButtonItem alloc] initWithCustomView: likeBtn];
    
    //采集按钮
    UIButton *collecBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    [collecBtn setTitle:@"采集" forState:UIControlStateNormal];
    collecBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [collecBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    collecBtn.backgroundColor = [UIColor redColor];
    [collecBtn sizeToFit];
    collecBtn.tag = 2;
    [collecBtn addTarget:self action:@selector(collecBtnClicked:) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem  *collecBarBtn = [[UIBarButtonItem alloc] initWithCustomView: collecBtn];
 
    self.navigationItem.rightBarButtonItems = @[collecBarBtn, likeBarBtn];
}

- (void) LikeBtnClicked:(UIButton*) btn{
    
    //切换喜欢按钮的状态
    btn.selected = !btn.selected;
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"OPERATION_WORKS_LIKEORNOT";
    parameters[@"biz"] = @"111";
    parameters[@"time"] = @"20180126225600";
    
    NSMutableDictionary* paramData = [NSMutableDictionary dictionary];
    //取得当前作品的数据库路径
    NSRange range = [self.unitData.picURL rangeOfString:@"photo/"];
    NSString* pictureUrl = [self.unitData.picURL substringFromIndex:(range.location + range.length)];
    paramData[@"path"] = pictureUrl;
    
    //拿到当前登录用户的用户名
    NSUserDefaults* userDef = [NSUserDefaults standardUserDefaults];
    NSString* username = [userDef objectForKey:@"loginName"];
    paramData[@"username"] = username;
    
    if (btn.selected) {
        paramData[@"isLike"] = @"yes";
    }else{
        paramData[@"isLike"] = @"no";
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
            
            NSInteger ret = [responseObject[@"retValue"] integerValue];
            NSInteger likeNum = [responseObject[@"likeNum"] integerValue];
            
            //更新数据库成功，应该接着更新UI
            if (1 == ret) {
                NSString* loveTxt = likeNum > 0 ? [NSString stringWithFormat:@"%zd", likeNum] : @"";
                self.gLikeLabel.text = loveTxt;
            }
        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}

- (void) collecBtnClicked:(UIButton*) btn{
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    
    parameters[@"ver"] = @"1";
    parameters[@"service"] = @"OPERATION_WORKS_COLLECTION_SELECT_DRAWNAME";
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
            //NSLog(@"Reply JSON: %@", responseObject);
            
            [self.drawName removeAllObjects];
            [self.drawName addObjectsFromArray: responseObject[@"drawName"]];
            
            //弹出画板名选择界面
            FYSelectDrawNameViewController* select = [[FYSelectDrawNameViewController alloc] init];
            select.modalPresentationStyle = UIModalPresentationCustom;
            select.drawName = self.drawName;
            select.picURL = self.unitData.picURL;
            select.picDesc = self.unitData.descriptionText;
            select.originUserName = self.unitData.owner;
            select.originDrawName = self.unitData.templateName;
            select.updateForwardNum = ^(NSInteger forwardNum) {
                NSString* zhuanCaiTxt = forwardNum > 0 ? [NSString stringWithFormat:@"%zd", forwardNum] : @"";
                self.gForwardLabel.text = zhuanCaiTxt;
            };
            [self presentViewController:select animated:YES completion:nil];

        } else{
            NSLog(@"Error: %@, %@, %@", error, response, responseObject);
        }
    }] resume];
}


//有画板封面
- (UIView*) getWorksOwnerInfo:(FYWorksUnitData*) unitData{
    
    CGFloat spacing = 10;
    CGFloat offsetY = 0;
    
    UIView* worksOwnerInfo = [[UIView alloc] init];
//    worksOwnerInfo.backgroundColor = [UIColor greenColor];
    
    offsetY += spacing;
    
    //用户头像
    UIImageView* headView = [[UIImageView alloc] initWithFrame:CGRectMake(spacing, offsetY, CellHeadIconRadius*2, CellHeadIconRadius*2)];
    headView.backgroundColor = [UIColor greenColor];
    [headView sd_setImageWithURL:[NSURL URLWithString:unitData.headIcon] completed:nil];
    headView.layer.cornerRadius = CellHeadIconRadius;
    headView.layer.masksToBounds = YES;
    [worksOwnerInfo addSubview:headView];
    
    //给用户头像添加点击事件
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHeadIcon:)];
    [headView addGestureRecognizer:tap];
    headView.userInteractionEnabled = YES;
    
    //用户名
    UILabel* username = [[UILabel alloc] init];
    username.text = unitData.owner;
    username.font = [UIFont systemFontOfSize:13];
    username.textAlignment = NSTextAlignmentCenter;
    [username sizeToFit];
    [worksOwnerInfo addSubview:username];
    username.fy_x = headView.fy_x + headView.bounds.size.width + spacing;
    username.fy_centerY = headView.fy_centerY;
    
    offsetY += headView.bounds.size.height + spacing;
    
    //画板模块(画板封面图片)
    UIImageView* drawbCover = [[UIImageView alloc] initWithFrame:CGRectMake(spacing, offsetY, CellHeadIconRadius*2, CellHeadIconRadius*2)];
    drawbCover.backgroundColor = [UIColor greenColor];
    [drawbCover sd_setImageWithURL:[NSURL URLWithString:unitData.headIcon] completed:nil];
    drawbCover.layer.cornerRadius = 5;
    drawbCover.layer.masksToBounds = YES;
    [worksOwnerInfo addSubview:drawbCover];

    
    //画板名
    UILabel* templateName = [[UILabel alloc] init];
    templateName.text = unitData.templateName;
    templateName.font = [UIFont systemFontOfSize:13];
    templateName.textAlignment = NSTextAlignmentCenter;
    [templateName sizeToFit];
    [worksOwnerInfo addSubview:templateName];
    templateName.fy_x = drawbCover.fy_x + drawbCover.bounds.size.width + spacing;
    templateName.fy_centerY = drawbCover.fy_centerY;
    
    offsetY += drawbCover.bounds.size.height + spacing;
    worksOwnerInfo.bounds = CGRectMake(0, 0, ScreenWidth, offsetY);
    
    return worksOwnerInfo;
}

- (UIView*) getWorksOperView:(FYWorksUnitData*) unitData{
    
    UIView* worksOperView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];

    //time
    UILabel* time = [[UILabel alloc] init];
    time.text = [NSString stringWithFormat:@"%zd", unitData.uploadTime];
    [time sizeToFit];
    [worksOperView addSubview:time];

    time.font = [UIFont systemFontOfSize:13];
    time.textAlignment = NSTextAlignmentCenter;

    [time mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(worksOperView).with.offset(0);
        make.left.equalTo(worksOperView).with.offset(5);
        make.bottom.equalTo(worksOperView).with.offset(0);
    }];
    
    //forward
    UIView* forwardView = [[UIView alloc] init];
    [worksOperView addSubview:forwardView];
    [forwardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(time.mas_right).with.offset(20);
        make.top.equalTo(worksOperView).with.offset(0);
        make.bottom.equalTo(worksOperView).with.offset(0);
    }];

    UIButton* forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [forwardBtn setImage:[UIImage imageNamed:@"mainCellShare"] forState:UIControlStateNormal];
    [forwardBtn sizeToFit];
    forwardBtn.tag = 2;
    [forwardBtn addTarget:self action:@selector(worksOperBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [forwardView addSubview:forwardBtn];
    [forwardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(forwardView).with.offset(0);
        make.left.equalTo(forwardView).with.offset(0);
        make.bottom.equalTo(forwardView).with.offset(0);
    }];

    UILabel* forwardLabel = [[UILabel alloc] init];
    
    //转采数量
    NSString* zhuanCaiTxt = unitData.forwardCount > 0 ? [NSString stringWithFormat:@"%zd", unitData.forwardCount] : @"";
    forwardLabel.text = zhuanCaiTxt;
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
    self.gForwardLabel = forwardLabel;

    //like
    UIView* likeView = [[UIView alloc] init];
    [worksOperView addSubview:likeView];
    [likeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(forwardView.mas_right).with.offset(20);
        make.top.equalTo(worksOperView).with.offset(0);
        make.bottom.equalTo(worksOperView).with.offset(0);
    }];

    UIButton* likeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [likeBtn setImage:[UIImage imageNamed:@"mainCellDing"] forState:UIControlStateNormal];
    [likeBtn sizeToFit];
    likeBtn.tag = 3;
    [likeBtn addTarget:self action:@selector(worksOperBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [likeView addSubview:likeBtn];
    [likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(likeView).with.offset(0);
        make.left.equalTo(likeView).with.offset(0);
        make.bottom.equalTo(likeView).with.offset(0);
    }];

    UILabel* likeLabel = [[UILabel alloc] init];
    
    //喜欢数量
    NSString* loveTxt = unitData.likeCount > 0 ? [NSString stringWithFormat:@"%zd", unitData.likeCount] : @"";
    likeLabel.text = loveTxt;
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
    self.gLikeLabel = likeLabel;
    
    //comment
    UIView* commentView = [[UIView alloc] init];
    [worksOperView addSubview:commentView];
    [commentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(likeView.mas_right).with.offset(20);
        make.top.equalTo(worksOperView).with.offset(0);
        make.bottom.equalTo(worksOperView).with.offset(0);
    }];
    
    UIButton* commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentBtn setImage:[UIImage imageNamed:@"mainCellComment"] forState:UIControlStateNormal];
    [commentBtn sizeToFit];
    commentBtn.tag = 4;
    [commentBtn addTarget:self action:@selector(worksOperBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [commentView addSubview:commentBtn];
    [commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(commentView).with.offset(0);
        make.left.equalTo(commentView).with.offset(0);
        make.bottom.equalTo(commentView).with.offset(0);
    }];
    
    UILabel* commentLabel = [[UILabel alloc] init];
    
    //评论数量
    NSString* commentTxt = unitData.commentCount > 0 ? [NSString stringWithFormat:@"%zd", unitData.commentCount] : @"";
    commentLabel.text = commentTxt;
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

- (void) worksOperBtnClicked:(UIButton*) btn{

    switch (btn.tag) {
        case 2: //点击了转发按钮
            {
                //
                FYClickForwardViewController* forwardVC = [[FYClickForwardViewController alloc] init];
                forwardVC.ownUsername = self.unitData.owner;
                forwardVC.ownDrawName = self.unitData.templateName;
                forwardVC.picPath = self.unitData.picURL;
                [self.navigationController pushViewController:forwardVC animated:YES];
                
            }
            break;
            
        case 3: //点击了喜欢按钮
            {
                //取得当前作品的数据库路径
                NSRange range = [self.unitData.picURL rangeOfString:@"photo/"];
                NSString* path = [self.unitData.picURL substringFromIndex:(range.location + range.length)];

                FYClickLikeViewController* clickLikeVC = [[FYClickLikeViewController alloc] init];
                clickLikeVC.picPath = path;
                [self.navigationController pushViewController:clickLikeVC animated:YES];
            }
            break;
            
        case 4: //点击了评论按钮
        {
            FYClickCommentViewController* clickCommentVC = [[FYClickCommentViewController alloc] init];
            clickCommentVC.ownUsername = self.unitData.owner;
            clickCommentVC.ownDrawName = self.unitData.templateName;
            clickCommentVC.picPath = self.unitData.picURL;
            [self.navigationController pushViewController:clickCommentVC animated:YES];
        }
            break;
            
        default:
            break;
    }
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

- (void) tapHeadIcon:(UITapGestureRecognizer*) gesture{
    
    FYPersonalCenterViewController* pcVC = [[FYPersonalCenterViewController alloc] init];
    pcVC.userName = self.unitData.owner;
    
    [self.navigationController pushViewController:pcVC animated:YES];
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

//懒加载
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

- (NSMutableArray<NSString*>*) drawName{
    
    if (!_drawName) {
        
        _drawName = [NSMutableArray<NSString*> array];
    }
    
    return _drawName;
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

    return self.worksUnitArrDetail.count;
}

- (FYDisplayCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FYDisplayCell* cell = (FYDisplayCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellID forIndexPath:indexPath];

    [cell.workImage sd_setImageWithURL:[NSURL URLWithString:self.worksUnitArrDetail[indexPath.item].picURL] completed:nil];
    cell.zhuanCaiLabel.text = [NSString stringWithFormat:@"%zd", self.worksUnitArrDetail[indexPath.item].forwardCount];
    cell.loveLabel.text = [NSString stringWithFormat:@"%zd", self.worksUnitArrDetail[indexPath.item].likeCount];
    cell.commentLabel.text = [NSString stringWithFormat:@"%zd", self.worksUnitArrDetail[indexPath.item].commentCount];
    
    cell.descriptionLabel.text = self.worksUnitArrDetail[indexPath.item].descriptionText;
    [cell setNeedsLayout];
    [cell.headerIcon sd_setImageWithURL:[NSURL URLWithString:self.worksUnitArrDetail[indexPath.item].headIcon] completed:nil];
    cell.usernameLabel.text = self.worksUnitArrDetail[indexPath.item].owner;
    cell.workModuleLabel.text = self.worksUnitArrDetail[indexPath.item].templateName;
    
    //re-layout
    [cell layoutIfNeeded];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    FYDetailInfoController* detail = [[FYDetailInfoController alloc] init];
    detail.unitData = self.worksUnitArrDetail[indexPath.item];
    detail.hasRecommend = YES;
    
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
