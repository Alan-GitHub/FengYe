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
#import "FYCollectionView.h"
#import "FYWorksUnitData.h"
#import "FYCollectionViewWaterFallLayout.h"
#import "FYDisplayCell.h"
#import "FYDrawboardCell.h"

#define FirstCollectionViewCellID @"FirstCollectionViewCellID"
#define SecondCollectionViewCellID @"SecondCollectionViewCellID"
#define ThirdCollectionViewCellID @"ThirdCollectionViewCellID"
#define TableViewCell @"TableViewCell"

#define ControlViewHeight 170

#define HeadIconHeight 60

@interface FYPersonalCenterViewController ()<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, retain) UITableView* gTableView;
@property(nonatomic, retain) UIScrollView* gScroView;
@property(nonatomic, retain) UIView* gPersonInfo;

@property(nonatomic, retain) UIView* gDrawboard;
@property(nonatomic, retain) UIView* gCollection;
@property(nonatomic, retain) UIView* gLike;
@property(nonatomic, retain) UIView* gRegard;
@property(nonatomic, assign) NSInteger gPrevClicked;

@property(nonatomic, retain) NSMutableArray<UIView*>* gMenuAttr;
@property(nonatomic, retain) NSMutableArray<FYCollectionView*>* gPageAttr;

@property(nonatomic, retain) FYCollectionView* gFirstView;
@property(nonatomic, retain) FYCollectionView* gSecondView;
@property(nonatomic, retain) FYCollectionView* gThirdView;
@property(nonatomic, retain) UIScrollView* gFourthView;

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
    
    UIView* controlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ControlViewHeight)];
    controlView.backgroundColor = [UIColor greenColor];
    tableView.tableHeaderView = controlView;
    [self setupControlView: controlView];
    
    //default select the first menu.
    self.gPrevClicked = 0;
    
#if TEST
    [self loadTestData];
#endif
}

