//
//  NCTestCenter.m
//  NaiveStudio
//
//  Created by Liang,Zhiyuan(GIS) on 2018/3/13.
//  Copyright © 2018年 Liang,Zhiyuan(GIS). All rights reserved.
//

#import "NCTestCenter.h"

@interface Dummy:NSObject
@end

@implementation Dummy

-(void)go{
    NSLog(@"go Dummy");
}

@end

@interface NCTestCenter()
@property (nonatomic) Dummy * dummy;
@end

@implementation NCTestCenter
-(Dummy*)dummy{
    if(!_dummy){
        _dummy = [Dummy new];
    }
    return _dummy;
}

+(void)dispatch:(void(^)(BOOL arg1, int arg2))blockArg{
    blockArg(YES, 123);
}
@end
