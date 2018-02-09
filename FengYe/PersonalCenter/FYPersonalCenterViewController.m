//
//  FYPersonalCenterViewController.m
//  FengYe
//
//  Created by Alan Turing on 2017/12/10.
//  Copyright © 2017年 Alan Turing. All rights reserved.
//

#import "FYPersonalCenterViewController.h"
#import "CommonAttr.h"
#import "FYPersonalCenterHeader.h"
#import "FYDisplayCell.h"
#import "FYCollectionViewWaterFallLayout.h"

#define topHeaderHeight 167
#define CollectionViewCellID @"CollectionViewCellID"

#define LayoutSpacing 10

#define SpacingV  10
#define DrawBoardColumnHeight 50
#define DrawBoardScrollHeight 170
#define UserColumnHeight 50
#define UserScrollHeight 170

@interface FYPersonalCenterViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic, retain) FYPersonalCenterHeader* topHeader;

@property(nonatomic, retain, readwrite) UICollectionView* collectionView;

@property(nonatomic, retain, readwrite) UICollectionViewFlowLayout* flowLayout;
@property(nonatomic, retain, readwrite) FYCollectionViewWaterFallLayout* waterFallLayout;

@property(nonatomic, strong) NSMutableArray* imageName;
@property(nonatomic, strong) NSMutableArray* imageLike;
@property(nonatomic, strong) NSMutableArray* imageColle;
@property(nonatomic, strong) NSMutableArray* attentionDrawBoard;
@property(nonatomic, strong) NSMutableArray* attentionUser;


@property(nonatomic, retain) UIScrollView* attentionBackView;
@property(nonatomic, retain) UIView* drawBoardColumn;
@property(nonatomic, retain) UIScrollView* drawBoardScroll;
@property(nonatomic, retain) UIView* userColumn;
@property(nonatomic, retain) UIScrollView* userScroll;



@end

@implementation FYPersonalCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor yellowColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(personalCenterBtnClick:) name:@"FYPersonalCenterBtnClick" object:nil];
    
    //collectionView
    [self.view addSubview:self.collectionView];
    
    self.topHeader = [[NSBundle mainBundle] loadNibNamed:@"FYPersonalCenterHeader" owner:nil options:nil].firstObject;
    self.topHeader.backgroundColor = [UIColor redColor];
    self.topHeader.frame = CGRectMake(0, -topHeaderHeight, ScreenWidth, topHeaderHeight);
    [self.collectionView addSubview:self.topHeader];
    [self.topHeader initBtn];
    
    
    [self addNavigationBtn];
    
    for (int i = 0; i < 15; i++) {
        NSString* imageStr = [NSString stringWithFormat:@"%d.bmp",i];
        [self.imageLike addObject:imageStr];
    }
    
    for (int i = 0; i < 15; i++) {
        NSString* imageStr = [NSString stringWithFormat:@"3.bmp"];
        [self.imageName addObject:imageStr];
    }
    
    for (int i = 0; i < 15; i++) {
        NSString* imageStr = [NSString stringWithFormat:@"%d.bmp",14-i];
        [self.imageColle addObject:imageStr];
    }
    
    for (int i = 0; i < 3; i++) {
        NSString* imageStr = [NSString stringWithFormat:@"8.bmp"];
        [self.attentionDrawBoard addObject:imageStr];
    }
    
    
}

//懒加载
- (NSMutableArray*) imageName{
    if(!_imageName){
        _imageName = [NSMutableArray array];
    }
    
    return _imageName;
}

- (NSMutableArray*) imageLike{
    if(!_imageLike){
        _imageLike = [NSMutableArray array];
    }
    
    return _imageLike;
}

- (NSMutableArray*) imageColle{
    if(!_imageColle){
        _imageColle = [NSMutableArray array];
    }
    
    return _imageColle;
}

