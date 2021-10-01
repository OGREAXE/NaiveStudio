//
//  FunctionManager.m
//  NaiveStudio
//
//  Created by liangzhiyuan on 2021/9/30.
//  Copyright © 2021 Liang,Zhiyuan(GIS). All rights reserved.
//

#import "NCScriptManager.h"
#import "NCViewManager.h"

@implementation NCScriptManager

+ (NSString *)statementOfGetObjectWithObject:(NSObject *)object {
//    NSString *smt = [NSString stringWithFormat:@"a = getObject(\"%p\")\nprint(a)\n", object];
    
    NSString *smt = [NSString stringWithFormat:@"a = [%@ sharedManager].selectedView; \nprint(a);", NSStringFromClass(NCViewManager.class)];
    return smt;
}

@end
