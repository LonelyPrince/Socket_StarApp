

//
//  ViewController.m
//  socket_tutorial
//
//  Created by xiaoliangwang on 14-7-4.
//  Copyright (c) 2014年 芳仔小脚印. All rights reserved.
//

#import "ViewController.h"
#import "YMSocketUtils.h"
#import "Model.h"
#import "Singleton.h"
#import <objc/runtime.h>
// 后面NSString这是运行时能获取到的C语言的类型
NSString * const TYPE_UINT8   = @"TC";// char是1个字节，8位
NSString * const TYPE_UINT16   = @"TS";// short是2个字节，16位
NSString * const TYPE_UINT32   = @"TI";
NSString * const TYPE_UINT64   = @"TQ";
NSString * const TYPE_STRING   = @"T@\"NSString\"";
NSString * const TYPE_ARRAY   = @"T@\"NSArray\"";

@interface ViewController ()



@property (nonatomic,strong)id object;



@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    
    _data = [[NSMutableData alloc]init];
    NSString * astr = @"192.168.1.2";
    NSArray *array = [astr componentsSeparatedByString:@"."]; //从字符.中分隔成2个元素的数组
    NSLog(@"array:%@",array);
    
    Cs_20001* cs_one = [Cs_20001 new];
    cs_one.package_tag= @"DIGW";
    cs_one.CRC= 1531354454;
    
    cs_one.module_name= @"BEAT";
    cs_one.Ret=0;
//    cs_one.Reserved= 12;
    cs_one.client_ip= array;
//    cs_one. data_len= 0;


    
    
	[Singleton sharedInstance].socketHost = @"192.168.1.1"; //host设定
    [Singleton sharedInstance].socketPort = 3000; //port设定
    
//     在连接前先进行手动断开
    [Singleton sharedInstance].socket.userData = SocketOfflineByUser;
    [[Singleton sharedInstance] cutOffSocket];

//     确保断开后再连，如果对一个正处于连接状态的socket进行连接，会出现崩溃
    [Singleton sharedInstance].socket.userData = SocketOfflineByServer;
    [[Singleton sharedInstance] socketConnectHost];

    
//     NSLog(@"conn:%d",connectBool);
    
    
     _socket=[[AsyncSocket alloc] initWithDelegate:self];
//    [_socket connectToHost:@"192.168.1.1" onPort:3000 error:nil];
//       [_socket connectToHost:@"127.0.0.1" onPort:1234 error:nil];

//  
//    [_socket readDataWithTimeout:-1 tag:1];


         [self RequestSpliceAttribute:cs_one];
    
    [_socket writeData:_data withTimeout:-1 tag:3];
   

    
    

}
//// socket连接
//-(void)socketConnectHost{
//    self.socket    = [[AsyncSocket alloc] initWithDelegate:self];
//    
//    NSError *error = nil;
//    
//    [self.socket connectToHost:@"192.168.1.1" onPort:3000 withTimeout:-1 error:&error];
//    
//    
//}

//-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
//{
//    
////    NSLog(@"socket1: %@",_socket);
//    NSLog(@"socket连接成功++");
//    NSLog(@"接下来开始发送心跳++");
//    [_socket readDataWithTimeout:-1 tag:3];
//    
//    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];
////    NSLog(@"socket2: %@",_socket);
//}
// 心跳连接
//-(void)longConnectToSocket{
//    
//    // 根据服务器要求发送固定格式的数据，假设为指令@"longConnect"，但是一般不会是这么简单的指令
//    
//    
//    NSMutableData * betaData1 = [[NSMutableData alloc]init];
//    
//    betaData1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"betaData"];
//    NSLog(@"betadata:%@",betaData1);
////    NSLog(@"socket3: %@",_socket);
//    [_socket writeData:betaData1 withTimeout:-1 tag:3];
////    NSLog(@"socket4: %@",_socket);
//}
//-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
//{
//    // 对得到的data值进行解析与转换即可
//    NSLog(@"读--");
//    NSLog(@"%ld",tag);
//    NSLog(@"data:%@",data);
////    NSString *newMessage = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
////    NSLog(@"newMessage:%@",newMessage);
//
//    [_socket readDataWithTimeout:-1 tag:3];
//    
//}

//- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
//{
//    NSLog(@"willDisconnectWithError");
//}
//-(void)onSocketDidDisconnect:(AsyncSocket *)sock
//{
//    NSLog(@"sorry the connect is failure %ld",sock.userData);
//     NSLog(@"onSocketDidDisconnect");
//    if (sock.userData == SocketOfflineByServer) {
//        // 服务器掉线，重连
//        [self socketConnectHost];
//        
//    }
//    else if (sock.userData == SocketOfflineByUser) {
//        // 如果由用户断开，不进行重连
//        return;
//    }
//    
//}



-(void)RequestSpliceAttribute:(id)obj{
    if (obj == nil) {
        self.object = _data;
    }
    unsigned int numIvars; //成员变量个数
    
    objc_property_t *propertys = class_copyPropertyList(NSClassFromString([NSString stringWithUTF8String:object_getClassName(obj)]), &numIvars);
    
    NSString *type = nil;
    NSString *name = nil;
    
    for (int i = 0; i < numIvars; i++) {
        objc_property_t thisProperty = propertys[i];
      
        name = [NSString stringWithUTF8String:property_getName(thisProperty)];
        NSLog(@"%d.name:%@",i,name);
        type = [[[NSString stringWithUTF8String:property_getAttributes(thisProperty)] componentsSeparatedByString:@","] objectAtIndex:0]; //获取成员变量的数据类型
        NSLog(@"%d.type:%@",i,type);
        
        id propertyValue = [obj valueForKey:[(NSString *)name substringFromIndex:0]];
        NSLog(@"%d.propertyValue:%@",i,propertyValue);
        
        NSLog(@"\n");
        
        if ([type isEqualToString:TYPE_UINT8]) {
            uint8_t i = [propertyValue charValue];// 8位
            [_data appendData:[YMSocketUtils byteFromUInt8:i]];
            NSLog(@"%lu",(unsigned long)[YMSocketUtils bytesFromUInt32:i].length);
            
        }else if([type isEqualToString:TYPE_UINT16]){
            uint16_t i = [propertyValue shortValue];// 16位
            [_data appendData:[YMSocketUtils bytesFromUInt16:i]];
           NSLog(@"%lu",(unsigned long)[YMSocketUtils bytesFromUInt32:i].length);
            
        }else if([type isEqualToString:TYPE_UINT32]){
            uint32_t i = [propertyValue intValue];// 32位
            [_data appendData:[YMSocketUtils bytesFromUInt32:i]];
            
            NSLog(@"%@",[YMSocketUtils bytesFromUInt32:i]);
            NSLog(@"%lu",_data.length);
            NSLog(@"conn:%@",_data);
            
        }else if([type isEqualToString:TYPE_UINT64]){
            uint64_t i = [propertyValue longLongValue];// 64位
            [_data appendData:[YMSocketUtils bytesFromUInt64:i]];
            NSLog(@"%lu",(unsigned long)[YMSocketUtils bytesFromUInt32:i].length);
            
        }else if([type isEqualToString:TYPE_STRING]){
            NSData *data = [(NSString*)propertyValue \
                            dataUsingEncoding:NSUTF8StringEncoding];// 通过utf-8转为data
             // 然后拼接字符串
            [_data appendData:data];
          NSLog(@"%lu",(unsigned long)[YMSocketUtils bytesFromUInt32:i].length);
            NSLog(@"%lu",(unsigned long)_data.length);
         
            
        }else if ([type isEqualToString: TYPE_ARRAY]){
        
            NSLog(@"数组类型");
            
            for (int i = 0; i<4; i++) {
                NSArray * arrtemp ;
                arrtemp= [[NSArray alloc]init];
                arrtemp =  propertyValue;
//                uint8_t intstring =[arrtemp[3-i] charValue];
                uint8_t arrint = [arrtemp[3-i] intValue];// 8位
                [_data appendData:[YMSocketUtils byteFromUInt8:arrint]];
            }
         // 用4个字节拼接字符串的长度拼接在字符串data之前

            [_data appendData:[YMSocketUtils bytesFromUInt32:_data.length]];
            NSLog(@"7个字段总长度：%lu",_data.length);
        
        }else {
            NSLog(@"RequestSpliceAttribute:未知类型");
            NSAssert(YES, @"RequestSpliceAttribute:未知类型");
        }
    }
    
    NSUserDefaults *userDef=[NSUserDefaults standardUserDefaults];//这个对象其实类似字典，着也是一个单例的例子
    [userDef setObject:_data forKey:@"betaData"];
    [userDef synchronize];//把数据同步到本地
    
    // hy: 记得释放C语言的结构体指针
    free(propertys);
    self.object = _data;
}



@end