- (NSMutableArray*) attentionDrawBoard{
    if(!_attentionDrawBoard){
        _attentionDrawBoard = [NSMutableArray array];
    }
    
    return _attentionDrawBoard;
}

- (NSMutableArray*) attentionUser{
    if(!_attentionUser){
        _attentionUser = [NSMutableArray array];
    }
    
    return _attentionUser;
}

- (UIScrollView*) attentionBackView{

    if (!_attentionBackView) {
        _attentionBackView = [[UIScrollView alloc] init];
//        _attentionBackView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight-topHeaderHeight-SystemBarHeight-NavigationBarHeight);
        _attentionBackView.frame = self.collectionView.bounds;
        _attentionBackView.contentInset = UIEdgeInsetsMake(topHeaderHeight+SystemBarHeight+NavigationBarHeight, 0, 0, 0);
//        _attentionBackView.backgroundColor = [UIColor greenColor];
    }

    return _attentionBackView;
}

- (UICollectionView*) collectionView{
    if(!_collectionView){
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
        _collectionView.contentInset = UIEdgeInsetsMake(topHeaderHeight, 0, 0, 0);
        _collectionView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
//        _collectionView.backgroundColor = [UIColor blueColor];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
//        [_collectionView registerClass:[FYDisplayCell class] forCellWithReuseIdentifier:CollectionViewCellID];
        [_collectionView registerNib:[UINib nibWithNibName:@"FYDisplayCell" bundle:nil] forCellWithReuseIdentifier:CollectionViewCellID];
    }
    
    return _collectionView;
}

- (UICollectionViewFlowLayout*) flowLayout{
    if (!_flowLayout) {
        
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = LayoutSpacing;
        _flowLayout.minimumInteritemSpacing = LayoutSpacing;
        _flowLayout.sectionInset = UIEdgeInsetsMake(LayoutSpacing, LayoutSpacing, LayoutSpacing, LayoutSpacing);
    }
    
    return _flowLayout;
}

- (UICollectionViewFlowLayout*) waterFallLayout{
    if (!_waterFallLayout) {
        
        _waterFallLayout = [[FYCollectionViewWaterFallLayout alloc] init];
        _waterFallLayout.data = self.imageLike;
    }
    
    return _waterFallLayout;
}

- (UIView*)drawBoardColumn{
    
    if (!_drawBoardColumn) {
        
        CGFloat drawBoardColumnY = SpacingV;
        self.drawBoardColumn = [[UIView alloc] initWithFrame:CGRectMake(0, drawBoardColumnY, ScreenWidth, DrawBoardColumnHeight)];
//        self.drawBoardColumn.backgroundColor = [UIColor blueColor];
        
        UILabel* label1 = [[UILabel alloc] init];
        label1.text = @"画板";
//        label1.backgroundColor = [UIColor redColor];
        label1.frame = CGRectMake(0, 0, 70, DrawBoardColumnHeight);
        label1.textAlignment = NSTextAlignmentCenter;
        
        UILabel* label2 = [[UILabel alloc] init];
        label2.text = @"查看全部 >";
//        label2.backgroundColor = [UIColor redColor];
        label2.frame = CGRectMake(ScreenWidth - 100, 0, 100, DrawBoardColumnHeight);
        label2.textAlignment = NSTextAlignmentCenter;
        
        [self.drawBoardColumn addSubview:label1];
        [self.drawBoardColumn addSubview:label2];
    }
    
    return _drawBoardColumn;
}

- (UIScrollView*)drawBoardScroll{
    
    int i = 0;
    if (!_drawBoardScroll) {
        
        CGFloat drawBoardScrollY = SpacingV + DrawBoardColumnHeight + SpacingV;
        _drawBoardScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, drawBoardScrollY, ScreenWidth, DrawBoardScrollHeight)];
        
        for (i=0; i<self.attentionDrawBoard.count; i++) {
                  
            UIView* element = [self drawBoardElement];
            element.frame = CGRectMake(SpacingV+(SpacingV+ScreenWidth/3)*i, 0, ScreenWidth/3, DrawBoardScrollHeight);
            [_drawBoardScroll addSubview: element];
        }
        
        _drawBoardScroll.showsHorizontalScrollIndicator = NO;
        _drawBoardScroll.contentSize = CGSizeMake((SpacingV + ScreenWidth/3)*i + SpacingV, 0);
        
    }
    
    //需要处理数据的更新显示问题
    
    return _drawBoardScroll;
}


