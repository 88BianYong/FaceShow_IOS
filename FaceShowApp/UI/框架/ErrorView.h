//
//  ErrorView.h
//  FaceShowApp
//
//  Created by niuzhaowang on 2017/9/13.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ErrorView : UIView
@property (nonatomic, copy) void(^retryBlock)();
@end
