//
//  Share.m
//  BlueCralishMoneyBook
//
//  Created by Bomi on 2019/9/11.
//  Copyright © 2019 PD101. All rights reserved.
//

#import "Share.h"

@implementation Share

- (instancetype)initWithName:(NSString *)name money:(NSString *)money {
    self = [super init];
    if (self) {
        self.name = name;
        self.money = money;
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_money forKey:@"money"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _money = [aDecoder decodeObjectForKey:@"money"];
    }
    return self;
}

@end
