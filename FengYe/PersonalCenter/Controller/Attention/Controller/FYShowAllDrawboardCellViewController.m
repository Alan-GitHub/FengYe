//
//  FYShowAllDrawboardCellViewController.m
//  FengYe
//
//  Created by Alan Turing on 2018/3/24.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYShowAllDrawboardCellViewController.h"
#import "FYModuleCell.h"
#import <UIImageView+WebCache.h>
#import "FYShowDetailDrawboardViewController.h"

#define DrawboardCell @"DrawboardCell"

@interface FYShowAllDrawboardCellViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation FYShowAllDrawboardCellViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"画板";
    
    CGFloat spacing = 10;
    CGFloat itemWidth = (self.view.bounds.size.width - 3 * spacing)/2;
    CGFloat itemHeight = self.drawboardCellOrigHeight * itemWidth/self.drawboardCellOrigWidth;
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
    
    UICollectionView* colleView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    colleView.delegate = self;
    colleView.dataSource = self;
    colleView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
    colleView.contentInset = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    [colleView registerNib:[UINib nibWithNibName:@"FYModuleCell" bundle:nil] forCellWithReuseIdentifier:DrawboardCell];
    
    [self.view addSubview:colleView];
}

//懒加载
- (NSMutableArray<FYDrawboardCellUnitData*>*) allDrawboardCellAttr{
    
    if (_allDrawboardCellAttr == nil) {
        _allDrawboardCellAttr = [NSMutableArray<FYDrawboardCellUnitData*> array];
    }
    
    return _allDrawboardCellAttr;
}

//代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.allDrawboardCellAttr.count;
}

- (FYModuleCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FYModuleCell* drawboardCell = [collectionView dequeueReusableCellWithReuseIdentifier:DrawboardCell forIndexPath:indexPath];
    NSInteger index = [indexPath item];
    
    [drawboardCell.coverImage sd_setImageWithURL:[NSURL URLWithString:self.allDrawboardCellAttr[index].coverImageURL]];
    drawboardCell.coverImage.contentMode = UIViewContentModeScaleAspectFill;
    
    drawboardCell.drawboardName.text = self.allDrawboardCellAttr[index].drawboardName;
    drawboardCell.ownerUserName.text = self.allDrawboardCellAttr[index].ownerUserName;
    
    return drawboardCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger index = [indexPath item];
    
    FYShowDetailDrawboardViewController* dbVC = [[FYShowDetailDrawboardViewController alloc] init];
    dbVC.specifyDrawData = self.allDrawboardCellAttr[index];
    dbVC.userName = self.allDrawboardCellAttr[index].ownerUserName;
    
    [self.navigationController pushViewController:dbVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
