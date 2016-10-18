//
//  SearchViewController.m
//  Calorie
//
//  Created by Z on 16/4/19.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchTableViewCell.h"
#import "CityTableViewController.h"
#import "ClubDetailViewController.h"

#import <UIImageView+WebCache.h>

@interface SearchViewController (){
    BOOL loadOver;
    BOOL isLoading;
}

//设置搜索参数
@property(nonatomic)NSInteger page;
@property(nonatomic)NSInteger perPage;
@property(nonatomic)NSInteger typeInt;
@property(nonatomic, strong)NSString *keyword;
//选择的城市信息
//@property(nonatomic, strong)NSString *cityName;
@property(nonatomic, strong)NSString *postalCode;
//接受参数的数组
@property(nonatomic, strong)NSMutableArray *dataArray;

@end

@implementation SearchViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //取消tableview下划线
    //    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //去掉tableView的滚动条
    self.tableView.showsVerticalScrollIndicator = NO;
    
    //各种初始化
    loadOver = NO;
    isLoading = NO;
    _page = 1;
    _perPage = 5;
    //默认按距离排序
    _typeInt = 0;
    
    //数组初始化
    _dataArray = [NSMutableArray new];
    
    //初始化
    _keyword = _searchTextField.text;
    
    //协议
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _searchTextField.delegate = self;
    
    //默认无锡
    _postalCode = @"0510";
}

- (void)requestData{
    isLoading = YES;
    __weak SearchViewController *weakSelf = self;
    //搜索API
    NSString *netUrl = @"/clubController/nearSearchClub";
    /*
     city：城市区号（用户选择的查询城市）
     jing：用户当前位置经度
     wei：用户当前位置纬度
     page：当前页码
     perPage：每页数量
     type：排序类型（0：按距离；1：按人气）
     可选featureId：需要查询的健身类型ID
     可选brandId：需要查询的品牌ID
     可选distance：查询附近多少米范围
     可选areaId：需要查询的区ID
     可选streetId：需要查询的街道ID
     可选keyword：需要查询的关键字
     */
    
    NSDictionary *parameters = @{
                                 @"city":_postalCode,
                                 @"jing":@(_jing),
                                 @"wei":@(_wei),
                                 @"page":@(_page),
                                 @"perPage":@(_perPage),
                                 @"type":@(_typeInt),
                                 @"keyword":_keyword
                                 };
    
    [Utilities getCoolCoverShow:true forController:self];
    [RequestAPI getURL:netUrl withParameters:parameters success:^(id responseObject) {
        [Utilities getCoolCoverShow:false forController:self];
        isLoading = NO;
        if ([responseObject[@"resultFlag"]integerValue] == 8001) {
            //NSLog(@".,.,.>>>>>%@",responseObject);
            NSDictionary *result = responseObject[@"result"];
            weakSelf.dataArray = result[@"models"];
            
            loadOver = YES;
            [weakSelf.tableView reloadData];
        }else{
            if ([responseObject[@"resultFlag"] integerValue] == 8020) {
                [self.view makeToast:@"暂无数据"
                            duration:1.0
                            position:CSToastPositionCenter];
                _postalCode = @"0510";
                [weakSelf requestData];
                [_cityBtn setTitle:@"无锡" forState:UIControlStateNormal];
            }else{
                [self.view makeToast:[NSString stringWithFormat:@"请稍后重试%@",responseObject[@"resultFlag"]]
                            duration:1.0
                            position:CSToastPositionCenter];
            }
        }
    } failure:^(NSError *error) {
        [Utilities getCoolCoverShow:false forController:self];
        isLoading = NO;
        [self.view makeToast:@"请保持网络畅通"
                    duration:1.0
                    position:CSToastPositionCenter];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UItableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (loadOver) {
        if(_dataArray.count == 0){
            [self.view makeToast:@"暂无数据"
                        duration:1.0
                        position:CSToastPositionCenter];
            return cell;
        }
        cell.nameLabel.text = _dataArray[indexPath.row][@"clubName"];
        cell.addressLabel.text = _dataArray[indexPath.row][@"clubAddressB"];
        if (_jing != 0) {
            cell.distanceLabel.text = [NSString stringWithFormat:@"%@米",_dataArray[indexPath.row][@"distance"]];
        }else{
            cell.distanceLabel.text = @"无法获取距离";
        }
        [cell.image sd_setImageWithURL:_dataArray[indexPath.row][@"clubLogo"]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选择
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ClubDetailViewController *clubDetail = [Utilities getStoryboard:@"Home" instanceByIdentity:@"ClubDetailView"];
    //
    clubDetail.clubKeyId = _dataArray[indexPath.row][@"clubId"];
    [self.navigationController pushViewController:clubDetail animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 220;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
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

#pragma mark - private

- (IBAction)searchButton:(UIButton *)sender forEvent:(UIEvent *)event {
    _keyword = _searchTextField.text;
    if (!isLoading) {
        [self requestData];
    }else{
        [self.view makeToast:@"请求正在进行，请稍后操作"
                    duration:1.0
                    position:CSToastPositionCenter];
    }
}

//选择城市按钮
- (IBAction)cityButtonAction:(UIButton *)sender forEvent:(UIEvent *)event {
    __weak SearchViewController *weakSelf  = self;
    CityTableViewController *cityView = [Utilities getStoryboard:@"Home" instanceByIdentity:@"CityView"];
    [self.navigationController pushViewController:cityView animated:YES];
    
    cityView.cityBlock = ^(NSString *city, NSString *postalCode){
        //_cityName = city;
        _postalCode = postalCode;
        NSLog(@"--->%@,%@",city,postalCode);
        [sender setTitle:city forState:UIControlStateNormal];
        [weakSelf requestData];
    };
}

//类型按钮
- (IBAction)typeAction:(UIButton *)sender forEvent:(UIEvent *)event {
    if(_jing == 0){
        [sender setEnabled:NO];
        return;
    }
    if (_typeInt) {
        _typeInt = 0;
        [sender setTitle:@"按距离" forState:UIControlStateNormal];
    }else{
        _typeInt = 1;
        [sender setTitle:@"按人气" forState:UIControlStateNormal];
    }
    //防止重复发送网络请求
    if (!isLoading) {
        [self requestData];
    }else{
        [self.view makeToast:@"请求正在进行，请稍后操作"
                    duration:1.0
                    position:CSToastPositionCenter];
    }
}

//行数按钮，用于显示用户输入行数
- (IBAction)perPageAction:(UIButton *)sender forEvent:(UIEvent *)event {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"请输入要显示的行数" preferredStyle:UIAlertControllerStyleAlert];
    //添加输入框
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"好了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (!isLoading) {
            if ([self isPureInt:alert.textFields.firstObject.text]) {
                _perPage = [alert.textFields.firstObject.text integerValue];
                [sender setTitle:[NSString stringWithFormat:@"%ld行",_perPage] forState:UIControlStateNormal];
                [self requestData];
            }
        }else{
            [self.view makeToast:@"请求正在进行，请稍后操作"
                        duration:1.0
                        position:CSToastPositionCenter];
        }
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
