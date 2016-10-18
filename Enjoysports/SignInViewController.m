//
//  SignInViewController.m
//  Enjoysports
//
//  Created by admin1 on 16/10/13.
//  Copyright © 2016年 admin1. All rights reserved.
//

#import "SignUpViewController.h"
#import "CodeViewController.h"
#import "TabBarViewController.h"
#import <ECSlidingViewController/ECSlidingViewController.h>
#import "LeftViewController.h"
#import "HomeNavViewController.h"
#import <UIImageView+WebCache.h>

@interface SignInViewController ()<UITextFieldDelegate>
//@property (strong,nonatomic) ECSlidingViewController *slidingVc;
@property (strong,nonatomic) NSMutableArray *objectForShow;
@property (strong,nonatomic) NSURL *url;
@property (strong,nonatomic) UIImage *images;
@end

@implementation SignInViewController

//视图已经出现时调用
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    
    //判断当前登录页面是否是  注册成功  跳转过来的
    if([[[StorageMgr singletonStorageMgr]objectForKey:@"SignUpSuccessfully"] boolValue]){
        //需要把 这个键的  值  重新设置成  no   （！！！！！！！！！！！！）
        [[StorageMgr singletonStorageMgr]removeObjectForKey:@"SignUpSuccessfully"];
        [[StorageMgr singletonStorageMgr]addKey:@"SignUpSuccessfully" andValue:@NO];
        //从单例化全局变量中提取用户名和密码
        NSString *username = [[StorageMgr singletonStorageMgr] objectForKey:@"Username"];
        NSString *password = [[StorageMgr singletonStorageMgr] objectForKey:@"Password"];
        //清除用完的用户名和密码
        [[StorageMgr singletonStorageMgr] removeObjectForKey:@"Username"];
        [[StorageMgr singletonStorageMgr] removeObjectForKey:@"Password"];
        _usernameTF.text = username;
        _passwordTF.text = password;
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _bgIamgeView.image = [UIImage imageNamed:@"headImgBG"];
    
    //协议
    _usernameTF.delegate = self;
    _passwordTF.delegate = self;
    
    //默认获取 textfield 焦点
    [_usernameTF becomeFirstResponder];
    
    PFQuery *query = [PFUser query];
    NSString *str = [Utilities getUserDefaults:@"imgURL"];
    if (str.length != 0) {
        NSLog(@"1");
        NSURL *url = [NSURL URLWithString:str];
        _url = url;
        NSLog(@"imgURL = %@",_url);
        [_headImg sd_setImageWithURL:_url];
    }else{
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (!error) {
                
                _objectForShow = [NSMutableArray arrayWithArray:objects];
                PFFile *file = _objectForShow.firstObject[@"userImage"];
                if (file) {
                    NSLog(@"2");
                    _url = [NSURL URLWithString:file.url];
                    NSLog(@"____________查询成功objectForShow = %@",file.url);
                    
                    [_headImg sd_setImageWithURL:_url];
                    [Utilities removeUserDefaults:@"imgURL"];
                    [Utilities setUserDefaults:@"imgURL" content:file.url];
                }else{
                    _headImg.image = [UIImage imageNamed:@"tupian"];
                }
            }
        }];
    }
    
    [self setMD5RSA];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

