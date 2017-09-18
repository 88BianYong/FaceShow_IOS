//
//  ClassMomentLikeView.h
//  FaceShowApp
//
//  Created by 郑小龙 on 2017/9/18.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ClassMomentLikeType)  {
    ClassMomentLikeType_Comment = 1,//只有评论
    ClassMomentLikeType_Like = 2,//只有点赞
    ClassMomentLikeType_Double = 3//评论点赞都有
    
};
@interface ClassMomentLikeView : UIView
@property (nonatomic, assign) ClassMomentLikeType type;
@end
