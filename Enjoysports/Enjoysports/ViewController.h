//
//  ViewController.h
//  Enjoysports
//
//  Created by admin1 on 16/10/12.
//  Copyright © 2016年 admin1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *headImg;
@property (weak, nonatomic) IBOutlet UITextField *usernameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
- (IBAction)signInAction:(UIButton *)sender forEvent:(UIEvent *)event;
- (IBAction)forgetPwAction:(UIButton *)sender forEvent:(UIEvent *)event;
- (IBAction)signUpAction:(UIButton *)sender forEvent:(UIEvent *)event;
- (IBAction)touristsLogin:(UIButton *)sender forEvent:(UIEvent *)event;
@property (weak, nonatomic) IBOutlet UIImageView *bgIamgeView;
@end

