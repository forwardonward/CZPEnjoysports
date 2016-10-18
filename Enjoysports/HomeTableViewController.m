//
//  HomeTableViewController.m
//  Calorie
//
//  Created by 杨凡 on 16/4/16.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "HomeTableViewController.h"

#import "TitleTableViewCell.h"
#import "HotClubTableViewCell.h"

#import <MapKit/MapKit.h>

#import <UIImageView+WebCache.h>
#import <UIButton+WebCache.h>

#import "SportTypeTableViewController.h"
#import "ClubDetailViewController.h"
#import "SearchViewController.h"
#import "CityTableViewController.h"

#import "UIScrollView+JElasticPullToRefresh.h"
#import "NavigationViewController.h"

@interface HomeTableViewController () <CLLocationManagerDelegate>{
    BOOL sportOver;
    BOOL hotClubOver;
    BOOL locationError;
    //防止刷新后没有网络上拉翻页页数增加
    BOOL loadingOver;
    BOOL isRefresh;
    //
    BOOL isBack;
}

@property(nonatomic)CGFloat jing;
@property(nonatomic)CGFloat wei;

@property(nonatomic)NSInteger hotClubPage;
@property(nonatomic)NSInteger totalPage;

//@property(nonatomic, strong)NSString *city;
@property(nonatomic, strong)NSString *cityName;

@property(nonatomic, strong)NSDictionary *adDict;

//运动类型
@property(nonatomic, strong)NSMutableArray *sportTypeArray;
//热门俱乐部数据
@property(nonatomic, strong)NSMutableArray *hotClubInfoArray;

//位置管理
@property(nonatomic, strong)CLLocationManager *locationManager;

//刷新器
@property(nonatomic, strong)UIRefreshControl *refresh;

@end

@implementation HomeTableViewController

//每次页面出现
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"EnableGesture" object:nil];
    
}

//每次页面消失
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DisableGesture" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //取消tableview下划线
    //    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //去掉tableView的滚动条
    self.tableView.showsVerticalScrollIndicator = NO;
    
    //初始化常量和变量
    [self initailVarAndLet];
    
    //初始化CLLocation
    [self initailCLLocation];
    
    //网络请求运动类型
    [self getSportType];
    
    //user
    [self setMD5RSA];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

//行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (hotClubOver) {
        return _hotClubInfoArray.count + 2;
    }else{
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        TitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (sportOver) {
            [cell.sportTypeBtn1 sd_setImageWithURL:_sportTypeArray[0][@"frontImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn2 sd_setImageWithURL:_sportTypeArray[1][@"frontImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn3 sd_setImageWithURL:_sportTypeArray[2][@"frontImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn4 sd_setImageWithURL:_sportTypeArray[3][@"frontImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn5 sd_setImageWithURL:_sportTypeArray[4][@"frontImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn6 sd_setImageWithURL:_sportTypeArray[5][@"frontImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn7 sd_setImageWithURL:_sportTypeArray[6][@"frontImgUrl"] forState:UIControlStateNormal];
            [cell.sportTypeBtn8 sd_setImageWithURL:_sportTypeArray[7][@"frontImgUrl"] forState:UIControlStateNormal];
            
            cell.sportTypeBtn1.tag = 1001;
            cell.sportTypeBtn2.tag = 1002;
            cell.sportTypeBtn3.tag = 1003;
            cell.sportTypeBtn4.tag = 1004;
            cell.sportTypeBtn5.tag = 1005;
            cell.sportTypeBtn6.tag = 1006;
            cell.sportTypeBtn7.tag = 1007;
            cell.sportTypeBtn8.tag = 1008;
        }
        return cell;
    }if (indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellLabel" forIndexPath:indexPath];
        return cell;
    }else{
        HotClubTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clubCell" forIndexPath:indexPath];
        
        if (hotClubOver) {
            //接下当前行对应的字典
            NSDictionary *tempDict = _hotClubInfoArray[indexPath.row - 2];
            
            cell.nameLabel.text = tempDict[@"name"];
            cell.addressLabel.text = tempDict[@"address"];
            if (_jing != 0) {
                cell.distanceLabel.text = [NSString stringWithFormat:@"距离%@米",tempDict[@"distance"]];
            }else{
                cell.distanceLabel.text = @"无法获取距离";
            }
            
            cell.clubImageView.userInteractionEnabled = YES;
            [cell.clubImageView sd_setImageWithURL:tempDict[@"image"]];
        }
        return cell;
    }
}

//cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 190;
    }else if(indexPath.row == 1){
        return 30;
    }
    return 220;
}

