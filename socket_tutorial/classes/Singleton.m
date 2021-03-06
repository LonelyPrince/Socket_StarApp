//
//  Singleton.m
//  socket_tutorial
//
//  Created by xiaoliangwang on 14-7-4.
//  Copyright (c) 2014年 芳仔小脚印. All rights reserved.
//

#import "Singleton.h"

#import <sys/socket.h>

#import <netinet/in.h>

#import <arpa/inet.h>

#import <unistd.h>

#import "ViewController.h"


@implementation Singleton

+(Singleton *) sharedInstance
{
    
    static Singleton *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstace = [[self alloc] init];
    });
    
    return sharedInstace;
}
// socket连接
-(void)socketConnectHost{
    self.socket    = [[AsyncSocket alloc] initWithDelegate:self];
    
    NSError *error = nil;
  
    [self.socket connectToHost:self.socketHost onPort:self.socketPort withTimeout:3 error:&error];

    
}
// 连接成功回调
#pragma mark  - 连接成功回调
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    
    
    NSLog(@"socket连接成功");
    NSLog(@"接下来开始发送心跳");
    [sock readDataWithTimeout:30 tag:0];
    self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];
    [self.connectTimer fire];
    
    
    
}
// 心跳连接
-(void)longConnectToSocket{
    
    // 根据服务器要求发送固定格式的数据，假设为指令@"longConnect"，但是一般不会是这么简单的指令
    

    NSMutableData * betaData1 = [[NSMutableData alloc]init];

    betaData1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"betaData"];
    NSLog(@"betadata:%@",betaData1);
    
    [self.socket writeData:betaData1 withTimeout:1 tag:1];
    
}
// 切断socket
-(void)cutOffSocket{
    
    self.socket.userData = SocketOfflineByUser;
    
    [self.connectTimer invalidate];
    
    [self.socket disconnect];
}
-(void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"sorry the connect is failure %ld",sock.userData);
    NSLog(@"onSocketDidDisconnect");
    if (sock.userData == SocketOfflineByServer) {
        // 服务器掉线，重连
        [self socketConnectHost];
    }
    else if (sock.userData == SocketOfflineByUser) {
        // 如果由用户断开，不进行重连
        return;
    }
    
}


-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    // 对得到的data值进行解析与转换即可
    
    NSLog(@"读--");
    NSLog(@"%ld",tag);
    NSLog(@"data:%@",data);
    
    [self.socket readDataWithTimeout:30 tag:0];
}

//发送数据  



@end
