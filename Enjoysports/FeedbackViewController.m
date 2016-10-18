//
//  FeedbackViewController.m
//  Calorie
//
//  Created by 杨凡 on 16/5/12.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "FeedbackViewController.h"
#import "TabBarViewController.h"
#import "LeftViewController.h"
#import "HomeNavViewController.h"

@interface FeedbackViewController ()
@property (strong,nonatomic) ECSlidingViewController *slidingVc;
@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(submit)];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = submitButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

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
//提交反馈意见
- (void)submit{
    NSString *userID = [[StorageMgr singletonStorageMgr]objectForKey:@"memberId"];
    NSString *message = _textView.text;
    
    NSLog(@"memberId = %@", userID);
    NSLog(@"message = %@", message);
    
    NSDictionary *dict = @{@"memberId":userID,
                           @"message":message
                           };
    [RequestAPI getURL:@"/systemConfigController/feedbackMessage" withParameters:dict success:^(id responseObject) {
        if ([responseObject[@"resultFlag"]integerValue] == 8001) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"提交成功！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self back];
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            [Utilities popUpAlertViewWithMsg:[NSString stringWithFormat:@"请保持网络通畅%@",responseObject[@"resultFlag"]]andTitle:nil onView:self];
        }
    } failure:^(NSError *error) {
        NSLog(@"error = %@",error.description);
        [Utilities popUpAlertViewWithMsg:@"请保持网络通畅" andTitle:nil onView:self];
    }];
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

#pragma mark - textView

//空白处收回键盘
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
