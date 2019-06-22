//
//  AZXNewAccountTableViewController.h
// BlueCralishMoneyBook
//
//  Created by candy on 2019/06/18.
//  Copyright © 2019年 PD101. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Account.h"

@class BlueCralishNewAccountTableViewController;

@protocol PassingDateDelegate <NSObject>;
@optional
- (void)viewController:(BlueCralishNewAccountTableViewController *)controller didPassDate:(NSString *)date;
// 使用代理将date值传给首页(让其筛选Fetch的managedObject)
@end

@interface BlueCralishNewAccountTableViewController : UITableViewController

@property (nonatomic, weak) id<PassingDateDelegate> delegate;

@property (nonatomic, assign) BOOL isSegueFromTableView; // 判断是否通过点击cell转来

@property (nonatomic, strong) Account *accountInSelectedRow; // 点击的cell是第几个
@end
