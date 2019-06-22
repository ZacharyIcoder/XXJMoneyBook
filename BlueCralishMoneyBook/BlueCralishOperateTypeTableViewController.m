//
//  AZXOperateTypeTableViewController.m
// BlueCralishMoneyBook
//
//  Created by candy on 2019/06/18.
//  Copyright © 2019年 PD101. All rights reserved.
//
/*
 object      Key
 收入類型組   incomeAZX
 支出類型組   expenseAZX
 
 */

#import "BlueCralishOperateTypeTableViewController.h"
#import "BlueCralishOperateTypeTableViewCell.h"
#import "AppDelegate.h"
#import "Account.h"
#import <CoreData/CoreData.h>

@interface BlueCralishOperateTypeTableViewController ()

@property (nonatomic, strong) NSMutableArray *typeArray;

@property (nonatomic, strong) NSString *incomeType;

@property (nonatomic, strong) NSUserDefaults *defaults;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation BlueCralishOperateTypeTableViewController

- (NSString *)incomeType {
    if (!_incomeType) {
        _incomeType = @"expense"; // 默認為支出
    }
    return _incomeType;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    if ([self.operationType isEqualToString:@"deleteAndMoveType"]) {
        // 如果是刪除和移動類別操作，並且第一次進入此界面，彈出教程
        [self judgeFirstLoadThisView];
        
        // 進入編輯模式
        [self.tableView setEditing:YES animated:YES];
    }
}

- (void)judgeFirstLoadThisView {
    if (![self.defaults boolForKey:@"haveLoadedAZXOperateTypeTableViewControllerAddAndDelete"]) {
        // 第一次進入此頁面
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"教學" message:@"點擊類別左邊的紅色減號刪除，按住並拖動右邊的三槓符號進行位置排序" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"知道了，不再提醒" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.defaults setBool:YES forKey:@"haveLoadedAZXOperateTypeTableViewControllerAddAndDelete"];
        }];
        
        [alert addAction:actionOK];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 將要退出界面時，將數組資料保存
    [self.defaults setObject:self.typeArray forKey:[self.incomeType stringByAppendingString:@"AZX"]];
}

- (IBAction)segControlChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.incomeType = @"expense";
        
        [self refreshAll];
        [self.tableView reloadData];
    } else {
        self.incomeType = @"income";
        
        [self refreshAll];
        [self.tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshAll];
    
}

- (void)refreshAll {
    // 取得儲存的支出/收入類型數組
    if ([self.incomeType isEqualToString:@"income"]) {
        // objectForKey總是返回不可變的對象(即使存進去的時候是可變的)
        self.typeArray = [NSMutableArray arrayWithArray:[self.defaults objectForKey:@"incomeAZX"]];
    } else {
        self.typeArray = [NSMutableArray arrayWithArray:[self.defaults objectForKey:@"expenseAZX"]];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.typeArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BlueCralishOperateTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"operateTypeCell" forIndexPath:indexPath];
    
    cell.type.text = self.typeArray[indexPath.row];
    
    // 得到類別名相應的圖片
    cell.image.image = [UIImage imageNamed:[self.defaults objectForKey:cell.type.text]];
    
    if ([self.operationType isEqualToString:@"changeType"]) {
        // 進行重命名操作
        cell.operation.text = @"重命名";
        cell.operation.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapLabel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRename:)];
        
        [cell.operation addGestureRecognizer:tapLabel];
    } else if ([self.operationType isEqualToString:@"deleteAndMoveType"]) {
        // 進行排序和刪除操作
        cell.operation.text = @"";
    }
    
    return cell;
}

#pragma mark - Add or delete methods

- (void)addType {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加類別" message:@"輸入新類別名稱" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"點擊輸入";
    }];
    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"確認" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 新加入類型保存起來並刷新tableView
        [self.typeArray addObject:alert.textFields[0].text];
        [self.tableView reloadData];
        // 保存資料
        [self.defaults setObject:self.typeArray forKey:[self.incomeType stringByAppendingString:@"AZX"]];
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:actionCancel];
    [alert addAction:actionOK];
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Rename methods

- (void)tapRename:(UITapGestureRecognizer *)gesture {
    // 通過點擊位置確定點擊的cell位置
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[gesture locationInView:self.tableView]];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改名稱" message:@"請輸入新類別名稱" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = self.typeArray[indexPath.row];
    }];
    
    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 保存在Assets中的圖片的名稱
        NSString *imageName = [self.defaults objectForKey:self.typeArray[indexPath.row]];
        
        // 將舊的類別名與圖片名稱的關聯除去
        [self.defaults removeObjectForKey:self.typeArray[indexPath.row]];
        
        // 將新的類別名與圖片名稱相關聯
        [self.defaults setObject:imageName forKey:alert.textFields[0].text];
        
        // 修改數組中存放的類別名稱
        self.typeArray[indexPath.row] = alert.textFields[0].text;
        
        // 刷新tableView
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        // 保存資料
        [self.defaults setObject:self.typeArray forKey:[self.incomeType stringByAppendingString:@"AZX"]];
    }];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:actionCancel];
    [alert addAction:actionOK];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}


#pragma mark - Move tableView delegate methods

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.operationType isEqualToString:@"deleteAndMoveType"]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    // 需要移動的行
    NSString *typeToMove = self.typeArray[fromIndexPath.row];
    
    [self.typeArray removeObjectAtIndex:fromIndexPath.row];
    [self.typeArray insertObject:typeToMove atIndex:toIndexPath.row];
    
    // 保存資料
    [self.defaults setObject:self.typeArray forKey:[self.incomeType stringByAppendingString:@"AZX"]];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 將要刪除的類別名與圖片名稱的關聯除去
        [self.defaults removeObjectForKey:self.typeArray[indexPath.row]];
        
        // 將所有此類別的帳單一並移去
        [self removeAllAccountOfOneType:self.typeArray[indexPath.row]];
        
        // 將其從tableView中移除
        [self.typeArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // 保存資料
        [self.defaults setObject:self.typeArray forKey:[self.incomeType stringByAppendingString:@"AZX"]];
    }
}

- (void)removeAllAccountOfOneType:(NSString *)type {
    // 刪除所有此類別的account
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Account"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"type == %@", type]];
    
    NSError *error = nil;
    NSArray *accounts = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    for (Account *account in accounts) {
        [self.managedObjectContext deleteObject:account];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 將detele改為刪除
    return @" 刪除 ";
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