- (IBAction)signInAction:(UIButton *)sender forEvent:(UIEvent *)event {
    if ([[StorageMgr singletonStorageMgr] objectForKey:@"exponent"] == NULL || [[StorageMgr singletonStorageMgr] objectForKey:@"modulus"] == NULL) {
        [self setMD5RSA];
        [Utilities popUpAlertViewWithMsg:@"请保持网络通畅哦" andTitle:nil  onView:self];
        return;
    }
    NSString *exponent = [[StorageMgr singletonStorageMgr] objectForKey:@"exponent"];
    NSString *modulus = [[StorageMgr singletonStorageMgr] objectForKey:@"modulus"];
    //MD5将原始密码进行MD5加密
    NSString *MD5Pwd = [_passwordTF.text getMD5_32BitString];
    //将MD5加密过后的密码进行RSA非对称加密
    NSString *RSAPwd = [NSString encryptWithPublicKeyFromModulusAndExponent:MD5Pwd.UTF8String modulus:modulus exponent:exponent];
    
    NSLog(@"user = %@",_usernameTF.text);
    NSLog(@"pw = %@",RSAPwd);
    
    if(_usernameTF.text.length == 0){
        [Utilities popUpAlertViewWithMsg:@"请填写用户名" andTitle:nil onView:self];
        return;
    }
    if(_passwordTF.text.length == 0){
        [Utilities popUpAlertViewWithMsg:@"请填写密码" andTitle:nil onView:self];
        return;
    }
    NSDictionary *dic = @{@"userName":_usernameTF.text,
                          @"password":RSAPwd,
                          @"deviceType":@7001,
                          @"deviceId":[Utilities uniqueVendor]};
    UIActivityIndicatorView *aiv = [Utilities getCoverOnView:self.view];
    [RequestAPI postURL:@"/login" withParameters:dic success:^(id responseObject) {
        NSLog(@"%@",responseObject);
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            //删除防止重名
            [[StorageMgr singletonStorageMgr]removeObjectForKey:@"inOrUp"];
            //添加 此键  放进全局变量   ，之后来判断用户是否登录进入的侧滑
            [[StorageMgr singletonStorageMgr]addKey:@"inOrUp" andValue:@YES];
            
            [[StorageMgr singletonStorageMgr]removeObjectForKey:@"LeftUsername"];
            [[StorageMgr singletonStorageMgr]addKey:@"LeftUsername" andValue:_usernameTF.text];
            
            [Utilities removeUserDefaults:@"OrLogin"];
            [Utilities removeUserDefaults:@"AddUserAndPw"];
            //缓存  键名  能判断用户上一次是否登录
            [Utilities setUserDefaults:@"OrLogin" content:@YES];
            [Utilities setUserDefaults:@"AddUserAndPw" content:@NO];
            //删除之前缓存到的用户和密码
            [Utilities removeUserDefaults:@"Username"];
            [Utilities removeUserDefaults:@"Password"];
            //缓存到用户登录的账号密码
            [Utilities setUserDefaults:@"Username" content:_usernameTF.text];
            [Utilities setUserDefaults:@"Password" content:_passwordTF.text];
            
            //如果用户决定打开账户锁才能帮其打开
            NSString *strUser = [Utilities getUserDefaults:@"switchUser"];
            if ([strUser isEqualToString:@"openUser"]) {
                [Utilities removeUserDefaults:@"switch"];
                [Utilities setUserDefaults:@"switch" content:@"open"];
            }
            
            [aiv stopAnimating];
            
            //这里获取到  ID  并存进全局变量
            NSDictionary *result = responseObject[@"result"];
            NSString *memberId = result[@"memberId"];
            [[StorageMgr singletonStorageMgr]removeObjectForKey:@"memberId"];
            [[StorageMgr singletonStorageMgr]addKey:@"memberId" andValue:memberId];
            
            int value = (arc4random() % 999999999) + 1;
            NSString *email = [NSString stringWithFormat:@"%d@qq.com",value];
            NSString *username = [NSString stringWithFormat:@"x%@",memberId];
            
            NSDictionary *dict = @{@"memberId":result[@"memberId"],
                                   @"memberSex":result[@"memberSex"],
                                   @"memberName":result[@"memberName"],
                                   @"birthday":result[@"birthday"],
                                   @"identificationcard":result[@"identificationcard"]
                                   };
            [[StorageMgr singletonStorageMgr]removeObjectForKey:@"dict"];
            [[StorageMgr singletonStorageMgr]addKey:@"dict" andValue:dict];
            
            //判断用户名是否存在 存在就别保存 username
            PFUser *user = [PFUser user];
            user.username = username;
            user.email = email;
            user.password = @"123456";
            
            [[StorageMgr singletonStorageMgr]removeObjectForKey:@"username"];
            [[StorageMgr singletonStorageMgr]addKey:@"username" andValue:username];
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (!error) {
                    NSLog(@"parse注册成功");
                }
            }];
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }else{
            [aiv stopAnimating];
            [Utilities errorShow:responseObject[@"resultFlag"] onView:self];
            _passwordTF.text = @"";
            [self setMD5RSA];
        }
    } failure:^(NSError *error) {
        [aiv stopAnimating];
        [Utilities popUpAlertViewWithMsg:@"您的用户名或密码错误" andTitle:nil onView:self];
        _passwordTF.text = @"";
        [self setMD5RSA];
    }];
    
}

- (IBAction)forgetPwAction:(UIButton *)sender forEvent:(UIEvent *)event {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CodeViewController *codeVc = [storyboard instantiateViewControllerWithIdentifier:@"CodeVc"];
    [self.navigationController pushViewController:codeVc animated:YES];
}

- (IBAction)signUpAction:(UIButton *)sender forEvent:(UIEvent *)event {
    //     SignUpViewController *signUpVc = [Utilities getStoryboard:@"Main" instanceByIdentity:@"SignUpVc"];
    //    [self.navigationController pushViewController:signUpVc animated:YES];
}

- (IBAction)touristsLogin:(UIButton *)sender forEvent:(UIEvent *)event {
    
    [[StorageMgr singletonStorageMgr]removeObjectForKey:@"inOrUp"];
    [[StorageMgr singletonStorageMgr]addKey:@"inOrUp" andValue:@NO];
    [[StorageMgr singletonStorageMgr]removeObjectForKey:@"inOrUp"];
    [[StorageMgr singletonStorageMgr]addKey:@"inOrUp" andValue:@NO];
    
    [Utilities removeUserDefaults:@"switch"];
    [Utilities setUserDefaults:@"switch" content:@"close"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TextField
//点return收回键盘
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
//点空白处收回键盘
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

//当文本输入框中输入的内容变化是调用该方法，返回值为NO不允许调用
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}

#pragma mark - setMD5RSA

- (void)setMD5RSA{
    //获取模数指数
    NSDictionary *dic = @{@"deviceType":@7001,
                          @"deviceId":[Utilities uniqueVendor]
                          };
    
    [RequestAPI getURL:@"/login/getKey" withParameters:dic success:^(id responseObject) {
        NSLog(@"responseObject : %@",responseObject);
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            NSDictionary *resultDict = responseObject[@"result"];
            NSString *exponent = resultDict[@"exponent"];
            NSString *modulus = resultDict[@"modulus"];
            //从单例化全局变量中删除数据
            [[StorageMgr singletonStorageMgr] removeObjectForKey:@"exponent"];
            [[StorageMgr singletonStorageMgr] removeObjectForKey:@"modulus"];
            
            [[StorageMgr singletonStorageMgr] addKey:@"exponent" andValue:exponent];
            [[StorageMgr singletonStorageMgr] addKey:@"modulus" andValue:modulus];
        }else{
            NSLog(@"resultFailed");
            [Utilities errorShow:responseObject[@"resultFlag"] onView:self];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
}

#pragma mark - NSNotificationCenter

- (void) menuSwitchAction{
    NSLog(@"menu");
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
    NSLog(@"1");
}
//关闭 侧滑手势
- (void)DisableGestureAction{
    _slidingVc.panGesture.enabled = NO;
    NSLog(@"2");
}
@end
