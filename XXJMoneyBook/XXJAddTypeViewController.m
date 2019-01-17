//
//  AZXAddTypeViewController.m
//  AZXTallyBook
//
//  Created by azx on 16/3/16.
//  Copyright © 2016年 azx. All rights reserved.
//

#import "XXJAddTypeViewController.h"
#import "XXJAddTypeCollectionViewCell.h"
#import "UIViewController+BackButtonHandler.h"

@interface XXJAddTypeViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *typeCollectionView;

@property (weak, nonatomic) IBOutlet UIImageView *showImage;

@property (weak, nonatomic) IBOutlet UITextField *typeTextField;

@property (strong, nonatomic) NSMutableArray *typeArray; // 存放各種類別名稱(用來顯示collectionView中圖片的資料源)

@property (strong, nonatomic) NSUserDefaults *defaults;

@property (strong, nonatomic) NSString *incomeType;

@property (strong, nonatomic) NSMutableArray *incomeArray; // 收入類別數組

@property (strong, nonatomic) NSMutableArray *expenseArray; // 支出類別數組

@property (strong, nonatomic) UIView *shadowView; // 實現點擊空白區域返回鍵盤的隔層

@property (weak, nonatomic) IBOutlet UIButton *localPhotoButton; // 打開本地相冊

@property (strong, nonatomic) UIImage *selectedPhoto; // 從相冊里選擇的圖片

@property (strong, nonatomic) NSIndexPath *selectedIndexOfImage; // 選中的屏幕上的圖片

@property (assign, nonatomic) BOOL isFromAlbum; // 最後保存時是從相冊選擇的還是從已有的圖片選擇，YES代表從相冊里選擇
@end

@implementation XXJAddTypeViewController
- (NSString *)incomeType {
    if (!_incomeType) {
        _incomeType = @"expense"; // 收支類型默認為支出
    }
    return _incomeType;
}

- (IBAction)typeChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        self.incomeType = @"expense";
    } else {
        self.incomeType = @"income";
    }
}

// 打開相冊
- (IBAction)localPhoto:(UIButton *)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        // 如果相冊可用
        UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
        photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        photoPicker.delegate = self;
        //設定選擇後的圖片可被編輯
        photoPicker.allowsEditing = YES;
        
        // 設定其彈出方式(自動適配iPad和iPhone)
        photoPicker.modalPresentationStyle = UIModalPresentationPopover;
        
        [self presentViewController:photoPicker animated:YES completion:nil];
        
        // 獲取popoverPresentationController
        UIPopoverPresentationController *presentationController = [photoPicker popoverPresentationController];
        
        presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        presentationController.sourceView = self.localPhotoButton;
        presentationController.sourceRect = self.localPhotoButton.bounds;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.typeCollectionView.delegate = self;
    self.typeCollectionView.dataSource = self;
    self.typeTextField.delegate = self;
    
    self.typeCollectionView.backgroundColor = [UIColor whiteColor];
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    // 一進入界面就彈出鍵盤
    [self.typeTextField becomeFirstResponder];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarItemPressed)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 取得支出收入的所有類型
    self.expenseArray = [NSMutableArray arrayWithArray:[self.defaults objectForKey:@"expenseAZX"]];
    self.incomeArray = [NSMutableArray arrayWithArray:[self.defaults objectForKey:@"incomeAZX"]];
    
    if (![self.defaults objectForKey:@"imagesShowInAZXAddTypeViewController"]) {
        // 如果還未保存顯示在這界面的圖片數組
        self.typeArray = [NSMutableArray arrayWithArray:@[@"餐飲食品", @"交通路費", @"日常用品", @"服裝首飾", @"學習教育", @"煙酒消費", @"房租水電", @"網上購物", @"運動健身", @"電子產品", @"化妝護理", @"醫療體檢", @"遊戲娛樂", @"外出旅遊", @"油費維護", @"慈善捐贈", @"其他支出", @"工資薪酬", @"獎金福利", @"生意經營", @"投資理財", @"彩票中獎", @"銀行利息", @"其他收入"]];
        [self.defaults setObject:self.typeArray forKey:@"imagesShowInAZXAddTypeViewController"];
    } else {
        self.typeArray = [NSMutableArray arrayWithArray:[self.defaults objectForKey:@"imagesShowInAZXAddTypeViewController"]];
    }
}

- (void)rightBarItemPressed {
    // 首先判斷是否新類別名已存在，不允許重復
    if ([self.expenseArray containsObject:self.typeTextField.text] || [self.incomeArray containsObject:self.typeTextField.text]) {
        [self popoverAlertControllerWithMessage:@"類別名已存在，請使用新的類別名"];
    } else if (self.typeTextField.text && self.showImage.image) {
        // 若兩者都已輸入，將圖片與類別名保存並聯繫起來
        [self savePhotoWithTypeName];
        
        // 跳回上一界面
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        // 彈出提示
        [self popoverAlertControllerWithMessage:@"圖片與類別名都需要輸入"];
    }
}

