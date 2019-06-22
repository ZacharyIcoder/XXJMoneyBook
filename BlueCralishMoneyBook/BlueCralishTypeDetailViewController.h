//
//  AZXTypeDetailViewController.h
// BlueCralishMoneyBook
//
//  Created by candy on 2019/06/18.
//  Copyright © 2019年 PD101. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlueCralishTypeDetailViewController : UIViewController

// 接收要显示哪一个月的哪一种类型的支出/收入
@property (nonatomic, strong) NSString *date;

@property (nonatomic, strong) NSString *type;

@property (nonatomic, strong) NSString *incomeType;

@end
