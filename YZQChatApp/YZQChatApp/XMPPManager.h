//
//  XMPPManager.h
//  YZQChatApp
//
//  Created by Apple on 16/2/25.
//  Copyright © 2016年 YZQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
@interface XMPPManager : NSObject

//通信管道
@property (nonatomic, strong)XMPPStream *xmppStream;

//好友花名册
@property (nonatomic, strong)XMPPRoster *xmppRoster;

@property(nonatomic)XMPPRosterCoreDataStorage *coreDataStorage;

//聊天消息对象
@property (nonatomic, strong)XMPPMessageArchiving *messageArchiving;

//被管理对象上下文
@property (nonatomic, strong)NSManagedObjectContext *context;

/*
 单例
 */


+ (instancetype)shareInstance;

/*
 @param name 用户名
 @Param passWord 密码
 注册
 */

- (void)registerWithUserName:(NSString *)name
                    passWord:(NSString *)passWord;


/*
 @param name 用户名
 @Param passWord 密码
 登录
 */

- (void)loginWithUserName:(NSString *)name
                 passWord:(NSString *)passWord;

@end
