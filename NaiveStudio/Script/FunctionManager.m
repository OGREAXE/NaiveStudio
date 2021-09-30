//
//  FunctionManager.m
//  NaiveStudio
//
//  Created by liangzhiyuan on 2021/9/30.
//  Copyright © 2021 Liang,Zhiyuan(GIS). All rights reserved.
//

#import "FunctionManager.h"

@implementation FunctionManager

+ (NSString *)statementOfGetObjectWithObject:(NSObject *)object {
    NSString *smt = [NSString stringWithFormat:@"a = getObject(\"%p\")\nprint(a)\n", object];
    return smt;
}

@end
