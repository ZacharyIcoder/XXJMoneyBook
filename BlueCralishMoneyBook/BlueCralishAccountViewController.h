//
//  AZXAccountViewController.h
// BlueCralishMoneyBook
//
//  Created by candy on 2019/06/18.
//  Copyright © 2019年 PD101. All rights reserved.
//

// 这个Controller有两个不同的UI(有按钮、无按钮)

#import <UIKit/UIKit.h>

@interface BlueCralishAccountViewController : UIViewController

@property (nonatomic, strong) NSString *passedDate; // 从别处传来的date值，用做Predicate筛选Fetch的ManagedObject

@property (nonatomic, strong) NSString *selectedType; // 若从统计的类别处传来，则一进入界面就选中该类型的行

@end
