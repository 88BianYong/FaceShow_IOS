//
//  UserPromptsManager.m
//  FaceShowApp
//
//  Created by niuzhaowang on 2017/12/20.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import "UserPromptsManager.h"
#import "YXGCDTimer.h"

NSString * const kHasNewTaskNotification = @"kHasNewTaskNotification";
NSString * const kHasNewMomentNotification = @"kHasNewMomentNotification";
NSString * const kHasNewResourceNotification = @"kHasNewResourceNotification";
NSString * const kHasNewCertificateNotification = @"kHasNewCertificateNotification";
NSString * const kHasReadCertificateNotification = @"kHasReadCertificateNotification";

@interface UserPromptsManager ()
@property (nonatomic, strong) YXGCDTimer *timer;
@property (nonatomic, strong) GetUserPromptsRequest *promptRequest;
@property (nonatomic, strong) GetUserNoReadCertRequest *certRequest;
@end

@implementation UserPromptsManager

+ (UserPromptsManager *)sharedInstance {
    static UserPromptsManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[UserPromptsManager alloc] init];
    });
    return manager;
}

- (void)performRequest {
    [self.promptRequest stopRequest];
    self.promptRequest = [[GetUserPromptsRequest alloc] init];
    self.promptRequest.clazsId = [UserManager sharedInstance].userModel.projectClassInfo.data.clazsInfo.clazsId;
    self.promptRequest.bizIds = @"taskNew,momentNew,resourceNew,momentMsgNew";
    [self.promptRequest startRequestWithRetClass:[GetUserPromptsRequestItem class] andCompleteBlock:^(id retItem, NSError *error, BOOL isMock) {
        if (error) {
            return;
        }
        GetUserPromptsRequestItem *item = (GetUserPromptsRequestItem *)retItem;
        self.data = item.data;
        self.taskNewView.hidden = item.data.taskNew.promptNum.integerValue==0;
        self.resourceNewView.hidden = item.data.resourceNew.promptNum.integerValue==0;
        self.momentNewView.hidden = item.data.momentNew.promptNum.integerValue==0&&item.data.momentMsgNew.promptNum.integerValue==0;
        if (item.data.taskNew.promptNum.integerValue > 0) {
            [[NSNotificationCenter defaultCenter]postNotificationName:kHasNewTaskNotification object:nil];
        }
        if (item.data.resourceNew.promptNum.integerValue > 0) {
            [[NSNotificationCenter defaultCenter]postNotificationName:kHasNewResourceNotification object:nil];
        }
        if (item.data.momentNew.promptNum.integerValue > 0 || item.data.momentMsgNew.promptNum.integerValue > 0) {
            [[NSNotificationCenter defaultCenter]postNotificationName:kHasNewMomentNotification object:nil];
        }
    }];
}

- (void)performCertRequest{
    [self.certRequest stopRequest];
    self.certRequest = [[GetUserNoReadCertRequest alloc] init];
    [self.certRequest startRequestWithRetClass:[GetUserNoReadCertRequest_Item class] andCompleteBlock:^(id retItem, NSError *error, BOOL isMock) {
        if (error) {
            return;
        }
        GetUserNoReadCertRequest_Item *item = (GetUserNoReadCertRequest_Item *)retItem;
        if(item.data.existNoReadCert.intValue > 0){
            [[NSNotificationCenter defaultCenter] postNotificationName:kHasNewCertificateNotification object:nil];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:kHasReadCertificateNotification object:nil];
        }
    }];
}

- (void)resumeHeartbeat {
    WEAK_SELF
    if (!self.timer) {
        self.timer = [[YXGCDTimer alloc] initWithInterval:30 repeats:YES triggerBlock:^{
            STRONG_SELF
            [self performRequest];
            [self performCertRequest];
        }];
    }
    [self.timer resume];
}

- (void)suspendHeartbeat {
    [self.timer suspend];
}

@end
