//
//  TaskListViewController.m
//  FaceShowApp
//
//  Created by niuzhaowang on 2017/9/14.
//  Copyright © 2017年 niuzhaowang. All rights reserved.
//

#import "TaskListViewController.h"
#import "TaskCell.h"
#import "EmptyView.h"
#import "ErrorView.h"
#import "GetAllTasksRequest.h"
#import "FSDataMappingTable.h"
#import "QuestionnaireResultViewController.h"
#import "QuestionnaireViewController.h"
#import "GetSigninRequest.h"
#import "SignInDetailViewController.h"
#import "UserPromptsManager.h"
#import "YXDrawerController.h"
#import "MJRefresh.h"
#import "HomeworkRequirementViewController.h"
#import "TaskFilterView.h"
#import "FinishedHomeworkViewController.h"
#import "GetHomeworkRequest.h"
#import "TaskCommentViewController.h"
#import "DoHomeworkViewController.h"
#import "FSTabBarController.h"
#import "UserPromptsManager.h"

extern NSString * const kPCCodeResultBackNotification;

@interface TaskListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) EmptyView *emptyView;
@property (nonatomic, strong) ErrorView *errorView;
@property (nonatomic, strong) TaskFilterView *filterView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MJRefreshHeaderView *header;
@property (nonatomic, strong) GetAllTasksRequest *request;
@property (nonatomic, strong) NSArray <GetAllTasksRequestItem_interactType *> *filterArray;
@property (nonatomic, strong) NSArray <GetAllTasksRequestItem_task *> *tasksArray;//任务列表所有数据
@property (nonatomic, strong) NSArray <GetAllTasksRequestItem_task *> *dataArray;//当前选中类型的任务数据
@property (nonatomic, strong) GetSigninRequest *getSigninRequest;
@property (nonatomic, strong) GetSignInRecordListRequestItem_SignIn *signIn;
@property (nonatomic, assign) InteractType currentType;
@property (nonatomic, assign) BOOL isLayoutComplete;
@property(nonatomic, strong) GetHomeworkRequest *getHomeworkRequest;
@end

@implementation TaskListViewController

- (void)dealloc {
    [self.header free];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    WEAK_SELF
    [self nyx_setupLeftWithImageName:@"抽屉列表按钮正常态" highlightImageName:@"抽屉列表按钮点击态" action:^{
        STRONG_SELF
        [YXDrawerController showDrawer];
    }];
    [self setupErrorView];
    [self setupObserver];
    [self requestTaskInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setupUI
- (void)setupErrorView {
    self.emptyView = [[EmptyView alloc]init];
    self.emptyView.title = @"暂无任务";
    [self.view addSubview:self.emptyView];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.emptyView.hidden = YES;
    self.errorView = [[ErrorView alloc]init];
    WEAK_SELF
    [self.errorView setRetryBlock:^{
        STRONG_SELF
        [self requestTaskInfo];
    }];
    [self.view addSubview:self.errorView];
    [self.errorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.errorView.hidden = YES;
}

- (void)setupUI {
    self.filterView = [[TaskFilterView alloc]initWithDataArray:self.filterArray];
    WEAK_SELF
    [self.filterView setTaskFilterItemChooseBlock:^(GetAllTasksRequestItem_interactType *item) {
        STRONG_SELF
        self.currentType = [FSDataMappingTable InteractTypeWithKey:item.interactType];
        [self resetFilter];
    }];
    [self.view addSubview:self.filterView];
    NSInteger rowcount = ceilf(self.filterArray.count / 3.0);
    [self.filterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(5);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(95 * rowcount);
    }];
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"ebeff2"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[TaskCell class] forCellReuseIdentifier:@"TaskCell"];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.filterView.mas_bottom).offset(5);
        make.left.right.bottom.mas_equalTo(0);
    }];
    
    self.header = [MJRefreshHeaderView header];
    self.header.scrollView = self.tableView;
    self.header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        STRONG_SELF
        [self requestTaskInfo];
    };
}

