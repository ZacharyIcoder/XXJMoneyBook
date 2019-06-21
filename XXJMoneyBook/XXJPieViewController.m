//
//  AZXPieViewController.m
//  AZXTallyBook
//
//  Created by azx on 16/3/12.
//  Copyright © 2016年 azx. All rights reserved.
//

#import "XXJPieViewController.h"
#import "XXJPieView.h"
#import "AppDelegate.h"
#import "Account.h"
#import "XXJPieTableViewCell.h"
#import "XXJTypeDetailViewController.h"
#import <CoreData/CoreData.h>
#import "UIColor+PieColor.h"
#import "UIColor+Hex.h"
#import "NSNumber+String.h"

@interface XXJPieViewController () <UITableViewDataSource, XXJPieViewDataSource>

@property (weak, nonatomic) IBOutlet XXJPieView *pieView;

@property (weak, nonatomic) IBOutlet UITableView *typeTableView;

@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;

@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *rightSwipe; // 右滑手勢

@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwipe; // 左滑手勢

@property (strong, nonatomic) UILabel *nullLabel; // 用來顯示"暫無資料"

@property (strong, nonatomic) NSString *incomeType;

@property (assign, nonatomic) double totalMoney; // 收入/支出總額

@property (strong, nonatomic) NSArray *dataArray; // fetch來的Accounts

@property (strong, nonatomic) NSArray *uniqueDateArray;

@property (strong, nonatomic) NSArray *uniqueTypeArray;

@property (strong, nonatomic) NSArray *sortedMoneyArray;

@property (strong, nonatomic) NSArray *sortedPercentArray; // 相應類別所佔總金額的比例

@property (strong, nonatomic) NSDictionary *dict; // 儲存有[type:money]的字典

@property (assign, nonatomic) NSInteger currentIndex; // 當前要顯示的資料的index(隨swipe而增減)

@property (strong, nonatomic) NSString *currentDateString; // 當前日期，用來顯示與篩選fetch結果

@property (strong, nonatomic) NSDate *currentDate; // 用來swipe時加減日期

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSArray *colors; // 一條漸變的顏色帶

@property (strong, nonatomic) NSArray *colorArray; // 儲存各種顏色(對應不同的type)

@end

@implementation XXJPieViewController

- (NSInteger)currentIndex {
    if (!_currentIndex) {
        _currentIndex = 0; // 默認為0
    }
    return _currentIndex;
}

- (NSString *)incomeType {
    if (!_incomeType) {
        _incomeType = @"expense"; // 默認為支出
    }
    return _incomeType;
}

- (NSArray *)colors {
    if (!_colors) {
        _colors = @[[UIColor pieColor1],
                    [UIColor pieColor2],
                    [UIColor pieColor3],
                    [UIColor pieColor4],
                    [UIColor pieColor5],
                    [UIColor pieColor6],
                    [UIColor pieColor7],
                    [UIColor pieColor8],
                    [UIColor pieColor9],
                    [UIColor pieColor10],
                    [UIColor pieColor11],
                    [UIColor pieColor12],
                    [UIColor pieColor13],
                    [UIColor pieColor14]];
    }
    return _colors;
}

- (IBAction)segValueChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.incomeType = @"expense";
        [self refreshAll];
    } else {
        self.incomeType = @"income";
        [self refreshAll];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.typeTableView.dataSource = self;
    self.pieView.dataSource = self;
    self.pieView.backgroundColor = [UIColor clearColor];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    [self setSwipeGesture];
    
    [self judgeFirstLoadThisView];
    
    self.title = @"統計";
}

- (void)judgeFirstLoadThisView {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults boolForKey:@"haveLoadedAZXPieViewController"]) {
        // 第一次進入此頁面
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"教學" message:@"首頁顯示本月的收支統計圖，手指左右划動屏幕可改變當前顯示月份，要查看某一類別的詳細情況，點擊該行" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"知道了，不再提醒" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [defaults setBool:YES forKey:@"haveLoadedAZXPieViewController"];
        }];
        
        [alert addAction:actionOK];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshAll];
}

- (void)viewWillDisappear:(BOOL)animated {
    // 離開界面時將圖上label全部移除
    [self.pieView removeAllLabel];
}

- (void)refreshAll {
    [self.pieView removeAllLabel];
    
    [self.nullLabel removeFromSuperview];
    
    [self fetchData];
    
    [self filterData];
    
    [self setMoneyLabel];
    
    [self.typeTableView reloadData];
    
    [self.pieView reloadData];
}

- (void)setSwipeGesture {
    // 分別設定左右滑動手勢
    self.leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    self.rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    
    [self.view addGestureRecognizer:self.leftSwipe];
    [self.view addGestureRecognizer:self.rightSwipe];
    
    self.leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    self.rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)gesture {
    // 創建一個標準日曆
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    
    if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        // 左滑月份加1
        [comps setMonth:1];
        self.currentDate = [calendar dateByAddingComponents:comps toDate:self.currentDate options:0];
    } else if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        // 右滑月份減1
        [comps setMonth:-1];
        self.currentDate = [calendar dateByAddingComponents:comps toDate:self.currentDate options:0];
    }
    
    [self refreshAll];
}

