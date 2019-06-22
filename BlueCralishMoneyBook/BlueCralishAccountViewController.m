//
//  AZXAccountViewController.m
// BlueCralishMoneyBook
//
//  Created by candy on 2019/06/18.
//  Copyright © 2019年 PD101. All rights reserved.
//

#import "BlueCralishAccountViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "BlueCralishAccountTableViewCell.h"
#import "BlueCralishNewAccountTableViewController.h"
#import "Account.h"
#import "UIColor+Hex.h"
#import "UIVieww+CConstraint/UIView+Constraint.h"

@interface BlueCralishAccountViewController () <UITableViewDelegate, UITableViewDataSource, PassingDateDelegate>

@property (weak, nonatomic) IBOutlet UITableView *accountTableView;

@property (weak, nonatomic) IBOutlet UILabel *moneySumLabel; // 結餘總金額

@property (weak, nonatomic) IBOutlet UIButton *addNewButton;


@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSMutableArray *fetchedResults;

@property (nonatomic, strong) NSArray *typeArray; // 存放各個類型，以便如果是從別的界面轉來可以選中該行

@property (nonatomic, strong) NSUserDefaults *defaults;

@end

@implementation BlueCralishAccountViewController

// navigation控制時從下一界面返回時不會再次調用viewDidLoad，應用viewWillAppear
- (void)viewDidLoad {
    [super viewDidLoad];
    self.accountTableView.delegate = self;
    self.accountTableView.dataSource = self;
    
    // 取得managedObjectContext
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    // 判斷是否第一次使用app
    [self judgeFirstLoadThisView];
    
    NSLog(@"%d", [self.defaults boolForKey:@"appDidLaunch"]);
    
    // 判斷是否需要輸入密碼
    [self judgeWhetherNeedCode];
}

- (void)judgeFirstLoadThisView {
    if (![self.defaults boolForKey:@"haveLoadedAZXAccountViewController"]) {
        // 第一次進入此頁面
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"歡迎使用小小記帳本" message:@"點擊紅色按鈕記錄新帳，首頁顯示所選日期的所有帳單，點擊相應帳單可編輯其內容，手指左滑可以刪除相應帳單" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"知道了，不再提醒" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.defaults setBool:YES forKey:@"haveLoadedAZXAccountViewController"];
        }];
        
        [alert addAction:actionOK];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)judgeWhetherNeedCode {
    if ([self.defaults boolForKey:@"useCodeAZX"] && ![self.defaults boolForKey:@"appDidLaunch"]) {
        // useCodeAZX是在設定界面中設定的，appDidLaunch每次退出應用時都將其設為NO，以便下一次進入應用時如果有使用密碼就會彈出對話框要求輸入密碼
        NSLog(@"needCode");
        UIAlertController *enterCode = [UIAlertController alertControllerWithTitle:@"提示" message:@"請輸入密碼" preferredStyle:UIAlertControllerStyleAlert];
        [enterCode addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.secureTextEntry = YES;
        }];
        
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([enterCode.textFields[0].text isEqualToString:[self.defaults objectForKey:@"codeAZX"]]) {
                // 如果密碼正確，進入應用，並將appDidLaunch設為YES
                [self.defaults setBool:YES forKey:@"appDidLaunch"];
            } else {
                // 如果密碼不正確
                [self enterWrongCode];
                
            }
        }];
        
        UIAlertAction *actionForget = [UIAlertAction actionWithTitle:@"忘記密碼" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 忘記密碼，彈出密保問題
            [self showProtectQuestion];
        }];
        
        [enterCode addAction:actionForget];
        [enterCode addAction:actionOK];
        
        [self presentViewController:enterCode animated:YES completion:nil];
    }
}

#pragma mark - code methods

- (void)enterWrongCode {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"密碼錯誤，請重試" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"再次輸入" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 點擊重試，再次彈出輸入密碼對話框
        [self judgeWhetherNeedCode];
    }];
    
    UIAlertAction *actionForget = [UIAlertAction actionWithTitle:@"忘記密碼" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 忘記密碼，則彈出密碼保護問題
        [self showProtectQuestion];
    }];
    
    [alert addAction:actionForget];
    [alert addAction:actionOK];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showProtectQuestion {
    NSString *title = [NSString string];
    NSString *message = [NSString string];
    if ([self.defaults objectForKey:@"questionAZX"] == nil) {
        // 如果未設定密保問題
        title = @"提示";
        message = @"未設定密保問題";
    } else {
        // 如果設定了密保問題
        title = @"輸入答案";
        message = [NSString stringWithFormat:@"%@", [self.defaults objectForKey:@"questionAZX"]];
    }
    
    UIAlertController *question = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([question.textFields[0].text isEqualToString:[self.defaults objectForKey:@"answerAZX"]]) {
            // 如果答案正確，讓用戶設定新密碼
            [self enterNewCode];
        } else {
            // 否則彈出錯誤提示
            [self wrongAnswer];
        }
    }];
    
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // 點擊返回，返回輸入密碼對話框
        [self judgeWhetherNeedCode];
    }];
    
    if ([self.defaults objectForKey:@"questionAZX"] == nil) {
        // 如果未設定密保問題
        [question addAction:no];
    } else {
        // 如果設定了密保問題，加入輸入文本框
        [question addTextFieldWithConfigurationHandler:nil];
        
        [question addAction:no];
        [question addAction:ok];
        
    }
    
    [self presentViewController:question animated:YES completion:nil];
}

