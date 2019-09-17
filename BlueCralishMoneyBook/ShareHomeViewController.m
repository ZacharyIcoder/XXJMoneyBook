//
//  ShareHomeViewController.m
//  BlueCralishMoneyBook
//
//  Created by Bomi on 2019/9/11.
//  Copyright © 2019 PD101. All rights reserved.
//

#import "ShareHomeViewController.h"
#import "UIVieww+CConstraint/UIView+Constraint.h"
#import "ShareBannerTableViewCell.h"
#import "ShareFriendTableViewCell.h"
#import "ShareHomeFactory.h"
#import "Share.h"

#define IDENTIFIER_BANNER_CELL @"ShareBannerTableViewCell"
#define IDENTIFIER_FRIEND_CELL @"ShareFriendTableViewCell"

@interface ShareHomeViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIButton *addButton;
@property (strong, nonatomic) NSMutableArray <Share *>*shares;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@end

@implementation ShareHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.addButton];
    [self.addButton constraintsBottom:self.tableView toLayoutAttribute:NSLayoutAttributeBottom constant:-32];
    [self.addButton constraintsCenterX:self.view toLayoutAttribute:NSLayoutAttributeCenterX];
    [self.addButton constraintsWidthWithConstant:50];
    [self.addButton constraintsHeightWithConstant:50];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (NSMutableArray <Share *>*)shares {
    NSData *data = [[NSUserDefaults standardUserDefaults] valueForKey:@"Shares"];
    NSMutableArray *shares = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return shares;
}

- (NSArray <Share *>*)testShares {
    return @[
             [[Share alloc] initWithName:@"David" money:@"1000"],
             [[Share alloc] initWithName:@"Ian" money:@"-200"],
             [[Share alloc] initWithName:@"John" money:@"3020"],
             ];
}

- (UIButton *)addButton {
    if (_addButton == nil) {
        UIButton *button = [[UIButton alloc] init];
        [button setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
        button.tintColor = [UIColor darkGrayColor];
        [button setBackgroundColor:[UIColor whiteColor]];
        button.layer.cornerRadius = 25;
        button.layer.masksToBounds = YES;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [button addTarget:self action:@selector(addButtonDidTapped:) forControlEvents:UIControlEventTouchUpInside];
        _addButton = button;
    }
    return _addButton;
}

- (void)addButtonDidTapped:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"ShareAddViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSString *)getIdentifierBySection:(NSInteger)section {
    if (section == 0) {
        return IDENTIFIER_BANNER_CELL;
    } else {
        return IDENTIFIER_FRIEND_CELL;
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    NSString *identifier = [self getIdentifierBySection:indexPath.section];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        
        ShareHomeFactory *factory = [ShareHomeFactory new];
        cell = [factory createCellWithIdentier:identifier];
    }
    if (indexPath.section == 0) {
        
        ShareBannerTableViewCell *bannerCell = (ShareBannerTableViewCell *)cell;
        [bannerCell configWithShares:self.shares];
        
    } else if (indexPath.section == 1) {
        
        ShareFriendTableViewCell *friendCell = (ShareFriendTableViewCell *)cell;
        [friendCell configCell:self.shares[indexPath.row]];
        [friendCell configIsEditing:self.tableView.isEditing];
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.shares.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return YES;
    } else {
        return NO;
    }
}
- (IBAction)editButtonDidTapped:(id)sender {
    if ([self.tableView isEditing]) {
        [self.tableView setEditing:NO animated:YES];
        [self.editButton setTitle:@"修改" forState:UIControlStateNormal];
    } else {
        [self.editButton setTitle:@"完成" forState:UIControlStateNormal];
        [self.tableView setEditing:YES animated:YES];
    }
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (indexPath.section == 1) {
//            [self.tableView beginUpdates];
            NSMutableArray *newShares = [NSMutableArray arrayWithArray:self.shares];
            [newShares removeObjectAtIndex:indexPath.row];
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newShares];
            [[NSUserDefaults standardUserDefaults] setValue:data forKey:@"Shares"];
            
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            [self.tableView reloadData];
//            [self.tableView endUpdates];
            
//            if (self.shares.count == 0) {
//                self.editButton.enabled = NO;
//                self.editButton.titleLabel.text = @"Edit";
//            }
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
       
    }
    
}

@end

