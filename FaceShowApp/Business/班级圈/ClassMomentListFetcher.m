//
//  ClassMomentListFetcher.m
//  FaceShowApp
//
//  Created by 郑小龙 on 2017/9/19.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import "ClassMomentListFetcher.h"
@interface ClassMomentListFetcher()
@property (nonatomic, strong) ClassMomentListRequest *request;
@end

@implementation ClassMomentListFetcher
- (void)startWithBlock:(void(^)(int total, NSArray *retItemArray, NSError *error))aCompleteBlock {
    [self.request stopRequest];
    self.request = [[ClassMomentListRequest alloc] init];
    self.request.limit = [NSString stringWithFormat:@"%@", @(self.pagesize)];
    self.request.offset = [NSString stringWithFormat:@"%@", @(self.lastID)];
    WEAK_SELF
    [self.request startRequestWithRetClass:[ClassMomentListRequestItem class] andCompleteBlock:^(id retItem, NSError *error, BOOL isMock) {
        STRONG_SELF
        if (error) {
            BLOCK_EXEC(aCompleteBlock,0,nil,error);
            return;
        }
        ClassMomentListRequestItem *item = retItem;
        BLOCK_EXEC(aCompleteBlock,0,item.data.moments,nil);

        BOOL isLastPage = item.data.moments.count < self.pagesize;
        if (isLastPage) {
            BLOCK_EXEC(aCompleteBlock,0,item.data.moments,nil);
        }else {
            BLOCK_EXEC(aCompleteBlock,(int)NSIntegerMax,item.data.moments,nil);
        }
    }];
}

@end