//按下cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row != 0) {
        ClubDetailViewController *clubDetailView = [Utilities getStoryboard:@"Home" instanceByIdentity:@"ClubDetailView"];
        if (sportOver) {
            NSString *clubKeyId = _hotClubInfoArray[indexPath.row - 2][@"id"];
            clubDetailView.clubKeyId = clubKeyId;
            [self.navigationController pushViewController:clubDetailView animated:YES];
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row >= 2) {
        CATransform3D rotation;
        rotation = CATransform3DMakeTranslation (10, 10, 0);
        //rotation = CATransform3DMakeRotation( (90.0*M_PI)/180, 0.0, 0.7, 0.4);
        //rotation.m34 = 1.0/ -600;
        
        //cell.layer.shadowColor = [[UIColor blackColor]CGColor];
        //cell.layer.shadowOffset = CGSizeMake(10, 10);
        //cell.alpha = 0;
        cell.layer.transform = rotation;
        //cell.layer.anchorPoint = CGPointMake(0, 0.5);
        
        
        [UIView beginAnimations:@"rotation" context:NULL];
        [UIView setAnimationDuration:0.8];
        cell.layer.transform = CATransform3DIdentity;
        //cell.alpha = 1;
        //cell.layer.shadowOffset = CGSizeMake(0, 0);
        [UIView commitAnimations];
    }
}

#pragma mark - private

- (void)initailVarAndLet{
    sportOver = NO;
    locationError = true;
    loadingOver = NO;
    isRefresh = NO;
    isBack = false;
    hotClubOver = YES;
    _sportTypeArray = [NSMutableArray new];
    _hotClubInfoArray = [NSMutableArray new];
    
    //判断是否之前获得过经纬度，获得过先默认给jing和wei这两个变量
    if ([[Utilities getUserDefaults:@"jing"] integerValue] != 0) {
        _jing = [[Utilities getUserDefaults:@"jing"] floatValue];
        _wei = [[Utilities getUserDefaults:@"wei"] floatValue];
        NSLog(@"jinf%f,wei%f",_jing,_wei);
    }
    
    //看看之前是否有缓存城市
    if ([Utilities getUserDefaults:@"cityName"] != nil) {
        _cityName = [Utilities getUserDefaults:@"cityName"];
    }else{
        //_city = @"0510";
        _cityName = @"无锡";
    }
    
    //初始化开始页面
    _hotClubPage = 1;
    
    [self getHotClub];
    
    //初始化刷新器
    [self initRefresh];
}

- (void)btnAction{
    for (int i = 1001; i <= 1008 ; i++) {
        UIButton *button = [self.tableView viewWithTag:i];
        [button addTarget:self action:@selector(sportAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)initAD{
    _ADScrollView.delegate = self;
    if (loadingOver) {
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UI_SCREEN_W, 110)];
        image.contentMode = UIViewContentModeScaleAspectFill;
        [image sd_setImageWithURL:_adDict[@"imgurl"]];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(AdAction)];
        [_ADScrollView addGestureRecognizer:tap];
        [_ADScrollView addSubview:image];
        _ADScrollView.showsHorizontalScrollIndicator = NO;
        _ADScrollView.contentSize = CGSizeMake(UI_SCREEN_W + 2, 110);
        //_ADScrollView.alwaysBounceHorizontal =YES;
        _ADScrollView.pagingEnabled = YES;
    }
}

- (void)AdAction{
    
}

- (void)initailCLLocation{
    _locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self;
    //表示每移动对少距离可以被识别
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    //表示把地球分割的精度，分割成边长为多少的小方块
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    //判断有没有决定过要不要使用定位功能(如果没有就执行if语句的操作)
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
#ifdef __IPHONE_8_0
        [_locationManager requestWhenInUseAuthorization];
#endif
    }
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        //开始持续获取设备坐标，更新位置
        [_locationManager startUpdatingLocation];
    }
}

