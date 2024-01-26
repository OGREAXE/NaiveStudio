//
//  NPEngine.h
//  NaivePatch
//
//  Created by mi on 2024/1/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NPEngine : NSObject

+ (NSDictionary *)defineClass:(NSString *)classDeclaration
              instanceMethods:(NSArray<NSString *> *)instanceMethods
                 classMethods:(NSArray<NSString *> *)classMethods;
@end

@interface JPBoxing : NSObject
@property (nonatomic) id obj;
@property (nonatomic) void *pointer;
@property (nonatomic) Class cls;
@property (nonatomic, weak) id weakObj;
@property (nonatomic, assign) id assignObj;
- (id)unbox;
- (void *)unboxPointer;
- (Class)unboxClass;
@end


NS_ASSUME_NONNULL_END
