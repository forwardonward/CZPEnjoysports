//
//  OpenOrCloseTableViewCell.m
//  Calorie
//
//  Created by xyl on 16/5/8.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import "OpenOrCloseTableViewCell.h"

@implementation OpenOrCloseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)changeValue:(UISwitch *)sender forEvent:(UIEvent *)event {
    if (_delegate && [_delegate respondsToSelector:@selector(switchChangeValue:switchs:)]) {
//        [_delegate switchChangeValue:switch:_indexPath];
        [_delegate switchChangeValue:_indexPath switchs:_switchBtn];
    }
}
@end
