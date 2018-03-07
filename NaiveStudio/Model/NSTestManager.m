//
//  NSTestManager.m
//  NaiveStudio
//
//  Created by 梁志远 on 07/03/2018.
//  Copyright © 2018 Liang,Zhiyuan(GIS). All rights reserved.
//

#import "NSTestManager.h"

@implementation NSTestManager

static NSTestManager * _instance = nil;

+(instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[NSTestManager alloc] init];
    });
    return _instance;
}

-(void)dispatch:(void(^)(int))block{
    if (block) {
        block(365);
    }
}

@end
