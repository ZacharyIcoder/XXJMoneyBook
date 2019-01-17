//
//  AZXAllHistoryViewController.m
//  AZXTallyBook
//
//  Created by azx on 16/3/11.
//  Copyright © 2016年 azx. All rights reserved.
//

#import "XXJAllHistoryViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "Account.h"
#import "XXJAllHistoryTableViewCell.h"
#import "XXJMonthHIstoryViewController.h"

@interface XXJAllHistoryViewController () <UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *totalDetailLabel;

@property (weak, nonatomic) IBOutlet UILabel *remainMoneyLabel;

@property (weak, nonatomic) IBOutlet UITableView *monthTableView;

@property (strong, nonatomic) NSArray *dataArray; // 儲存fetch來的所有Account

@property (strong, nonatomic) NSMutableArray *monthIncome; // 每個月的收入金額

@property (strong, nonatomic) NSMutableArray *monthExpense; // 每個月的支出金額

@property (assign, nonatomic) double totalIncome; // 總收入

@property (assign, nonatomic) double totalExpense; // 總支出

@property (strong, nonatomic) NSMutableArray *uniqueDateArray; // 儲存不重復月份的數組

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end

@implementation XXJAllHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.monthTableView.dataSource = self;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    // 數組的初始化
    self.monthIncome = [NSMutableArray array];
    self.monthExpense = [NSMutableArray array];
    
    [self judgeFirstLoadThisView];
}

- (void)judgeFirstLoadThisView {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults boolForKey:@"haveLoadedAZXAllHistoryViewController"]) {
        // 第一次進入此頁面
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"教學" message:@"首頁顯示所有月份的帳單總額，點擊相應月份查看該月份所有天數的詳細內容，手指左滑可刪除相應行的記錄" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"知道了，不再提醒" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [defaults setBool:YES forKey:@"haveLoadedAZXAllHistoryViewController"];
        }];
        
        [alert addAction:actionOK];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self fetchData];
    
    [self filterUniqueDate];
    
    [self calculateMonthsMoney];
    
    [self setTotalLabel];
    
    [self.monthTableView reloadData];
}

- (void)fetchData {
    // 得到所有account
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Account"];
    
    NSError *error = nil;
    self.dataArray = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:request error:&error]];
}

- (void)filterUniqueDate {
    NSMutableArray *dateArray = [NSMutableArray array];
    
    // 將月份組成一個數組
    for (Account *account in self.dataArray) {
        // 取前7位的年和月份
        [dateArray addObject:[account.date substringToIndex:7]];
    }
    
    // 用NSSet得到不重復的月份
    NSSet *set = [NSSet setWithArray:[dateArray copy]];
    
    // 再得到排序後的數組
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
    self.uniqueDateArray = [NSMutableArray arrayWithArray:[set sortedArrayUsingDescriptors:sortDesc]];
    
}

- (void)calculateMonthsMoney {
    // 先將資料取得添加到暫時數組中，防止每次調用這方法在沒有資料改變的情況下金額顯示增大
    double tmpTotalIncome = 0;
    double tmpTotalExpense = 0;
    NSMutableArray *tmpMonthIncome = [NSMutableArray array];
    NSMutableArray *tmpMonthExpense = [NSMutableArray array];
    
    
    for (NSInteger i = 0; i < self.uniqueDateArray.count; i++) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Account"];
        
        // 過濾月份
        [request setPredicate:[NSPredicate predicateWithFormat:@"date beginswith[c] %@", self.uniqueDateArray[i]]];
        
        NSError *error = nil;
        NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        double income = 0;
        double expense = 0;
        for (Account *account in results) {
            if ([account.incomeType isEqualToString:@"income"]) {
                income += [account.money doubleValue];
            } else {
                expense += [account.money doubleValue];
            }
        }
        
        // 加到暫存總收入支出中
        tmpTotalIncome += income;
        tmpTotalExpense += expense;
        
        // 並將結果暫時儲存在收入/支出數組相應月份在uniqueDateArray的位置
        // 方便到時候設定cell的各個屬性
        [tmpMonthIncome addObject:[NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:income]]];
        [tmpMonthExpense addObject:[NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:expense]]];
        
    }
    
    // 將暫存值賦給屬性以顯示在UI上
    self.totalIncome = tmpTotalIncome;
    self.totalExpense = tmpTotalExpense;
    
    self.monthIncome = tmpMonthIncome;
    self.monthExpense = tmpMonthExpense;
    
}

