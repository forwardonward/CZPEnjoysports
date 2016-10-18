//
//  SecureViewController.h
//  Calorie
//
//  Created by xyl on 16/5/7.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecureViewController : UIViewController
- (IBAction)jumpHome:(UIBarButtonItem *)sender;

@property (weak, nonatomic) IBOutlet UILabel *messageLab;
@property (nonatomic,strong) NSString *password;
- (IBAction)savePwd:(UIBarButtonItem *)sender;

@property (nonatomic) BOOL touchHome;

@end
