//
//  ShareFriendTableViewCell.m
//  BlueCralishMoneyBook
//
//  Created by Bomi on 2019/9/11.
//  Copyright © 2019 PD101. All rights reserved.
//

#import "ShareFriendTableViewCell.h"
#import "UIColor+Hex.h"

@implementation ShareFriendTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
}

- (void)configCell:(Share *)share {
    NSString *title = @"";
    if (share.money.doubleValue >= 0) {
        title = @"借";
        [self.titleButton setBackgroundColor:[UIColor hexColor:@"E4D078"]];
    } else {
        title = @"欠";
        [self.titleButton setBackgroundColor:[UIColor hexColor:@"EAACB6"]];
    }
    [self.titleButton setTitle:title forState:UIControlStateNormal];
    self.nameLabel.text = share.name;
    self.moneyLabel.text = share.money;
}

- (void)configIsEditing:(BOOL)isEditing {
    if (isEditing) {
        [self.titleButton setHidden:YES];
    } else {
        [self.titleButton setHidden:NO];
    }
}

@end