//初始化刷新器
- (void)initRefresh{
    
    JElasticPullToRefreshLoadingViewCircle *loadingViewCircle = [[JElasticPullToRefreshLoadingViewCircle alloc] init];
    loadingViewCircle.tintColor = [UIColor whiteColor];
    
    __weak __typeof(self)weakSelf = self;
    [self.tableView addJElasticPullToRefreshViewWithActionHandler:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.self conRefresh];
        });
    } LoadingView:loadingViewCircle];
    
    //波浪颜色 透明度
    [self.tableView setJElasticPullToRefreshFillColor:[UIColor colorWithRed:0.0431 green:0.7569 blue:0.9412 alpha:1]];
    //空白地方颜色
    [self.tableView setJElasticPullToRefreshBackgroundColor:[UIColor orangeColor]];
}

//当第一次加载app完后才能刷新
- (void)conRefresh{
    //获得运动类型
    if (!sportOver) {
        [self getSportType];
    }
    //获得热门俱乐部
    _hotClubPage = 1;
    isRefresh  =YES;
    [self getHotClub];
    NSLog(@"jing=%f,wei=%f",_jing,_wei);
}

//首页按钮
- (void)sportAction:(UIButton *)sender{
    
    
    SportTypeTableViewController *sportTypeView = [Utilities getStoryboard:@"Home" instanceByIdentity:@"SportTypeView"];
    
    NSDictionary *tempDict = [NSDictionary new];
    switch (sender.tag) {
        case 1001:{
            tempDict = _sportTypeArray[0];
            break;
        }
        case 1002:{
            tempDict = _sportTypeArray[1];
            break;
        }
        case 1003:{
            tempDict = _sportTypeArray[2];
            break;
        }
        case 1004:{
            tempDict = _sportTypeArray[3];
            break;
        }
        case 1005:{
            tempDict = _sportTypeArray[4];
            break;
        }
        case 1006:{
            tempDict = _sportTypeArray[5];
            break;
        }
        case 1007:{
            tempDict = _sportTypeArray[6];
            break;
        }
        case 1008:{
            tempDict = _sportTypeArray[7];
            break;
        }
        default:{
            
            break;
        }
    }
    [self.navigationController pushViewController:sportTypeView animated:YES];
    NSString *fId = tempDict[@"id"];
    NSString *typeName = tempDict[@"name"];
    //将运动id和经纬度传过去
    sportTypeView.city = _cityName;
    sportTypeView.sportType = fId;
    sportTypeView.sportName = typeName;
    sportTypeView.setJing = _jing;
    sportTypeView.setWei = _wei;
}
#pragma mark - 网络请求

- (void)getSportType{
    
    __weak HomeTableViewController *weakSelf = self;
    
    //获取健身项目分类列表url
    NSString *netUrl = @"/homepage/category";
    NSInteger page = 1;
    NSInteger perPage = 10;
    
    NSDictionary *parameters = @{
                                 @"page":@(page),
                                 @"perPage":@(perPage)
                                 };
    //网络请求
    [RequestAPI getURL:netUrl withParameters:parameters success:^(id responseObject) {
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            NSDictionary *result = responseObject[@"result"];
            //数据解析得到name
            _sportTypeArray = result[@"models"];
            //NSLog(@"%@",_sportTypeArray);
            sportOver = YES;
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
            NSArray *indexArray=[NSArray arrayWithObject:indexPath];
            [weakSelf.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationFade];
        }else{
            [self.view makeToast:[NSString stringWithFormat:@"请保持网络畅通,稍后试试吧%@",responseObject[@"resultFlag"]]
                        duration:1.0
                        position:CSToastPositionCenter];
        }
    } failure:^(NSError *error) {
        [self.view makeToast:@"请保持网络畅通"
                    duration:1.0
                    position:CSToastPositionCenter];
    }];
}

