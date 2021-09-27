//
//  NCNetworkData.m
//  NaiveStudioMac
//
//  Created by Liang,Zhiyuan(GIS)2 on 2019/1/15.
//  Copyright © 2019 Liang,Zhiyuan(GIS). All rights reserved.
//

#import "NCNetworkData.h"
#if TARGET_OS_IPHONE
#else
#import <AppKit/AppKit.h>
#endif

#import "GCDAsyncSocket.h"

@implementation NCNetworkData

#if TARGET_OS_IPHONE
-(instancetype)initWithImage:(UIImage*)image{
    self = [super init];
    if (self) {
        self.type = NCNetworkDataTypeImage;
        self.data = UIImagePNGRepresentation(image);
    }
    return self;
}
#else
-(instancetype*)initWithImage:(NSImage*)image{
    return nil;
}

-(NSImage*)image{
    if (self.type == NCNetworkDataTypeImage) {
        return [[NSImage alloc] initWithData:self.data];
    }
    else {
        return nil;
    }
}

#endif

-(instancetype)initWithString:(NSString*)string{
    self = [super init];
    if (self) {
        NSString * delimStr = [[NSString alloc] initWithData:DATA_FRAGMENT_DELIMITER encoding:NSUTF8StringEncoding];
        
        string = [string stringByReplacingOccurrencesOfString:delimStr withString:@"\n"];
        self.type = NCNetworkDataTypeString;
        self.data = [[string copy] dataUsingEncoding:NSUTF8StringEncoding];
    }
    return self;
}

#define kCoderType @"kCoderType"
#define kCoderData @"kCoderData"

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeInteger:self.type forKey:kCoderType];
    [aCoder encodeObject:self.data forKey:kCoderData];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.type = [aDecoder decodeIntegerForKey:kCoderType];
        self.data = [aDecoder decodeObjectForKey:kCoderData];
    }
    return self;
}

-(NSString * )string{
    if (self.type == NCNetworkDataTypeString) {
        return [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    }
    else {
        return nil;
    }
}

@end


