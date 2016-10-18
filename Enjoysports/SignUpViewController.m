//
//  SignUpViewController.m
//  Enjoysports
//
//  Created by admin1 on 16/10/13.
//  Copyright © 2016年 admin1. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()<UITextFieldDelegate>{
    //用于Code的计数
    NSInteger count;
}
@property (strong,nonatomic) NSTimer *timer;
@end
@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = NO;
    
    //密码提示信息
    [_firstPwMessage setTitle:@"" forState:UIControlStateNormal];
    [_secondPwMessage setTitle:@"" forState:UIControlStateNormal];
    
    count = 60;
    
    _phoneTF.delegate = self;
    _codeTF.delegate = self;
    _firstPwTF.delegate = self;
    _secondPwTF.delegate = self;
    
    //默认获取 textfield 焦点
    [_phoneTF becomeFirstResponder];
    
    //获取模数指数
    NSDictionary *dic = @{@"deviceType":@7001,
                          @"deviceId":[Utilities uniqueVendor]
                          };
    
    [RequestAPI getURL:@"/login/getKey" withParameters:dic success:^(id responseObject) {
        NSLog(@"responseObject : %@",responseObject);
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            NSDictionary *resultDict = responseObject[@"result"];
            NSLog(@"resultDict = %@",resultDict);
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if (_firstPwTF == textField) {
        if(_firstPwTF.text.length == 0){
            [_firstPwMessage setTitle:@"请输入您的密码" forState:UIControlStateNormal];
            [_firstPwMessage setBackgroundImage:[UIImage imageNamed:@"PwMessage"] forState:UIControlStateNormal];
        }else if (_firstPwTF.text.length < 6 || _firstPwTF.text.length >= 16) {
            [_firstPwMessage setTitle:@"请设置6-16位的密码" forState:UIControlStateNormal];
            [_firstPwMessage setBackgroundImage:[UIImage imageNamed:@"PwMessage"] forState:UIControlStateNormal];
        }
    }else if (_secondPwTF == textField) {
        if([_secondPwTF.text isEqualToString: _firstPwTF.text]){
            
            [_secondPwMessage setTitle:@"密码一致" forState:UIControlStateNormal];
            [_secondPwMessage setBackgroundImage:[UIImage imageNamed:@"PwMessage"] forState:UIControlStateNormal];
        }else {
            
            [_secondPwMessage setTitle:@"密码不一致！" forState:UIControlStateNormal];
            [_secondPwMessage setBackgroundImage:[UIImage imageNamed:@"PwMessage"] forState:UIControlStateNormal];
        }
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (self.firstPwTF == textField) {
        [_firstPwMessage setTitle:@"" forState:UIControlStateNormal];
        [_secondPwMessage setTitle:@"" forState:UIControlStateNormal];
        [_firstPwMessage setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_secondPwMessage setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    if (self.secondPwTF == textField) {
        [_secondPwMessage setTitle:@"" forState:UIControlStateNormal];
        [_secondPwMessage setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        
    }
}


- (IBAction)codeAction:(id)sender forEvent:(UIEvent *)event {
    //判断用户是否输入手机号  再判断用户手机号是否为11位
    if (_phoneTF.text.length == 0) {
        [Utilities popUpAlertViewWithMsg:@"请输入您的手机号" andTitle:nil onView:self];
        return;
    }
    if (_phoneTF.text.length == 11) {
        NSDictionary *dic = @{@"userTel":_phoneTF.text,
                              @"type":@1};
        [RequestAPI getURL:@"/register/verificationCode" withParameters:dic success:^(id responseObject) {
            NSLog(@"code = %@",responseObject);
            if ([responseObject[@"resultFlag"] integerValue] == 8001) {
                //定时器
                [self setTime];
            }else{
                [Utilities errorShow:responseObject[@"resultFlag"] onView:self];
            }
        } failure:^(NSError *error) {
            NSLog(@"error = %@",[error userInfo]);
        }];
    }else{
        [Utilities popUpAlertViewWithMsg:@"手机号码的位数必须为11位" andTitle:nil onView:self];
    }
}

#pragma mark - Timer

- (void)setTime{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeTime) userInfo:nil repeats:YES];
}

- (void)changeTime{
    
    if (count > 0) {
        [_codeBtn setTitle:[NSString stringWithFormat:@"%ld秒",count] forState:UIControlStateNormal];
        _codeBtn.userInteractionEnabled = NO;
        count --;
    }else{
        [_codeBtn setTitle:@"重新发送" forState:UIControlStateNormal];
        _codeBtn.userInteractionEnabled = YES;
    }
}

#pragma mark - TextField

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

//当文本输入框中输入的内容变化是调用该方法，返回值为NO不允许调用
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}



- (IBAction)signUpAction:(UIButton *)sender forEvent:(UIEvent *)event {
    NSString *exponent = [[StorageMgr singletonStorageMgr] objectForKey:@"exponent"];
    NSString *modulus = [[StorageMgr singletonStorageMgr] objectForKey:@"modulus"];
    //MD5将原始密码进行MD5加密
    NSString *MD5Pwd = [_firstPwTF.text getMD5_32BitString];
    //将MD5加密过后的密码进行RSA非对称加密
    NSString *RSAPwd = [NSString encryptWithPublicKeyFromModulusAndExponent:MD5Pwd.UTF8String modulus:modulus exponent:exponent];
    
    if (_firstPwTF.text.length == 0 || _secondPwTF.text.length ==0) {
        [Utilities popUpAlertViewWithMsg:@"请填写密码" andTitle:nil onView:self];
        return;
    }
    if (![_firstPwTF.text isEqualToString:_secondPwTF.text]) {
        [Utilities popUpAlertViewWithMsg:@"两次输入的密码需要相同" andTitle:nil onView:self];
        return;
    }
    if (_firstPwTF.text.length < 6 || _firstPwTF.text.length > 16) {
        [Utilities popUpAlertViewWithMsg:@"请设置6-16位的密码" andTitle:nil onView:self];
        return;
    }
    
    NSDictionary *dic = @{@"userTel":_phoneTF.text,
                          @"userPsw":RSAPwd,
                          @"nickName":_phoneTF.text,
                          @"city":@0511,
                          @"nums":_codeTF.text,
                          @"deviceId":[Utilities uniqueVendor]};
    
    [RequestAPI postURL:@"/register" withParameters:dic success:^(id responseObject) {
        if ([responseObject[@"resultFlag"] integerValue] == 0) {
            
            [[StorageMgr singletonStorageMgr]addKey:@"Username" andValue:_phoneTF.text];
            [[StorageMgr singletonStorageMgr]addKey:@"Password" andValue:_firstPwTF.text];
            //现将同名 键 在单例化全局变量中删除   以保证该键的唯一性
            [[StorageMgr singletonStorageMgr]removeObjectForKey:@"SignUpSuccessfully"];
            //在初始化一个同名 键 为yes  表示注册成功
            [[StorageMgr singletonStorageMgr]addKey:@"SignUpSuccessfully" andValue:@YES];
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            [Utilities errorShow:responseObject[@"resultFlag"] onView:self];
        }
    } failure:^(NSError *error) {
        NSLog(@"error = %@",[error userInfo]);
    }];

}
@end
