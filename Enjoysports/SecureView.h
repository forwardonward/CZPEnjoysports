//
//  SecureView.h
//  Calorie
//
//  Created by xyl on 16/5/7.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecureView : UIView

@property (nonatomic,strong) NSMutableArray *buttons;
@property(nonatomic)CGPoint currentPoint;
@property (nonatomic,strong) NSString *password;
@property (nonatomic) BOOL flag;
@property(nonatomic) NSInteger count;
@property(nonatomic,strong) NSString *pwdStr;
@property (nonatomic) BOOL setPwdBool;
@property (nonatomic) BOOL touchHome;
@end
