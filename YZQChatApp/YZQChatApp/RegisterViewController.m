//
//  RegisterViewController.m
//  YZQChatApp
//
//  Created by Apple on 16/2/25.
//  Copyright © 2016年 YZQ. All rights reserved.
//

#import "RegisterViewController.h"
#import "XMPPManager.h"
#import "XMPPFramework.h"
@interface RegisterViewController ()<XMPPStreamDelegate>
//注册用户名
@property (weak, nonatomic) IBOutlet UITextField *userName;
//注册密码
@property (weak, nonatomic) IBOutlet UITextField *passWord;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //添加代理
    [[XMPPManager shareInstance].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    // Do any additional setup after loading the view.
}
#pragma mark 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender{
 
    //注册成功 自动登录
    [[XMPPManager shareInstance] loginWithUserName:self.userName.text passWord:self.passWord.text];
}

#pragma maerk 验证成功
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"验证成功");
    
    //设置用户当前状态为上线（available） 下线（unavailable）
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    
    //将节点发送出去
    [[XMPPManager shareInstance].xmppStream sendElement:presence];
    
}

//注册
- (IBAction)resignAction:(UIButton *)sender {
    NSString *name = self.userName.text;
    NSString *passWord = self.passWord.text;
    [[XMPPManager shareInstance]registerWithUserName:name passWord:passWord];
    [self.userName resignFirstResponder];
    [self.passWord resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
