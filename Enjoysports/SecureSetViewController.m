//
//  SecureSetViewController.m
//  Calorie
//
//  Created by xyl on 16/5/8.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "SecureSetViewController.h"

//cells
#import "OpenOrCloseTableViewCell.h"
#import "SetPwdTableViewCell.h"

#import "SecureViewController.h"
#import "TabBarViewController.h"
#import "LeftViewController.h"

#import "HomeNavViewController.h"
@interface SecureSetViewController ()<UITableViewDelegate,UITableViewDataSource,SwitchTableViewDelegate>{
    NSInteger mycount;
    BOOL flag;
    BOOL setting;
    NSString *str;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) ECSlidingViewController *slidingVc;
@end

@implementation SecureSetViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //取消tableview下划线
    //    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //去掉tableView的滚动条
    self.tableView.showsVerticalScrollIndicator = NO;
    
    mycount = 1;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    self.navigationItem.leftBarButtonItem.title = @"";
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
//                                                 name:UIApplicationWillResignActiveNotification object:nil]; //监听是否触发home键挂起程序.
    
    //监听是否重新进入程序程序.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
        {
            OpenOrCloseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
//            //设置ON一边的背景颜色，默认是绿色
//            cell.switchBtn.onTintColor = [UIColor yellowColor];
//            //设置OFF一边的背景颜色，默认是灰色，发现OFF背景颜色其实也是控件”边框“颜色
//            cell.switchBtn.tintColor = [UIColor purpleColor];
//            //设置划块颜色
//            cell.switchBtn.thumbTintColor=[UIColor greenColor];
            if ([Utilities getUserDefaults:@"switch"]) {
                str = [Utilities getUserDefaults:@"switch"];
            }else{
                str = @"close";
            }
            
            if ([str isEqualToString:@"close"]) {
                setting = NO;
            }else{
                setting = YES;
            }
            
            [cell.switchBtn setOn:setting];
            cell.delegate = self;
            cell.indexPath = indexPath;
            return cell;
        }
            break;
            
        default:
        {
            SetPwdTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
            return cell;
        }
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    //取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            
        }
            break;
        case 1:
        {
            SecureViewController *secureVc = [Utilities getStoryboard:@"Sliding" instanceByIdentity:@"secureVc"];
            [self.navigationController pushViewController:secureVc animated:YES];
            [[StorageMgr singletonStorageMgr]removeObjectForKey:@"SetPwdBool"];
            [[StorageMgr singletonStorageMgr]addKey:@"SetPwdBool" andValue:@YES];
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - SwitchTableViewDelegate

- (void)switchChangeValue:(NSIndexPath *)indexPath switchs:(id)sender;{
    UISwitch *swithBtn = (UISwitch *)sender;
    if ([swithBtn isOn]) {
        flag = YES;
        [Utilities removeUserDefaults:@"switchUser"];
        [Utilities setUserDefaults:@"switchUser" content:@"openUser"];
        [Utilities removeUserDefaults:@"switch"];
        [Utilities setUserDefaults:@"switch" content:@"open"];
    }else{
        flag = NO;
        [Utilities removeUserDefaults:@"switchUser"];
        [Utilities setUserDefaults:@"switchUser" content:@"closeUser"];
        [Utilities removeUserDefaults:@"switch"];
        [Utilities setUserDefaults:@"switch" content:@"close"];
    }
}

- (IBAction)JumpHome:(UIBarButtonItem *)sender {
    //这里跳转到首页
    LeftViewController * leftVc = [Utilities getStoryboard:@"Home" instanceByIdentity:@"LeftVc"];
    TabBarViewController * tabView = [Utilities getStoryboard:@"Home" instanceByIdentity:@"TabView"];
    //----------------------侧滑开始 center----------------------
    //初始化侧滑框架,并且设置中间显示的页面
    _slidingVc = [ECSlidingViewController slidingWithTopViewController:tabView];
    //设置侧滑 的  耗时
    _slidingVc.defaultTransitionDuration = 0.25f;
    //设置 控制侧滑的手势   (这里同时对触摸 和 拖拽相应)
    _slidingVc.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGesturePanning | ECSlidingViewControllerAnchoredGestureTapping;
    //设置上述手势的识别范围
    [tabView.view addGestureRecognizer:_slidingVc.panGesture];
    //----------------------侧滑开始 left----------------------
    _slidingVc.underLeftViewController = leftVc;
    //设置侧滑的开闭程度   (peek都是设置中间的页面出现的宽度 )
    _slidingVc.anchorRightPeekAmount = UI_SCREEN_W / 4;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(menuSwitchAction) name:@"MenuSwitch" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(EnableGestureAction) name:@"EnableGesture" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DisableGestureAction) name:@"DisableGesture" object:nil];
    //
    HomeNavViewController *homeNav = [[HomeNavViewController alloc]initWithRootViewController:_slidingVc];
    _slidingVc.navigationController.navigationBar.hidden = YES;
    
    [self presentViewController:homeNav animated:YES completion:nil];
    
    [[StorageMgr singletonStorageMgr]removeObjectForKey:@"SetPwdBool"];
}

#pragma mark - NSNotificationCenter

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
//激活 侧滑手势
- (void)EnableGestureAction{
    _slidingVc.panGesture.enabled = YES;
}
//关闭 侧滑手势
- (void)DisableGestureAction{
    _slidingVc.panGesture.enabled = NO;
}

//-----------------------------
//- (void)applicationWillResignActive:(NSNotification *)notification
//{
//    
//}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
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
                    flag = NO;
                }else{
                    flag = YES;
                }
                
                if (flag) {
                    
                    SecureViewController *secureVc = [Utilities getStoryboard:@"Sliding" instanceByIdentity:@"secureVc"];
                    secureVc.touchHome = YES;
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"TouchHome" object:nil];
                    [self presentViewController:secureVc animated:YES completion:nil];
                    
                }else{
                    
                }
            }
            
        }
    }
            
}
@end