- (void)fetchData {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Account"];
    
    // 設定日期格式
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy.MM.dd";
    
    if (self.currentDateString == nil) {
        // 如果還未設定，默認顯示當前所處月份
        self.currentDate = [NSDate date];
        self.currentDateString = [[dateFormatter stringFromDate:self.currentDate] substringToIndex:7];
        
        [request setPredicate:[NSPredicate predicateWithFormat:@"date beginswith[c] %@ and incomeType == %@", self.currentDateString, self.incomeType]];
    } else {
        self.currentDateString = [[dateFormatter stringFromDate:self.currentDate] substringToIndex:7];
        [request setPredicate:[NSPredicate predicateWithFormat:@"date beginswith[c] %@ and incomeType == %@", self.currentDateString, self.incomeType]];
    }
    
    NSError *error = nil;
    self.dataArray = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (self.dataArray.count == 0) {
        // 如果沒有資料，中間顯示"暫無資料"
        self.nullLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        self.nullLabel.text = @"暫無資料";
        self.nullLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        self.nullLabel.textColor = [UIColor lightGrayColor];
        [self.nullLabel sizeToFit];
        self.nullLabel.center = self.view.center;
        [self.view addSubview:self.nullLabel];
    }
}


// 得到了totalMoney(總金額)，sortedMoneyArray(某一類別的金額的數組)，uniqueTypeArray(類別數組，與左邊的數組排序相同)，uniqueDateArray(日期數組)，sortedPercentArray(每個類別所花金額佔總金額的比例)，colorArray（儲存各種顏色對應不同的type)
- (void)filterData {
    // 設定各個屬性的暫存數組，防止直接資料加入屬性多次調用方法導致資料疊加
    NSMutableArray *tmpTypeArray = [NSMutableArray array];
    NSMutableArray *tmpAccountArray = [NSMutableArray array];
    NSDictionary *tmpDict = [NSMutableDictionary dictionary];
    NSMutableArray *tmpMoneyArray = [NSMutableArray array];
    NSMutableArray *tmpDateArray = [NSMutableArray array];
    NSMutableArray *tmpSortedPercentArray = [NSMutableArray array];
    NSMutableArray *tmpColorArray = [NSMutableArray array];
    
    double tmpMoney = 0;
    for (Account *account in self.dataArray) {
        [tmpTypeArray addObject:account.type];
        [tmpAccountArray addObject:account];
        tmpMoney += [account.money doubleValue];
        [tmpDateArray addObject:[account.date substringToIndex:7]];
    }
    
    self.totalMoney = tmpMoney;
    
    // 去掉重復元素
    NSSet *typeSet = [NSSet setWithArray:[tmpTypeArray copy]];
    
    //
    tmpTypeArray = [NSMutableArray array];
    
    // 得到降序的無重復元素的日期數組
    NSSet *dateSet = [NSSet setWithArray:[tmpDateArray copy]];
    self.uniqueDateArray = [dateSet sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:nil ascending:NO]]];
    
    for (NSString *type in typeSet) {
        // 從中過濾其中一個類別的所有Account，然後得到一個類別的總金額
        NSArray *array = [tmpAccountArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %@", type]];
        
        double totalMoneyInOneType = 0;
        for (Account *account in array) {
            totalMoneyInOneType += [account.money doubleValue];
        }
        
        // 將金額封裝成NSNumber來排序
        [tmpMoneyArray addObject:[NSNumber numberWithDouble:totalMoneyInOneType]];
        
        // 將type加入數組
        [tmpTypeArray addObject:type];
        
    }
    
    // 這裡使用字典是為了使type和money能關聯起來，而且因為money要排序的原因無法使它們在各自數組保持相同的index，所以用字典的方法
    tmpDict = [NSDictionary dictionaryWithObjects:[tmpMoneyArray copy] forKeys:[tmpTypeArray copy]];
    
    // 降序排列
    self.sortedMoneyArray = [tmpMoneyArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:nil ascending:NO]]];
    
    NSMutableArray *tmpTypes = [NSMutableArray array];
    NSInteger x = 0;
    
    double tmpTotalPercent = 0;
    
    for (NSInteger i = 0; i < self.sortedMoneyArray.count; i++) {
        // 將相應百分比(小數點後兩位)加入數組
        // 此處為了總和為100%，將最後一個設為總額減去數組前除最後一個外所有的元素的百分比
        double money = [self.sortedMoneyArray[i] doubleValue];
        
        double percent = [[NSString stringWithFormat:@"%.2f",money/self.totalMoney*100] doubleValue];
        
        if (i != self.sortedMoneyArray.count - 1) {
            // 如果不是數組最後一個的話，直接加入數組
            [tmpSortedPercentArray addObject:[NSNumber numberWithDouble:percent]];
            // 並累計前面百分比的總和
            tmpTotalPercent += percent;
        } else {
            // 如果是最後一個元素，通過用1減去前面的總和得到
            [tmpSortedPercentArray addObject:[NSNumber numberWithDouble:[[NSString stringWithFormat:@"%.2f", 100-tmpTotalPercent] doubleValue]]];
        }
        
        // 將相應顏色加入數組(超過數組的14時從頭開始)
        [tmpColorArray addObject:self.colors[i%14]];
        
        // 將相應類型加入數組
        // 因為可能一個金額對應著多個類型，判斷是否出現此情況，若出現，則將x++, 取出數組其餘類型
        if (i > 0 && (self.sortedMoneyArray[i-1] == self.sortedMoneyArray[i])) {
            x++;
        } else {
            x = 0;
        }
        NSString *type = [tmpDict allKeysForObject:self.sortedMoneyArray[i]][x];
        // 此數組中加入的順序與moneyArray中一樣
        [tmpTypes addObject:type];
    }
    
    self.sortedPercentArray = [tmpSortedPercentArray copy];
    self.colorArray = [tmpColorArray copy];
    self.uniqueTypeArray = [tmpTypes copy];
}

