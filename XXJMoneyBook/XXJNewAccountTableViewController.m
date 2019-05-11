//
//  AZXNewAccountTableViewController.m
//  AZXTallyBook
//
//  Created by azx on 16/2/21.
//  Copyright © 2016年 azx. All rights reserved.
//

#import "XXJNewAccountTableViewController.h"
#import "AppDelegate.h"
#import "XXJAccountViewController.h"
#import "UIViewController+BackButtonHandler.h"
#import "VENCalculatorInputTextField.h"

@interface XXJNewAccountTableViewController () <UITextViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *moneyTextField; // 只是為了標記位置，真正使用的是下面自定義的textField

@property (strong, nonatomic) VENCalculatorInputTextField *customTextField; // 自定義textField，可彈出數字計算器鍵盤

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (weak, nonatomic) IBOutlet UITextView *detailTextView; //詳細描述

@property (strong, nonatomic) UIDatePicker *datePicker; //日期選擇器

@property (strong, nonatomic) UIPickerView *pickerView; // 類型選擇器

@property (strong, nonatomic) NSString *incomeType; //收入(income)還是支出(expense)

@property (strong, nonatomic) UIView *shadowView; // 插入的灰色夾層

@property (strong, nonatomic) NSUserDefaults *userDefaults;

@property (strong, nonatomic) NSMutableArray *incomeArray; // 分別用來儲存兩種類型的種類

@property (strong, nonatomic) NSMutableArray *expenseArray;

@property (weak, nonatomic) NSIndexPath *index;
@end

@implementation XXJNewAccountTableViewController

#pragma mark - view did load

- (BOOL)isSegueFromTableView {
    if (!_isSegueFromTableView) {
        _isSegueFromTableView = NO; // 默認為NO
    }
    return _isSegueFromTableView;
}

// 在viewDidAppear中才能確定控件layout之後的位置
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 第三方庫的自定義數字計算器鍵盤，將其frame設為moneyTextField的frame，將其完全覆蓋
    // 如果是在viewdidload中為了彈出鍵盤而設定的customTextField，則移除並重設
    // 而如果中途從別的界面切過來，在customTextField已存在(width肯定不為0)的情況下，不再重復加入自定義textField
    if (self.customTextField.frame.size.width == 0) {
        // 這裡將自定義的鍵盤覆蓋原有的moneyTextField
        self.customTextField.frame = self.moneyTextField.frame;
        [[self.moneyTextField superview] bringSubviewToFront:self.customTextField];
        
        self.customTextField.textAlignment = NSTextAlignmentRight;
        self.customTextField.placeholder = @"輸入金額";
        self.customTextField.textColor = [UIColor redColor];
        
    }
    
    
    // 如果是從tableView傳來，根據類別選擇字體顏色
    if (self.isSegueFromTableView) {
        self.customTextField.text = self.accountInSelectedRow.money;
        if ([self.incomeType isEqualToString:@"income"]) {
            self.customTextField.textColor = [UIColor blueColor];
        } else {
            self.customTextField.textColor = [UIColor redColor];
        }
    }
    
    //一進入界面即彈出鍵盤輸入金額
    [self.customTextField becomeFirstResponder];
    
    // 給tableView加上一個Tap手勢，使得點擊空白處收回鍵盤，點擊相應cell的位置時調用相應的method
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreen:)];
    tap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tap];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 自定義"保存"按鈕(右側)
    [self customizeRightButton];
    
    
    // 判斷是怎樣轉到這個界面的
    if (self.isSegueFromTableView) {
        // 如果是點擊tableView而來，顯示傳遞過來的各個屬性
        self.dateLabel.text = self.accountInSelectedRow.date;
        self.detailTextView.text = self.accountInSelectedRow.detail;
        self.incomeType = self.accountInSelectedRow.incomeType;
        self.typeLabel.text = self.accountInSelectedRow.type;
        
        // money在Viewdidappear里設定
        
    } else {
        // 如果是點擊記帳按鈕而來
        //日期顯示默認為當前日期
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        self.dateLabel.text = [dateFormatter stringFromDate:[NSDate date]];
        
        //利用textView的delegate實現其placeholder
        self.detailTextView.delegate = self;
        self.detailTextView.text = @"詳細描述(選填)";
        self.detailTextView.textColor = [UIColor lightGrayColor];
        [self textViewDidChange:self.detailTextView];
        
        // 類別默認為支出
        self.incomeType = @"expense";
    }
    
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
//    self.tableView.estimatedRowHeight = 77;
    
    // 判斷是否第一次進入界面
    [self judgeFirstLoadThisView];
    
    // 進入界面先彈出鍵盤(此處只是為了彈出鍵盤而加入customTextField，在Viewdidappear中是要移除重新賦值的)
    self.customTextField = [[VENCalculatorInputTextField alloc] initWithFrame:CGRectZero];
    [[self.moneyTextField superview] addSubview:self.customTextField];
    [self.customTextField becomeFirstResponder];
    
}