- (UIView*)userColumn{
    
    if (!_userColumn) {
        
        CGFloat userColumnY = SpacingV + DrawBoardColumnHeight + SpacingV + DrawBoardScrollHeight + SpacingV;
        _userColumn = [[UIView alloc] initWithFrame:CGRectMake(0, userColumnY, ScreenWidth, UserColumnHeight)];
//        _userColumn.backgroundColor = [UIColor blueColor];
        
        UILabel* label1 = [[UILabel alloc] init];
        label1.text = @"用户";
//        label1.backgroundColor = [UIColor redColor];
        label1.frame = CGRectMake(0, 0, 70, DrawBoardColumnHeight);
        label1.textAlignment = NSTextAlignmentCenter;
        
        UILabel* label2 = [[UILabel alloc] init];
        label2.text = @"查看全部 >";
//        label2.backgroundColor = [UIColor redColor];
        label2.frame = CGRectMake(ScreenWidth - 100, 0, 100, DrawBoardColumnHeight);
        label2.textAlignment = NSTextAlignmentCenter;
        
        [self.userColumn addSubview:label1];
        [self.userColumn addSubview:label2];
    }
    
    return _userColumn;
}

- (UIScrollView*)userScroll{
    
    if (!_userScroll) {
        CGFloat userScrollY = SpacingV + DrawBoardColumnHeight + SpacingV + DrawBoardScrollHeight + SpacingV + UserColumnHeight + SpacingV;
        _userScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, userScrollY, ScreenWidth, UserScrollHeight)];
//        _userScroll.backgroundColor = [UIColor yellowColor];
        
        int i;
        UIView* userElement;
        for (i=0; i<5; i++) {
 
            userElement = [self userElement];
            userElement.frame = CGRectMake(SpacingV+(SpacingV+ScreenWidth/3)*i, 0, ScreenWidth/3, UserScrollHeight);
            [_userScroll addSubview:userElement];
        }
        
         _userScroll.showsHorizontalScrollIndicator = NO;
        _userScroll.contentSize = CGSizeMake((SpacingV + ScreenWidth/3)*i + SpacingV, 0);
    }
    
    return _userScroll;
}