- (void)popoverAlertControllerWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// 點擊back按鈕後調用 引用的他人寫的一個extension
- (BOOL)navigationShouldPopOnBackButton {
    if (![self.typeTextField.text isEqualToString:@""] && self.showImage.image) {
        // 當二者都填上內容時，點擊返回詢問是否保存
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"還未保存，是否返回？" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *OK = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:cancel];
        [alert addAction:OK];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    return YES;
}

// 將圖片與類別名關聯並保存
- (void)savePhotoWithTypeName {
    if (self.isFromAlbum) {
        // 如果是從相冊中選擇的
        [self savePhotoFromAlbum];
    } else {
        // 如果是從已有的圖片中選擇的
        NSInteger index = [self.typeCollectionView indexPathsForSelectedItems][0].row;
        // 圖片的名稱(路徑)
        NSString *imageName = self.typeArray[index];
        // 將二者關聯起來
        [self.defaults setObject:imageName forKey:self.typeTextField.text];
    }
}

- (void)savePhotoFromAlbum {
    NSData *data;
    if (UIImagePNGRepresentation(self.selectedPhoto) == nil) {
        data = UIImageJPEGRepresentation(self.selectedPhoto, 1.0);
    }
    else {
        data = UIImagePNGRepresentation(self.selectedPhoto);
    }
    
    //圖片保存的路徑
    //這裡將圖片放在沙盒的documents文件夾中
    NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 新類別名
    NSString *type = self.typeTextField.text;
    
    //把剛剛圖片轉換的data對象拷貝至沙盒中 並保存為 類別名.png
    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:[NSString stringWithFormat:@"/%@.png", type]] contents:data attributes:nil];
    
    //得到選擇後沙盒中圖片的完整路徑
    NSString *filePath = [[NSString alloc]initWithFormat:@"%@%@",DocumentsPath, [NSString stringWithFormat:@"/%@.png", type]];
    
    
    // 將類別名與圖片的儲存路徑關聯起來，到時候取出圖片時直接用[imageNamed:儲存路徑]方法
    [self.defaults setObject:filePath forKey:type];
    
    // 將類別名加入相應的類別數組
    if ([self.incomeType isEqualToString:@"income"]) {
        [self.incomeArray addObject:type];
        [self.defaults setObject:self.incomeArray forKey:@"incomeAZX"];
    } else {
        [self.expenseArray addObject:type];
        [self.defaults setObject:self.expenseArray forKey:@"expenseAZX"];
    }
    
    // 並將新加入的圖片保存在此頁面的typeArray，下次進入界面就會顯示出來
    [self.typeArray addObject:filePath];
    [self.defaults setObject:self.typeArray forKey:@"imagesShowInAZXAddTypeViewController"];
}

#pragma mark - textField delegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    //插入一個透明的夾層
    [self insertTransparentView];
    [self.shadowView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldResignKeyboard)]];
}

- (void)insertTransparentView {
    self.shadowView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.shadowView];
    [self.view bringSubviewToFront:self.shadowView];
}

- (void)textFieldResignKeyboard {
    [self.typeTextField resignFirstResponder];
    [self.shadowView removeFromSuperview];
    self.shadowView = nil;
}



#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.typeArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XXJAddTypeCollectionViewCell *cell = [self.typeCollectionView dequeueReusableCellWithReuseIdentifier:@"typeImageCell" forIndexPath:indexPath];
    // 得到相應名稱(路徑)的圖片，
    cell.image.image = [UIImage imageNamed:self.typeArray[indexPath.row]];
    UIView *backgroundView = [[UIView alloc] initWithFrame:cell.frame];
    backgroundView.backgroundColor = [UIColor lightGrayColor];
    
    cell.selectedBackgroundView = backgroundView;
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    XXJAddTypeCollectionViewCell *cell = (XXJAddTypeCollectionViewCell *)[self.typeCollectionView cellForItemAtIndexPath:indexPath];
    
    // 顯示選中的圖片
    self.showImage.image = cell.image.image;
    
    // 設為從已有圖片選擇
    self.isFromAlbum = NO;
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat totalWidth = self.typeCollectionView.frame.size.width;
    
    // 一行顯示4個cell
    return CGSizeMake(totalWidth / 4 , totalWidth / 4);
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^ {
        // 如果之前屏幕上有選中的圖片，將屏幕上被選中的cell給deselect掉
        if ([self.typeCollectionView indexPathsForSelectedItems].count != 0) {
            [self.typeCollectionView deselectItemAtIndexPath:[self.typeCollectionView indexPathsForSelectedItems][0] animated:YES];
        }
    }];
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([type isEqualToString:@"public.image"]) {
        // 當選擇的類型是圖片時，顯示在小imageView上
        self.selectedPhoto = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        
        self.showImage.image = self.selectedPhoto;
    }
    
    // 設為從相冊選擇
    self.isFromAlbum = YES;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
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
