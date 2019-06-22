//
//  AZXAccountTableViewCell.h
// BlueCralishMoneyBook
//
//  Created by candy on 2019/06/18.
//  Copyright © 2019年 PD101. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlueCralishAccountTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *typeImage; // 图像显示名称为typeName的图片
@property (weak, nonatomic) IBOutlet UILabel *typeName;
@property (weak, nonatomic) IBOutlet UILabel *money;

@end
