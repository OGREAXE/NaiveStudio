//
//  NCObjCSourceParser.m
//  NaivePatch
//
//  Created by mi on 2024/1/19.
//

#import "NCObjCSourceParser.h"

@implementation NPPatchedMethod

- (BOOL)isClassMethod {
    if (self.selector.length) {
        return [self.selector characterAtIndex:0] == '+';
    }
    
    return NO;
}

@end

@implementation NPPatchedClass

@end

@implementation NCObjCSourceParser

- (NSArray<NPPatchedClass *> *)extractPatchMethodFromContent:(NSString *)content {
    
    content = [self stringByRemovingCommentsInString:content];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@implementation((.|\\s)*?)@end" options:NSRegularExpressionCaseInsensitive error:NULL];

    
    NSArray *myArray = [regex matchesInString:content options:0 range:NSMakeRange(0, [content length])] ;
    
    NSMutableArray *classes = [NSMutableArray array];

    for (NSTextCheckingResult *match in myArray) {
        NSRange matchRange = [match rangeAtIndex:1];
        
        NSString *impContent = [content substringWithRange:matchRange];
        
        NSString *className = [[impContent componentsSeparatedByString:@"\n"] objectAtIndex:0];
        className = [className stringByTrimmingCharactersInSet:
                                      [NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        [matches addObject:impContent];
//         NSLog(@"%@", [matches lastObject]);
        
//        NSString *methodRegexPattern = @"- *\\(.*?\\)((.|\\s)*?)\\{((.|\\s)*?)\\}";
        NSString *patchMethodRegexPattern = @" *#pragma  *mark  *patch *\n *([-|+] *\\(.*?\\)(.|\\s)*?)\\{((.|\\s)*?)\\}";
        NSRegularExpression *methodRegex = [NSRegularExpression regularExpressionWithPattern:patchMethodRegexPattern options:NSRegularExpressionCaseInsensitive error:NULL];
        
        NSArray *methodArray = [methodRegex matchesInString:impContent options:0 range:NSMakeRange(0, [impContent length])] ;
        
        NPPatchedClass *pClass = [NPPatchedClass new];
        pClass.name = className;
        
        NSMutableArray *methods = [NSMutableArray array];
        NSMutableArray *classMethods = [NSMutableArray array];
        
        for (NSTextCheckingResult *methodMatch in methodArray) {
            NSRange methodDeclareMatchRange = [methodMatch rangeAtIndex:1];
            
            NSString *decl = [impContent substringWithRange:methodDeclareMatchRange];
            
            NSLog(@"method: %@", decl);
            
            NSString *body = [self methodBodyFromString:impContent fromIndex:methodDeclareMatchRange.location + methodDeclareMatchRange.length];
            
            NSLog(@"body: %@ \n end of %@\n", body, decl);
            
            NPPatchedMethod *pMethod = [NPPatchedMethod new];
            pMethod.selector = decl;
            pMethod.body = body;
            
            if (pMethod.isClassMethod) {
                [classMethods addObject:pMethod];
            } else {
                [methods addObject:pMethod];
            }
        }
        
        pClass.patchedMethods = methods;
        pClass.patchedClassMethods = classMethods;
        
        [classes addObject:pClass];
    }
    
    return classes;
}

- (NSString *)stringByRemovingCommentsInString:(NSString *)string {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?:/\\*(?:[^*]|(?:\\*+[^*/]))*\\*+/)|(?://.*)" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:string options:0 range:NSMakeRange(0, [string length]) withTemplate:@""];
    
    return modifiedString;
}

- (NSString *)methodBodyFromString:(NSString *)string fromIndex:(NSInteger)fromIndex {
    int par = 0;
    
    BOOL isInIgnoreState = NO;
    int startIndex = 0, endIndex = 0;
//    int lasti = 0;
    for (int i = fromIndex; i < string.length; i ++) {
        unichar c = [string characterAtIndex:i];
        if (c == '"') {
            if (i>0 && [string characterAtIndex:i-1] == '\\') {
                
            } else {
                isInIgnoreState = !isInIgnoreState;
            }
        }
        
        if (!isInIgnoreState) {
            if (c == '{') {
                if (par == 0) startIndex = i;
                par ++;
            }
            else if (c == '}') {
                if (par == 1) {
                    endIndex = i;
                    break;
                }
                par --;
            }
        }
    }
    
    if (endIndex > 0) {
        return [string substringWithRange:NSMakeRange(startIndex, endIndex - startIndex + 1)];
    }
    
    return nil;
}


@end
