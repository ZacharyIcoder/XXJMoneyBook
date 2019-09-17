//
//  ShareHomeFactory.m
//  BlueCralishMoneyBook
//
//  Created by Bomi on 2019/9/11.
//  Copyright © 2019 PD101. All rights reserved.
//

#import "ShareHomeFactory.h"

@implementation ShareHomeFactory

- (UITableViewCell *)createCellWithIdentier:(NSString *)identifier {
    
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"ShareHomeCell" owner:self options:nil];
    int index = 0;
    for (UIView *view in views) {
        if ([view isMemberOfClass:NSClassFromString(identifier)]) {
            break;
        }
        index += 1;
    }
//    NSUInteger index = [views indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
//        return [obj isMemberOfClass:NSClassFromString(identifier)];
//    }];
    
    return views[index];
}

@end