- (void)judgeFirstLoadThisView {
    // 創建userDefault單例對象
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![self.userDefaults boolForKey:@"haveLoadedAZXNewAccountTableViewController"]) {
        // 第一次進入此頁面
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"教學" message:@"輸入金額、類別、日期以及詳細(選填)，點右上角按鈕保存" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"知道了，不再提醒" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.userDefaults setBool:YES forKey:@"haveLoadedAZXNewAccountTableViewController"];
        }];
        
        [alert addAction:actionOK];
        
        
        [self.customTextField resignFirstResponder];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 視圖消失時，判斷是否有代理且實現了代理方法
    // 若實現了，將date傳過去
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewController:didPassDate:)]) {
//        [self.delegate viewController:self didPassDate:self.dateLabel.text];
    }
    
}

#pragma mark - tap screen methods

- (void)tapScreen:(UITapGestureRecognizer *)gesture {
    // 根據點擊的位置判斷點擊的cell在哪一個section和row
    // 因為此界面高度是寫死的，所以通過點擊位置的y坐標來判斷點擊的是哪一個位置(這裡沒用indexPathForRowAtPoint是因為這個方法判斷不准...)
    // 坐標示意圖:
    // section:0 row:0   y: 99 - 149
    // section:0 row:1   y: 149 - 199
    // section:0 row:2   y: 199 - 249
    // section:0 row:0   y: 285 - 369
    
    CGFloat touchY = [gesture locationInView:[self.tableView superview]].y;
    
    if (touchY < 99 || touchY > 149) {
        [self.customTextField resignFirstResponder];
        // 因為在大於三位數且存在小數點的情況下會默認每隔3位加一個逗號，將逗號都去掉
        self.customTextField.text = [self deleteDotsInString:self.customTextField.text];
    }
    if (touchY < 285 || touchY > 369) {
        [self.detailTextView resignFirstResponder];
    }
    
    
    
//    // 根據indexPath的不同執行不同的方法
//    if (touchY >= 99 && touchY <= 149) {
//        //點擊輸入金額，彈出自定義鍵盤
//        [self.customTextField becomeFirstResponder];
//    } else if (touchY >= 149 && touchY <= 199) {
//        // 點擊類別選擇，創建一個類別選擇框
//        [self setUpPickerView];
//    } else if (touchY >= 199 && touchY <= 249) {
//        // 點擊選擇日期，創建一個日期選擇框
//        [self setUpDatePicker];
//    } else if (touchY >= 285 && touchY <= 369) {
//        // 點擊詳細說明，彈出鍵盤
//        [self.detailTextView becomeFirstResponder];
//    }
}

- (void)setUpDatePicker {
    // 插入夾層
    [self insertShadowView];
    
    // 初始化一個datePicker並使其居中
    if (self.datePicker == nil) {
        self.datePicker = [[UIDatePicker alloc] init];
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        self.datePicker.center = self.view.center;
        self.datePicker.backgroundColor = [UIColor whiteColor];
        //設為圓角矩形
        self.datePicker.layer.cornerRadius = 10;
        self.datePicker.layer.masksToBounds = YES;
        [self.view addSubview:self.datePicker];
    } else {
        [self.view addSubview:self.datePicker];
    }
    
    //添加監聽事件
    [self.datePicker addTarget:self action:@selector(datePickerValueDidChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)setUpPickerView {
    // 第一次進入應用時，設定pickerView的默認資料
    [self setDefaultDataForPickerView];
    
    // 插入夾層
    [self insertShadowView];
    
    // 初始化一個pickerView並使其居中
    if (self.pickerView == nil) {
        self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 300, 180)];
        self.pickerView.center = self.view.center;
        self.pickerView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.pickerView];
    } else {
        [self.view addSubview:self.pickerView];
    }
    
    // 設定delegate
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    // 默認顯示第一個類別
    if ([self.incomeType isEqualToString:@"expense"]) {
        self.typeLabel.text = self.expenseArray[0];
    } else {
        self.typeLabel.text = self.incomeArray[0];
    }
}

