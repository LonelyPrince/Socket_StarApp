//
//  ViewController.h
//  socket_tutorial
//
//  Created by xiaoliangwang on 14-7-4.
//  Copyright (c) 2014年 芳仔小脚印. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncSocket.h"

extern NSString * const TYPE_UINT8;
extern NSString * const TYPE_UINT16;
extern NSString * const TYPE_UINT32;
extern NSString * const TYPE_UINT64;
extern NSString * const TYPE_STRING;
extern NSString * const TYPE_ARRAY;

@interface ViewController : UIViewController

@property (nonatomic, strong) NSMutableData *data;
@property(nonatomic,assign )BOOL connectBool;
@property (nonatomic, strong)  AsyncSocket *socket;

-(void)socketConnectHost;// socket连接
@end
