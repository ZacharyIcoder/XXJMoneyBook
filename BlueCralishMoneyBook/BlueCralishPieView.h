//
//  AZXPieView.h
// BlueCralishMoneyBook
//
//  Created by candy on 2019/06/18.
//  Copyright © 2019年 PD101. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BlueCralishPieView;

@protocol BlueCralishPieViewDataSource <NSObject>

@required

- (NSArray *)percentsForPieView:(BlueCralishPieView *)pieView;
- (NSArray *)typesForPieView:(BlueCralishPieView *)pieView;
- (NSArray *)colorsForPieView:(BlueCralishPieView *)pieView;

@end

@interface BlueCralishPieView : UIView

@property (weak, nonatomic) id<BlueCralishPieViewDataSource> dataSource;

- (void)reloadData;

- (void)removeAllLabel;

@end
