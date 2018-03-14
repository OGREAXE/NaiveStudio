//
//  NCTestCenter.h
//  NaiveStudio
//
//  Created by Liang,Zhiyuan(GIS) on 2018/3/13.
//  Copyright © 2018年 Liang,Zhiyuan(GIS). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NCTestCenter : NSObject

+(void)dispatch:(void(^)(BOOL arg1, int arg2))blockArg;

@end
