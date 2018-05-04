//
//  FYCollectionView.m
//  FengYe
//
//  Created by Alan Turing on 2018/3/15.
//  Copyright © 2018年 Alan Turing. All rights reserved.
//

#import "FYCollectionView.h"

@implementation FYCollectionView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{

    return YES;
}


@end
