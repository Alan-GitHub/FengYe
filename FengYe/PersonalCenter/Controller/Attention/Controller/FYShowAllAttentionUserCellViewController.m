//
//  FYShowAllAttentionUserCellViewController.m
//  FengYe
//
//  Created by Alan Turing on 2018/3/24.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYShowAllAttentionUserCellViewController.h"
#import "FYUsersCell.h"
#import <UIImageView+WebCache.h>
#import "FYPersonalCenterViewController.h"

#define UserCell @"UserCell"

#define Spacing 10
#define ItemWidth  ((self.view.bounds.size.width - 3 * Spacing)/2)
#define ItemHeight  (self.userCellOrigHeight * ItemWidth/self.userCellOrigWidth)

@interface FYShowAllAttentionUserCellViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation FYShowAllAttentionUserCellViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"用户";
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(ItemWidth, ItemHeight);
    
    UICollectionView* colleView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    colleView.delegate = self;
    colleView.dataSource = self;
    colleView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
    colleView.contentInset = UIEdgeInsetsMake(Spacing, Spacing, Spacing, Spacing);
    [colleView registerNib:[UINib nibWithNibName:@"FYUsersCell" bundle:nil] forCellWithReuseIdentifier:UserCell];
    
    [self.view addSubview:colleView];
}

//懒加载
- (NSMutableArray<FYUserCellData*>*) allAttentionUsersCellAttr{
    
    if (_allAttentionUsersCellAttr == nil) {
        _allAttentionUsersCellAttr = [NSMutableArray<FYUserCellData*> array];
    }
    
    return _allAttentionUsersCellAttr;
}

//代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.allAttentionUsersCellAttr.count;
}

- (FYUsersCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FYUsersCell* userCell = [collectionView dequeueReusableCellWithReuseIdentifier:UserCell forIndexPath:indexPath];
    NSInteger index = [indexPath item];
    
    [userCell.userHeadIcon sd_setImageWithURL:[NSURL URLWithString:self.allAttentionUsersCellAttr[index].userHeadIcon]];
    userCell.userHeadIcon.layer.cornerRadius = (ItemWidth - 60) / 2;
    userCell.userHeadIcon.layer.masksToBounds = YES;
    userCell.userName.text = self.allAttentionUsersCellAttr[index].userName;
    
    NSString* fansStr = [NSString stringWithFormat:@"%zd 粉丝", self.allAttentionUsersCellAttr[index].fansNums];
    userCell.fansNums.text = fansStr;
    
    return userCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    FYPersonalCenterViewController* pcVC = [[FYPersonalCenterViewController alloc] init];
    pcVC.userName = self.allAttentionUsersCellAttr[indexPath.item].userName;
    
    [self.navigationController pushViewController:pcVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