- (void)requestTaskInfo {
    [self.view nyx_startLoading];
    WEAK_SELF
    [self.request stopRequest];
    self.request = [[GetAllTasksRequest alloc] init];
    self.request.clazsId = [UserManager sharedInstance].userModel.projectClassInfo.data.clazsInfo.clazsId;
    [self.request startRequestWithRetClass:[GetAllTasksRequestItem class] andCompleteBlock:^(id retItem, NSError *error, BOOL isMock) {
        STRONG_SELF
        [self.header endRefreshing];
        [self.view nyx_stopLoading];
        self.errorView.hidden = YES;
        self.emptyView.hidden = YES;
        if (error) {
            self.errorView.hidden = NO;
            return;
        }
        GetAllTasksRequestItem *item = (GetAllTasksRequestItem *)retItem;
        if (isEmpty(item.data)) {
            self.emptyView.hidden = NO;
            return;
        }
        self.tasksArray = [NSArray arrayWithArray:item.data.tasks];
        self.filterArray = [NSArray arrayWithArray:item.data.interactTypes];
        self.dataArray = [self filterWithType:self.currentType];
        if (self.dataArray.count == 0) {
            [self.view nyx_showToast:@"暂无此类型的任务哦"];
        }
        if (!self.isLayoutComplete) {
            [self setupUI];
            self.currentType = InteractType_SignIn;
            [self resetFilter];
            self.isLayoutComplete = YES;
        }else {
            self.filterView.dataArray = self.filterArray;
        }
        self.filterView.selectedIndex = [self indexForInteractType:self.currentType];
        [self.tableView reloadData];
    }];
}
#pragma mark - filter
- (NSArray *)filterWithType:(InteractType)type {
    NSMutableArray *resultArray = [NSMutableArray array];
    for (int i = 0; i < self.tasksArray.count; i++) {
        GetAllTasksRequestItem_task *task = self.tasksArray[i];
        InteractType taskType = [FSDataMappingTable InteractTypeWithKey:task.interactType];
        if (taskType == type) {
            [resultArray addObject:task];
        }
    }
    return resultArray;
}

