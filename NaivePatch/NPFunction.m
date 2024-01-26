//
//  NPFunction.m
//  NaivePatch
//
//  Created by mi on 2024/1/22.
//

#import "NPFunction.h"

@implementation NPNumber : NSObject

+ (NPNumber *)numberWithNumber:(NSNumber *)number {
    NPNumber *n = [NPNumber new];
    n.number = number;
    
    return n;
}

@end

@interface NPValue ()

@end

@implementation NPValue

+ (NPValue *)valueWithRect:(CGRect)rect {
    return [NSValue valueWithCGRect:rect];
}

+ (NPValue *)valueWithPoint:(CGPoint)point {
    return NULL;
}

+ (NPValue *)valueWithSize:(CGSize)size {
    return NULL;
}

+ (NPValue *)valueWithRange:(NSRange)range {
    return NULL;
}

+ (NPValue *)valueWithInset:(UIEdgeInsets)inset {
    return NULL;
}

- (id)toObject {
    return NULL;
}
- (CGRect)toRect {
    return CGRectZero;
}

- (CGPoint)toPoint {
    return CGPointZero;
}

- (CGSize)toSize {
    return CGSizeZero;
}

- (NSRange)toRange {
    return NSMakeRange(0, 0);
}

@end

@implementation NPFunction

- (NPValue *)callWithArguments:(NSArray<NPValue*> *)args {
    return NULL;
}

@end
