//
//  NSNumber+String.m
//  SKBank
//
//  Created by candy on 2019/06/13.
//

#import "NSNumber+String.h"

@implementation NSNumber (String)

- (NSString *)stringDecimalWithoutZero {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.maximumFractionDigits = 20;
    formatter.roundingMode = NSNumberFormatterRoundUp;
    return [formatter stringFromNumber:self];
}

- (NSString *)stringDecimalWithoutZeroWithDigit:(NSUInteger)digit {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.maximumFractionDigits = digit;
    formatter.roundingMode = NSNumberFormatterRoundUp;
    return [formatter stringFromNumber:self];
}

- (NSString *)stringDecimalWithDigit:(NSUInteger)digit {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.minimumFractionDigits = digit;
    formatter.roundingMode = NSNumberFormatterRoundUp;
    return [formatter stringFromNumber:self];
}

- (NSString *)stringForCurrencyWithDigit:(NSUInteger)digit {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    formatter.minimumFractionDigits = digit;
    formatter.roundingMode = NSNumberFormatterRoundUp;
    [formatter setCurrencySymbol:@""];
    return [formatter stringFromNumber:self];
}

@end
