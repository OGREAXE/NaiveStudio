//
//  NCTestCenter.m
//  NaiveStudio
//
//  Created by Liang,Zhiyuan(GIS) on 2018/3/13.
//  Copyright © 2018年 Liang,Zhiyuan(GIS). All rights reserved.
//

#import "NCTestCenter.h"

@interface TestObject : NSObject

@end

@implementation TestObject

- (void)dealloc {
    NSLog(@"TestObject dealloc");
}

@end

@interface DummyBase : NSObject

@end

@implementation DummyBase

- (void)go {
    NSLog(@"go base");
}

- (void)toBePatch:(int)i {
    NSLog(@"super not patched");
}

@end

@interface Dummy:DummyBase

@property (nonatomic) NSString *str;

@end

@implementation Dummy

- (id)init {
    self = [super init];
    
    if (self) {
        _str = @"hahaha";
    }
    
    return self;
}

-(void)go{
//    [super go];
    NSLog(@"go Dummy");
}

- (void)goWithBlock:(void (^)(int i))block {
    block(123);
}

- (void)goWithReturnableBlock:(int (^)(int i))block {
    int res = block(123);
    NSLog(@"result of block is %d", res);
}

- (void)goWithReturnableBlock2:(NSString * (^)(int i, NSString *s))block {
    NSString *res = block(123, @"456");
    NSLog(@"result of goWithReturnableBlock2 is %@", res);
    
    [self goWithBlock:^(int i) {
        NSLog(@"oc invoke block %d", i);
    }];
}

- (void)toBePatch:(int)i {
    NSLog(@"I am not patched");
}

- (void)toBePatch2:(void (^)(int i))block {
    NSLog(@"toBePatch2 is not patched");
}

- (void)testGCD:(id)obj {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"testGCD %@", obj);
    });
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