- (void)addNavigationBtn{
    
    
//    CGFloat spacing = 5;
//    CGFloat toolWidth = 100 + 2 * spacing;
//
//    UIToolbar* tool = [[UIToolbar alloc] init];
//    tool.frame = CGRectMake(0, 0, toolWidth, 44);
//    tool.backgroundColor = [UIColor redColor];
//
//    UIButton* btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnSearch.frame = CGRectMake(0, 0, toolWidth/3, 44);
//    btnSearch.backgroundColor = [UIColor yellowColor];
//    [tool addSubview:btnSearch];
//
//    UIButton* btnSettings = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnSettings.frame = CGRectMake(toolWidth/3 + spacing, 0, toolWidth/3, 44);
//    btnSettings.backgroundColor = [UIColor yellowColor];
//    [tool addSubview:btnSettings];
//
//    UIButton* btnPublish = [UIButton buttonWithType:UIButtonTypeCustom];
//    btnPublish.frame = CGRectMake(2*(toolWidth/3+spacing), 0, toolWidth/3, 44);
//    btnPublish.backgroundColor = [UIColor yellowColor];
//    [tool addSubview:btnPublish];
//
//
//    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:tool];
//    self.navigationItem.rightBarButtonItem = item;
    
    NSMutableArray<UIBarButtonItem*>* att = [NSMutableArray array];
    
    UIButton* btnPublish = [UIButton buttonWithType:UIButtonTypeCustom];
    //        btnPublish.frame = CGRectMake(2*(toolWidth/3+spacing), 0, toolWidth/3, 44);
    [btnPublish setTitle:@"publish" forState:UIControlStateNormal];
    btnPublish.backgroundColor = [UIColor greenColor];
    UIBarButtonItem* itemPublish = [[UIBarButtonItem alloc] initWithCustomView:btnPublish];
    [att addObject:itemPublish];
    
    UIButton* btnSettings = [UIButton buttonWithType:UIButtonTypeCustom];
//        btnSettings.frame = CGRectMake(toolWidth/3 + spacing, 0, toolWidth/3, 44);
    [btnSettings setTitle:@"settings" forState:UIControlStateNormal];
    btnSettings.backgroundColor = [UIColor greenColor];
    UIBarButtonItem* itemSettings = [[UIBarButtonItem alloc] initWithCustomView:btnSettings];
    [att addObject:itemSettings];
    
    UIButton* btnSearch = [UIButton buttonWithType:UIButtonTypeCustom];
    //        btnSearch.frame = CGRectMake(0, 0, 100, 44);
    [btnSearch setTitle:@"Search" forState:UIControlStateNormal];
    btnSearch.backgroundColor = [UIColor greenColor];
    UIBarButtonItem* itemSearch = [[UIBarButtonItem alloc] initWithCustomView:btnSearch];
    [att addObject:itemSearch];
    
    self.navigationItem.rightBarButtonItems  = att;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    switch (collectionView.tag) {
        case 0:
            return 2;// self.imageName.count;
            break;
        
        case 1:
            return self.imageColle.count;
            break;
            
        case 2:
            return self.imageLike.count;
            break;
            
        case 3:
            return 0;
            break;
            
        default:
            break;
    }
    
    return 0;
}

- (FYDisplayCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FYDisplayCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellID forIndexPath:indexPath];
    
    switch (collectionView.tag) {
        case 0:
            [cell.workImage setImage:[UIImage imageNamed:self.imageName[indexPath.item]]];
            break;
            
        case 1:
            [cell.workImage setImage:[UIImage imageNamed:self.imageColle[indexPath.item]]];
            break;
            
        case 2:
            [cell.workImage setImage:[UIImage imageNamed:self.imageLike[indexPath.item]]];
            break;
            
        case 3:
            break;
            
        default:
            break;
    }
    
//    cell.backgroundColor = [UIColor greenColor];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake((ScreenWidth - (3 * LayoutSpacing))/2, 230);
}

- (void) personalCenterBtnClick:(NSNotification*) notification{
    int tag = [[notification.userInfo objectForKey:@"btnTag"] intValue];
//    NSLog(@"%d", tag);
    
    switch (tag) {
        case 0:
            {
                [self.topHeader removeFromSuperview];
                [self.attentionBackView removeFromSuperview];
                [self.collectionView addSubview:self.topHeader];
                
                [self.collectionView setCollectionViewLayout:self.flowLayout animated:NO];
                self.collectionView.tag = 0;
                [self.collectionView reloadData];
                break;
            }
        
        case 1:
            {
                [self.topHeader removeFromSuperview];
                [self.attentionBackView removeFromSuperview];
                [self.collectionView addSubview:self.topHeader];
                
                [self.collectionView setCollectionViewLayout:self.waterFallLayout animated:NO];
                self.collectionView.tag = 1;
                [self.collectionView reloadData];
                break;
            }
            
        case 2:
            {
                [self.topHeader removeFromSuperview];
                [self.attentionBackView removeFromSuperview];
                [self.collectionView addSubview:self.topHeader];
                
                [self.collectionView setCollectionViewLayout:self.waterFallLayout animated:NO];
                self.collectionView.tag = 2;
                [self.collectionView reloadData];
                break;
            }
        
        case 3:
            {
                [self.topHeader removeFromSuperview];
                [self.attentionBackView addSubview:self.topHeader];
                [self displayAttentionInterface];
                self.collectionView.tag = 3;
                [self.collectionView reloadData];
                break;
            }

        default:
            break;
    }

}

