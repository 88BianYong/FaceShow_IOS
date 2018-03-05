//
//  IMImageMessageRightCell.m
//  FaceShowApp
//
//  Created by ZLL on 2018/3/2.
//  Copyright © 2018年 niuzhaowang. All rights reserved.
//

#import "IMImageMessageRightCell.h"

@implementation IMImageMessageRightCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessage:(IMTopicMessage *)message {
    [super setMessage:message];
    
    [self.avatarButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(15.f);
        make.right.mas_equalTo(-15.f);
        make.size.mas_equalTo(CGSizeMake(40.f, 40.f));
    }];
    
    self.usernameLabel.hidden = YES;
    [self.usernameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    
    [self.messageBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatarButton.mas_top);
        make.right.equalTo(self.avatarButton.mas_left).offset(-5.f).priorityHigh();
        make.bottom.mas_equalTo(0.f);
        make.left.mas_greaterThanOrEqualTo(75 * kPhoneWidthRatio);
    }];
    
    [self.stateButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.messageBackgroundView.mas_centerY).offset(-5);
        make.right.equalTo(self.messageBackgroundView.mas_left).offset(-5.f);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
}

@end
