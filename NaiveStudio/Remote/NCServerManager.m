//
//  NCRemoteManager.m
//  NaiveStudio
//
//  Created by Liang,Zhiyuan(GIS)2 on 2019/1/7.
//  Copyright © 2019 Liang,Zhiyuan(GIS). All rights reserved.
//

#import "NCServerManager.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import "CocoaAsyncSocket.h"
#import "NCScriptInterpreter.h"
#import "NCNetworkData.h"
#import "NCViewManager.h"
#import "Common.h"

#define TAG_TEXT 101
#define TAG_BIN 102

#define DEFAULT_SEND_TIMEOUT 10

//#define DATA_FRAGMENT_DELIMITER [GCDAsyncSocket CRLFData]

@interface NCServerManager()<GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *serverSocket;

@property (strong, nonatomic) GCDAsyncSocket *clientSockect;

@property (strong, nonatomic) NCScriptInterpreter *interpreter;

@end

#define LOG_SERVER(fmt, ...) NSLog(fmt,##__VA_ARGS__)

@implementation NCServerManager

static NCServerManager *_instance = nil;

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[NCServerManager alloc] init];
    });
    return _instance;
}

- (id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceivePrintFromEngineNotification:)
                                                     name:NCPrintContentFromEngineNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveLogNotification:)
                                                     name:@"NCLogNotification" object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (GCDAsyncSocket *)clientSockects {
    if (!_clientSockect) {
        _clientSockect = [[GCDAsyncSocket alloc] init];
    }
    
    return _clientSockect;
}

- (NCScriptInterpreter *)interpreter {
    if (!_interpreter) {
        _interpreter = [[NCScriptInterpreter alloc] init];
    }
    
    return _interpreter;
}



- (BOOL)startServer {
    self.serverSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError * error = nil;
    BOOL result = [self.serverSocket acceptOnPort:LISTENING_PORT error:&error];
    if (error) {
        LOG_SERVER(@"error start server socket %@",error);
    }
    if (result) {
        LOG_SERVER(@"server address: %@ -------port: %d", [self getIpAddresses], self.serverSocket.localPort);
    }
    return result;
}

- (void)stopServer {
    [self.serverSocket disconnect];
    self.serverSocket = nil;
    self.clientSockect = nil;
}


- (BOOL)isServerRunning{
    return self.serverSocket != nil;
}

- (NSString *)host{
    return [self getIpAddresses];
}

- (NSUInteger)port{
    return LISTENING_PORT;
}

// 连接上新的客户端socket
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(nonnull GCDAsyncSocket *)newSocket {
    // 保存客户端的socket
    self.clientSockect = newSocket;
    
    LOG_SERVER(@"new socket connected!");
    LOG_SERVER(@"client address: %@ -------port: %d", newSocket.connectedHost, newSocket.connectedPort);
    
//    [newSocket readDataWithTimeout:- 1 tag:0];
    [newSocket readDataToData:DATA_FRAGMENT_DELIMITER withTimeout:-1 tag:0];
}

/**
 读取客户端发送的数据
 
 @param sock 客户端的Socket
 @param data 客户端发送的数据
 @param tag 当前读取的标记
 */
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
//    if (tag == TAG_TEXT) {
//        NSString *text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        LOG_SERVER(@"didReadData:**************\n%@",text);
//
//        [self.interpreter runWithCode:text];
//    }
//
    NSData * dataWithoutDelim = [data subdataWithRange:NSMakeRange(0, data.length-2)];
    NCNetworkData * ncData = [NSKeyedUnarchiver unarchiveObjectWithData:dataWithoutDelim];
    switch (ncData.type) {
        case NCNetworkDataTypeString:
            {
                LOG_SERVER(@"didReadData:**************\n%@",ncData.string);
            
                [self dispatchWithString:ncData.string];
            }
            break;
        case NCNetworkDataTypeImage:
        {
            LOG_SERVER(@"didReadData:image");
            //todo image
        }
            break;
        default:
            break;
    }
    
//    [sock readDataWithTimeout:- 1 tag:0];
    [sock readDataToData:DATA_FRAGMENT_DELIMITER withTimeout:-1 tag:0];
}

- (void)dispatchWithString:(NSString *)string {
    if ([string isEqualToString:@"lock"]) {
        //handle lock screen
        [self handleLockScreenCommand];
    } else if ([string isEqualToString:@"unlock"]) {
        //handle lock screen
        [self handleUnlockScreenCommand];
    }  else if ([string isEqualToString:@"?NAIVE_PATCH?"]) {
        //todo patch
        NSLog(@"NAIVE_PATCH:%@", string);
        
    } else {
        [self.interpreter runWithCode:string];
    }
}

- (void)handleLockScreenCommand {
    [[NCViewManager sharedManager] beginLockScreenMode];
    
//    [self writeToClientWithText:@"lock success"];
    [self writeToClientWithContent:@"lock success" metaData:@{WRITE_CLIENT_TEXT_COLOR_KEY:@"0x0000ffff"}];
}

- (void)handleUnlockScreenCommand {
    [[NCViewManager sharedManager] exitLockScreenMode];
    
//    [self writeToClientWithText:@"unlock success"];
    [self writeToClientWithContent:@"unlock success" metaData:@{WRITE_CLIENT_TEXT_COLOR_KEY:@"0x0000ffff"}];
}

- (NSString *)getIpAddresses{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

- (void)writeToClientWithText:(NSString *)text {
    NCNetworkData * networkData = [[NCNetworkData alloc] initWithString:text];
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:networkData];
//    [self.clientSockect writeData:data withTimeout:10 tag:TAG_TEXT];
    NSMutableData * dataWithDelimiter = [[NSMutableData alloc] initWithData:data];
    [dataWithDelimiter appendData:DATA_FRAGMENT_DELIMITER];
    [self.clientSockect writeData:dataWithDelimiter withTimeout:DEFAULT_SEND_TIMEOUT tag:TAG_TEXT];
}

- (void)writeToClientWithContent:(NSString *)text {
    [self writeToClientWithContent:text metaData:nil];
}

- (void)writeToClientWithContent:(NSString *)text metaData:(NSDictionary *)meta{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:meta];
    
    if (text) {
        [dict setObject:text forKey:@"content"];
    }
    
    NSError *err = nil;
    
    NSData *json = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    
    if (err) {
        NSLog(@"error creating json %@", err);
        return;
    }
    
    NSString *outputJsonText = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    
    [self writeToClientWithText:outputJsonText];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    if (tag == TAG_TEXT) {
        LOG_SERVER(@"didWriteDataWithTag");
    }
}

- (void)didReceivePrintFromEngineNotification:(NSNotification*)notification {
    NSString * str = notification.object;
    
//    [self writeToClientWithText:str];
    [self writeToClientWithContent:str
                          metaData:@{WRITE_CLIENT_CONTENT_TYPE_KEY:@(NCWriteToClientContentTypeFromEngine)}];
}

- (void)didReceiveLogNotification:(NSNotification*)notification {
    NSString * str = notification.object;
    
//    [self writeToClientWithText:str];
    [self writeToClientWithContent:str metaData:@{WRITE_CLIENT_TEXT_COLOR_KEY:@"0x0000FFFF"}];
}

@end