#if TEST
-(void) loadTestData{
    
    //collection menu
    FYWorksUnitData* data1 = [[FYWorksUnitData alloc] init];
    
    //data.picURL = @"0.bmp";
    data1.picWidth = 320;
    data1.picHeight = 480;
    data1.uploadTime = 20180201;
    data1.forwardCount = 5;
    data1.likeCount = 5;
    data1.commentCount = 5;
    data1.descriptionText = @"adjflskdlfjlskdioiuoiuoiuojkhkuiouiouuiuijkhkjhgjgjuyuytuytujhkl";
    //data.headIcon = @"/Users/alanturing/Desktop/FengYe/FengYe/TestImage/1.bmp";
    data1.templateName = @"ss";
    data1.owner = @"alan";
    [self.gCollectionUnitAttr addObject:data1];
    
    FYWorksUnitData* data2 = [[FYWorksUnitData alloc] init];
    
    //data.picURL = @"0.bmp";
    data2.picWidth = 320;
    data2.picHeight = 480;
    data2.uploadTime = 20180201;
    data2.forwardCount = 5;
    data2.likeCount = 5;
    data2.commentCount = 5;
    data2.descriptionText = @"adjflskdlfjlskdioiuoiuoiuojkhkuiouiouuiuijkhkjhgjgjuyuytuytujhkl";
    //data.headIcon = @"/Users/alanturing/Desktop/FengYe/FengYe/TestImage/1.bmp";
    data2.templateName = @"ss";
    data2.owner = @"alan";
    [self.gCollectionUnitAttr addObject:data2];
    
    FYWorksUnitData* data3 = [[FYWorksUnitData alloc] init];
    
    //data.picURL = @"0.bmp";
    data3.picWidth = 320;
    data3.picHeight = 480;
    data3.uploadTime = 20180201;
    data3.forwardCount = 5;
    data3.likeCount = 5;
    data3.commentCount = 5;
    data3.descriptionText = @"adjflskdlfjlskdioiuoiuoiuojkhkuiouiouuiuijkhkjhgjgjuyuytuytujhkl";
    //data.headIcon = @"/Users/alanturing/Desktop/FengYe/FengYe/TestImage/1.bmp";
    data3.templateName = @"ss";
    data3.owner = @"alan";
    [self.gCollectionUnitAttr addObject:data3];

    
    //like menu
    FYWorksUnitData* data4 = [[FYWorksUnitData alloc] init];
    
    //data.picURL = @"0.bmp";
    data4.picWidth = 320;
    data4.picHeight = 480;
    data4.uploadTime = 20180201;
    data4.forwardCount = 5;
    data4.likeCount = 5;
    data4.commentCount = 5;
    data4.descriptionText = @"adjflskdlfjlskdioiuoiuoiuojkhkuiouiouuiuijkhkjhgjgjuyuytuytujhkl";
    //data.headIcon = @"/Users/alanturing/Desktop/FengYe/FengYe/TestImage/1.bmp";
    data4.templateName = @"ss";
    data4.owner = @"alan";
    [self.gLikeUnitAttr addObject:data4];
    
    FYWorksUnitData* data5 = [[FYWorksUnitData alloc] init];
    
    //data.picURL = @"0.bmp";
    data5.picWidth = 320;
    data5.picHeight = 480;
    data5.uploadTime = 20180201;
    data5.forwardCount = 5;
    data5.likeCount = 5;
    data5.commentCount = 5;
    data5.descriptionText = @"adjflskdlfjlskdioiuoiuoiuojkhkuiouiouuiuijkhkjhgjgjuyuytuytujhkl";
    //data.headIcon = @"/Users/alanturing/Desktop/FengYe/FengYe/TestImage/1.bmp";
    data5.templateName = @"ss";
    data5.owner = @"alan";
    [self.gLikeUnitAttr addObject: data5];
}
#endif

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
    [imageView setImage:[UIImage imageNamed:@"defaultUserIcon"]];
    imageView.layer.cornerRadius = HeadIconHeight/2;
    imageView.layer.masksToBounds = YES;
    
    //name label
    UILabel* username = [[UILabel alloc] init];
    [personInfo addSubview:username];
    [username mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_top).with.offset(5);
        make.left.equalTo(imageView.mas_right).with.offset(10);
    }];
    username.text = @"username";
    username.font = [UIFont systemFontOfSize:20];
    [username sizeToFit];
    
    //fans
    UILabel* fans = [[UILabel alloc] init];
    [personInfo addSubview:fans];
    [fans mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(imageView.mas_bottom).with.offset(-5);
        make.left.equalTo(imageView.mas_right).with.offset(10);
    }];
    fans.text = @"2 fans >";
    fans.font = [UIFont systemFontOfSize:13];
    [fans sizeToFit];
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
    drawboardNums.text = @"1";
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
    collectionNums.text = @"2";
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
    likeNums.text = @"3";
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
    UIView* regard = [[UIView alloc] init];
    [fourLabelBackView addSubview:regard];
    [regard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fourLabelBackView.mas_top).with.offset(0);
        make.left.equalTo(like.mas_right).with.offset(labelSpacing*2);
        make.bottom.equalTo(fourLabelBackView.mas_bottom).with.offset(0);
        make.width.mas_equalTo(labelWidth);
    }];
    regard.backgroundColor = [UIColor clearColor];
    self.gRegard = regard;
    [self.gMenuAttr addObject:regard];
    
    UITapGestureRecognizer* tapRegard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    regard.tag = 3;
    [regard addGestureRecognizer:tapRegard];
    
    UILabel* regardNums = [[UILabel alloc] init];
    [regard addSubview:regardNums];
    [regardNums mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(regard.mas_top).with.offset(0);
        make.left.equalTo(regard.mas_left).with.offset(0);
        make.right.equalTo(regard.mas_right).with.offset(0);
        make.height.mas_equalTo(regard.mas_height).multipliedBy(0.5);
    }];
    regardNums.backgroundColor = [UIColor clearColor];
    regardNums.text = @"4";
    regardNums.textAlignment = NSTextAlignmentCenter;
    
    UILabel* regardTitle = [[UILabel alloc] init];
    [regard addSubview:regardTitle];
    [regardTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(collectionNums.mas_bottom).with.offset(0);
        make.left.equalTo(regard.mas_left).with.offset(0);
        make.right.equalTo(regard.mas_right).with.offset(0);
        make.bottom.equalTo(regard.mas_bottom).with.offset(0);
    }];
    regardTitle.backgroundColor = [UIColor clearColor];
    regardTitle.text = @"关注";
    regardTitle.font = [UIFont systemFontOfSize:13];
    regardTitle.textAlignment = NSTextAlignmentCenter;
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

- (void) addViewToScrollView:(NSInteger) index{
    
    if (index == 3) {
        [self.gScroView addSubview:self.gFourthView];
        
//#if TEST
//        if (HasRegardInterestGroup) {
//            <#statements#>
//        }
//#endif
        
        return;
    }
    
    UIView* goalView = self.gPageAttr[index];
    
    for (int i = 0; i < self.gScroView.subviews.count; i++) {
        
        if ([goalView isEqual:self.gScroView.subviews[i]]) {
            
            return;
        }
    }
    goalView.frame = CGRectMake(ScreenWidth*index, 0, ScreenWidth, self.gScroView.bounds.size.height);
    [self.gScroView addSubview:goalView];
}

