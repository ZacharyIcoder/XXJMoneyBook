//
//  ShareBannerTableViewCell.h
//  BlueCralishMoneyBook
//
//  Created by Bomi on 2019/9/11.
//  Copyright © 2019 PD101. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Share.h"

@interface ShareBannerTableViewCell : UITableViewCell

- (void)configWithShares:(NSArray <Share *>*)shares;

@end
