//
//  UserPromptsManager.h
//  FaceShowApp
//
//  Created by niuzhaowang on 2017/12/20.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetUserPromptsRequest.h"
#import "GetUserNoReadCertRequest.h"

extern NSString * const kHasNewTaskNotification;
extern NSString * const kHasNewMomentNotification;
extern NSString * const kHasNewResourceNotification;
extern NSString * const kHasNewCertificateNotification;
extern NSString * const kHasReadCertificateNotification;

@interface UserPromptsManager : NSObject
@property (nonatomic, strong) UIView *taskNewView;
@property (nonatomic, strong) UIView *resourceNewView;
@property (nonatomic, strong) UIView *momentNewView;

@property (nonatomic, strong) GetUserPromptsRequestItem_data *data;

+ (UserPromptsManager *)sharedInstance;

- (void)resumeHeartbeat;
- (void)suspendHeartbeat;
@end
