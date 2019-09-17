//
//  ShareFriendTableViewCell.h
//  BlueCralishMoneyBook
//
//  Created by Bomi on 2019/9/11.
//  Copyright © 2019 PD101. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Share.h"

@interface ShareFriendTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *titleButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;

- (void)configCell:(Share *)share;
- (void)configIsEditing:(BOOL)isEditing;

@end
