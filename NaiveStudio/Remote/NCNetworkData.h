//
//  NCNetworkData.h
//  NaiveStudioMac
//
//  Created by Liang,Zhiyuan(GIS)2 on 2019/1/15.
//  Copyright © 2019 Liang,Zhiyuan(GIS). All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NCNetworkDataType){
    NCNetworkDataTypeUnknown = 0,
    NCNetworkDataTypeString,
    NCNetworkDataTypeImage,
};

#define DATA_FRAGMENT_DELIMITER [GCDAsyncSocket CRLFData]

@interface NCNetworkData : NSObject<NSCoding>

@property (nonatomic) NCNetworkDataType type;

@property (nonatomic) NSData * data;

//#if TARGET_OS_IPHONE
//+(NSData*)serializeWithImage:(UIImage*)image;
//#else
//+(NSData*)serializeWithImage:(NSImage*)image;
//#endif
//
//+(NSData*)serializeWithString:(NSString*)string;
//
//-(instancetype)initWithData:(NSData*)data;

#if TARGET_OS_IPHONE

-(instancetype)initWithImage:(UIImage*)image;

@property (nonatomic,readonly) UIImage * image;

#else

-(instancetype*)initWithImage:(NSImage*)image;

@property (nonatomic,readonly) NSImage * image;

#endif

-(instancetype)initWithString:(NSString*)string;

@property (nonatomic,readonly) NSString * string;

@end

NS_ASSUME_NONNULL_END
