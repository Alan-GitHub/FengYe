//
//  uploadModel.h
//  FengYe
//
//  Created by Alan Turing on 2018/4/24.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface uploadModel : NSObject

@property(nonatomic, copy) NSString* path;
@property(nonatomic, copy) NSString* type;
@property(nonatomic, copy) NSString* name;
@property(nonatomic, assign) BOOL isUploaded;
@end
