//
//  LoginViewController.m
//  YZQChatApp
//
//  Created by Apple on 16/2/25.
//  Copyright © 2016年 YZQ. All rights reserved.
//

#import "LoginViewController.h"
#import "XMPPManager.h"
#import "XMPPFramework.h"
@interface LoginViewController ()<XMPPStreamDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *passWord;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //添加代理
    [[XMPPManager shareInstance].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Do any additional setup after loading the view.
}

#pragma mark 验证成功
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)loginAction:(UIButton *)sender {

    NSString *name = self.userName.text;
    NSString *password = self.passWord.text;
    //执行登录
    [[XMPPManager shareInstance]loginWithUserName:name passWord:password];
    
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
