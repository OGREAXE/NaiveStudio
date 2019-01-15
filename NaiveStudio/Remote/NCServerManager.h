//
//  NCRemoteManager.h
//  NaiveStudio
//
//  Created by Liang,Zhiyuan(GIS)2 on 2019/1/7.
//  Copyright © 2019 Liang,Zhiyuan(GIS). All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define LISTENING_PORT 12345

@interface NCServerManager : NSObject

+(instancetype)sharedManager;

-(BOOL)startServer;

-(void)stopServer;

@property (nonatomic,readonly) BOOL isServerRunning;

@property (nonatomic,readonly) NSString * host;

@property (nonatomic,readonly) NSUInteger port;

@end

NS_ASSUME_NONNULL_END