//获取热门俱乐部
- (void)getHotClub{
    __weak HomeTableViewController *weakSelf = self;
    
    NSInteger perPage = 5;
    
    
    NSDictionary *parameters;
    if (_jing == 0) {
        parameters = @{
                       @"city":_cityName,
                       @"page":@(_hotClubPage),
                       @"perPage":@(perPage)
                       };
    }else{
        parameters = @{
                       @"city":_cityName,
                       @"jing":@(_jing),
                       @"wei":@(_wei),
                       @"page":@(_hotClubPage),
                       @"perPage":@(perPage)
                       };
    }
    
    //获取热门会所（及其体验券）列表
    NSString *nerUrl = @"/homepage/choice";
    if (!isRefresh) {
        [Utilities getCoolCoverShow:true forController:self];
    }
    //网络请求
    [RequestAPI getURL:nerUrl withParameters:parameters success:^(id responseObject) {
        [Utilities getCoolCoverShow:false forController:self];
        [weakSelf loadDataEnd];
        hotClubOver = true;
        //初始化按钮事件
        [self btnAction];
        if (isRefresh) {
            [weakSelf.tableView stopLoading];
            isRefresh = NO;
        }
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            
            //等于1表示是下拉刷新或者刚进入页面
            if (weakSelf.hotClubPage == 1) {
                _hotClubInfoArray = nil;
                _hotClubInfoArray = [NSMutableArray new];
            }
            
            NSDictionary *result = responseObject[@"result"];
            NSArray *info = result[@"models"];
            NSDictionary *pagingInfo = result[@"pagingInfo"];
            //广告
            NSArray *array = responseObject[@"advertisement"];
            _adDict = array.firstObject;
            //封装数据
            for (int i = 0; i < info.count; i++) {
                NSString *name = info[i][@"name"];
                NSString *address = info[i][@"address"];
                NSString *distance = info[i][@"distance"];
                NSString *image = info[i][@"image"];
                NSString *clubKeyId = info[i][@"id"];
                
                NSDictionary *dict = @{
                                       @"name":name,
                                       @"address":address,
                                       @"distance":distance,
                                       @"image":image,
                                       @"id":clubKeyId
                                       };
                [weakSelf.hotClubInfoArray addObject:dict];
            }
            //网络请求完毕后刷新cell（用于判断是否经历过第一次刷新）
            loadingOver = YES;
            weakSelf.totalPage = [pagingInfo[@"totalPage"] integerValue];
            //初始化广告
            [self initAD];
            [weakSelf.tableView reloadData];
        }else{
            weakSelf.totalPage = 0;
            if ([responseObject[@"resultFlag"] integerValue] == 8020) {
                weakSelf.hotClubPage = 0;
                [_chooseLocationButton setTitle:_cityName forState:UIControlStateNormal];
                hotClubOver = false;
                [weakSelf.tableView reloadData];
                [self.view makeToast:@"暂无数据,您可以从上方选择城市"
                            duration:1.0
                            position:CSToastPositionCenter];
                return ;
            }
            [self.view makeToast:[NSString stringWithFormat:@"保持网络畅通，稍后再试%@",responseObject[@"resultFlag"]]
                        duration:1.0
                        position:CSToastPositionCenter];
        }
    } failure:^(NSError *error) {
        [Utilities getCoolCoverShow:false forController:self];
        weakSelf.totalPage = 0;
        if (isRefresh) {
            [weakSelf.tableView stopLoading];
            isRefresh = NO;
        }
        [self.view makeToast:@"请保持网络畅通"
                    duration:1.0
                    position:CSToastPositionCenter];
    }];
}

#pragma mark - CLLocationManagerDelegate

//定位开始执行
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    if (newLocation.coordinate.latitude == oldLocation.coordinate.latitude && newLocation.coordinate.longitude == oldLocation.coordinate.longitude) {
        NSLog(@"获得完毕经纬度");
        locationError = false;
        _jing = newLocation.coordinate.longitude;
        _wei = newLocation.coordinate.latitude;
        
        [Utilities removeUserDefaults:@"jing"];
        [Utilities removeUserDefaults:@"wei"];
        [Utilities setUserDefaults:@"jing" content:@(newLocation.coordinate.longitude)];
        [Utilities setUserDefaults:@"wei" content:@(newLocation.coordinate.latitude)];
        
        [self getCityName];
        [manager stopUpdatingLocation];
    }
}

