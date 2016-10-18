//
//  RightTableViewCell.m
//  Calorie
//
//  Created by Z on 16/5/7.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "RightTableViewCell.h"

@implementation RightTableViewCell

- (void)awakeFromNib {
    // Initialization code
    _clubLable.adjustsFontSizeToFitWidth = true;
    _experienceLable.adjustsFontSizeToFitWidth = true;
    
    //添加阴影效果
    _rightView.layer.masksToBounds = NO;//隐藏边界
    _rightView.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    
    _rightView.layer.shadowOffset = CGSizeMake(0, 0);//shadowOffset阴影偏移,x向右偏移3，y向下偏移3，默认(0, -3),这个跟shadowRadius配合使用
    
    _rightView.layer.shadowOpacity = 0.8;//阴影透明度，默认0
    
    _rightView.layer.shadowRadius = 8;//阴影半径，默认3
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
