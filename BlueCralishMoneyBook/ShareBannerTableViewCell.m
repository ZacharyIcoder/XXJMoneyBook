//
//  ShareBannerTableViewCell.m
//  BlueCralishMoneyBook
//
//  Created by Bomi on 2019/9/11.
//  Copyright © 2019 PD101. All rights reserved.
//

#import "ShareBannerTableViewCell.h"
#import "NSNumber+String.h"

@interface ShareBannerTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *oweLabel;
@property (weak, nonatomic) IBOutlet UILabel *lendLabel;

@end

@implementation ShareBannerTableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)configWithShares:(NSArray <Share *>*)shares {
    double oweTotal = 0;
    double lendTotal = 0;
    for (Share *share in shares) {
        if (share.money.doubleValue >= 0) {
            lendTotal += share.money.doubleValue;
        } else {
            oweTotal += share.money.doubleValue;
        }
    }
    oweTotal = fabs(oweTotal);
    self.oweLabel.text = [NSString stringWithFormat:@"💰 %@", [@(oweTotal) stringDecimalWithDigit:2]];
    self.lendLabel.text = [NSString stringWithFormat:@"💰 %@", [@(lendTotal) stringDecimalWithDigit:2]];
}

@end
