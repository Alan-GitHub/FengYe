//
//  FYWorksUnitData.h
//  FengYe
//
//  Created by Alan Turing on 2018/1/26.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYWorksUnitData : NSObject
@property(nonatomic, strong) NSString* picURL;
@property(nonatomic, assign) NSInteger picWidth;
@property(nonatomic, assign) NSInteger picHeight;

@property(nonatomic, assign) NSInteger uploadTime;
@property(nonatomic, assign) NSInteger forwardCount;
@property(nonatomic, assign) NSInteger likeCount;
@property(nonatomic, assign) NSInteger commentCount;

@property(nonatomic, strong) NSString* descriptionText;
@property(nonatomic, strong) NSString* headIcon;
@property(nonatomic, strong) NSString* templateName;
@property(nonatomic, strong) NSString* owner;
@end