- (void)setTotalLabel {
    // 示意圖: 總收入: xxx(不限長度)  總支出: xxx(不限長度)
    NSString *incomeString = [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:self.totalIncome]];
    NSString *expenseString = [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:self.totalExpense]];
    
    
    NSMutableAttributedString *mutString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"總收入: %@  總支出: %@", incomeString, expenseString]];
    
    
    [mutString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 4)];
    
    [mutString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(5, incomeString.length)];
    
    [mutString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(5 + incomeString.length + 2, 4)];
    
    [mutString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(5 + incomeString.length + 2 + 5, expenseString.length)];
    
    [self.totalDetailLabel setAttributedText:mutString];
    
    
    // 計算結餘
    double remainMoney = self.totalIncome - self.totalExpense;
    
    self.remainMoneyLabel.text = [NSString stringWithFormat:@"結餘: %@", [NSNumber numberWithDouble:remainMoney]];
    
}

#pragma UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.uniqueDateArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XXJAllHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"monthAccountCell" forIndexPath:indexPath];
    
    cell.date.text = self.uniqueDateArray[indexPath.row];
    
    NSMutableAttributedString * mutString = [self configMoneyLabelWithIndexPath:indexPath];
    
    [cell.money setAttributedText:mutString];
    
    return cell;
}

- (NSMutableAttributedString *)configMoneyLabelWithIndexPath:(NSIndexPath *)indexPath {
    // 收入金額
    NSString  *income = self.monthIncome[indexPath.row];
    
    NSString *incomeString = [@"收入: " stringByAppendingString:income];
    
    // 為了排版，固定金額數目為7位，不足補空格
    for (NSInteger i = income.length; i < 7; i++) {
        incomeString = [incomeString stringByAppendingString:@" "];
    }
    
    // 支出金額(前留一空格)
    NSString *expense = self.monthExpense[indexPath.row];
    NSString *expenseString = [@" 支出: " stringByAppendingString:expense];
    
    // 排版
    for (NSInteger i = expense.length; i < 7; i++) {
        expenseString = [expenseString stringByAppendingString:@" "];
    }
    
    // 合併兩個字符串
    NSString *moneyString = [incomeString stringByAppendingString:expenseString];
    
    // 設定文本不同顏色
    NSMutableAttributedString *mutString = [[NSMutableAttributedString alloc] initWithString:moneyString];
    
    // 示意圖: 收入: xxxxxxx 支出: xxxxxxx
    [mutString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 3)];
    [mutString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(4, 7)];
    [mutString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(12, 3)];
    [mutString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(16, 7)];
    
    return mutString;
}

#pragma mark - UITabelView Delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 取得相應日期的資料
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Account"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"date beginswith[c] %@", self.uniqueDateArray[indexPath.row]]];
        NSError *error = nil;
        NSArray *accountToBeDeleted = [self.managedObjectContext executeFetchRequest:request error:&error];
        
        // 首先刪除CoreData里的資料
        for (Account *account in accountToBeDeleted) {
            [self.managedObjectContext deleteObject:account];
        }
        // 然後移除提供資料源的數組
        [self.uniqueDateArray removeObjectAtIndex:indexPath.row];
        // 刪除tableView的行
        [self.monthTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        // 最後更新UI
        [self calculateMonthsMoney];
        
        [self setTotalLabel];
        
        [self.monthTableView reloadData];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 將detele改為刪除
    return @" 刪除 ";
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showMonthDetail"]) {
        if ([[segue destinationViewController] isKindOfClass:[XXJMonthHIstoryViewController class]]) {
            XXJMonthHIstoryViewController *viewController = [segue destinationViewController];
            NSIndexPath *indexPath = [self.monthTableView indexPathForSelectedRow];
            
            // 將被點擊cell的相應屬性傳過去
            viewController.date = self.uniqueDateArray[indexPath.row];
        }
    }
}


@end
