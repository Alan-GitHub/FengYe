//
//  CommonAttr.h
//  FengYe
//
//  Created by Alan Turing on 2018/1/7.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#ifndef CommonAttr_h
#define CommonAttr_h

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define SystemBarHeight 20
#define NavigationBarHeight 44
#define SystemBottomHeight 49
#define SystemHeight 113  //20 + 44 + 49

//#define ServerURL @"http://192.168.1.101:8080/FengYeApp/UserController"
#define ServerURL @"http://39.108.120.44:8080/FengYeApp/UserController"

#define TEST false

#define NotificationLoginOrRegister @"LoginOrRegisterNotification"


#define DrawboardLayoutRowMargin 10
#define DrawboardLayoutColMargin 10

//person center layout
typedef NS_ENUM(NSInteger, OffsetType) {
    OffsetTypeMin,
    OffsetTypeCenter,
    OffsetTypeMax,
};

#define MainBackgroundColor [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1]

#define CellHeadIconRadius 15

//上传图片缓存目录
#define PHOTOCACHEPATH [NSTemporaryDirectory() stringByAppendingPathComponent:@"photoCache"]

#endif /* CommonAttr_h */
