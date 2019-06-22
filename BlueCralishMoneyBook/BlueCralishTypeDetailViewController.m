//
//  AZXTypeDetailViewController.m
// BlueCralishMoneyBook
//
//  Created by candy on 2019/06/18.
//  Copyright © 2019年 PD101. All rights reserved.
//

#import "BlueCralishTypeDetailViewController.h"
#import "AppDelegate.h"
#import "Account.h"
#import "BlueCralishAllHistoryTableViewCell.h"
#import "BlueCralishAccountViewController.h"
#import <CoreData/CoreData.h>
#import "UIColor+Hex.h"

@interface BlueCralishTypeDetailViewController () <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;

@property (weak, nonatomic) IBOutlet UITableView *typeTableView;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSArray *dataArray; // fetch而来的数据

@property (strong, nonatomic) NSArray *uniqueDateArray;

@property (strong, nonatomic) NSArray *uniqueMoneyArray;

@property (assign, nonatomic) double totalMoney;

@end

@implementation BlueCralishTypeDetailViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.typeTableView.dataSource = self;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = @"細項";
    
    [self fetchData];
    
    [self filterData];
    
    [self setLabel];
    
    [self.typeTableView reloadData];
}

- (void)fetchData {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Account"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"date beginswith[c] %@ and type == %@ and incomeType == %@", self.date, self.type, self.incomeType]];
    
    NSError *error = nil;
    self.dataArray = [self.managedObjectContext executeFetchRequest:request error:&error];
}

- (void)filterData {
    NSMutableArray *tmpDateArray = [NSMutableArray array];
    NSMutableArray *tmpMoneyArray = [NSMutableArray array];
    double tmpTotalMoney = 0;
    
    for (Account *account in self.dataArray) {
        [tmpDateArray addObject:account.date];
        tmpTotalMoney += [account.money doubleValue];
    }
    
    self.totalMoney = tmpTotalMoney;
    
    NSSet *set = [NSSet setWithArray:[tmpDateArray copy]];
    
    self.uniqueDateArray = [set sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:nil ascending:YES]]];
    
    for (NSInteger i = 0; i < self.uniqueDateArray.count; i++) {
        // 将某一天的过滤出来
        NSArray *accountsInOneDay = [self.dataArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"date == %@", self.uniqueDateArray[i]]];
        
        // 计算这一天金额总量
        double tmpTotalMoney = 0;
        for (Account *account in accountsInOneDay) {
            tmpTotalMoney += [account.money doubleValue];
        }
        
        [tmpMoneyArray addObject:[NSNumber numberWithDouble:tmpTotalMoney]];
    }
    
    self.uniqueMoneyArray = [tmpMoneyArray copy];
}

- (void)setLabel {
    NSString *str;
    UIColor *color;
    // 支出用红色，收入用绿色
    if ([self.incomeType isEqualToString:@"income"]) {
        str = @"共收入:";
        color = [UIColor hexColor:@"d8ae47"];
    } else {
        str = @"共支出:";
        color = [UIColor hexColor:@"ee4b2e"];
    }
    
    NSMutableAttributedString *mutString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  %@  %@ %@", self.date, self.type, str, [NSNumber numberWithDouble:self.totalMoney]]];
    
    NSInteger formerStringLength = self.date.length + 2 + self.type.length + 2 + str.length + 1;
    
    [mutString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, formerStringLength)];
    
    // 金额部分用color(不同颜色)
    [mutString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(formerStringLength, [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:self.totalMoney]].length)];
    
    [self.moneyLabel setAttributedText:mutString];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.uniqueDateArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BlueCralishAllHistoryTableViewCell *cell = [self.typeTableView dequeueReusableCellWithIdentifier:@"typeDetailCell" forIndexPath:indexPath];
    cell.date.text = self.uniqueDateArray[indexPath.row];
    
    cell.money.text = [NSString stringWithFormat:@"%@", self.uniqueMoneyArray[indexPath.row]];
    if ([self.incomeType isEqualToString:@"income"]) {
        cell.money.textColor = [UIColor hexColor:@"89aa9f"];
    } else {
        cell.money.textColor = [UIColor hexColor:@"f37171"];
    }
    
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToDayDetail"]) {
        if ([[segue destinationViewController] isKindOfClass:[BlueCralishAccountViewController class]]) {
            BlueCralishAccountViewController *viewController = [segue destinationViewController];
            
            NSIndexPath *indexPath = [self.typeTableView indexPathForSelectedRow];
            
            viewController.passedDate = self.uniqueDateArray[indexPath.row];
            viewController.selectedType = self.type;
        }
    }
}


@end