- (void)setMoneyLabel {
    NSMutableAttributedString *mutString;
    if ([self.incomeType isEqualToString:@"income"]) {
        mutString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ 總收入: %@", self.currentDateString, [NSNumber numberWithDouble:self.totalMoney]]];
        [mutString addAttribute:NSForegroundColorAttributeName value:[UIColor hexColor:@"d8ae47"] range:NSMakeRange(13, [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:self.totalMoney]].length)];
    } else {
        mutString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ 總支出: %@", self.currentDateString, [NSNumber numberWithDouble:self.totalMoney]]];
        [mutString addAttribute:NSForegroundColorAttributeName value:[UIColor hexColor:@"ee4b2e"] range:NSMakeRange(13, [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:self.totalMoney]].length)];
        
    }
    
    [mutString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 12)];
    
    [self.moneyLabel setAttributedText:mutString];
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.uniqueTypeArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XXJPieTableViewCell *cell = [self.typeTableView dequeueReusableCellWithIdentifier:@"pieTypeCell" forIndexPath:indexPath];
    
    cell.colorView.backgroundColor = self.colorArray[indexPath.row];
    
    NSString *type = self.uniqueTypeArray[indexPath.row];
    NSNumber *money = self.sortedMoneyArray[indexPath.row];
    
    NSNumber *percent = self.sortedPercentArray[indexPath.row];
    NSString *percentString = [NSString stringWithFormat:@"%@", percent];
    percentString = [@(percentString.doubleValue) stringForCurrencyWithDigit:2];
    NSString *blankString = @"   ";
    NSMutableAttributedString *mutString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@%@%@  %@%%", type, blankString, money, blankString, [self filterLastZeros:percentString]]];
    
    [mutString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, type.length)];
    
    // 計算金額顯示的長度
    NSInteger moneyLength = [NSString stringWithFormat:@"%@", money].length;
    
    if ([self.incomeType isEqualToString:@"income"]) {
        [mutString addAttribute:NSForegroundColorAttributeName value:[UIColor hexColor:@"d8ae47"] range:NSMakeRange(type.length + blankString.length, moneyLength)];
    } else {
        [mutString addAttribute:NSForegroundColorAttributeName value:[UIColor hexColor:@"ee4b2e"] range:NSMakeRange(type.length + blankString.length, moneyLength)];
    }
    
    [mutString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(type.length + blankString.length + moneyLength + blankString.length, percentString.length)];
    
    [cell.moneyLabel setAttributedText:mutString];
    
    return cell;
}

- (NSString *)filterLastZeros:(NSString *)string {
    NSString *str = string;
    if ([str containsString:@"."] && [string substringFromIndex:[string rangeOfString:@"."].location].length > 3) {
        // 如果小數點後大於2位，只保留兩位
        str = [string substringToIndex:[string rangeOfString:@"."].location+3];
    }
    if ([str containsString:@"."]) {
        if ([[str substringFromIndex:str.length-1] isEqualToString: @"0"]) {
            // 如果最後一位為0，捨棄
            return [str substringToIndex:str.length-1];
        } else if ([[str substringFromIndex:str.length-2] isEqualToString:@"00"]) {
            // 如果後兩位為0，捨棄
            return [str substringToIndex:str.length-2];
        } else {
            return str;
        }
    }
    return str;
}


#pragma mark - AZXPieView DataSource

- (NSArray *)percentsForPieView:(XXJPieView *)pieView {
    return self.sortedPercentArray;
}

- (NSArray *)colorsForPieView:(XXJPieView *)pieView {
    return self.colorArray;
}

- (NSArray *)typesForPieView:(XXJPieView *)pieView {
    return self.uniqueTypeArray;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showTypeDetail"]) {
        if ([[segue destinationViewController] isKindOfClass:[XXJTypeDetailViewController class]]) {
            XXJTypeDetailViewController *viewController = [segue destinationViewController];
            viewController.date = self.currentDateString;
            
            viewController.incomeType = self.incomeType;
            
            NSIndexPath *indexPath = [self.typeTableView indexPathForSelectedRow];
            
            viewController.type = self.uniqueTypeArray[indexPath.row];
            
        }
    }
}


@end
