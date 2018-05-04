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

//#define InterestGroupSize 100
#define InrstGroupMarginIn 8
#define InrstGroupMarginLeft 10
//#define InrstGroupMarginBottom 20
#define InrstGroupMarginRight 10
//#define MarginTop 10

#define ModuleCell @"ModuleCell"

@interface FYAttentionViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic, retain) NSMutableArray<FYInterestGroupUnitData*>* interestGroupAttr;
@property(nonatomic, retain) NSMutableArray* drawboardAttr;
@property(nonatomic, retain) NSMutableArray* attentionUsersAttr;

@property(nonatomic, retain) UIView* interestGroupBackView;
@property(nonatomic, retain) UIScrollView* drawboardBackView;
@property(nonatomic, retain) UIScrollView* attentionUsersBackView;
@end

@implementation FYAttentionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.frame = CGRectMake(3*ScreenWidth, 0, ScreenWidth, ScreenHeight-SystemHeight);
//    self.view.backgroundColor = [UIColor redColor];
    
    [self loadData];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.view addGestureRecognizer:tap];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 100);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 2;
    
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth,150) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    [collectionView registerNib:[UINib nibWithNibName:@"FYModuleCell" bundle:nil] forCellWithReuseIdentifier:ModuleCell];
    //        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"AA"];
    [self.drawboardBackView addSubview:collectionView];

}

- (void) tapAction{
    
    NSLog(@"tapAction");
    [self.view setNeedsLayout];
}

- (void)viewDidLayoutSubviews{
    
    CGFloat offsetY = 0;
    CGFloat backViewOuterSpacing = 20;
//    CGFloat backViewInnerSpacing = 10;
    
    offsetY += backViewOuterSpacing;
    
    if (self.interestGroupAttr.count) {
    
        [self addInterestGroupBackView:offsetY];
        offsetY += self.interestGroupBackView.bounds.size.height + backViewOuterSpacing;
    }
    
    if (1) { //drawboard
        
        self.drawboardBackView.frame = CGRectMake(0, offsetY, ScreenWidth, 150);
        self.drawboardBackView.backgroundColor = [UIColor greenColor];
        [self.view addSubview:self.drawboardBackView];
        
        offsetY += self.drawboardBackView.bounds.size.height + backViewOuterSpacing;
    }
    
}

- (void) addInterestGroupBackView:(CGFloat)offsetY{
    
    CGFloat backViewInnerSpacing = 10;
    CGFloat interestGroupSize = 120;
    
    UILabel* interestTitle = [[UILabel alloc] init];
    interestTitle.text = @"兴趣";
    interestTitle.font = [UIFont systemFontOfSize:17];
    [interestTitle sizeToFit];
    //        interestTitle.backgroundColor = [UIColor redColor];
    
    UIButton* interestBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [interestBtn setTitle:@"查看全部>" forState:UIControlStateNormal];
    interestBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [interestBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [interestBtn sizeToFit];
    interestBtn.frame = CGRectMake(ScreenWidth-interestBtn.bounds.size.width-backViewInnerSpacing, 0, interestBtn.bounds.size.width, interestTitle.bounds.size.height);
    //        interestBtn.backgroundColor = [UIColor redColor];
    
    UIView* interestGroupTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, interestTitle.bounds.size.height)];
    [interestGroupTitleView addSubview:interestTitle];
    [interestTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(interestGroupTitleView.mas_top).with.offset(0);
        make.left.equalTo(interestGroupTitleView.mas_left).with.offset(backViewInnerSpacing+5);
    }];
    [interestGroupTitleView addSubview:interestBtn];
    //        interestGroupTitleView.backgroundColor = [UIColor yellowColor];
    
    self.interestGroupBackView.frame = CGRectMake(0, offsetY, ScreenWidth, interestGroupSize + backViewInnerSpacing + interestTitle.bounds.size.height);
    self.interestGroupBackView.backgroundColor = [UIColor greenColor];
    [self.interestGroupBackView addSubview:interestGroupTitleView];
    
    UIScrollView* interestGroupScroll = [[UIScrollView alloc] init];
    [self.interestGroupBackView addSubview:interestGroupScroll];
    [interestGroupScroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(interestGroupTitleView.mas_bottom).with.offset(backViewInnerSpacing);
        make.left.equalTo(self.interestGroupBackView.mas_left).with.offset(0);
        make.bottom.equalTo(self.interestGroupBackView.mas_bottom).with.offset(0);
        make.right.equalTo(self.interestGroupBackView.mas_right).with.offset(0);
    }];
    //        interestGroupScroll.backgroundColor = [UIColor yellowColor];
    interestGroupScroll.showsHorizontalScrollIndicator = NO;
    
    CGFloat imageHeight = 0;
    NSInteger i;
    FYInterestGroupUnitData* inrstGroupUnitData;
    for (i = 0; i < self.interestGroupAttr.count; i++)
    {
        inrstGroupUnitData = self.interestGroupAttr[i];
        
        UIView* inrstGroup = [[UIView alloc] init];
        inrstGroup.frame = CGRectMake(InrstGroupMarginLeft + (interestGroupSize+InrstGroupMarginIn) * i, 0, interestGroupSize, interestGroupSize);
        inrstGroup.backgroundColor = [self randomColor];
        inrstGroup.layer.cornerRadius = 15;
        inrstGroup.clipsToBounds = YES;
        [interestGroupScroll addSubview:inrstGroup];
        
        imageHeight = interestGroupSize * inrstGroupUnitData.coverImageHeight / inrstGroupUnitData.coverImageWidth;
        UIImageView* imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, interestGroupSize, imageHeight);
        [imageView sd_setImageWithURL:[NSURL URLWithString:inrstGroupUnitData.coverImageURL]];
        imageView.layer.cornerRadius = 15;
        imageView.layer.masksToBounds = YES;
        [inrstGroup addSubview:imageView];
        
        UILabel* groupName = [[UILabel alloc] initWithFrame:CGRectMake(0, interestGroupSize*2/3, interestGroupSize, interestGroupSize/3)];
        groupName.text = inrstGroupUnitData.interestGroupName;
        groupName.textAlignment = NSTextAlignmentCenter;
        groupName.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.5];
        [inrstGroup addSubview:groupName];
        
        //            inrstGroup.tag = i;
        //            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(interestGroupClicked:)];
        //            [inrstGroup addGestureRecognizer:tap];
    }
    CGFloat tmpWidth = InrstGroupMarginLeft + (interestGroupSize + InrstGroupMarginIn) * (i - 1) + interestGroupSize + InrstGroupMarginRight;
    interestGroupScroll.contentSize = CGSizeMake(tmpWidth, 0);
    
    [self.view addSubview:self.interestGroupBackView];
}

