//
//  ChatListViewController.m
//  FaceShowApp
//
//  Created by ZLL on 2018/1/5.
//  Copyright © 2018年 niuzhaowang. All rights reserved.
//

#import "ChatListViewController.h"
#import "ContactsViewController.h"
#import "ChatListCell.h"
#import "IMManager.h"
#import "IMConnectionManager.h"
#import "IMUserInterface.h"
#import "IMRequestManager.h"
#import "ChatViewController.h"
#import "TestIMViewController.h"
#import "IMTimeHandleManger.h"
#import "YXDrawerController.h"

@interface ChatListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<IMTopic *> *dataArray;
@property (nonatomic, strong) IMTopic *chattingTopic;
@property (nonatomic, assign) NSInteger privateTopicIndex;
@end

@implementation ChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"聊聊";
    WEAK_SELF
    [self nyx_setupLeftWithImageName:@"抽屉列表按钮正常态" highlightImageName:@"抽屉列表按钮点击态" action:^{
        STRONG_SELF
        [YXDrawerController showDrawer];
    }];
//    [[IMManager sharedInstance] startConnection];
    [self setupNavRightView];
    [self setupUI];
    [self setupData];
    [self updateUnreadPromptView];
    [self setupObserver];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavRightView {
    UIButton *navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    navRightBtn.frame = CGRectMake(0, 0, 75, 30);
    navRightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [navRightBtn setTitle:@"通讯录" forState:UIControlStateNormal];
    [navRightBtn setTitleColor:[UIColor colorWithHexString:@"1da1f2"] forState:UIControlStateNormal];
    [navRightBtn addTarget:self action:@selector(navRightBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self nyx_setupRightWithCustomView:navRightBtn];
}

- (void)navRightBtnAction:(UIButton *)sender {
    ContactsViewController *contactsVC = [[ContactsViewController alloc] init];
    [self.navigationController pushViewController:contactsVC animated:YES];
}

#pragma mark - setupUI
- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithHexString:@"ebeff2"];
    
    self.tableView = [[UITableView alloc]init];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"ffffff"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[ChatListCell class] forCellReuseIdentifier:@"ChatListCell"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.right.bottom.mas_equalTo(0);
    }];
}

- (void)setupData {
    self.dataArray = [NSMutableArray arrayWithArray:[IMUserInterface findAllTopics]];
    self.privateTopicIndex = 0;
    for (IMTopic *topic in self.dataArray) {
        if (topic.type == TopicType_Group) {
            self.privateTopicIndex++;
        }else {
            break;
        }
    }
}

- (void)updateUnreadPromptView {
    BOOL hasUnread = NO;
    for (IMTopic *topic in self.dataArray) {
        if (topic.unreadCount > 0) {
            hasUnread = YES;
            break;
        }
    }
    self.unreadPromptView.hidden = !hasUnread;
}

- (void)setupObserver {
    WEAK_SELF
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:kIMMessageDidUpdateNotification object:nil]subscribeNext:^(id x) {
        STRONG_SELF
        NSNotification *noti = (NSNotification *)x;
        IMTopicMessage *message = noti.object;
        for (IMTopic *item in self.dataArray) {
            if (item.topicID == message.topicID) {
                NSUInteger index = [self.dataArray indexOfObject:item];
                IMTopic *topic = self.dataArray[index];
                BOOL isSameMsg = [message.uniqueID isEqualToString:topic.latestMessage.uniqueID];
                topic.latestMessage = message;
                [self.dataArray replaceObjectAtIndex:index withObject:topic];
                if (isSameMsg) {
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                }else {
                    if ((index==self.privateTopicIndex && topic.type==TopicType_Private)
                        || (index==0 && topic.type==TopicType_Group)) {
                        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    }else {
                        NSInteger targetIndex = topic.type==TopicType_Group? 0:self.privateTopicIndex;
                        [self.dataArray removeObject:topic];
                        [self.dataArray insertObject:topic atIndex:targetIndex];
                        [self.tableView reloadData];
                    }
                }
                return;
            }
        }
    }];
    
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:kIMTopicDidUpdateNotification object:nil]subscribeNext:^(id x) {
        STRONG_SELF
        NSNotification *noti = (NSNotification *)x;
        IMTopic *topic = noti.object;
        if (topic.members.count == 0) {
            return;
        }
        for (IMTopic *item in self.dataArray) {
            if (item.topicID == topic.topicID) {
                NSUInteger index = [self.dataArray indexOfObject:item];
                [self.dataArray replaceObjectAtIndex:index withObject:topic];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                return;
            }
        }
        NSInteger targetIndex = topic.type==TopicType_Group? 0:self.privateTopicIndex;
        [self.dataArray insertObject:topic atIndex:targetIndex];
        [self.tableView reloadData];
    }];
    
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:kIMUnreadMessageCountDidUpdateNotification object:nil]subscribeNext:^(id x) {
        STRONG_SELF
        NSNotification *noti = (NSNotification *)x;
        int64_t topicID = ((NSNumber *)[noti.userInfo valueForKey:kIMUnreadMessageCountTopicKey]).longLongValue;
        int64_t count = ((NSNumber *)[noti.userInfo valueForKey:kIMUnreadMessageCountKey]).longLongValue;
        for (IMTopic *item in self.dataArray) {
            if (item.topicID == topicID) {
                item.unreadCount = count;
                NSUInteger index = [self.dataArray indexOfObject:item];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
        [self updateUnreadPromptView];
    }];
    
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:UIApplicationWillTerminateNotification object:nil]subscribeNext:^(id x) {
        STRONG_SELF
        [self clearChattingTopicUnreadCount];
    }];
}

- (void)clearChattingTopicUnreadCount {
    [IMUserInterface resetUnreadMessageCountWithTopicID:self.chattingTopic.topicID];
    for (IMTopic *item in self.dataArray) {
        if (item.topicID == self.chattingTopic.topicID) {
            item.unreadCount = 0;
            NSInteger index = [self.dataArray indexOfObject:item];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    [self updateUnreadPromptView];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatListCell" forIndexPath:indexPath];
    cell.topic = self.dataArray[indexPath.row];
    cell.isLastRow = indexPath.row == self.dataArray.count - 1;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IMTopic *topic = self.dataArray[indexPath.row];
    self.chattingTopic = topic;
    ChatViewController *chatVC = [[ChatViewController alloc]init];
    chatVC.topic = self.dataArray[indexPath.row];
    WEAK_SELF
    [chatVC setExitBlock:^{
        STRONG_SELF
        [self clearChattingTopicUnreadCount];
        self.chattingTopic = nil;
    }];
    [self.navigationController pushViewController:chatVC animated:YES];
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
////        IMTopic *topic = self.dataArray[indexPath.row];
////        if (topic.type == TopicType_Group) {//群聊不可删除
////            return;
////        }
//        //删除聊天
////        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//        DDLogDebug(@"删除");
//    }
//}
@end
