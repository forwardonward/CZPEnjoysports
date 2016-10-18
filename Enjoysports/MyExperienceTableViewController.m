//
//  MyExperienceTableViewController.m
//  Calorie
//
//  Created by Z on 16/5/7.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "MyExperienceTableViewController.h"
#import "LeftTableViewCell.h"
#import "RightTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "TabBarViewController.h"
#import "ExperienceViewController.h"
#import "LeftViewController.h"
#import "HomeNavViewController.h"

@interface MyExperienceTableViewController (){
    BOOL isLoading;
}

@property (nonatomic, strong)NSMutableArray *dataArray;
@property (strong,nonatomic) ECSlidingViewController *slidingVc;

@end

@implementation MyExperienceTableViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = backButton;
    
    //取消tableview下划线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //去掉tableView的滚动条
    self.tableView.showsVerticalScrollIndicator = NO;

}

//回首页
- (void)back{
//    //这里跳转到首页
//    LeftViewController * leftVc = [Utilities getStoryboard:@"Home" instanceByIdentity:@"LeftVc"];
//    TabBarViewController * tabView = [Utilities getStoryboard:@"Home" instanceByIdentity:@"TabView"];
//    //----------------------侧滑开始 center----------------------
//    //初始化侧滑框架,并且设置中间显示的页面
//    _slidingVc = [ECSlidingViewController slidingWithTopViewController:tabView];
//    //设置侧滑 的  耗时
//    _slidingVc.defaultTransitionDuration = 0.25f;
//    //设置 控制侧滑的手势   (这里同时对触摸 和 拖拽相应)
//    _slidingVc.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGesturePanning | ECSlidingViewControllerAnchoredGestureTapping;
//    //设置上述手势的识别范围
//    [tabView.view addGestureRecognizer:_slidingVc.panGesture];
//    //----------------------侧滑开始 left----------------------
//    _slidingVc.underLeftViewController = leftVc;
//    //设置侧滑的开闭程度   (peek都是设置中间的页面出现的宽度 )
//    _slidingVc.anchorRightPeekAmount = UI_SCREEN_W / 4;
//    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuSwitchAction) name:@"MenuSwitch" object:nil];
//    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(EnableGestureAction) name:@"EnableGesture" object:nil];
//    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DisableGestureAction) name:@"DisableGesture" object:nil];
//    
//    HomeNavViewController *homeNav = [[HomeNavViewController alloc]initWithRootViewController:_slidingVc];
//    _slidingVc.navigationController.navigationBar.hidden = YES;
//    
//    [self presentViewController:homeNav animated:YES completion:nil];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isLoading = true;
    _dataArray = [NSMutableArray new];
    [self getExperienceList];
    
    //监听是否重新进入程序程序.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    NSString *str;
    BOOL flags;
    if([[Utilities getUserDefaults:@"OrLogin"] boolValue]){
        //如果登录了那么这里在判断  上一次是否按了退出按钮   yse  表示按了
        if ( [[Utilities getUserDefaults:@"AddUserAndPw"] boolValue]) {
            
        }else{
            str = [Utilities getUserDefaults:@"switchUser"];
            if ([str isEqualToString:@"openUser"]) {
                if ([Utilities getUserDefaults:@"switch"]) {
                    str = [Utilities getUserDefaults:@"switch"];
                }else{
                    str = @"close";
                }
                
                if ([str isEqualToString:@"close"]) {
                    flags = NO;
                }else{
                    flags = YES;
                }
                
                if (flags) {
                    
                    SecureViewController *secureVc = [Utilities getStoryboard:@"Sliding" instanceByIdentity:@"secureVc"];
                    secureVc.touchHome = YES;
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"TouchHome" object:nil];
                    [self presentViewController:secureVc animated:YES completion:nil];
                    
                }else{
                    ;
                }
            }
            
        }
    }
}

- (void)getExperienceList{
    /*
     订单
     /orderController/orderList
     GET
     入参：memberId（用户ID）；type（订单类型，0表示所有订单）
     出参：resultFlag（8001成功）
     */
    NSString *netUrl = @"/orderController/orderList";
    NSString *userId = [[StorageMgr singletonStorageMgr] objectForKey:@"memberId"];
    NSDictionary *parameters = @{
                            @"memberId":userId,
                            @"type":@0
                            };
    __weak MyExperienceTableViewController *weakSelf = self;
    //
    [RequestAPI getURL:netUrl withParameters:parameters success:^(id responseObject) {
        isLoading = false;
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            NSLog(@"res = %@",responseObject);
            NSDictionary *result = responseObject[@"result"];
            NSArray *array = result[@"orderList"];
            for (int i = 0; i < array.count; i++) {
                NSDictionary *dict = array[i];
                //特别注意，这里做判断是为了显示订单是体验券的(毕竟这是用来查询订单的）
                if ([dict[@"type"] integerValue] == 1) {
                    [_dataArray addObject:array[i]];
                }
            }
            [weakSelf.tableView reloadData];
        }else{
            [Utilities popUpAlertViewWithMsg:@"" andTitle:[NSString stringWithFormat:@"错误%@",responseObject[@"resultFlag"]] onView:self];
        }
    } failure:^(NSError *error) {
        isLoading = false;
        [Utilities popUpAlertViewWithMsg:@"" andTitle:[NSString stringWithFormat:@"网络错误%ld",error.code]onView:self];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 0) {
        LeftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftCell" forIndexPath:indexPath];
        NSDictionary *dict = _dataArray[indexPath.row];
        [cell.experienceImg sd_setImageWithURL:dict[@"imgUrl"]];
        cell.clubLable.text = dict[@"clubName"];
        cell.experienceLable.text = dict[@"productName"];
        return cell;
    }else{
        RightTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rightCell" forIndexPath:indexPath];
        NSDictionary *dict = _dataArray[indexPath.row];
        [cell.experienceImg sd_setImageWithURL:dict[@"imgUrl"]];
        cell.clubLable.text = dict[@"clubName"];
        cell.experienceLable.text = dict[@"productName"];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ExperienceViewController *experienceView = [Utilities getStoryboard:@"Home" instanceByIdentity:@"experienceVc"];
    [self.navigationController pushViewController:experienceView animated:true];
    NSDictionary *dict = _dataArray[indexPath.row];
    experienceView.experienceInfos = dict[@"orderId"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            return 150;
            break;
        default:
            return 150;
            break;
    }
}

- (void) menuSwitchAction{
    //如果中间那扇门在在右侧，说明  已经被侧滑  因此需要关闭
    if (_slidingVc.currentTopViewPosition == ECSlidingViewControllerTopViewPositionAnchoredRight) {
        //中间  页面向左滑
        [_slidingVc resetTopViewAnimated:YES];
    }else {
        //中间  页面向右滑
        [_slidingVc anchorTopViewToRightAnimated:YES];
    }
}
- (void)EnableGestureAction{
    _slidingVc.panGesture.enabled = YES;
}
//关闭 侧滑手势
- (void)DisableGestureAction{
    _slidingVc.panGesture.enabled = NO;
}

@end
