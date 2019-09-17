//
//  Share.h
//  BlueCralishMoneyBook
//
//  Created by Bomi on 2019/9/11.
//  Copyright © 2019 PD101. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Share : NSObject <NSCoding, NSSecureCoding>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *money;

- (instancetype)initWithName:(NSString *)name money:(NSString *)money;

@end

