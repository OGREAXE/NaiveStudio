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
#import "NCInterpreterController.h"
#import "NCNetworkData.h"

#define TAG_TEXT 101
#define TAG_BIN 102

@interface NCServerManager()<GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *serverSocket;

@property (strong, nonatomic) GCDAsyncSocket* clientSockect;

@property (strong, nonatomic) NCInterpreterController * interpreter;

@end

#define LOG_SERVER(fmt, ...) NSLog(fmt,##__VA_ARGS__)

@implementation NCServerManager

static NCServerManager *_instance = nil;

+(instancetype)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[NCServerManager alloc] init];
    });
    return _instance;
}

-(id)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceivePrintNotification:) name:@"NCPrintStringNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLogNotification:) name:@"NCLogNotification" object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(GCDAsyncSocket * )clientSockects{
    if (!_clientSockect) {
        _clientSockect = [[GCDAsyncSocket alloc] init];
    }
    
    return _clientSockect;
}

-(NCInterpreterController*)interpreter{
    if (!_interpreter) {
        _interpreter = [[NCInterpreterController alloc] init];
    }
    
    return _interpreter;
}



-(BOOL)startServer{
    self.serverSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError * error = nil;
    BOOL result = [self.serverSocket acceptOnPort:LISTENING_PORT error:&error];
    if (error) {
        LOG_SERVER(@"error start server socket %@",error);
    }
    if (result) {
        LOG_SERVER(@"服务器的地址: %@ -------端口: %d", [self getIpAddresses], self.serverSocket.localPort);
    }
    return result;
}

-(void)stopServer{
    [self.serverSocket disconnect];
    self.serverSocket = nil;
    self.clientSockect = nil;
}


-(BOOL)isServerRunning{
    return self.serverSocket != nil;
}

-(NSString*)host{
    return [self getIpAddresses];
}

-(NSUInteger)port{
    return LISTENING_PORT;
}

// 连接上新的客户端socket
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(nonnull GCDAsyncSocket *)newSocket
{
    // 保存客户端的socket
    self.clientSockect = newSocket;
    
    LOG_SERVER(@"链接成功");
    LOG_SERVER(@"客户端的地址: %@ -------端口: %d", newSocket.connectedHost, newSocket.connectedPort);
    
    [newSocket readDataWithTimeout:- 1 tag:0];
}

/**
 读取客户端发送的数据
 
 @param sock 客户端的Socket
 @param data 客户端发送的数据
 @param tag 当前读取的标记
 */
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
//    if (tag == TAG_TEXT) {
//        NSString *text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        LOG_SERVER(@"didReadData:**************\n%@",text);
//
//        [self.interpreter runWithCode:text];
//    }
//
    
    NCNetworkData * ncData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    switch (ncData.type) {
        case NCNetworkDataTypeString:
            {
                LOG_SERVER(@"didReadData:**************\n%@",ncData.string);
            
                    [self.interpreter runWithCode:ncData.string];
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
    
    [sock readDataWithTimeout:- 1 tag:0];
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

-(void)writeToClientWithText:(NSString*)text{
    NCNetworkData * networkData = [[NCNetworkData alloc] initWithString:text];
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:networkData];
    [self.clientSockect writeData:data withTimeout:10 tag:TAG_TEXT];
}

-(void)didReceivePrintNotification:(NSNotification*)notification{
    NSString * str = notification.object;
    
    [self writeToClientWithText:str];
    
}

-(void)didReceiveLogNotification:(NSNotification*)notification{
    NSString * str = notification.object;
    
    [self writeToClientWithText:str];
}

@end
