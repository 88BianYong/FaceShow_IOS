//
//  MessageDetailViewController.m
//  FaceShowApp
//
//  Created by LiuWenXing on 2017/9/17.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "GetNoticeDetailRequest.h"
#import "ErrorView.h"

@interface MessageDetailViewController ()

@property (nonatomic, strong) ErrorView *errorView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *detailImageView;
@property (nonatomic, strong) GetNoticeDetailRequest *request;
@property (nonatomic, strong) GetNoticeDetailRequestItem_Data *data;
@end

@implementation MessageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"通知详情";
    
    self.errorView = [[ErrorView alloc] init];
    WEAK_SELF
    [self.errorView setRetryBlock:^{
        STRONG_SELF
        [self setupNoticeData];
    }];
    [self.view addSubview:self.errorView];
    [self.errorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.errorView.hidden = YES;
    
    [self setupNoticeData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNoticeData {
    [self.view nyx_startLoading];
    [self.request stopRequest];
    self.request = [[GetNoticeDetailRequest alloc] init];
    WEAK_SELF
    [self.request startRequestWithRetClass:[GetNoticeDetailRequestItem class] andCompleteBlock:^(id retItem, NSError *error, BOOL isMock) {
        STRONG_SELF
        [self.view nyx_stopLoading];
        if (error) {
            self.errorView.hidden = NO;
            return;
        }
        GetNoticeDetailRequestItem *item = (GetNoticeDetailRequestItem *)retItem;
        self.data = item.data;
        [self setupUI];
        BLOCK_EXEC(self.fetchNoticeDetailSucceedBlock);
    }];
}

#pragma mark - setupUI
- (void)setupUI {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor colorWithHexString:@"ebeff2"];
    [self.contentView addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(5);
    }];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.textColor = [UIColor colorWithHexString:@"333333"];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 0;
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(25);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.centerX.mas_equalTo(0);
    }];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [UIFont systemFontOfSize:13];
    self.timeLabel.textColor = [UIColor colorWithHexString:@"999999"];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(15);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.centerX.mas_equalTo(0);
    }];
    
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.numberOfLines = 0;
    [self.contentView addSubview:self.detailLabel];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(19);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
    }];
    
    self.detailImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.detailImageView];
    [self.detailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.detailLabel.mas_bottom).offset(22);
        make.left.mas_equalTo(15);
        make.right.bottom.mas_equalTo(-15);
    }];
    [self setModel];
}

- (void)setModel {
    self.titleLabel.text = self.data.title;
    self.timeLabel.text = self.data.createTime;
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:self.data.content];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.minimumLineHeight = 21;
    [attributedStr setAttributes:@{
                                   NSParagraphStyleAttributeName : style,
                                   NSFontAttributeName : [UIFont systemFontOfSize:14],
                                   NSForegroundColorAttributeName : [UIColor colorWithHexString:@"333333"]
                                   } range:NSMakeRange(0, attributedStr.length)];
    self.detailLabel.attributedText = attributedStr;
    
    [self.detailImageView sd_setImageWithURL:[NSURL URLWithString:self.data.attachUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image) {
            self.detailImageView.image = [image nyx_aspectFitImageWithSize:CGSizeMake(SCREEN_WIDTH - 30, (SCREEN_WIDTH - 30) / image.size.width * image.size.height)];
        }
    }];
}

@end