//获得城市
- (void)getCityName{
    CLGeocoder *geocoder = [CLGeocoder new];
    CLLocation *annotationLocation = [[CLLocation alloc]initWithLatitude:_wei longitude:_jing];
    [geocoder reverseGeocodeLocation:annotationLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        //如果没有出现错误
        if (!error) {
            NSDictionary *info = [placemarks[0] addressDictionary];
            NSString *name = info[@"City"];
            NSLog(@"name-->%@",name);
            if (name != nil) {
                //是不是中文地址
                if([[name substringFromIndex:name.length - 1] isEqualToString:@"市"]){
                    _cityName = [name substringToIndex:name.length - 1];
                    [_chooseLocationButton setTitle:_cityName forState:UIControlStateNormal];
                }else{
                    [self.view makeToast:@"你当前语言非中文，我们不能为您提供服务,我们将您地址默认为无锡" duration:2.0f position:CSToastPositionCenter];
                    [_chooseLocationButton setTitle:@"无锡" forState:UIControlStateNormal];
                    _cityName = @"无锡";
                    //_city = name;
                }
                [self getHotClub];
                [[StorageMgr singletonStorageMgr] addKey:@"jing" andValue:@(_jing)];
                [[StorageMgr singletonStorageMgr] addKey:@"wei" andValue:@(_wei)];
                [[StorageMgr singletonStorageMgr] addKey:@"cityName" andValue:[_cityName lowercaseString]];
                
                //把城市缓存起来
                [Utilities removeUserDefaults:@"cityName"];
                [Utilities setUserDefaults:@"cityName" content:_cityName];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"setCity" object:nil userInfo:@{@"city":_cityName}];
                
                NSLog(@"_city = %@",_cityName);
            }else{
                [self.view makeToast:@"我们无法获取位置,您可以自行选择"
                            duration:1.0
                            position:CSToastPositionCenter];
                [_chooseLocationButton setTitle:@"无位置" forState:UIControlStateNormal];
            }
        }else{
            [self.view makeToast:@"逆地理编码失败"
                        duration:1.0
                        position:CSToastPositionCenter];
        }
    }];
}

//定位失败
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    locationError = YES;
    //失败就获取默认的,或者使用之前的经纬度
    [self getHotClub];
    [self checkError:error];
}

//定位请求错误提示
-(void)checkError:(NSError *)error{
    switch (error.code) {
        case kCLErrorNetwork:{
            [self.view makeToast:@"没有网络连接"
                        duration:1.0
                        position:CSToastPositionCenter];
        }
            break;
        case kCLErrorDenied:{
            [self.view makeToast:@"您没有开定位"
                        duration:1.0
                        position:CSToastPositionCenter];
        }
            break;
        case kCLErrorLocationUnknown:{
            [self.view makeToast:@"获取位置失败"
                        duration:1.0
                        position:CSToastPositionCenter];
            NSLog(@"获取位置失败");
        }
            break;
        default:{
            [self.view makeToast:@"UnKnow Error"
                        duration:1.0
                        position:CSToastPositionCenter];
        }
            break;
    }
}

/** 定位服务状态改变时调用*/
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        {
            NSLog(@"用户还未决定授权");
            break;
        }
        case kCLAuthorizationStatusRestricted:
        {
            NSLog(@"访问受限");
            break;
        }
        case kCLAuthorizationStatusDenied:
        {
            // 类方法，判断是否开启定位服务
            if ([CLLocationManager locationServicesEnabled]) {
                NSLog(@"定位服务开启，被拒绝");
                [self.view makeToast:@"您未对本程序授权定位，您可前往设置打开本app的定位，可更好的为您服务"
                            duration:1.0
                            position:CSToastPositionCenter];
            } else {
                NSLog(@"定位服务关闭，不可用");
                [self.view makeToast:@"定位服务关闭，不可用"
                            duration:1.0
                            position:CSToastPositionCenter];
            }
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            NSLog(@"获得前后台授权");
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            NSLog(@"获得前台授权");
            break;
        }
        default:
            break;
    }
}

#pragma mark - UIScrollViewDelegate

//滚动(上拉刷新)
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView.contentSize.height + 64 > scrollView.frame.size.height ) {
        if(scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height + 74){
            [self createTableFooter];
            [self loadDataing];
        }
    }else{
        if (scrollView.contentOffset.y > -64) {
            [self createTableFooter];
            [self loadDataing];
        }
    }
}

