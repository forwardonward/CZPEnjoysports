//
//  LeftViewController.m
//  Calorie
//
//  Created by xyl on 16/4/17.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "LeftViewController.h"
#import "SignInViewController.h"
#import "NavigationViewController.h"
#import "MyMessageViewController.h"
#import "MyWorkViewController.h"
#import "MyCollectViewController.h"
#import "MessageNavViewController.h"
#import "WorkNavViewController.h"
#import "CollectNavViewController.h"
#import "MessageTableViewCell.h"
#import "WorkTableViewCell.h"
#import "CollectTableViewCell.h"

#import "SecureTableViewCell.h"
#import "SecureNavViewController.h"
//体验券列表
#import "ExperienceListTableViewCell.h"
#import "MyExperienceTableViewController.h"
#import "ExperienceNavView.h"
//反馈页面
#import "FeedbackTableViewCell.h"
#import "FeedbackNavViewController.h"

//#import ""
#import <UIImageView+WebCache.h>

@interface LeftViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic)NSMutableArray *objectForShow;
@property (strong, nonatomic)NSURL *url;

@end

@implementation LeftViewController

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //判断用户是否登录
   [self signInOrSignUp];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _objectForShow = [NSMutableArray new];
    //取消tableview下划线
    //    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //去掉tableView的滚动条
    self.tableView.showsVerticalScrollIndicator = NO;
   
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(weatherShow:) name:@"setCity" object:nil];
    
    //监听是否重新进入程序程序.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    NSString *str;
    BOOL flag;
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
                    ;
                }
            }
            
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)signInOrSignUp{
    [_objectForShow removeAllObjects];
    //值如果是YES  则是登录了  else  NO则是未登录
    if([[[StorageMgr singletonStorageMgr]objectForKey:@"inOrUp"] boolValue]){
        
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
                NSLog(@"2");
                _objectForShow = [NSMutableArray arrayWithArray:objects];
               PFFile *file = _objectForShow.firstObject[@"userImage"];
                NSLog(@"____________查询成功objectForShow = %@",file.url);
                _url = [NSURL URLWithString:file.url];
                [_headImg sd_setImageWithURL:_url];
                [Utilities removeUserDefaults:@"imgURL"];
                [Utilities setUserDefaults:@"imgURL" content:file.url];
            }
        }];
        }
        _nickName.text = [Utilities getUserDefaults:@"Username"];
    }else{
        _headImg.image = [UIImage imageNamed:@"tupian"];
        _nickName.text = @"未登录";
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(signIn)];
        [_headImg addGestureRecognizer:tap];
    }
}