- (void)enterNewCode {
    // 用來比較兩次輸入新密碼是否一樣
    __block NSString *tmpNewCode = [NSString string];
    
    // 輸入新密碼
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"設定" message:@"請輸入新密碼" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.secureTextEntry = YES;
    }];
    
    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        tmpNewCode = alert.textFields[0].text;
        // 再次輸入密碼
        [self enterNewCodeAgainWithCode:tmpNewCode];
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:actionCancel];
    [alert addAction:actionOK];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
}

- (void)enterNewCodeAgainWithCode:(NSString *)tmpNewCode {
    // 再次輸入密碼
    
    UIAlertController *alert2 = [UIAlertController alertControllerWithTitle:@"設定" message:@"再次輸入新密碼" preferredStyle:UIAlertControllerStyleAlert];
    [alert2 addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.secureTextEntry = YES;
    }];
    
    UIAlertAction *actionOK2 = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([alert2.textFields[0].text isEqualToString:tmpNewCode]) {
            // 如果兩次密碼相同，保存密碼
            [self.defaults setObject:tmpNewCode forKey:@"codeAZX"];
            // 彈窗顯示修改成功
            [self changeSuccessfully];
        } else {
            // 兩次密碼輸入不相同
            UIAlertController *alertWrong = [UIAlertController alertControllerWithTitle:@"提示" message:@"兩次輸入密碼必須相同" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *enterAgain = [UIAlertAction actionWithTitle:@"再次輸入" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                // 遞歸調用enterNewCode函數，再次輸入
                [self enterNewCode];
            }];
            
            [alertWrong addAction:cancel];
            [alertWrong addAction:enterAgain];
            
            [self presentViewController:alertWrong animated:YES completion:nil];
        }
    }];
    
    UIAlertAction *actionCancel2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert2 addAction:actionCancel2];
    [alert2 addAction:actionOK2];
    
    [self presentViewController:alert2 animated:YES completion:nil];
    
}

- (void)changeSuccessfully {
    UIAlertController *success = [UIAlertController alertControllerWithTitle:@"" message:@"修改成功" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    
    [success addAction:ok];
    
    [self presentViewController:success animated:YES completion:nil];
}

- (void)wrongAnswer {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"答案錯誤，請重試" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"再次輸入" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 點擊重試，再次彈出密保問題對話框
        [self showProtectQuestion];
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    
    
    [alert addAction:actionCancel];
    [alert addAction:actionOK];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - view Will Appear

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.passedDate) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", @"今日",self.passedDate];
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy.MM.dd";
        self.passedDate = [dateFormatter stringFromDate:[NSDate date]];
        self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", @"今日",self.passedDate];
    }
    
    [self fetchAccounts];
    [self.accountTableView reloadData];
    NSLog(@"fetech new account");
    
    // 計算結餘總額
    [self calculateMoneySumAndSetText];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.selectedType) {
        // 如果是從統計類型界面跳轉而來
        NSArray *indexArray = [self indexsOfObject:self.selectedType InArray:self.typeArray];
        
        // 將相應type的行背景加深
        for (NSNumber *indexNumber in indexArray) {
            BlueCralishAccountTableViewCell *cell = [self.accountTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[indexNumber integerValue] inSection:0]];
            
            cell.backgroundColor = [UIColor lightGrayColor];
        }
    }
}

// 返回一個含有該object相同的元素所在index的數組，且元素被封裝成NSNumber
- (NSArray *)indexsOfObject:(id)object InArray:(NSArray *)array {
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    for (NSInteger i = 0; i < array.count; i++) {
        id obj = array[i];
        if ([obj isEqual:object]) {
            [tmpArray addObject:[NSNumber numberWithInteger:i]];
        }
    }
    return [tmpArray copy];
}

- (void)fetchAccounts {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Account"];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"date == %@", self.passedDate]];  // 根據傳來的date篩選需要的結果
    
    NSError *error = nil;
    self.fetchedResults = [NSMutableArray arrayWithArray:[self.managedObjectContext executeFetchRequest:request error:&error]];
    
    // 暫時儲存類型
    NSMutableArray *tmpTypeArray = [NSMutableArray array];
    
    for (NSInteger i = 0; i < self.fetchedResults.count; i++) {
        Account *account = self.fetchedResults[i];
        [tmpTypeArray addObject:account.type];
    }
    
    // 這一步是為從統計類型界面跳轉而來做準備的，為了進入界面就默認從所有類型中選中該類型
    self.typeArray = [tmpTypeArray copy];
}

