//
//  HotClubTableViewCell.m
//  Calorie
//
//  Created by 杨凡 on 16/4/16.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "HotClubTableViewCell.h"

@implementation HotClubTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    //_clubImageView.contentMode = UIViewContentModeScaleAspectFit;
    // Initialization code
    //添加阴影效果
    _hotClubView.layer.masksToBounds = NO;//隐藏边界
    _hotClubView.layer.shadowColor = [UIColor blackColor].CGColor;//shadowColor阴影颜色
    
    _hotClubView.layer.shadowOffset = CGSizeMake(0, 0);//shadowOffset阴影偏移,x向右偏移3，y向下偏移3，默认(0, -3),这个跟shadowRadius配合使用
    
    _hotClubView.layer.shadowOpacity = 0.8;//阴影透明度，默认0
    
    _hotClubView.layer.shadowRadius = 8;//阴影半径，默认3
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