- (NSMutableArray*) gMenuAttr{
    
    if (!_gMenuAttr) {
        _gMenuAttr = [NSMutableArray array];
    }
    
    return _gMenuAttr;
}

- (NSMutableArray*) gPageAttr{
    
    if (!_gPageAttr) {
        _gPageAttr = [NSMutableArray array];
    }
    
    return _gPageAttr;
}

- (NSMutableArray*) gCollectionUnitAttr{
    
    if (!_gCollectionUnitAttr) {
        _gCollectionUnitAttr = [NSMutableArray array];
    }
    
    return _gCollectionUnitAttr;
}

- (NSMutableArray*) gLikeUnitAttr{
    
    if (!_gLikeUnitAttr) {
        _gLikeUnitAttr = [NSMutableArray array];
    }
    
    return _gLikeUnitAttr;
}

- (FYCollectionView*) gFirstView{
    
    if (!_gFirstView) {
        
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = DrawboardLayoutRowMargin;
        layout.minimumInteritemSpacing = DrawboardLayoutColMargin;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        
        _gFirstView = [[FYCollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-SystemHeight) collectionViewLayout:layout];
        _gFirstView.backgroundColor = [UIColor clearColor];
        _gFirstView.tag = 0;
        //[_gFirstView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:FirstCollectionViewCellID];
        [_gFirstView registerNib:[UINib nibWithNibName:@"FYDrawboardCell" bundle:nil] forCellWithReuseIdentifier:FirstCollectionViewCellID];
        _gFirstView.mainVC = self;
    }
    
    return _gFirstView;
}

- (FYCollectionView*) gSecondView{
    
    if (!_gSecondView) {
        
        FYCollectionViewWaterFallLayout* layout = [[FYCollectionViewWaterFallLayout alloc] init];
        layout.data = self.gCollectionUnitAttr;
        
        _gSecondView = [[FYCollectionView alloc] initWithFrame:CGRectMake(ScreenWidth, 0, ScreenWidth, ScreenHeight-SystemHeight) collectionViewLayout:layout];
        _gSecondView.backgroundColor = [UIColor clearColor];
        _gSecondView.tag = 1;
        //[_gSecondView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:SecondCollectionViewCellID];
        [_gSecondView registerNib:[UINib nibWithNibName:@"FYDisplayCell" bundle:nil] forCellWithReuseIdentifier:SecondCollectionViewCellID];
        _gSecondView.mainVC = self;
    }
    
    return _gSecondView;
}

- (FYCollectionView*) gThirdView{
    
    if (!_gThirdView) {
        
        FYCollectionViewWaterFallLayout* layout = [[FYCollectionViewWaterFallLayout alloc] init];
        layout.data = self.gLikeUnitAttr;
        
        _gThirdView = [[FYCollectionView alloc] initWithFrame:CGRectMake(2*ScreenWidth, 0, ScreenWidth, ScreenHeight-SystemHeight) collectionViewLayout:layout];
        _gThirdView.backgroundColor = [UIColor clearColor];
        _gThirdView.tag = 2;
        //[_gThirdView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:ThirdCollectionViewCellID];
        [_gThirdView registerNib:[UINib nibWithNibName:@"FYDisplayCell" bundle:nil] forCellWithReuseIdentifier:ThirdCollectionViewCellID];
        _gThirdView.mainVC = self;
    }
    
    return _gThirdView;
}

- (UIScrollView*) gFourthView{
    
    if (!_gFourthView) {
        _gFourthView = [[UIScrollView alloc] initWithFrame:CGRectMake(3*ScreenWidth, 0, ScreenWidth, ScreenHeight-SystemHeight)];
        _gFourthView.backgroundColor = [UIColor orangeColor];
    }
    
    return _gFourthView;
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
    [self.gScroView addSubview:self.gFirstView];
    [cell addSubview:self.gScroView];

    [self.gPageAttr addObject:self.gFirstView];
    [self.gPageAttr addObject:self.gSecondView];
    [self.gPageAttr addObject:self.gThirdView];
//    [self.gPageAttr addObject:self.gFourthView];

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
    NSInteger index = [FYCollectionView whichScroll];
    FYCollectionView* isScrolling;
    if (self.gPageAttr.count != 0) {
        isScrolling = [self.gPageAttr objectAtIndex:index];
    } else{
        isScrolling = self.gFirstView;
    }
    
    if (isScrolling.offsetType == OffsetTypeMin) { }
    
    if (isScrolling.offsetType == OffsetTypeCenter) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, scrollView.contentSize.height-scrollView.bounds.size.height + SystemBottomHeight);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
