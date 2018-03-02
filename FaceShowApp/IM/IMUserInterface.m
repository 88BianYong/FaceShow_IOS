//
//  IMUserInterface.m
//  FaceShowApp
//
//  Created by niuzhaowang on 2018/1/3.
//  Copyright © 2018年 niuzhaowang. All rights reserved.
//

#import "IMUserInterface.h"
#import "IMRequestManager.h"
#import "IMDatabaseManager.h"
#import "IMTextMessageSender.h"

@implementation IMUserInterface

+ (void)sendTextMessageWithText:(NSString *)text topicID:(int64_t)topicID {
    [self sendTextMessageWithText:text topicID:topicID uniqueID:nil];
}

+ (void)sendTextMessageWithText:(NSString *)text topicID:(int64_t)topicID uniqueID:(NSString *)uniqueID {
    IMTextMessage *msg = [[IMTextMessage alloc]init];
    msg.text = text;
    msg.topicID = topicID;
    msg.uniqueID = uniqueID;
    
    [[IMTextMessageSender sharedInstance]addTextMessage:msg];
}

+ (void)sendTextMessageWithText:(NSString *)text toMember:(IMMember *)member {
    IMTextMessage *msg = [[IMTextMessage alloc]init];
    msg.text = text;
    msg.otherMember = member;
    
    [[IMTextMessageSender sharedInstance]addTextMessage:msg];
}

+ (NSArray<IMTopic *> *)findAllTopics {
    NSArray<IMTopic *> *topics = [[IMDatabaseManager sharedInstance]findAllTopics];
    NSMutableArray *array = [NSMutableArray array];
    for (IMTopic *topic in topics) {
        if (topic.type == TopicType_Private) {
            [array addObject:topic];
        }else {
            [array insertObject:topic atIndex:0];
        }
    }
    return array;
}

+ (void)findMessagesInTopic:(int64_t)topicID
                      count:(NSUInteger)count
                   asending:(BOOL)asending
              completeBlock:(void(^)(NSArray<IMTopicMessage *> *array, BOOL hasMore))completeBlock {
    [[IMDatabaseManager sharedInstance]findMessagesInTopic:topicID count:count asending:asending completeBlock:completeBlock];
}

+ (void)findMessagesInTopic:(int64_t)topicID
                      count:(NSUInteger)count
                beforeIndex:(int64_t)index
              completeBlock:(void(^)(NSArray<IMTopicMessage *> *array, BOOL hasMore))completeBlock {
    [[IMDatabaseManager sharedInstance]findMessagesInTopic:topicID count:count beforeIndex:index completeBlock:completeBlock];
}

+ (void)clearDirtyMessages {
    [[IMDatabaseManager sharedInstance] clearDirtyMessages];
}

+ (void)resetUnreadMessageCountWithTopicID:(int64_t)topicID {
    [[IMDatabaseManager sharedInstance] resetUnreadMessageCountWithTopicID:topicID];
}
@end