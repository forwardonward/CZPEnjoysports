//
//  LeftTableViewCell.m
//  Calorie
//
//  Created by Z on 16/5/7.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "LeftTableViewCell.h"

@implementation LeftTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _clubLable.adjustsFontSizeToFitWidth = true;
    _experienceLable.adjustsFontSizeToFitWidth = true;
    
    //添加阴影效果
    _leftView.layer.masksToBounds = NO;//隐藏边界
    _leftView.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    
    _leftView.layer.shadowOffset = CGSizeMake(0, 0);//shadowOffset阴影偏移,x向右偏移3，y向下偏移3，默认(0, -3),这个跟shadowRadius配合使用
    
    _leftView.layer.shadowOpacity = 0.8;//阴影透明度，默认0
    
    _leftView.layer.shadowRadius = 8;//阴影半径，默认3
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
