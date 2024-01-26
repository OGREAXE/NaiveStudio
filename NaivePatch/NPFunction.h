//
//  NPFunction.h
//  NaivePatch
//
//  Created by mi on 2024/1/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define NPNUMBER(a) [NPNumber numberWithNumber:@(a)]

//for primitive type like int, float ,char
@interface NPNumber : NSObject

@property (nonatomic) NSNumber *number;

+ (NPNumber *)numberWithNumber:(NSNumber *)number;

@end

@interface NPValue : NSObject

+ (NPValue *)valueWithRect:(CGRect)rect;
+ (NPValue *)valueWithPoint:(CGPoint)point;
+ (NPValue *)valueWithSize:(CGSize)size;
+ (NPValue *)valueWithRange:(NSRange)range;
+ (NPValue *)valueWithInset:(UIEdgeInsets)inset;

@property (nonatomic) NSString *types;

- (id)toObject;
- (CGRect)toRect;
- (CGPoint)toPoint;
- (CGSize)toSize;
- (NSRange)toRange;

@end

@interface NPFunction : NSObject

- (NPValue *)callWithArguments:(NSArray<NPValue*> *)args;

@end

NS_ASSUME_NONNULL_END
