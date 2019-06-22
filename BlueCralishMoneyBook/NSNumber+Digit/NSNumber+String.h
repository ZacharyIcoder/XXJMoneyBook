//
//  NSNumber+String.h
//  SKBank
//
//  Created by candy on 2019/06/13.
//

#import <Foundation/Foundation.h>

@interface NSNumber (String)

- (NSString *)stringDecimalWithoutZero;
- (NSString *)stringDecimalWithoutZeroWithDigit:(NSUInteger)digit;
- (NSString *)stringDecimalWithDigit:(NSUInteger)digit;
- (NSString *)stringForCurrencyWithDigit:(NSUInteger)digit;

@end
