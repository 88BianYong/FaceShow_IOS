//
//  LoginRequest.h
//  FaceShowApp
//
//  Created by LiuWenXing on 2017/9/20.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import "YXGetRequest.h"

@interface LoginRequest : YXGetRequest
@property (nonatomic, strong) NSString *loginName;
@property (nonatomic, strong) NSString *password;
@end
