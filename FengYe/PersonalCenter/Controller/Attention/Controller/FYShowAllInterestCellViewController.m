//
//  FYShowAllInterestCellViewController.m
//  FengYe
//
//  Created by Alan Turing on 2018/3/24.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYShowAllInterestCellViewController.h"
#import "FYInterestingCell.h"
#import <UIImageView+WebCache.h>
#import "FYInterestGroupDetailController.h"

#define InterestCell @"InterestCell"

@interface FYShowAllInterestCellViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation FYShowAllInterestCellViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"兴趣";
    
    CGFloat spacing = 10;
    CGFloat itemWidth = (self.view.bounds.size.width - 3 * spacing)/2;
    CGFloat itemHeight = itemWidth;
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    UICollectionView* colleView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    colleView.delegate = self;
    colleView.dataSource = self;
    colleView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
    colleView.contentInset = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    [colleView registerNib:[UINib nibWithNibName:@"FYInterestingCell" bundle:nil] forCellWithReuseIdentifier:InterestCell];
    
    [self.view addSubview:colleView];
}

//懒加载
- (NSMutableArray<FYInterestGroupUnitData*>*) allInterestCellAttr{
    
    if (_allInterestCellAttr == nil) {
        _allInterestCellAttr = [NSMutableArray<FYInterestGroupUnitData*> array];
    }
    
    return _allInterestCellAttr;
}

//代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.allInterestCellAttr.count;
}

- (FYInterestingCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FYInterestingCell* inrstCell = [collectionView dequeueReusableCellWithReuseIdentifier:InterestCell forIndexPath:indexPath];
    NSInteger index = [indexPath item];
    
    inrstCell.interestGroupName.text = self.allInterestCellAttr[index].interestGroupName;
    
    NSString* coverImageURL = [self.allInterestCellAttr[index].coverImageURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [inrstCell.coverImage sd_setImageWithURL:[NSURL URLWithString:coverImageURL]];
    inrstCell.coverImage.contentMode = UIViewContentModeScaleAspectFill;
    
    return inrstCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FYInterestGroupDetailController* detail = [[FYInterestGroupDetailController alloc] init];
    detail.interestGroupUnitData = self.allInterestCellAttr[indexPath.item];
    
    [self.navigationController pushViewController:detail animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
