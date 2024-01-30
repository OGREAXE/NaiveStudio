//
//  NCObjCSourceParser.h
//  NaivePatch
//
//  Created by mi on 2024/1/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NPPatchedMethod : NSObject

@property (nonatomic, readonly) BOOL isClassMethod;

@property (nonatomic) NSString *selector;

@property (nonatomic) NSString *body;

@end

@interface NPPatchedClass : NSObject

@property (nonatomic, copy) NSString *name;

@property (nonatomic) NSArray<NPPatchedMethod *> *patchedMethods;

@property (nonatomic) NSArray<NPPatchedMethod *> *patchedClassMethods;

@end

@interface NCObjCSourceParser : NSObject

- (NSArray<NPPatchedClass *> *)extractPatchMethodFromContent:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