#pragma mark - Observer
- (void)setupObserver {
    WEAK_SELF
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"kReloadSignInRecordNotification" object:nil] subscribeNext:^(NSNotification *x) {
        STRONG_SELF
//        NSDictionary *dic = (NSDictionary *)x.object;
//        NSIndexPath *currentIndex = [dic objectForKey:@"kSignInRecordCurrentIndexPath"];
//        NSString *signInTime = [dic valueForKey:@"kCurrentIndexPathSucceedSigninTime"];
//        GetSignInRecordListRequestItem_SignIn *signIn = self.signIn;
//        GetSignInRecordListRequestItem_UserSignIn *userSignIn = [GetSignInRecordListRequestItem_UserSignIn new];
//        userSignIn.signinTime = signInTime;
//        signIn.userSignIn = userSignIn;
//        GetAllTasksRequestItem_task *task = self.dataArray[currentIndex.row];
//        task.stepFinished = @"1";
//        [self.tableView reloadRowsAtIndexPaths:@[currentIndex] withRowAnimation:UITableViewRowAnimationNone];
        self.currentType = InteractType_SignIn;
        [self requestTaskInfo];
    }];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kHomeworkFinishedNotification object:nil] subscribeNext:^(NSNotification *x) {
        STRONG_SELF
        [self.dataArray enumerateObjectsUsingBlock:^(GetAllTasksRequestItem_task * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            STRONG_SELF
            self.currentType = InteractType_Homework;
            [self requestTaskInfo];
        }];
    }];
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:kTabBarDidSelectNotification object:nil]subscribeNext:^(NSNotification *x) {
        STRONG_SELF
        if (self.navigationController == x.object) {
            [self requestTaskInfo];
        }
    }];
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:kPCCodeResultBackNotification object:nil]subscribeNext:^(id x) {
        STRONG_SELF
        [self.navigationController popToViewController:self animated:YES];
    }];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kHasNewCertificateNotification object:nil]subscribeNext:^(id x) {
        STRONG_SELF
        UIBarButtonItem *navItem = self.navigationItem.leftBarButtonItems.lastObject;
        UIButton *customBtn = (UIButton *)navItem.customView;
        UIView *redPointView = [[UIView alloc] init];
        redPointView.layer.cornerRadius = 4.5f;
        redPointView.backgroundColor = [UIColor colorWithHexString:@"ff0000"];
        [customBtn.imageView addSubview:redPointView];
        [redPointView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-3.5);
            make.top.mas_equalTo(3.5);
            make.size.mas_equalTo(CGSizeMake(9, 9));
        }];
    }];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kHasReadCertificateNotification object:nil] subscribeNext:^(id x) {
        STRONG_SELF
        UIBarButtonItem *navItem = self.navigationItem.leftBarButtonItems.lastObject;
        UIButton *customBtn = (UIButton *)navItem.customView;
        [customBtn.imageView removeSubviews];
    }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TaskCell"];
    cell.task = self.dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GetAllTasksRequestItem_task *task = self.dataArray[indexPath.row];
    InteractType type = [FSDataMappingTable InteractTypeWithKey:task.interactType];
    if (type == InteractType_SignIn) {
        [self.getSigninRequest stopRequest];
        self.getSigninRequest = [[GetSigninRequest alloc]init];
        self.getSigninRequest.stepId = task.stepId;
        WEAK_SELF
        [self.view nyx_startLoading];
        [self.getSigninRequest startRequestWithRetClass:[GetSigninRequestItem class] andCompleteBlock:^(id retItem, NSError *error, BOOL isMock) {
            STRONG_SELF
            [self.view nyx_stopLoading];
            if (error) {
                [self.view nyx_showToast:error.localizedDescription];
                return;
            }
            GetSigninRequestItem *item = retItem;
            item.data.signIn.stepId = task.stepId;
            SignInDetailViewController *signInDetailVC = [[SignInDetailViewController alloc] init];
            signInDetailVC.signIn = item.data.signIn;
            signInDetailVC.currentIndexPath = indexPath;
            [self.navigationController pushViewController:signInDetailVC animated:YES];
        }];
    }else if (type == InteractType_Homework) {
        [self.getHomeworkRequest stopRequest];
        self.getHomeworkRequest = [[GetHomeworkRequest alloc]init];
        self.getHomeworkRequest.stepId = task.stepId;
        WEAK_SELF
        [self.view nyx_startLoading];
        [self.getHomeworkRequest startRequestWithRetClass:[GetHomeworkRequestItem class] andCompleteBlock:^(id retItem, NSError *error, BOOL isMock) {
            STRONG_SELF
            [self.view nyx_stopLoading];
            if (error) {
                [self.view nyx_showToast:error.localizedDescription];
                return;
            }
            GetHomeworkRequestItem *item = (GetHomeworkRequestItem *)retItem;
            if ([item.data.userHomework.finishStatus isEqualToString:@"1"]) {
                FinishedHomeworkViewController *vc = [[FinishedHomeworkViewController alloc]init];
                vc.userHomework = item.data.userHomework;
                vc.homework = item.data.homework;
                [self.navigationController pushViewController:vc animated:YES];
            }else {
                HomeworkRequirementViewController *vc = [[HomeworkRequirementViewController alloc]init];
                vc.homework = item.data.homework;
                vc.userHomework = item.data.userHomework;
                vc.isFinished = NO;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
    }else if (type == InteractType_Evaluate) {
        QuestionnaireViewController *vc = [[QuestionnaireViewController alloc]initWithStepId:task.stepId interactType:type];
        vc.name = task.interactName;
        WEAK_SELF
        [vc setCompleteBlock:^{
            STRONG_SELF
            self.currentType = InteractType_Evaluate;
            [self requestTaskInfo];
            [self checkIfHasUncompleteTask];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (type == InteractType_Questionare) {
        QuestionnaireViewController *vc = [[QuestionnaireViewController alloc]initWithStepId:task.stepId interactType:type];
        vc.name = task.interactName;
        WEAK_SELF
        [vc setCompleteBlock:^{
            STRONG_SELF
            self.currentType = InteractType_Questionare;
            [self requestTaskInfo];
            [self checkIfHasUncompleteTask];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (type == InteractType_Vote) {
        if (task.stepFinished.boolValue) {
            QuestionnaireResultViewController *vc = [[QuestionnaireResultViewController alloc]initWithStepId:task.stepId];
            vc.name = task.interactName;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            QuestionnaireViewController *vc = [[QuestionnaireViewController alloc]initWithStepId:task.stepId interactType:type];
            vc.name = task.interactName;
            WEAK_SELF
            [vc setCompleteBlock:^{
                STRONG_SELF
                self.currentType = InteractType_Vote;
                [self requestTaskInfo];
                [self checkIfHasUncompleteTask];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if (type == InteractType_Comment) {
        TaskCommentViewController *vc = [[TaskCommentViewController alloc]initWithStepId:task.stepId];
        vc.title = task.interactName;
        WEAK_SELF
        [vc setCompleteBlock:^{
            STRONG_SELF
            self.currentType = InteractType_Comment;
            [self requestTaskInfo];
            [self checkIfHasUncompleteTask];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)checkIfHasUncompleteTask {
    for (GetAllTasksRequestItem_task *task in self.dataArray) {
        InteractType type = [FSDataMappingTable InteractTypeWithKey:task.interactType];
        if (task.stepFinished.integerValue!=1 && (type==InteractType_Vote || type==InteractType_Questionare || type == InteractType_Comment || type == InteractType_Evaluate || type == InteractType_Homework)) {
            return;
        }
    }
    [UserPromptsManager sharedInstance].taskNewView.hidden = YES;
}

- (void)resetFilter {
    self.dataArray = [self filterWithType:self.currentType];
    [self.tableView reloadData];
    if (self.dataArray.count == 0) {
        [self.view nyx_showToast:@"暂无此类型的任务哦"];
    }
}

- (NSInteger)indexForInteractType:(InteractType)type {
    __block NSInteger index = 0;
    WEAK_SELF
    [self.filterArray enumerateObjectsUsingBlock:^(GetAllTasksRequestItem_interactType * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        STRONG_SELF
        if ([FSDataMappingTable InteractTypeWithKey:obj.interactType] == type) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}
@end
