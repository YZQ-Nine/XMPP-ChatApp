//
//  XMPPManager.m
//  YZQChatApp
//
//  Created by Apple on 16/2/25.
//  Copyright © 2016年 YZQ. All rights reserved.
//

#import "XMPPManager.h"
//创建枚举器
typedef enum : NSUInteger {
    ConnectPurposeRegister,
    ConnectPurposeLogin,
} ConnectPurpose;

//枚举法二：
//typedef NS_ENUM(NSInteger, Connect) {
//
//    ConnectPurposeq;
//    ConnectPurposeW;
//
//};

//遵守协议
@interface XMPPManager ()<XMPPStreamDelegate, XMPPRosterDelegate, XMPPMessageArchivingStorage>

@property (nonatomic, copy) NSString *registerPassWord;

@property (nonatomic, copy) NSString *loginPassWord;
//链接服务器的目的
@property (nonatomic)ConnectPurpose connectPurpose;

@end

static XMPPManager *manager = nil;

@implementation XMPPManager

#pragma mark 单例
+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [XMPPManager new];
        
    });
    return manager;
}

#pragma mark 初始化相关属性

- (instancetype)init{
    self = [super init];
    if (self) {
        //通讯管道进行初始化
        self.xmppStream = [[XMPPStream alloc] init];
               //设置相关参数
        _xmppStream.hostName = kHostName;
        _xmppStream.hostPort = kHostPort;
        
        //添加代理可以添加多个
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //好友花名册的初始化 并进行相关设置
        //花名册数据管理助手
        self.coreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
        
        self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.coreDataStorage dispatchQueue:dispatch_get_main_queue()];
        //激活通信管道
        [self.xmppRoster activate:self.xmppStream];
        //添加代理
        [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //初始化聊天信息并设置相关参数
        XMPPMessageArchivingCoreDataStorage *messagecoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        
        self.messageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:messagecoreDataStorage dispatchQueue:dispatch_get_main_queue()];
        //激活
        [self.messageArchiving activate:self.xmppStream];
        
        [self.messageArchiving addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        self.context = messagecoreDataStorage.mainThreadManagedObjectContext;
        

    }
    return self;

}

#pragma mark 连接服务器

- (void)connectToServer{
    if ([self.xmppStream isConnected]) {
        //如果当前已经有连接，先断开当前连接 再建立新的连接
        //设置用户状态为下线
        XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
        [self.xmppStream sendElement:presence];

        
        [self.xmppStream disconnect];
    }
    NSError *error = nil;
    BOOL result = [self.xmppStream connectWithTimeout:20.f error:&error];
    if (!result) {
        //连接有错误
        NSLog(@"错误信息：%@", error);
    }

}

#pragma mark 注册

- (void)registerWithUserName:(NSString *)name passWord:(NSString *)passWord{
    //链接服务器的目的为注册
    self.connectPurpose = ConnectPurposeRegister;
    //创建一个账号
    XMPPJID *jid = [XMPPJID jidWithUser:name domain:kDomin resource:kResource];
    
    NSLog(@"%@",jid);
    
    self.xmppStream.myJID = jid;
    //保存注册密码
    self.registerPassWord = passWord;
    //向服务器发送连接请求
    [self connectToServer];

}

#pragma mark 登录

-(void)loginWithUserName:(NSString *)name passWord:(NSString *)passWord{
    
    //链接服务器的目的为登录
    self.connectPurpose = ConnectPurposeLogin;
    
    XMPPJID *jid = [XMPPJID jidWithUser:name domain:kDomin resource:kResource];
    
    self.xmppStream.myJID = jid;
    
    self.loginPassWord = passWord;
    
    [self connectToServer];

}

#pragma mark XMPPStreamDelegate

#pragma mark 连接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
   
    NSLog(@"连接成功");
    
    //判断是注册还是登录
    switch (self.connectPurpose) {
        case ConnectPurposeRegister:{
            //注册
            NSError *error = nil;
            [self.xmppStream registerWithPassword:self.registerPassWord error:&error];
            if (error) {
                NSLog(@"注册error:%@", error);
            }
            break;
        }
        case ConnectPurposeLogin:{
            //登录
            NSError *error = nil;
            //验证
            [self.xmppStream authenticateWithPassword:self.loginPassWord error:&error];
            if (error) {
                NSLog(@"登录验证error:%@", error);
            }
            break;
        }
            default:
            break;
    }
    
}

#pragma mark 连接超时
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender {
    NSLog(@"连接服务器超时");
}


#pragma mark 连接失败
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    NSLog(@"断开连接");
}

#pragma mark 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"注册成功");
}

#pragma maerk 验证成功
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"验证成功");
    
    //设置用户当前状态为上线（available） 下线（unavailable）
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    
    //将节点发送出去
    [self.xmppStream sendElement:presence];
    
}

#pragma mark 注册失败
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    NSLog(@"注册失败");
}

#pragma mark 验证失败
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    NSLog(@"验证失败");
}

#pragma mark 接收到好友请求
-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    NSLog(@"接收到好友请求");
}

@end
