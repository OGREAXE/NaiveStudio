//
//  FunctionManager.m
//  NaiveStudio
//
//  Created by liangzhiyuan on 2021/9/30.
//  Copyright © 2021 Liang,Zhiyuan(GIS). All rights reserved.
//

#import "FunctionManager.h"

@implementation FunctionManager

+ (NSString *)statementOfGetObjectWithAddress:(NSUInteger)address {
    NSString *smt = [NSString stringWithFormat:@"getObject(%d)", address];
    return smt;
}

@end
