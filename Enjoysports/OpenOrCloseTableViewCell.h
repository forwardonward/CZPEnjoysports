//
//  OpenOrCloseTableViewCell.h
//  Calorie
//
//  Created by xyl on 16/5/8.
//  Copyright © 2016年 Hurricane. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SwitchTableViewDelegate <NSObject>

@required

- (void)switchChangeValue:(NSIndexPath *)indexPath switchs:(id)sender;

@end

@interface OpenOrCloseTableViewCell : UITableViewCell

@property(weak,nonatomic) id<SwitchTableViewDelegate>delegate;
@property(nonatomic,strong) NSIndexPath *indexPath;

@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;

- (IBAction)changeValue:(UISwitch *)sender forEvent:(UIEvent *)event;

@end