-(void)createTableFooter{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    footerView.backgroundColor = [UIColor blackColor];
    self.tableView.tableFooterView = footerView;
    
    UILabel *loadMore = [[UILabel alloc]initWithFrame:CGRectMake((UI_SCREEN_W - 120)  / 2 , 0, 120, 40)];
    //loadMore.backgroundColor = [UIColor brownColor];
    loadMore.textColor = [UIColor whiteColor];
    loadMore.textAlignment = NSTextAlignmentCenter;
    loadMore.tag = 10086;
    loadMore.text = @"加载中...";
    loadMore.font = [UIFont systemFontOfSize:B_Font];
    loadMore.textColor = [UIColor lightGrayColor];
    [footerView addSubview:loadMore];
}

-(void)loadDataing{
    //判断是否还存在下一页
    if (_totalPage > _hotClubPage) {
        if (loadingOver) {
            //之前如果是yes说明正常进入了网络请求，页数加一，把加载成功改为NO
            _hotClubPage ++;
            loadingOver = NO;
            [self getHotClub];
        }
    }else{
        [self beforeLoadEnd];
        [self performSelector:@selector(loadDataEnd) withObject:nil afterDelay:1.0f];
    }
}

- (void)beforeLoadEnd{
    UILabel *loadMore = (UILabel *)[self.tableView.tableFooterView viewWithTag:10086];
    loadMore.text = @"没有更多数据";
    loadMore.frame = CGRectMake((UI_SCREEN_W - 120)  / 2 , 0, 120, 40);
}

- (void)loadDataEnd{
    self.tableView.tableFooterView =[[UIView alloc]init];
}

#pragma mark - titleAction

- (IBAction)chooseLocationAction:(UIButton *)sender forEvent:(UIEvent *)event {
    [self chooseCity];
}

- (IBAction)searchAction:(UIBarButtonItem *)sender {
    
    SearchViewController *searchView = [Utilities getStoryboard:@"Home" instanceByIdentity:@"SearchView"];
    [self.navigationController pushViewController:searchView animated:YES];
    searchView.jing = _jing;
    searchView.wei = _wei;
}

- (void)chooseCity{
    CityTableViewController *cityView = [Utilities getStoryboard:@"Home" instanceByIdentity:@"CityView"];
    [self.navigationController pushViewController:cityView animated:YES];
    cityView.cityBlock = ^(NSString *city, NSString *postalCode){
        //如果是从选择城市页面回来 要防止页码不对的问题
        _hotClubPage = 1;
        [_chooseLocationButton setTitle:city forState:UIControlStateNormal];
        _cityName = city;
        //_city = postalCode;
        NSLog(@"%@,%@",city,postalCode);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setCity" object:nil userInfo:@{@"city":_cityName}];
        locationError = NO;
        [self getHotClub];
    };
}

#pragma mark - setMD5RSA