- (void) displayAttentionInterface{
    
    [self.collectionView addSubview:self.attentionBackView];
    [self.attentionBackView addSubview:self.drawBoardColumn];
    [self.attentionBackView addSubview:self.drawBoardScroll];
    [self.attentionBackView addSubview:self.userColumn];
    [self.attentionBackView addSubview:self.userScroll];
    
    self.attentionBackView.contentSize = CGSizeMake(ScreenWidth, self.userScroll.frame.origin.y + UserScrollHeight + SpacingV + SystemBottomHeight);
}

- (UIView*) drawBoardElement{
    
    UIView* element = [[UIView alloc] init];
    element.bounds = CGRectMake(0, 0, ScreenWidth/3, DrawBoardScrollHeight);
    element.backgroundColor = [UIColor whiteColor];
    
    UIImageView* image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"8.bmp"]];
    image.frame = CGRectMake(0, 0, ScreenWidth/3, DrawBoardScrollHeight*2/3);
    [element addSubview:image];
    
    UILabel* bigText = [[UILabel alloc] initWithFrame:CGRectMake(10, DrawBoardScrollHeight*2/3, 100, DrawBoardScrollHeight/6)];
    bigText.text = @"动漫礼服";
    bigText.font = [UIFont systemFontOfSize:15];
    [element addSubview:bigText];
    
    UILabel* littleText = [[UILabel alloc] initWithFrame:CGRectMake(10, DrawBoardScrollHeight*5/6, 100, DrawBoardScrollHeight/6)];
    littleText.text = @"吻笑眉";
    littleText.font = [UIFont systemFontOfSize:13];
    [element addSubview:littleText];
    
    return element;
}

- (UIView*) userElement{
    
    UIView* element = [[UIView alloc] init];
    element.bounds = CGRectMake(0, 0, ScreenWidth/3, DrawBoardScrollHeight);
    element.backgroundColor = [UIColor whiteColor];
    
    UIImageView* image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"8.bmp"]];
    image.frame = CGRectMake(25, 20, 70, 70);
    image.layer.cornerRadius = 35;
    image.layer.masksToBounds = YES;
    [element addSubview:image];
    
    UILabel* bigText = [[UILabel alloc] initWithFrame:CGRectMake(10, DrawBoardScrollHeight*2/3, 100, DrawBoardScrollHeight/6)];
    bigText.text = @"动漫礼服";
    bigText.font = [UIFont systemFontOfSize:15];
    [element addSubview:bigText];
    
    UILabel* littleText = [[UILabel alloc] initWithFrame:CGRectMake(10, DrawBoardScrollHeight*5/6, 100, DrawBoardScrollHeight/6)];
    littleText.text = @"吻笑眉";
    littleText.font = [UIFont systemFontOfSize:13];
    [element addSubview:littleText];
    
    return element;
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FYPersonalCenterBtnClick" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
// 设置按钮选中标题的颜色:富文本:描述一个文字颜色,字体,阴影,空心,图文混排
// 创建一个描述文本属性的字典
NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
attrs[NSForegroundColorAttributeName] = [UIColor blackColor];
[itemSearch setTitleTextAttributes:attrs forState:UIControlStateNormal];

// 设置字体尺寸:只有设置正常状态下,才会有效果
NSMutableDictionary *attrsNor = [NSMutableDictionary dictionary];
attrsNor[NSFontAttributeName] = [UIFont systemFontOfSize:13];
[itemSearch setTitleTextAttributes:attrsNor forState:UIControlStateNormal];
*/

@end
