//
//  IMRequestManager.m
//  FaceShowApp
//
//  Created by niuzhaowang on 2018/1/3.
//  Copyright © 2018年 niuzhaowang. All rights reserved.
//

#import "IMRequestManager.h"
#import "IMManager.h"
#import "GetMemberTopicsRequest.h"
#import "GetTopicsRequest.h"
#import "IMTopicMessage.h"
#import "GetTopicMsgsRequest.h"
#import "IMConfig.h"
#import "CreateTopicRequest.h"
#import "SaveTextMsgRequest.h"

@interface IMRequestManager()
@property (nonatomic, strong) GetMemberTopicsRequest *getTopicsRequest;
@property (nonatomic, strong) GetTopicsRequest *topicDetailRequest;
@property (nonatomic, strong) GetTopicMsgsRequest *msgsRequest;
@property (nonatomic, strong) CreateTopicRequest *createTopicRequest;
@property (nonatomic, strong) SaveTextMsgRequest *saveTextMsgRequest;
@end

@implementation IMRequestManager
+ (IMRequestManager *)sharedInstance {
    static IMRequestManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[IMRequestManager alloc] init];
    });
    return manager;
}

- (void)requestTopicsWithCompleteBlock:(void(^)(NSArray<IMTopic *> *topics,NSError *error))completeBlock {
    NSString *reqId = [IMConfig generateUniqueID];
    [self.getTopicsRequest stopRequest];
    self.getTopicsRequest = [[GetMemberTopicsRequest alloc]init];
    self.getTopicsRequest.reqId = reqId;
    WEAK_SELF
    [self.getTopicsRequest startRequestWithRetClass:[GetMemberTopicsRequestItem class] andCompleteBlock:^(id retItem, NSError *error, BOOL isMock) {
        STRONG_SELF
        if (error) {
            BLOCK_EXEC(completeBlock,nil,error);
            return;
        }
        GetMemberTopicsRequestItem *item = (GetMemberTopicsRequestItem *)retItem;
        NSMutableArray *array = [NSMutableArray array];
        for (TopicData_topic *topicItem in item.data.topic) {
            [array addObject:[topicItem toIMTopic]];
        }
        BLOCK_EXEC(completeBlock,array,nil);
    }];
}

- (void)requestTopicDetailWithTopicIds:(NSString *)topicIds completeBlock:(void(^)(NSArray<IMTopic *> *topics,NSError *error))completeBlock {
    NSString *reqId = [IMConfig generateUniqueID];
    [self.topicDetailRequest stopRequest];
    self.topicDetailRequest = [[GetTopicsRequest alloc]init];
    self.topicDetailRequest.reqId = reqId;
    self.topicDetailRequest.topicIds = topicIds;
    WEAK_SELF
    [self.topicDetailRequest startRequestWithRetClass:[GetTopicsRequestItem class] andCompleteBlock:^(id retItem, NSError *error, BOOL isMock) {
        STRONG_SELF
        if (error) {
            BLOCK_EXEC(completeBlock,nil,error);
            return;
        }
        GetTopicsRequestItem *item = (GetTopicsRequestItem *)retItem;
        NSMutableArray *array = [NSMutableArray array];
        for (TopicData_topic *topicItem in item.data.topic) {
            [array addObject:[topicItem toIMTopic]];
        }
        BLOCK_EXEC(completeBlock,array,nil);
    }];
}

- (void)requestTopicMsgsWithTopicID:(int64_t)topicID
                            startID:(int64_t)startID
                           asending:(BOOL)asending
                      completeBlock:(void(^)(NSArray<IMTopicMessage *> *msgs,NSError *error))completeBlock {
    NSString *reqId = [IMConfig generateUniqueID];
    [self.msgsRequest stopRequest];
    self.msgsRequest = [[GetTopicMsgsRequest alloc]init];
    self.msgsRequest.reqId = reqId;
    self.msgsRequest.topicId = [NSString stringWithFormat:@"%@",@(topicID)];
    self.msgsRequest.startId = [NSString stringWithFormat:@"%@",@(startID)];
    self.msgsRequest.order = asending? @"asc":@"desc";
    WEAK_SELF
    [self.msgsRequest startRequestWithRetClass:[GetTopicMsgsRequestItem class] andCompleteBlock:^(id retItem, NSError *error, BOOL isMock) {
        STRONG_SELF
        if (error) {
            BLOCK_EXEC(completeBlock,nil,error);
            return;
        }
        GetTopicMsgsRequestItem *item = (GetTopicMsgsRequestItem *)retItem;
        NSMutableArray *array = [NSMutableArray array];
        for (TopicMsgData_topicMsg *msg in item.data.topicMsg) {
            [array addObject:[msg toIMTopicMessage]];
        }
        BLOCK_EXEC(completeBlock,array,nil);
    }];
}

- (void)requestNewTopicWithMember:(IMMember *)member completeBlock:(void(^)(IMTopic *topic,NSError *error))completeBlock {
    NSString *reqId = [IMConfig generateUniqueID];
    [self.createTopicRequest stopRequest];
    self.createTopicRequest = [[CreateTopicRequest alloc]init];
    self.createTopicRequest.reqId = reqId;
    self.createTopicRequest.topicType = @"1";
    if (member.memberID > 0) {
        self.createTopicRequest.imMemberIds = [NSString stringWithFormat:@"%@,%@",@([IMManager sharedInstance].currentMember.memberID),@(member.memberID)];
    }else if (member.userID > 0) {
        self.createTopicRequest.yxUsers = [NSString stringWithFormat:@"%@,%@",@([IMManager sharedInstance].currentMember.userID),@(member.userID)];
    }
    WEAK_SELF
    [self.createTopicRequest startRequestWithRetClass:[CreateTopicRequestItem class] andCompleteBlock:^(id retItem, NSError *error, BOOL isMock) {
        STRONG_SELF
        if (error) {
            BLOCK_EXEC(completeBlock,nil,error);
            return;
        }
        CreateTopicRequestItem *item = (CreateTopicRequestItem *)retItem;
        BLOCK_EXEC(completeBlock,[item.data.topic toIMTopic],nil);
    }];
}

- (void)requestSaveTextMsgWithMsg:(IMTextMessage *)msg completeBlock:(void(^)(IMTopicMessage *msg,NSError *error))completeBlock{
    WEAK_SELF
    [self.saveTextMsgRequest stopRequest];
    self.saveTextMsgRequest = [[SaveTextMsgRequest alloc]init];
    self.saveTextMsgRequest.topicId = [NSString stringWithFormat:@"%@",@(msg.topicID)];
    self.saveTextMsgRequest.msg = msg.text;
    self.saveTextMsgRequest.reqId = msg.uniqueID;
    [self.saveTextMsgRequest startRequestWithRetClass:[SaveTextMsgRequestItem class] andCompleteBlock:^(id retItem, NSError *error, BOOL isMock) {
        STRONG_SELF
        if (error) {
            BLOCK_EXEC(completeBlock,nil,error);
            return;
        }
        SaveTextMsgRequestItem *item = (SaveTextMsgRequestItem *)retItem;
        TopicMsgData_topicMsg *topicMsg = item.data.topicMsg.firstObject;
        BLOCK_EXEC(completeBlock,[topicMsg toIMTopicMessage],nil);
    }];
}

@end