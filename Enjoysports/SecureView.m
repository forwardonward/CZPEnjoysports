//
//  SecureView.m
//  Calorie
//
//  Created by xyl on 16/5/7.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "SecureView.h"
#import "SecureViewController.h"
#import "SecureSetViewController.h"
@implementation SecureView

-(void)awakeFromNib{
    
    //用完之后改成YES，切记
    if ([[StorageMgr singletonStorageMgr]objectForKey:@"SetPwdBool"]) {
        _setPwdBool = NO;
    }else{
        _setPwdBool = YES;
    }
    
    _count = 1;
    _flag = YES;
    _buttons = [NSMutableArray new];
    [self setup];
    self.alpha = 1;
    //可以让我们绘制的东西有机会被重新绘制
    //将本视图的内容模式调整为可以被重绘模式
    self.contentMode = UIViewContentModeRedraw;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(touchHomes) name:@"TouchHome" object:nil];
}

////使用代码创建视图的初始化方法
//- (void)initWithFrame{
//    NSLog(@"3");
//    self.contentMode = UIViewContentModeRedraw;
//    _buttons = [NSMutableArray new];
//    [self setup];
//}


-(void)drawRect:(CGRect)rect{
    if (self.buttons.count==0 ) {
        return;
    }
    
    //  创建路径
    UIBezierPath *path=[UIBezierPath bezierPath];
    
    path.lineCapStyle=kCGLineCapRound;
    path.lineJoinStyle=kCGLineJoinRound;
    
    //  遍历所有按钮进行绘制
    [self.buttons enumerateObjectsUsingBlock:^(__kindof UIButton * _Nonnull obj, NSUInteger index, BOOL * _Nonnull stop) {
        //    第一个按钮，中心点就是起点
        if (index ==0 ) {
            [path moveToPoint:obj.center];
        }else {
            [path addLineToPoint:obj.center];
        }
    }];
    [path addLineToPoint:self.currentPoint];
    //  设置路径属性
    path.lineWidth = 10;
    //线条色
    [[UIColor blackColor]setStroke];
    //绘制线条
    [path stroke];
    
}

- (void)setup{
    for (int i=0; i<9; i++) {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
        //设置按钮的状态背景
        [btn setBackgroundImage:[UIImage imageNamed:@"1"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"2"] forState:UIControlStateSelected];
        btn.backgroundColor = [UIColor orangeColor];
        
        //        九宫格法计算每个按钮的frame
        CGFloat row = i / 3;
        CGFloat loc = i % 3;
        CGFloat btnW = self.frame.size.height / 8;
        CGFloat btnH = btnW;
        CGFloat padding = (self.frame.size.width-3*btnW)/8;
        CGFloat btnX = padding+(btnW+padding)*loc;
        CGFloat btnY = padding+(btnW+padding)*row;
        btn.frame=CGRectMake(btnX, btnY, btnW, btnH);
        
        btn.tag = i+1;
        btn.backgroundColor = [UIColor clearColor];
        btn.clipsToBounds = YES;
        btn.layer.cornerRadius = btnW / 2;
        btn.alpha = 0.5;
        
        //3.把按钮添加到视图中
        [self addSubview:btn];
        //4.禁止按钮的点击事件
        btn.userInteractionEnabled = NO;
        
    }
}

