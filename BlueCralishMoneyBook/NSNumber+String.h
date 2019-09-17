//
//  NSNumber+String.h
//  SKBank
//
//  Created by Bomi on 2018/6/25.
//

#import <Foundation/Foundation.h>

@interface NSNumber (String)

- (NSString *)stringDecimalWithoutZero;
- (NSString *)stringDecimalWithoutZeroWithDigit:(NSUInteger)digit;
- (NSString *)stringDecimalWithDigit:(NSUInteger)digit;
- (NSString *)stringForCurrencyWithDigit:(NSUInteger)digit;

@end
