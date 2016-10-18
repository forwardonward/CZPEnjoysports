//
//  CollectSubpageTableViewCell.h
//  Calorie
//
//  Created by Z on 16/4/19.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectSubpageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *clubView;//俱乐部View
@property (weak, nonatomic) IBOutlet UIImageView *clubImage;//俱乐部图片
@property (weak, nonatomic) IBOutlet UILabel *clubName;//俱乐部名字
@property (weak, nonatomic) IBOutlet UILabel *clubAddress;//地址
@property (weak, nonatomic) IBOutlet UILabel *distance;//距离

@end