#pragma mark - customize right button

// 自定義右側保存按鈕
- (void)customizeRightButton {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(preserveButtonPressed:)];
    self.navigationItem.rightBarButtonItem = rightItem;
}


- (void)preserveButtonPressed:(UIButton *)sender {
    if ([self.typeLabel.text isEqualToString:@"點擊輸入"] || [self.customTextField.text isEqualToString:@""]) {
        // type和money都是必填的，如果有一個沒填，則彈出AlertController提示
        [self presentAlertControllerWithMessage:@"金錢數額和類型都是必填的"];
    } else if ([self.customTextField.text componentsSeparatedByString:@"."].count > 2) {
        // 輸入超過兩個小數點
        [self presentAlertControllerWithMessage:@"輸入金額不格式不符"];
    } else if ([self moneyTextContainsCharacterOtherThanNumber]) {
        // 輸入純數字以外的字符
        [self presentAlertControllerWithMessage:@"輸入金額只能是數字"];
    } else {
        if (self.isSegueFromTableView) {
            // 若是從tableView傳來的，則只需更新account就好
            self.accountInSelectedRow.type = self.typeLabel.text;
            self.accountInSelectedRow.detail = self.detailTextView.text;
            [self setMoneyToAccount:self.accountInSelectedRow];
            self.accountInSelectedRow.incomeType = self.incomeType;
            self.accountInSelectedRow.date = self.dateLabel.text;
        } else {
            // 若是必填項都已填好且要記新帳，則將屬性保存在CoreData中
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            
            Account *account = [NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:appDelegate.managedObjectContext];
            
            account.type = self.typeLabel.text;
            // 截取money的小數點
            [self setMoneyToAccount:account];
            account.incomeType = self.incomeType;
            account.date = self.dateLabel.text;
            
            // 此處因為textView無法使用placeholder而將其文本默認為"詳細描述(選填)"
            // 故通過判斷其是否被修改來決定儲存的內容
            if (![self.detailTextView.text isEqualToString:@"詳細描述(選填)"]) {
                account.detail = self.detailTextView.text;
            } else {
                // 當用戶未編輯詳細描述時，將account的detail設為空
                account.detail = @"";
            }
        }
        
        [(AppDelegate *)[[UIApplication sharedApplication]delegate] saveContext];
        // 跳轉到前一界面
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setMoneyToAccount:(Account *)account {
    NSString *moneyInput = self.customTextField.text;
    if ([moneyInput containsString:@"."]) {
        NSString *dotString = [moneyInput substringFromIndex:[moneyInput rangeOfString:@"."].location]; // 截取小數點後(包括小數點)的string
        
        if (dotString.length == 1) {
            // 若只有一個小數點，去掉最後一個小數點
            account.money = [moneyInput substringToIndex:moneyInput.length - 1];
        } else if (dotString.length == moneyInput.length) {
            // 若小數點在首位
            account.money = [@"0" stringByAppendingString:dotString];
        } else {
            // 若小數點後大於一位，則保留一位(精確到角)
            account.money = [moneyInput substringToIndex:[moneyInput rangeOfString:@"."].location + 2];
        }
    } else {
        // 若為整數
        account.money = self.customTextField.text;
    }
    
}

- (void)presentAlertControllerWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    
    [alertController addAction:action];
    
    // 彈出alertController之前先將所有的鍵盤收回，否則會導致之後鍵盤不響應
    [self.customTextField resignFirstResponder];
    [self.detailTextView resignFirstResponder];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (BOOL)moneyTextContainsCharacterOtherThanNumber {
    if (!([self isPureInt:self.customTextField.text] || [self isPureFloat:self.customTextField.text])) {
        // 如果出現了純數字以外的字符，返回YES
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)deleteDotsInString:(NSString *)string {
    NSArray *subStrings = [string componentsSeparatedByString:@","];
    
    NSString *newString = [NSString string];
    for (NSInteger i = 0; i < subStrings.count; i++) {
        newString = [newString stringByAppendingString:subStrings[i]];
    }
    
    return newString;
}

//判斷是否為整形
- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

//判斷是否為浮點形
- (BOOL)isPureFloat:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}


// 借用一個開源的extension，點擊系統的back按鈕時，若內容都已輸入，彈出彈框
- (BOOL)navigationShouldPopOnBackButton {
    if (self.isSegueFromTableView) {
        // 如果是從tableView傳來查看詳細的，那只在用戶修改了資料後彈出對話框提示
        if (![self.customTextField.text isEqualToString:self.accountInSelectedRow.money] || ![self.typeLabel.text isEqualToString:self.accountInSelectedRow.type] || ![self.dateLabel.text isEqualToString:self.accountInSelectedRow.date] || ![self.detailTextView.text isEqualToString:self.accountInSelectedRow.detail]) {
            
            [self alertControllerAskWhetherStoreWithMessage:@"確定返回？修改將不會被保存"];
            
            return NO;
        }
    } else if (![self.customTextField.text isEqualToString:@""] && ![self.typeLabel.text isEqualToString:@"點擊輸入"]) {
        // 如果金額類別都填寫了，彈出框詢問是否保存
        [self alertControllerAskWhetherStoreWithMessage:@"確定返回？這筆帳單將不會被保存"];
        
        return NO;
    }
    return YES;
}

- (void)alertControllerAskWhetherStoreWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 直接返回主界面並且不保存(更新)account
        [self.navigationController popViewControllerAnimated:YES];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"不，留在頁面" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else {
        return 1;
    }
}

#pragma mark - insert shadow view and add button

- (void)insertShadowView {
    //插入一個淺灰色的夾層
    [self insertGrayView];
    
    //點擊picker外的灰色夾層也視為確認
    [self.shadowView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickerSelected)]];
    
    // 暫時隱藏右側的保存按鈕
    self.navigationItem.rightBarButtonItem = nil;
    
}