- (void)setMD5RSA{
    //获取模数指数
    NSDictionary *dic = @{@"deviceType":@7001,
                          @"deviceId":[Utilities uniqueVendor]
                          };
    
    [RequestAPI getURL:@"/login/getKey" withParameters:dic success:^(id responseObject) {
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            NSDictionary *resultDict = responseObject[@"result"];
            NSString *exponent = resultDict[@"exponent"];
            NSString *modulus = resultDict[@"modulus"];
            //从单例化全局变量中删除数据
            [[StorageMgr singletonStorageMgr] removeObjectForKey:@"exponent"];
            [[StorageMgr singletonStorageMgr] removeObjectForKey:@"modulus"];
            
            [[StorageMgr singletonStorageMgr] addKey:@"exponent" andValue:exponent];
            [[StorageMgr singletonStorageMgr] addKey:@"modulus" andValue:modulus];
            
            [self lastOrLogin];
        }else{
            NSLog(@"resultFailed");
        }
        
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
}

- (void)lastOrLogin{
    //首先判断用户是否登录过
    if([[Utilities getUserDefaults:@"OrLogin"] boolValue]){
        //拿到缓存的密码
        NSString *username = [Utilities getUserDefaults:@"Username"];
        NSString *password = [Utilities getUserDefaults:@"Password"];
        if (username.length == 0 || password.length == 0) {
            return;
        }
        //如果登录了那么这里在判断  上一次是否按了退出按钮   yse  表示按了
        if ( [[Utilities getUserDefaults:@"AddUserAndPw"] boolValue]) {
            
            //表示用户 登录后  按了退出  这边依旧设置未登录  因为这里是默认从appdelage 进入  所以  全局变量inOrup  这边默认是NO （也就是未登录）
            //然后让  SignUpSuccessfully这个键为YES   那么在进入登录界面时  会运行  viewWillA 里面的放法
            [[StorageMgr singletonStorageMgr]removeObjectForKey:@"SignUpSuccessfully"];
            [[StorageMgr singletonStorageMgr]addKey:@"SignUpSuccessfully" andValue:@YES];
            //最后把  之前退出时  缓存了一个Username 的值给  全局变量 的Username    这样退出之后就会有用户名显示
            [[StorageMgr singletonStorageMgr]addKey:@"Username" andValue:[Utilities getUserDefaults:@"Username"]];
            return;
        }
        //这里是当判断到用户有登陆过  并且没有退出过   开启APP时   默认请求登录
        NSString *exponent = [[StorageMgr singletonStorageMgr] objectForKey:@"exponent"];
        NSString *modulus = [[StorageMgr singletonStorageMgr] objectForKey:@"modulus"];
        //MD5将原始密码进行MD5加密
        NSString *MD5Pwd = [password getMD5_32BitString];
        //将MD5加密过后的密码进行RSA非对称加密
        NSString *RSAPwd = [NSString encryptWithPublicKeyFromModulusAndExponent:MD5Pwd.UTF8String modulus:modulus exponent:exponent];
        
        NSDictionary *dic = @{@"userName":username,
                              @"password":RSAPwd,
                              @"deviceType":@7001,
                              @"deviceId":[Utilities uniqueVendor]};
        
        [RequestAPI postURL:@"/login" withParameters:dic success:^(id responseObject) {
            //NSLog(@"obj =======  %@",responseObject);
            if ([responseObject[@"resultFlag"] integerValue] == 8001) {
                NSLog(@"自动登录成功");
                NSDictionary *result = responseObject[@"result"];
                
                //这里将 全局变量键inOrUp  设置成yes  就可以运行leftVC  里的viewWillA  里的方法
                [[StorageMgr singletonStorageMgr]removeObjectForKey:@"inOrUp"];
                [[StorageMgr singletonStorageMgr]addKey:@"inOrUp" andValue:@YES];
                
                //紧接着这边给缓存  键Username  给值（result[@"contactTel"]）
                [Utilities removeUserDefaults:@"Username"];
                [Utilities setUserDefaults:@"Username" content:result[@"contactTel"]];
                
                NSString *strUser = [Utilities getUserDefaults:@"switchUser"];
                NSLog(@"strUser = %@",strUser);
                if ([strUser isEqualToString:@"openUser"]) {
                    [Utilities removeUserDefaults:@"switch"];
                    [Utilities setUserDefaults:@"switch" content:@"open"];
                }
                
                //这里获取到  ID  并存进全局变量
                NSString *memberId = result[@"memberId"];
                [[StorageMgr singletonStorageMgr]removeObjectForKey:@"memberId"];
                [[StorageMgr singletonStorageMgr]addKey:@"memberId" andValue:memberId];
                
                NSDictionary *dict = @{@"memberId":result[@"memberId"],
                                       @"memberSex":result[@"memberSex"],
                                       @"memberName":result[@"memberName"],
                                       @"birthday":result[@"birthday"],
                                       @"identificationcard":result[@"identificationcard"]
                                       };
                [[StorageMgr singletonStorageMgr]removeObjectForKey:@"dict"];
                [[StorageMgr singletonStorageMgr]addKey:@"dict" andValue:dict];
            }else{
                [self.view makeToast:@"登录失败，请保持网络通畅"
                            duration:1.0
                            position:CSToastPositionCenter];
                NavigationViewController *navView = [Utilities getStoryboard:@"Main" instanceByIdentity:@"nav"];
                [self presentViewController:navView animated:YES completion:nil];
            }
        } failure:^(NSError *error) {
            [self.view makeToast:@"系统繁忙,请重新登录"
                        duration:1.0
                        position:CSToastPositionCenter];
            NavigationViewController *navView = [Utilities getStoryboard:@"Main" instanceByIdentity:@"nav"];
            [self presentViewController:navView animated:YES completion:nil];
        }];
    }
}

- (IBAction)leftButton:(UIBarButtonItem *)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"MenuSwitch" object:nil];
}
@end