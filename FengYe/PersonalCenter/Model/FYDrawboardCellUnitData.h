//
//  FYDrawboardCellUnitData.h
//  FengYe
//
//  Created by Alan Turing on 2018/3/23.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYDrawboardCellUnitData : NSObject

@property(nonatomic, copy) NSString* coverImageURL;
@property(nonatomic, assign) NSInteger coverImageWidth;
@property(nonatomic, assign) NSInteger coverImageHeight;
@property(nonatomic, copy) NSString* drawboardName;
@property(nonatomic, copy) NSString* descriptionText;
@property(nonatomic, copy) NSString* ownerHeadIcon;
@property(nonatomic, copy) NSString* ownerUserName;

@property(nonatomic, assign) NSInteger attentionNum;
@property(nonatomic, assign) NSInteger picNums;
@end
