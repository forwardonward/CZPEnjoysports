//
//  SecureViewController.m
//  Calorie
//
//  Created by xyl on 16/5/7.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "SecureViewController.h"
#import "HomeNavViewController.h"
#import "LeftViewController.h"
#import "TabBarViewController.h"
#import "SecureSetViewController.h"

@interface SecureViewController (){
    BOOL setPwdBool;
}
@property (strong,nonatomic) ECSlidingViewController *slidingVc;
@end

@implementation SecureViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //用完之后改成no，切记(在view 中)
    if ([[StorageMgr singletonStorageMgr]objectForKey:@"SetPwdBool"]) {
        setPwdBool = NO;
    }else{
        setPwdBool = YES;
    }
    
    if (setPwdBool) {
        if (_touchHome == YES) {
            self.navigationItem.leftBarButtonItem.enabled = NO;
            self.navigationItem.rightBarButtonItem.enabled = NO;
            self.navigationItem.rightBarButtonItem.title = @"";
            self.navigationItem.leftBarButtonItem.title = @"";
        }
        
        _password = [Utilities getUserDefaults:@"SecurePwd"];
        self.navigationItem.title = @"安全锁";
        self.navigationItem.rightBarButtonItem.title = @"";
        self.navigationItem.rightBarButtonItem.enabled = NO;
        if(_password == nil){
            _messageLab.text = @"请设置手势密码:";
        }else{
            _messageLab.text = @"请输入您的密码:";
        }
    }else{
        self.navigationItem.title = @"修改密码";
        self.navigationItem.rightBarButtonItem.title = @"保存";
        self.navigationItem.rightBarButtonItem.enabled = NO;
        _messageLab.text = @"请设置您的新密码";
        NSString *str = [Utilities getUserDefaults:@"SecurePwd"];
        [Utilities setUserDefaults:@"OldPwd" content:str];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(Success) name:@"Success" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(NotSuccess) name:@"NotSuccess" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(SecondSet) name:@"SecondSet" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pwdFalse) name:@"pwdFalse" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(JumpSet) name:@"JumpSet" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setPwd) name:@"setPwd" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pwdLength) name:@"pwdLength" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(rightBtn) name:@"rightBtn" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pwdNot) name:@"pwdNot" object:nil];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (IBAction)jumpHome:(UIBarButtonItem *)sender {
    if (setPwdBool) {
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
            
            HomeNavViewController *homeNav = [[HomeNavViewController alloc]initWithRootViewController:_slidingVc];
            _slidingVc.navigationController.navigationBar.hidden = YES;
            
            [self presentViewController:homeNav animated:YES completion:nil];

    }else {
        [self.navigationController popViewControllerAnimated:YES];
        NSString *str = [Utilities getUserDefaults:@"OldPwd"];
        [Utilities removeUserDefaults:@"SecurePwd"];
        [Utilities setUserDefaults:@"SecurePwd" content:str];
    }
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

- (void)Success{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"设置成功" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            SecureSetViewController *secureSetVc = [Utilities getStoryboard:@"Sliding" instanceByIdentity:@"secureSetVc"];
            [self.navigationController pushViewController:secureSetVc animated:YES];
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
}

- (void)NotSuccess{
    [Utilities popUpAlertViewWithMsg:@"设置失败，两次绘制的密码请保持一致" andTitle:nil onView:self];
}

- (void)SecondSet{
    [Utilities popUpAlertViewWithMsg:@"请再次绘制" andTitle:nil onView:self];
}

- (void)pwdFalse{
    [Utilities popUpAlertViewWithMsg:@"密码错误" andTitle:nil onView:self];
}

- (void)JumpSet{
    if (_touchHome) {
        [self dismissViewControllerAnimated:YES completion:nil];
        _touchHome = NO;
        return;
    }
    SecureSetViewController *secureSetVc = [Utilities getStoryboard:@"Sliding" instanceByIdentity:@"secureSetVc"];
    [self.navigationController pushViewController:secureSetVc animated:YES];
}
- (IBAction)savePwd:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [[StorageMgr singletonStorageMgr]removeObjectForKey:@"SetPwdBool"];
}

- (void)setPwd{
    [Utilities popUpAlertViewWithMsg:@"设置密码成功" andTitle:nil onView:self];
}

- (void)pwdLength{
    [Utilities popUpAlertViewWithMsg:@"这种密码百分百被破哦,重新绘制吧" andTitle:nil onView:self];
}

- (void)rightBtn{
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)pwdNot{
    [Utilities popUpAlertViewWithMsg:@"新密码不能与旧密码相同哦" andTitle:nil onView:self];
}
@end
