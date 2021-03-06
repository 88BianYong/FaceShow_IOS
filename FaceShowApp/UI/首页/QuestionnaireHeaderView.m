//
//  QuestionnaireHeaderView.m
//  FaceShowApp
//
//  Created by niuzhaowang on 2017/9/25.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import "QuestionnaireHeaderView.h"

@interface QuestionnaireHeaderView()
@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *descLabel;
@end

@implementation QuestionnaireHeaderView

- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    self.backgroundColor = [UIColor colorWithHexString:@"ebeff2"];
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(5);
        make.bottom.mas_equalTo(-5);
    }];
    self.bgView = bgView;
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.backgroundColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.titleLabel.textColor = [UIColor colorWithHexString:@"333333"];
    self.titleLabel.numberOfLines = 0;
    [bgView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(15);
    }];
    
    self.descLabel = [[UILabel alloc]init];
    self.descLabel.backgroundColor = [UIColor whiteColor];
    self.descLabel.font = [UIFont systemFontOfSize:13];
    self.descLabel.textColor = [UIColor colorWithHexString:@"333333"];
    self.descLabel.numberOfLines = 0;
    [self.bgView addSubview:self.descLabel];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(5.f);
//        make.bottom.mas_equalTo(-20);
    }];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineHeightMultiple = 1.2;
    NSDictionary *dic = @{NSParagraphStyleAttributeName:paraStyle};
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:title attributes:dic];
    self.titleLabel.attributedText = attributeStr;
}

- (void)setDesc:(NSString *)desc {
    _desc = desc;
    if (desc.length > 0) {
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.lineHeightMultiple = 1.2;
        NSDictionary *dic = @{NSParagraphStyleAttributeName:paraStyle};
        NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:desc attributes:dic];
        self.descLabel.attributedText = attributeStr;
    }
}

+ (CGFloat)heightForTitle:(NSString *)title desc:(NSString *)desc {
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont boldSystemFontOfSize:18];
    label.numberOfLines = 0;
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineHeightMultiple = 1.2;
    NSDictionary *dic = @{NSParagraphStyleAttributeName:paraStyle};
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:title attributes:dic];
    label.attributedText = attributeStr;
    CGSize size = [label sizeThatFits:CGSizeMake(SCREEN_WIDTH-30, CGFLOAT_MAX)];
    
    if (desc.length > 0) {
        UILabel *label1 = [[UILabel alloc]init];
        label1.font = [UIFont systemFontOfSize:13];
        label1.numberOfLines = 0;
        NSMutableParagraphStyle *paraStyle1 = [[NSMutableParagraphStyle alloc] init];
        paraStyle1.lineHeightMultiple = 1.2;
        NSDictionary *dic1 = @{NSParagraphStyleAttributeName:paraStyle};
        NSAttributedString *attributeStr1 = [[NSAttributedString alloc] initWithString:desc attributes:dic1];
        label1.attributedText = attributeStr1;
        CGSize size1 = [label1 sizeThatFits:CGSizeMake(SCREEN_WIDTH-30, CGFLOAT_MAX)];
        
        return size.height+50+size1.height;
    }
    
    return size.height + 50 + 10;
}

@end
