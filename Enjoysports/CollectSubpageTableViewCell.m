//
//  CollectSubpageTableViewCell.m
//  Calorie
//
//  Created by Z on 16/4/19.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "CollectSubpageTableViewCell.h"

@implementation CollectSubpageTableViewCell

- (void)awakeFromNib {
    // Initialization code
    //添加阴影效果
    _clubView.layer.masksToBounds = NO;//隐藏边界
    
    _clubView.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    
    _clubView.layer.shadowOffset = CGSizeMake(0, 0);//shadowOffset阴影偏移,x向右偏移3，y向下偏移3，默认(0, -3),这个跟shadowRadius配合使用
    
    _clubView.layer.shadowOpacity = 0.8;//阴影透明度，默认0
    
    _clubView.layer.shadowRadius = 8;//阴影半径，默认3
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
