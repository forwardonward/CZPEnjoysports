//
//  LeftTableViewCell.h
//  Calorie
//
//  Created by Z on 16/5/7.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIImageView *experienceImg;
@property (weak, nonatomic) IBOutlet UILabel *clubLable;
@property (weak, nonatomic) IBOutlet UILabel *experienceLable;

@end