#pragma mark - TabView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
        {
            //个人信息
            MessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
            return cell;
        }
        case 1:
        {
            //我的课程
            WorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
            return cell;
        }
        case 2:
        {
            //我的收藏
            CollectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell3" forIndexPath:indexPath];
            return cell;
        }
        case 3:{
            //体验券列表
            ExperienceListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell4" forIndexPath:indexPath];
            return cell;
        }
        case 5:{
            //安全
            SecureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell6" forIndexPath:indexPath];
            return cell;
        }
        default:{
            //反馈
            FeedbackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell5" forIndexPath:indexPath];
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    //取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            //个人信息
            if ([[[StorageMgr singletonStorageMgr]objectForKey:@"inOrUp"] boolValue]) {
                MessageNavViewController *messageNav = [Utilities getStoryboard:@"Sliding" instanceByIdentity:@"MessageNav"];
                [self presentViewController:messageNav animated:YES completion:nil];
            }else{
                [Utilities popUpAlertViewWithMsg:@"您当前未登录，请点击头像登录哦！" andTitle:nil onView:self];
            }
        }
            break;
        case 1:
        {
            //我的课程
            if ([[[StorageMgr singletonStorageMgr]objectForKey:@"inOrUp"] boolValue]) {
                WorkNavViewController *workNav = [Utilities getStoryboard:@"Sliding" instanceByIdentity:@"WorkNav"];
                [self presentViewController:workNav animated:YES completion:nil];
            }else{
                [Utilities popUpAlertViewWithMsg:@"您当前未登录，请点击头像登录哦！" andTitle:nil onView:self];
            }
        }
            break;
        case 2:
        {
            //我的收藏
            if ([[[StorageMgr singletonStorageMgr]objectForKey:@"inOrUp"] boolValue]) {
                CollectNavViewController *collectNav = [Utilities getStoryboard:@"Sliding" instanceByIdentity:@"CollectNav"];
                [self presentViewController:collectNav animated:YES completion:nil];
            }else{
                [Utilities popUpAlertViewWithMsg:@"您当前未登录，请点击头像登录哦！" andTitle:nil onView:self];
            }
        }
            break;
        case 3:{
             //体验券
            if (![[[StorageMgr singletonStorageMgr]objectForKey:@"inOrUp"] boolValue]) {
                [Utilities popUpAlertViewWithMsg:@"您当前未登录，请点击头像登录哦！" andTitle:nil onView:self];
                return;
            }
           
            MyExperienceTableViewController *experienceTableView = [Utilities getStoryboard:@"Sliding" instanceByIdentity:@"experience"];
            [self presentViewController:experienceTableView animated:true completion:nil];
            break;
        }
        case 4:{
            //反馈
            if ([[[StorageMgr singletonStorageMgr]objectForKey:@"inOrUp"] boolValue]) {
                FeedbackNavViewController *feedbackNav = [Utilities getStoryboard:@"Sliding" instanceByIdentity:@"FeedbackNav"];
                [self presentViewController:feedbackNav animated:YES completion:nil];
            }else{
                [Utilities popUpAlertViewWithMsg:@"您当前未登录，请点击头像登录哦！" andTitle:nil onView:self];
            }
            break;
        }
        case 5:
        {
            //账户安全
            if ([[[StorageMgr singletonStorageMgr]objectForKey:@"inOrUp"] boolValue]) {
                SecureNavViewController *SecureNav = [Utilities getStoryboard:@"Sliding" instanceByIdentity:@"SecureNav"];
                [self presentViewController:SecureNav animated:YES completion:nil];
            }else{
                [Utilities popUpAlertViewWithMsg:@"您当前未登录，请点击头像登录哦！" andTitle:nil onView:self];
            }
//            SecureNavViewController *SecureNav = [Utilities getStoryboard:@"Sliding" instanceByIdentity:@"SecureNav"];
//            [self presentViewController:SecureNav animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

#pragma mark - signIn

- (void)signIn{
    //因为 侧滑没有  导航体系  所以这边直接跳转到跳转类的导航条上
    NavigationViewController *navView = [Utilities getStoryboard:@"Main" instanceByIdentity:@"nav"];
    [self presentViewController:navView animated:YES completion:nil];
}

#pragma mark - signOut

- (IBAction)signOut:(UIButton *)sender forEvent:(UIEvent *)event {
    [Utilities removeUserDefaults:@"AddUserAndPw"];
    [Utilities setUserDefaults:@"AddUserAndPw" content:@NO];
    
    //值如果是YES  则是登录了  else  NO则是未登录
    if ([[[StorageMgr singletonStorageMgr]objectForKey:@"inOrUp"] boolValue]) {
        //缓存一个bool 类型 键名   可以判断下次登录是否自动显示账号密码
        [Utilities setUserDefaults:@"AddUserAndPw" content:@YES];
        
        NavigationViewController *navView = [Utilities getStoryboard:@"Main" instanceByIdentity:@"nav"];
//        SignInViewController *signInVc = [Utilities getStoryboard:@"Main" instanceByIdentity:@"signInVc"];
        //这里是当登录退出时  将全局变量SignUpSuccessfully  设置成yes   当调到  登录页面就会运行  viewWillA里的方法
        [[StorageMgr singletonStorageMgr]removeObjectForKey:@"SignUpSuccessfully"];
        [[StorageMgr singletonStorageMgr]addKey:@"SignUpSuccessfully" andValue:@YES];
        //接着给全局变量 键Username 值（_nickName.text）   这样登录退出后就会有用户名显示
        [[StorageMgr singletonStorageMgr]addKey:@"Username" andValue:_nickName.text];
        //缓存到 键为Username的值   homeTabVc  中能用到
        [Utilities removeUserDefaults:@"Username"];
        [Utilities setUserDefaults:@"Username" content:_nickName.text];
        [self presentViewController:navView animated:YES completion:nil];
    }else{
        [Utilities popUpAlertViewWithMsg:@"您当前未登录，请点击头像登录哦！" andTitle:nil onView:self];
    }
}

- (void)weatherShow:(NSNotification *)city{
    NSString *cityName = city.userInfo[@"city"];
    NSString *appID = @"529615526ff3a9a5dca577698b0be231";
    NSString *urlStr = @"http://api.openweathermap.org/data/2.5/weather";
    if (cityName.length == 0) {
        _weather.text = @"";
        _city.text = @"";
    }
    NSDictionary *dic = @{@"q":cityName, @"appid":appID};
    
    [[AppAPIClient sharedClient] GET:urlStr parameters:dic progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *mainDic = responseObject[@"main"];
        NSString *weatherStr = mainDic[@"temp_max"];
        NSInteger num = [weatherStr integerValue];
        NSString *weatherStrLast = [NSString stringWithFormat:@"%ld°C",(num - 273)];
        _weather.text = weatherStrLast;
        _city.text = cityName;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@",[error userInfo]);
    }];
}
@end
