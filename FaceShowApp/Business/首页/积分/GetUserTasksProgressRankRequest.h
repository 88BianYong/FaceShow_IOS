//
//  GetUserTasksProgressRankRequest.h
//  FaceShowApp
//
//  Created by ZLL on 2018/6/16.
//  Copyright © 2018年 niuzhaowang. All rights reserved.
//

#import "YXGetRequest.h"

@protocol GetUserTasksProgressRankRequestItem_element <NSObject>
@end

@interface GetUserTasksProgressRankRequestItem_element : JSONModel
@property (nonatomic, strong) NSString<Optional> *avator;
@property (nonatomic, strong) NSString<Optional> *userName;
@property (nonatomic, strong) NSString<Optional> *taskProgress;
@property (nonatomic, strong) NSString<Optional> *userId;
@end

@interface GetUserTasksProgressRankRequestItem_userRank : JSONModel
@property (nonatomic, strong) NSArray<Optional,GetUserTasksProgressRankRequestItem_element> *elements;
@property (nonatomic, strong) NSString<Optional> *pageSize;
@property (nonatomic, strong) NSString<Optional> *pageNum;
@property (nonatomic, strong) NSString<Optional> *offset;
@property (nonatomic, strong) NSString<Optional> *totalElements;
@property (nonatomic, strong) NSString<Optional> *lastPageNumber;
@end

@interface GetUserTasksProgressRankRequestItem_data : JSONModel
@property (nonatomic, strong) GetUserTasksProgressRankRequestItem_userRank<Optional> *userRank;
@end

@interface GetUserTasksProgressRankRequestItem : HttpBaseRequestItem
@property (nonatomic, strong) GetUserTasksProgressRankRequestItem_data<Optional> *data;
@end

@interface GetUserTasksProgressRankRequest : YXGetRequest
@property (nonatomic, strong) NSString *clazsId;
@property (nonatomic, strong) NSString<Optional> *offset;
@property (nonatomic, strong) NSString<Optional> *pageSize;
@end
