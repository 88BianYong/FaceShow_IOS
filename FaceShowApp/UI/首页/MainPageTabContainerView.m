//
//  MainPageTabContainerView.m
//  FaceShowApp
//
//  Created by niuzhaowang on 2017/9/14.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import "MainPageTabContainerView.h"
#import "UserPromptsManager.h"

@interface MainPageTabContainerView()
@property (nonatomic, strong) NSMutableArray *tabButtonArray;
@property (nonatomic, strong) UIView *sliderView;
@end

@implementation MainPageTabContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setTabNameArray:(NSArray *)tabNameArray {
    _tabNameArray = tabNameArray;
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    self.tabButtonArray = [NSMutableArray array];
    CGFloat tabWidth = SCREEN_WIDTH/tabNameArray.count;
    [tabNameArray enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *b = [[UIButton alloc]init];
        [b setTitle:obj forState:UIControlStateNormal];
        [b setTitleColor:[UIColor colorWithHexString:@"999999"] forState:UIControlStateNormal];
        [b setTitleColor:[UIColor colorWithHexString:@"333333"] forState:UIControlStateSelected];
        b.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [b addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:b];
        [b mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.left.mas_equalTo(tabWidth*idx);
            make.width.mas_equalTo(tabWidth);
        }];
        [self.tabButtonArray addObject:b];
        if (idx == 0) {
            b.selected = YES;
        }
    }];
    self.sliderView = [[UIView alloc]init];
    self.sliderView.backgroundColor = [UIColor colorWithHexString:@"1da1f2"];
    [self addSubview:self.sliderView];
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.mas_equalTo(0);
        make.height.mas_equalTo(2);
        make.width.mas_equalTo(tabWidth);
    }];
    
    UIView *resourceNewView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 3 / 8 + 5, 6, 9, 9)];
    resourceNewView.layer.cornerRadius = 4.5f;
    resourceNewView.backgroundColor = [UIColor colorWithHexString:@"ff0000"];
    resourceNewView.hidden = YES;
    [self addSubview:resourceNewView];
    [self bringSubviewToFront:resourceNewView];
    [UserPromptsManager sharedInstance].resourceNewView = resourceNewView;
    
    UIView *momentNewView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * 5 / 8 + 5, 6, 9, 9)];
    momentNewView.layer.cornerRadius = 4.5f;
    momentNewView.backgroundColor = [UIColor colorWithHexString:@"ff0000"];
    momentNewView.hidden = YES;
    [self addSubview:momentNewView];
    [self bringSubviewToFront:momentNewView];
    [UserPromptsManager sharedInstance].taskNewView = momentNewView;
}

- (void)btnAction:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    for (UIButton *b in self.tabButtonArray) {
        b.selected = NO;
    }
    sender.selected = YES;
    CGFloat tabWidth = SCREEN_WIDTH/self.tabNameArray.count;
    NSInteger index = [self.tabButtonArray indexOfObject:sender];
    [UIView animateWithDuration:0.2 animations:^{
        [self.sliderView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(tabWidth*index);
        }];
        [self layoutIfNeeded];
    }];
    BLOCK_EXEC(self.tabClickBlock,index);
}

@end