- (void)calculateMoneySumAndSetText {
    // 計算結餘總金額
    double moneySum = 0;
    for (Account *account in self.fetchedResults) {
        if ([account.incomeType isEqualToString:@"income"]) {
            moneySum += [account.money doubleValue];
        } else {
            moneySum -= [account.money doubleValue];
        }
    }
    
    NSString *moneySumString = [NSString stringWithFormat:@"今日結餘 %@", [NSNumber numberWithDouble:[[NSString stringWithFormat:@"%.2f", moneySum] doubleValue]]];
    
    NSMutableAttributedString *mutString = [[NSMutableAttributedString alloc] initWithString:moneySumString];
    
    // 在moneySumLabel上前面字體黑色，後半段根據正負決定顏色
    [mutString addAttribute:NSForegroundColorAttributeName value:[UIColor hexColor:@"303338"] range:NSMakeRange(0, 5)];
    [mutString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:16] range:NSMakeRange(0, 4)];
    [mutString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(5, moneySumString.length - 5)];
    
    if (moneySum >= 0) {
        [mutString addAttribute:NSForegroundColorAttributeName value:[UIColor hexColor:@"d8ae47"] range:NSMakeRange(4, moneySumString.length - 4)];
        [mutString addAttribute:NSUnderlineColorAttributeName value:[UIColor hexColor:@"d8ae47"] range:NSMakeRange(5, moneySumString.length - 5)];
        
    } else {
        [mutString addAttribute:NSForegroundColorAttributeName value:[UIColor hexColor:@"ee4b2e"] range:NSMakeRange(4, moneySumString.length - 4)];
        [mutString addAttribute:NSUnderlineColorAttributeName value:[UIColor hexColor:@"ee4b2e"] range:NSMakeRange(5, moneySumString.length - 5)];
    }
    
    [self.moneySumLabel setAttributedText:mutString];
}

#pragma mark - UITableViewDataSource

- (void)configureCell:(BlueCralishAccountTableViewCell *)cell atIndexPath:(NSIndexPath*)indexPath {
    Account *account = [self.fetchedResults objectAtIndex:indexPath.row];
    cell.typeName.text = account.type;
    cell.money.text = account.money;
    
    // 此處的圖片名稱通過相應的type作為key從NSUserDefaults中取出
    cell.typeImage.image = [UIImage imageNamed:[self.defaults objectForKey:cell.typeName.text]];
    
    // 根據類型選擇不同顏色
    if ([account.incomeType isEqualToString:@"income"]) {
        cell.money.textColor = [UIColor hexColor:@"89aa9f"];
    } else {
        cell.money.textColor = [UIColor hexColor:@"f37171"];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BlueCralishAccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accountCell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchedResults.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.fetchedResults.count == 0) {
        UIView *emptyView = [UIView new];
        UILabel *label = [UILabel new];
        label.text = @"今日尚未記帳喔!";
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:15];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        [emptyView addSubview:label];
        [label constraints:emptyView constant:UIEdgeInsetsMake(5, 5, -5, -5)];
        return emptyView;
    } else {
        return [UIView new];
    }
}


#pragma mark - UITabelView Delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 首先刪除CoreData里的資料
        [self.managedObjectContext deleteObject:self.fetchedResults[indexPath.row]];
        // 然後移除提供資料源的fetchResults(不然會出現tableView的update問題而crush)
        [self.fetchedResults removeObjectAtIndex:indexPath.row];
        // 刪除tableView的行
        [self.accountTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        // 最後更新UI
        [self calculateMoneySumAndSetText];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 將detele改為刪除
    return @" 刪除 ";
}

#pragma mark - PassingDateDelegate

- (void)viewController:(BlueCralishNewAccountTableViewController *)controller didPassDate:(NSString *)date {
    self.passedDate = date;  // 接收從AZXNewAccountTableViewController傳來的date值，用做Predicate來篩選Fetch的ManagedObject
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue destinationViewController] isKindOfClass:[BlueCralishNewAccountTableViewController class]]) {  // segue時將self設為AZXNewAccountTableViewController的代理
        BlueCralishNewAccountTableViewController *viewController = [segue destinationViewController];
        viewController.delegate = self;
    }
    
    if ([segue.identifier isEqualToString:@"addNewAccount"]) {
        // 點擊記帳按鈕時，創建一個新帳本，並告知不是點擊tableView轉來
        BlueCralishNewAccountTableViewController *viewController = [segue destinationViewController];
        viewController.isSegueFromTableView = NO;
    } else if ([segue.identifier isEqualToString:@"segueToDetailView"]) {
        // 點擊已保存的帳本記錄，查看詳細，並告知是點擊tableView而來
        // 轉到詳細頁面時，要顯示被點擊cell的內容，所以要將account傳過去，讓其顯示相應內容
        BlueCralishNewAccountTableViewController *viewController = [segue destinationViewController];
        viewController.isSegueFromTableView = YES;
        viewController.accountInSelectedRow = self.fetchedResults[self.accountTableView.indexPathForSelectedRow.row];
    }
}


@end
