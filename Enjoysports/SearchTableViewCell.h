//
//  SearchTableViewCell.h
//  Calorie
//
//  Created by Z on 16/4/19.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *hotClubView;//俱乐部View
@property (weak, nonatomic) IBOutlet UIImageView *image;//俱乐部图片
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;//俱乐部名字
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;//地址
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;//距离

@end