//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    
//    CGPoint starPoint=[self getCurrentPoint:touches];
//    UIButton *btn=[self getCurrentBtnWithPoint:starPoint];
//    
//            btn.selected=YES;if (btn && btn.selected != YES) {
//
//        [self.buttons addObject:btn];
//    }
//    [self setNeedsDisplay];
//}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //  获取触摸对象
    UITouch *touch = touches.anyObject;
    //  获取触摸点
    CGPoint loc = [touch locationInView:self];
    self.currentPoint = loc;
    CGPoint movePoint=[self getCurrentPoint:touches];
    UIButton *btn=[self getCurrentBtnWithPoint:movePoint];
    //存储按钮
    //已经连过的按钮，不可再连
    if (btn && btn.selected != YES) {
        //设置按钮的选中状态
        btn.selected=YES;
        //把按钮添加到数组中
        [_buttons addObject:btn];
    }
    [self setNeedsDisplay];
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    //  定义最后一个按钮
    UIButton *lastBtn = [self.buttons lastObject];
    //  将最后一个按钮中心点定义为相对滑动的当前点
    self.currentPoint = lastBtn.center;
    for (UIButton *obj in _buttons) {
        obj.selected = NO;
        NSString *str = [NSString stringWithFormat:@"%ld",(long)obj.tag];
        if (_password) {
            _password = [_password stringByAppendingString:str];
        }else {
            _password = str;
        }
    }
    
    if (_setPwdBool) {
        //密码判断
//        if (_password.length < 4) {
//            [[NSNotificationCenter defaultCenter]postNotificationName:@"pwdLength" object:nil];
        
//        }
//        if (_flag) {
//            [self times];
//        }else{
//            //0.1s 后执行times方法
//            [self performSelector:@selector(times) withObject:nil afterDelay:0.10f];
//        }
        
    
        if (![Utilities getUserDefaults:@"SecurePwd"]) {
            NSLog(@"0");
            if (_count == 1) {
                _pwdStr = _password;
            }else {
                if ([_pwdStr isEqualToString:_password]) {
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"Success" object:nil];
                    [Utilities setUserDefaults:@"SecurePwd" content:_pwdStr];
                }else{
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"NotSuccess" object:nil];
                    _pwdStr = nil;
                }
            }
            
            if (_count < 2 ) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"SecondSet" object:nil];
                _count ++;
            }else {
                _count = 1;
            }
        }else{
            NSLog(@"1");
            NSString *str = [Utilities getUserDefaults:@"SecurePwd"];
            if ([_password isEqualToString:str]) {
                if (_touchHome) {
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"JumpSet" object:nil];
                    _touchHome = NO;
                    return;
                }
                [[NSNotificationCenter defaultCenter]postNotificationName:@"JumpSet" object:nil];
            }else{
                [[NSNotificationCenter defaultCenter]postNotificationName:@"pwdFalse" object:nil];
            }
        }
    }else {
        //密码判断
        if (_password.length < 4) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"pwdLength" object:nil];
            if (_flag) {
                [self times];
            }else{
                //0.1s 后执行times方法
                [self performSelector:@selector(times) withObject:nil afterDelay:0.10f];
            }
            return;
        }
        NSString *strPwd = [Utilities getUserDefaults:@"OldPwd"];
        if ([_password isEqualToString:strPwd]) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"pwdNot" object:nil];
            if (_flag) {
                [self times];
            }else{
                //0.1s 后执行times方法
                [self performSelector:@selector(times) withObject:nil afterDelay:0.10f];
            }
            return;
        }
        //设置密码
        if (_count == 1) {
            _pwdStr = _password;
        }else {
            if ([_pwdStr isEqualToString:_password]) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"setPwd" object:nil];
                [Utilities removeUserDefaults:@"SecurePwd"];
                [Utilities setUserDefaults:@"SecurePwd" content:_pwdStr];
                UIView *vw = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
                vw.alpha = 0.5;
                vw.backgroundColor = [UIColor grayColor];
                vw.layer.zPosition = 10;
                [self addSubview:vw];
                self.userInteractionEnabled = NO;
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"rightBtn" object:nil];
            }else{
                [[NSNotificationCenter defaultCenter]postNotificationName:@"NotSuccess" object:nil];
                _pwdStr = nil;
            }
        }
        
        if (_count < 2 ) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SecondSet" object:nil];
            _count ++;
        }else {
            _count = 1;
        }
    }
    
    if (_flag) {
        [self times];
    }else{
        //0.1s 后执行times方法
        [self performSelector:@selector(times) withObject:nil afterDelay:0.10f];
    }
}

- (void)times{
    _password = nil;
    [_buttons removeAllObjects];
    //  重绘
    [self setNeedsDisplay];
}

//对功能点进行封装
//获取触摸的点
-(CGPoint)getCurrentPoint:(NSSet *)touches
{
    UITouch *touch=[touches anyObject];
    CGPoint point=[touch locationInView:touch.view];
    return point;
}
//判断触摸的点是否在按钮的范围内。
-(UIButton *)getCurrentBtnWithPoint:(CGPoint)point
{
    for (UIButton *btn in self.subviews) {
        if (CGRectContainsPoint(btn.frame, point)) {
            return btn;
        }
    }
    return Nil;
}

- (void)touchHomes{
    _touchHome = YES;
}
@end
