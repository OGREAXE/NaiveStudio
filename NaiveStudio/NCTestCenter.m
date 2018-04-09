//
//  NCTestCenter.m
//  NaiveStudio
//
//  Created by Liang,Zhiyuan(GIS) on 2018/3/13.
//  Copyright © 2018年 Liang,Zhiyuan(GIS). All rights reserved.
//

#import "NCTestCenter.h"

@implementation NCTestCenter
+(void)dispatch:(void(^)(BOOL arg1, int arg2))blockArg{
    blockArg(YES, 123);
}
@end
