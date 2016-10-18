//
//  SignUpViewController.h
//  Enjoysports
//
//  Created by admin1 on 16/10/13.
//  Copyright © 2016年 admin1. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;
- (IBAction)codeAction:(id)sender forEvent:(UIEvent *)event;
@property (weak, nonatomic) IBOutlet UITextField *firstPwTF;
@property (weak, nonatomic) IBOutlet UITextField *secondPwTF;
- (IBAction)signUpAction:(UIButton *)sender forEvent:(UIEvent *)event;
@property (weak, nonatomic) IBOutlet UIButton *firstPwMessage;
@property (weak, nonatomic) IBOutlet UIButton *secondPwMessage;






@end