#pragma mark - set data for pickerView

- (void)setDefaultDataForPickerView {
    // 從userDefault中獲取資料
    self.incomeArray = [self.userDefaults objectForKey:@"incomeAZX"];
    self.expenseArray = [self.userDefaults objectForKey:@"expenseAZX"];
    
    if (self.incomeArray.count == 0 || self.expenseArray.count == 0) {
        //若第一次進入應用，則為其設定默認的收入支出種類
        self.incomeArray = [NSMutableArray arrayWithArray:@[@"工資薪酬", @"獎金福利", @"生意經營", @"投資理財", @"彩票中獎", @"銀行利息", @"其他收入"]];
        self.expenseArray = [NSMutableArray arrayWithArray:@[@"餐飲食品", @"交通路費", @"日常用品", @"服裝首飾", @"學習教育", @"煙酒消費", @"房租水電", @"網上購物", @"運動健身", @"電子產品", @"化妝護理", @"醫療體檢", @"遊戲娛樂", @"外出旅遊", @"油費維護", @"慈善捐贈", @"其他支出"]];
        
        // 保存至userDefaults中
        [self.userDefaults setObject:self.incomeArray forKey:@"incomeAZX"];
        [self.userDefaults setObject:self.expenseArray forKey:@"expenseAZX"];
        
        // 將type名當做key，將圖片的名稱當做object(這裡暫時這兩者是一樣的，如果用戶修改了類別的名稱，則將新的type名當做key與圖片的名稱相關聯)
        for (NSString *string in self.incomeArray) {
            [self.userDefaults setObject:string forKey:string];
        }
        for (NSString *string in self.expenseArray) {
            [self.userDefaults setObject:string forKey:string];
        }
    }
}

#pragma mark - date value changed

- (void)datePickerValueDidChanged:(UIDatePicker *)sender {
    // NSDate轉NSString
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    self.dateLabel.text = [dateFormatter stringFromDate:sender.date];
}

#pragma mark - picker selected

