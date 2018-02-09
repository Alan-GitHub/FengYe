//
//  FYPersonalCenterHeader.m
//  FengYe
//
//  Created by Alan Turing on 2018/1/14.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYPersonalCenterHeader.h"

@interface FYPersonalCenterHeader()
@property (weak, nonatomic) IBOutlet UIView *attentionBtn;
@property (weak, nonatomic) IBOutlet UILabel *attentionNum;
@property (weak, nonatomic) IBOutlet UIView *likeBtn;
@property (weak, nonatomic) IBOutlet UILabel *likeNum;
@property (weak, nonatomic) IBOutlet UIView *collectionBtn;
@property (weak, nonatomic) IBOutlet UILabel *collectionNum;
@property (weak, nonatomic) IBOutlet UIView *drawBoardBtn;
@property (weak, nonatomic) IBOutlet UILabel *drawBoardNum;

@property (retain, nonatomic) UIView *previousPressedBtn;

@end

@implementation FYPersonalCenterHeader

//Btn: drawBoard, collection, like, attention
- (void)initBtn{
    //Add gesture
    UITapGestureRecognizer* tapDrawBoard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    UITapGestureRecognizer* tapCollection = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    UITapGestureRecognizer* tapLike = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    UITapGestureRecognizer* tapAttention = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];

    self.drawBoardBtn.tag = 0;
    [self.drawBoardBtn addGestureRecognizer:tapDrawBoard];

    self.collectionBtn.tag = 1;
    [self.collectionBtn addGestureRecognizer:tapCollection];

    self.likeBtn.tag = 2;
    [self.likeBtn addGestureRecognizer:tapLike];

    self.attentionBtn.tag = 3;
    [self.attentionBtn addGestureRecognizer:tapAttention];

    self.previousPressedBtn = self.drawBoardBtn;
    self.previousPressedBtn.backgroundColor = [UIColor lightGrayColor];

//    self.backScrollView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
}

- (void)tapAction:(UITapGestureRecognizer*)sender {

    if (sender.view.tag == self.previousPressedBtn.tag) {
        return;
    }

    self.previousPressedBtn.backgroundColor = [UIColor whiteColor];
    sender.view.backgroundColor = [UIColor lightGrayColor];
    self.previousPressedBtn = sender.view;

    switch (sender.view.tag) {
        case 0:
        {
            NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"0", @"btnTag", nil];
            NSNotification* notification = [NSNotification notificationWithName:@"FYPersonalCenterBtnClick" object:nil userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            break;
        }

        case 1:
        {
            NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"1", @"btnTag", nil];
            NSNotification* notification = [NSNotification notificationWithName:@"FYPersonalCenterBtnClick" object:nil userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            break;
        }
            
        case 2:
        {
            NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"2", @"btnTag", nil];
            NSNotification* notification = [NSNotification notificationWithName:@"FYPersonalCenterBtnClick" object:nil userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            break;
        }
            
        case 3:
        {
            NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"3", @"btnTag", nil];
            NSNotification* notification = [NSNotification notificationWithName:@"FYPersonalCenterBtnClick" object:nil userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            break;
        }

        default:
            NSLog(@"error...");
            break;
    }
}
@end