- (void) loadData{
    
#if TEST
    FYInterestGroupUnitData* inrstGroupData1 = [[FYInterestGroupUnitData alloc] init];
    inrstGroupData1.interestGroupName = @"Group1";
    inrstGroupData1.interestGroupDesc = @"description for group1";
    inrstGroupData1.coverImageWidth = 320;
    inrstGroupData1.coverImageHeight = 460;
    [self.interestGroupAttr addObject:inrstGroupData1];
    
    FYInterestGroupUnitData* inrstGroupData2 = [[FYInterestGroupUnitData alloc] init];
    inrstGroupData2.interestGroupName = @"Group2";
    inrstGroupData2.interestGroupDesc = @"description for group2";
    inrstGroupData2.coverImageWidth = 320;
    inrstGroupData2.coverImageHeight = 460;
    [self.interestGroupAttr addObject:inrstGroupData2];
    
    FYInterestGroupUnitData* inrstGroupData3 = [[FYInterestGroupUnitData alloc] init];
    inrstGroupData3.interestGroupName = @"Group3";
    inrstGroupData3.interestGroupDesc = @"description for group3";
    inrstGroupData3.coverImageWidth = 320;
    inrstGroupData3.coverImageHeight = 460;
    [self.interestGroupAttr addObject:inrstGroupData3];
    
    FYInterestGroupUnitData* inrstGroupData4 = [[FYInterestGroupUnitData alloc] init];
    inrstGroupData4.interestGroupName = @"Group4";
    inrstGroupData4.interestGroupDesc = @"description for group4";
    inrstGroupData4.coverImageWidth = 320;
    inrstGroupData4.coverImageHeight = 460;
    [self.interestGroupAttr addObject:inrstGroupData4];
    
    FYInterestGroupUnitData* inrstGroupData5 = [[FYInterestGroupUnitData alloc] init];
    inrstGroupData5.interestGroupName = @"Group5";
    inrstGroupData5.interestGroupDesc = @"description for group5";
    inrstGroupData5.coverImageWidth = 320;
    inrstGroupData5.coverImageHeight = 460;
    [self.interestGroupAttr addObject:inrstGroupData5];
#endif
    
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

- (UIScrollView*) drawboardBackView{
    
    if (_drawboardBackView == nil) {
        _drawboardBackView = [[UIScrollView alloc] init];
    }
    
    return _drawboardBackView;
}

- (UIScrollView*) attentionUsersBackView{
    
    if (_attentionUsersBackView == nil) {
        _attentionUsersBackView = [[UIScrollView alloc] init];
    }
    
    return _attentionUsersBackView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return 10;
}

- (FYModuleCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FYModuleCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:ModuleCell forIndexPath:indexPath];
    
//    cell.backgroundColor = [UIColor grayColor];
    
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor*) randomColor{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}


@end
