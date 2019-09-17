//
//  ShareAddViewController.m
//  BlueCralishMoneyBook
//
//  Created by Bomi on 2019/9/16.
//  Copyright © 2019 PD101. All rights reserved.
//

#import "ShareAddViewController.h"
#import "UIColor+Hex.h"
#import "Share.h"

@interface ShareAddViewController ()
@property (weak, nonatomic) IBOutlet UIButton *lendOweButton;
@property (assign, nonatomic) BOOL isLend;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *moneyTextField;

@end

@implementation ShareAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isLend = YES;
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTapped:)];
    [self.view addGestureRecognizer:ges];
}

- (void)viewDidTapped:(id)sender {
    [self.view endEditing:YES];
}

- (void)setIsLend:(BOOL)isLend {
    _isLend = isLend;
    if (isLend) {
        [self.lendOweButton setTitle:@"借" forState:UIControlStateNormal];
        [self.lendOweButton setBackgroundColor:[UIColor hexColor:@"E4D078"]];
    } else {
        [self.lendOweButton setTitle:@"欠" forState:UIControlStateNormal];
        [self.lendOweButton setBackgroundColor:[UIColor hexColor:@"EAACB6"]];
    }
}

- (IBAction)leandOweButtonDidTapped:(UIButton *)button {
    self.isLend = !self.isLend;
}

- (IBAction)finishedShareButtonDidTapped:(id)sender {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
    
    NSString *name = self.nameTextField.text;
    NSString *money = self.moneyTextField.text;
    if (!self.isLend) {
        money = [NSString stringWithFormat:@"-%@", money];
    }
    
    Share *share = [[Share alloc] initWithName:name money:money];
    
    NSData *data = [[NSUserDefaults standardUserDefaults] valueForKey:@"Shares"];
    NSMutableArray *shares = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (shares == nil) {
        NSMutableArray *mArr = [NSMutableArray new];
        [mArr addObject:share];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:mArr];
        [[NSUserDefaults standardUserDefaults] setValue:data forKey:@"Shares"];
        return;
    }
    else {
        [shares addObject:share];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:shares];
        [[NSUserDefaults standardUserDefaults] setValue:data forKey:@"Shares"];
    }
    
}

@end