- (void)pickerSelected {
    self.navigationItem.rightBarButtonItem = nil;
    
    [self.pickerView removeFromSuperview];
    [self.datePicker removeFromSuperview];
    
    //移除遮擋層並銷毀
    [self.shadowView removeFromSuperview];
    self.shadowView = nil;
    
    //恢復右邊的取消按鈕
    [self customizeRightButton];
}

#pragma mark - detail text View delegate methods

//利用delegate方法實現textView的placeholder
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString: @"詳細描述(選填)"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"詳細描述(選填)";
        textView.textColor = [UIColor lightGrayColor];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
//    CGSize size = CGSizeMake(self.view.frame.size.width, INFINITY);
//    CGSize estimateSize = [textView sizeThatFits:size];
//    [textView.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull constraint, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
//            constraint.constant = estimateSize.height;
//        }
//    }];
    CGFloat startHeight = textView.frame.size.height;
    CGFloat calcHeight = [textView sizeThatFits:textView.frame.size].height;
    
    if (startHeight != calcHeight) {
        [UIView setAnimationsEnabled:NO];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        [UIView setAnimationsEnabled:YES];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
    }
}

#pragma mark - insert a shadow view

//插入一個淺灰色的夾層
//此處不選擇if (view == nil) {...} 是因為別的地方也要用shadowView，為了防止其上添加各種不同的方法使得複雜，所以每次退出就銷毀，進來就用全新的
- (void)insertGrayView {
    self.shadowView = [[UIView alloc] initWithFrame:self.view.frame];
    self.shadowView.backgroundColor = [UIColor grayColor];
    self.shadowView.alpha = 0.5;
    [self.view addSubview:self.shadowView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath.row == 1) {
        [self.view bringSubviewToFront:self.pickerView];
    } else if (indexPath.row == 2) {
        [self.view bringSubviewToFront:self.datePicker];
    }
}

#pragma mark - UIPickerView dataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return 2; // 左側的需要收入與支出兩行
    } else {
        // 根據類型不同提供不同的行數
        if ([self.incomeType isEqualToString:@"income"]) {
            return self.incomeArray.count;
        } else if ([self.incomeType isEqualToString:@"expense"]) {
            return self.expenseArray.count;
        } else {
            return 0;
        }
    }
}

#pragma mark - UIPickerView delegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) { // 默認第一行為支出
        if (row == 0) {
            return @"支出";
        } else {
            return @"收入";
        }
    } else {
        // 根據收入支出類型不同分別返回不同的資料
        if ([self.incomeType isEqualToString:@"income"]) {
            return self.incomeArray[row];
        } else {
            return self.expenseArray[row];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    // 根據indexPath的不同執行不同的方法
    if ([indexPath section] == 0) {
        switch ([indexPath row]) {
            case 0:
                //點擊輸入金額，彈出自定義鍵盤
                [self.customTextField becomeFirstResponder];
                break;
            case 1:
                // 點擊類別選擇，創建一個類別選擇框
                [self setUpPickerView];
                break;
            case 2:
                // 點擊選擇日期，創建一個日期選擇框
                [self setUpDatePicker];
                break;
            default:
                break;
        }
    }
    else {
        // 點擊詳細說明，彈出鍵盤
        [self.detailTextView becomeFirstResponder];
    }
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        // 選擇不同種類時改變incomeType值，以使得dataSource方法中得以判斷右邊需要多少行,並改變customTextField的字體顏色
        if (row == 0) {
            self.incomeType = @"expense";
            self.customTextField.textColor = [UIColor redColor];
            // 當切換到支出選項時，默認顯示支出第一個類別的名稱(不然的話還得要拉一下才可以)
            self.typeLabel.text = self.expenseArray[0];
        } else {
            self.incomeType = @"income";
            self.customTextField.textColor = [UIColor blueColor];
            // 當切換到收入選項時，默認顯示收入第一個類別的名稱
            self.typeLabel.text = self.incomeArray[0];
        }
        [self.pickerView reloadComponent:1];
    } else {
        if ([self.incomeType isEqualToString:@"income"]) {
            self.typeLabel.text = self.incomeArray[row];
        } else {
            self.typeLabel.text = self.expenseArray[row];
        }
    }
}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
