//
//  ExperienceViewController.m
//  Calorie
//
//  Created by xyl on 16/4/22.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "ExperienceViewController.h"
#import "FirstExperienceTableViewCell.h"
#import "SecondExperienceTableViewCell.h"
#import <UIImageView+WebCache.h>
@interface ExperienceViewController ()<UITableViewDelegate,UITableViewDataSource>{
    CGFloat height;
}

@property (strong,nonatomic)NSMutableDictionary *objectForShow;

@end

@implementation ExperienceViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"购买" style:UIBarButtonItemStyleDone target:self action:@selector(buyExperience)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)buyExperience{
    /*
     下单
     /orderController/billOrder
     POST
     入参：memberId（用户ID）；userName（用户名）；productName（体验券名）；productSinglePrice（单价）；paymentId（支付方式，领取免费体验券时填2）；shouldPay（总价）；donePay（最终应付，总价减去折扣以及积分抵用后的价格）；needQuantity（购买数量）；type（卡券类型，体验券为1）；usedSportCoin（运动币抵用，100运动币=1RMB）；messageLefted（购买备注）；productId（体验券ID）
     出参：resultFlag（8001成功）
     */
    
    //下单
    NSString *url = @"/orderController/billOrder";
    NSString *userId = [[StorageMgr singletonStorageMgr] objectForKey:@"memberId"];
    if (userId == nil) {
        [Utilities popUpAlertViewWithMsg:@"" andTitle:@"请登录" onView:self];
        return;
    }
    NSDictionary *dict = @{
                           //用户ID
                           @"memberId":userId,
                           //用户名
                           @"userName":[Utilities getUserDefaults:@"Username"],
                           //体验券名
                           @"productName":_objectForShow[@"eName"],
                           //单价
                           @"productSinglePrice":@(0),
                           //支付方式，领取免费体验券时填2
                           @"paymentId":@2,
                           //总价
                           @"shouldPay":@0,
                           //最终应付，总价减去折扣以及积分抵用后的价格
                           @"donePay":@([_objectForShow[@"currentPrice"] floatValue]),
                           //购买数量
                           @"needQuantity":@1,
                           //卡券类型，体验券为1
                           @"type":@1,
                           //运动币抵用，100运动币=1RMB
                           @"usedSportCoin":@0,
                           //购买备注
                           @"messageLefted":@"这里是购买备注",
                           //体验券ID
                           @"productId":_experienceInfos
                           };
    [SVProgressHUD showWithStatus:@"正在购买"];
    self.navigationController.navigationBar.userInteractionEnabled = false;
    [RequestAPI postURL:url withParameters:dict success:^(id responseObject) {
        [SVProgressHUD dismiss];
        self.navigationController.navigationBar.userInteractionEnabled = true;
        if ([responseObject[@"resultFlag"] integerValue] == 8001) {
            NSDictionary *dict = responseObject[@"result"];
            NSString *resultStr = [NSString stringWithFormat:@"您已购买%@的%@,合计%@元",dict[@"clubName"],dict[@"productname"],dict[@"donepay"]];
            [self.view makeToast:resultStr duration:3.f position:CSToastPositionBottom];
        }else{
            if ([responseObject[@"resultFlag"] integerValue] == 8032) {
                [self.view makeToast:[NSString stringWithFormat:@"金额异常：%@",responseObject[@"resultFlag"]] duration:1.f position:CSToastPositionBottom];
                return ;
            }
            [self.view makeToast:[NSString stringWithFormat:@"网络异常：%@",responseObject[@"resultFlag"]] duration:1.f position:CSToastPositionBottom];
        }
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        self.navigationController.navigationBar.userInteractionEnabled = true;
        [self.view makeToast:@"网络错误" duration:1.f position:CSToastPositionBottom];
        [Utilities popUpAlertViewWithMsg:@"网络错误" andTitle:@"" onView:self];
    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置tableView不能滑动
     //[self.TableView setScrollEnabled:NO];
    //取消tableview下划线
    //    self.tableView.tableFooterView = [[UIView alloc]init];
    self.TableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //去掉tableView的滚动条
    self.TableView.showsVerticalScrollIndicator = NO;
    
    //[[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    _TableView.delegate = self;
    _TableView.dataSource = self ;
    
    _objectForShow = [NSMutableDictionary new];
    [self showExperience];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)showExperience{
    [_objectForShow removeAllObjects];
    NSDictionary *dic = @{@"experienceId":_experienceInfos,};
    
    [Utilities getCoolCoverShow:true forController:self];
    [RequestAPI getURL:@"/clubController/experienceDetail" withParameters:dic success:^(id responseObject) {
        [Utilities getCoolCoverShow:false forController:self];
        //NSLog(@"obj = %@",responseObject);
        _objectForShow = [NSMutableDictionary dictionaryWithDictionary:responseObject[@"result"]];
        [_TableView reloadData];
    } failure:^(NSError *error) {
        [Utilities getCoolCoverShow:false forController:self];
        NSLog(@"error = %@", [error userInfo]);
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section  {
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    switch (indexPath.row) {
        case 0:{
            FirstExperienceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
            [ cell.eLogoImageView sd_setImageWithURL:_objectForShow[@"eLogo"] placeholderImage:[UIImage imageNamed:@"hotClubDefaultImage"]];
            cell.eName.text = [NSString stringWithFormat:@"%@",_objectForShow[@"eName"]];
            cell.eClubName.adjustsFontSizeToFitWidth = YES;
            cell.eClubName.text = [NSString stringWithFormat:@"%@",_objectForShow[@"eClubName"]];
            cell.eAddress.text = [NSString stringWithFormat:@"%@",_objectForShow[@"eAddress"]];
            //设置文字自适应
            cell.eAddress.adjustsFontSizeToFitWidth = YES;
            //取消边框线
            //            [cell setBackgroundView:[[UIView alloc] init]];
            //            cell.backgroundColor = [UIColor clearColor];
            return cell;
            break;
        }
            
        default:{
            SecondExperienceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
            
            cell.orginPrice.text = [NSString stringWithFormat:@"原价:%@",_objectForShow[@"orginPrice"]];
            cell.currentPrice.text =[NSString stringWithFormat:@"现价:%@",_objectForShow[@"currentPrice"]];
            cell.saleCount.text = [NSString stringWithFormat:@"销售数量:%@",_objectForShow[@"saleCount"]];
            cell.endDate.text = [NSString stringWithFormat:@"有效期结束时间:%@",_objectForShow[@"endDate"]];
            cell.endDate.adjustsFontSizeToFitWidth = YES;
            cell.useDate.text = [NSString stringWithFormat:@"可用时间段:%@",_objectForShow[@"useDate"]];
            cell.beginDate.text = [NSString stringWithFormat:@"有效期开始时间:%@",_objectForShow[@"beginDate"]];
            cell.beginDate.adjustsFontSizeToFitWidth = YES;
            cell.relus.text = [NSString stringWithFormat:@"使用规则:\n%@",_objectForShow[@"rules"]];
            //取消选中颜色
            UIView *cellClickVc = [[UIView alloc]initWithFrame:cell.frame];
            cell.selectedBackgroundView = cellClickVc;
            cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
            //用户交互
            //cell.userInteractionEnabled = NO;
            //            //取消边框线
            //            [cell setBackgroundView:[[UIView alloc] init]];
            //            cell.backgroundColor = [UIColor clearColor];
            
            //获取文字内容
            NSString *content = cell.relus.text;
            //获取文字宽度
            CGSize maxSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width - 20, 10000);
            //获取文字字体
            UIFont *contentFont = cell.relus.font;
            //根据上述三元素获取文字的高度
            CGSize contentSize = [content boundingRectWithSize:maxSize options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:contentFont} context:nil].size;
            
            CGFloat contentHeight = contentSize.height;
            //将文本视图的高度约束设置为文字内容高度加上文本视图默认的上下留白长度（8）,多加一点防止显示不全
            cell.tapTrick.constant = contentHeight + 18;
            
            height = cell.tapTrick.constant;
            
            NSLog(@"--->%@",_objectForShow[@"rules"]);
            
            return cell;
            break;
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            return 256;
            break;
        default:
            return 133 + height;
            break;
    }
}
@end
