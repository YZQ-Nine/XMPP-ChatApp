//
//  ChetViewController.m
//  YZQChatApp
//
//  Created by Apple on 16/2/25.
//  Copyright © 2016年 YZQ. All rights reserved.
//

#import "ChetViewController.h"
#import "XMPPManager.h"
@interface ChetViewController ()<UITableViewDataSource, UITableViewDelegate, XMPPStreamDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *chatTableView;

@property (weak, nonatomic) IBOutlet UITextField *chatTextField;
//存放聊天信息
@property (nonatomic, strong) NSMutableArray *messageArray;
@end

@implementation ChetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.chatTextField.delegate = self;
    //添加代理
    [[XMPPManager shareInstance].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.chatTableView.dataSource = self;
    
    self.chatTableView.delegate = self;
    
    self.messageArray = [NSMutableArray array];
    
    NSLog(@"%@", self.friendJid);
    //查询聊天记录
    [self searchMessage];
    
    
}

#pragma mark XMPPStreamDelegate

#pragma mark 接收到消息
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSLog(@"接收到消息");
    //查询新的聊天记录
    [self searchMessage];
}

#pragma mark 消息发送失败
-(void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error{

    NSLog(@"消息发送失败");

}

#pragma mark 消息发送成功
-(void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
    NSLog(@"消息发送成功");
    
    //查询新的聊天记录
    [self searchMessage];
}

#pragma mark 获取聊天信息
- (void)searchMessage{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:[XMPPManager shareInstance].context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND bareJidStr == %@", [XMPPManager shareInstance].xmppStream.myJID.bare, self.friendJid];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[XMPPManager shareInstance].context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"查询失败：%@", error);
        
    }
    //清空数组，添加数据
    [self.messageArray removeAllObjects];
    //然后添加数据
    [self.messageArray addObjectsFromArray:fetchedObjects];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0];
    //刷新
    [self.chatTableView reloadData];
    if (self.messageArray.count > 0) {
        //自动滑到最后一行
        [self.chatTableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
   
    
    NSLog(@"%@", self.messageArray);
   
}

//发送消息
- (IBAction)sendMessage:(UIButton *)sender {

    //创建消息对象
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
   
    //设置消息内容
    [message addBody:self.chatTextField.text];
    
    //发送消息
    [[XMPPManager shareInstance].xmppStream sendElement:message];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"main_cell" forIndexPath:indexPath];
    if (cell) {
        XMPPMessageArchiving_Message_CoreDataObject *message = self.messageArray[indexPath.row];
        if (message.isOutgoing) {
            //发出消息
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.textColor = [UIColor redColor];
            //解决cell混乱
            cell.detailTextLabel.hidden = YES;
            cell.textLabel.hidden = NO;
            
            cell.textLabel.text = message.body;
        } else {
            //接收到消息
            cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
            cell.detailTextLabel.hidden = NO;
            cell.textLabel.hidden = YES;
            cell.detailTextLabel.text = message.body;
            
            
        }
    }
       return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 输入框根据键盘上移
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    CGFloat offset = self.view.frame.size.height - (textField.frame.origin.y + textField.frame.size.height + 216 + 50);
    if (offset <= 0) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.view.frame;
            frame.origin.y = offset;
            self.view.frame = frame;
            
        }];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        self.view.frame = frame;
        
    }];
    return YES;


}


//键盘回收
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //注销第一响应
    [textField resignFirstResponder];
    return YES;
}


@end
