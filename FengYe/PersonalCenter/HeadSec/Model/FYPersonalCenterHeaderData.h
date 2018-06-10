//
//  FYPersonalCenterHeaderData.h
//  FengYe
//
//  Created by Alan Turing on 2018/3/31.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYPersonalCenterHeaderData : NSObject

@property(nonatomic, assign) NSInteger drawboardNum;
@property(nonatomic, assign) NSInteger collectionNum;
@property(nonatomic, assign) NSInteger likeNum;
@property(nonatomic, assign) NSInteger attentionNum;
@property(nonatomic, assign) NSInteger fansNum;
@property(nonatomic, copy) NSString* headIconURL;
@property(nonatomic, copy) NSString* username;

@property(nonatomic, assign) bool isAttention;
@end
