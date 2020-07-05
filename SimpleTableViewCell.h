//
//  SimpleTableViewCell.h
//  TestMyTableView
//
//  Created by GY on 13-5-27.
//  Copyright (c) 2013年 guyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SimpleTableViewCell : UITableViewCell


@property(nonatomic,weak)IBOutlet UIImageView *uiImage;
@property(nonatomic,weak)IBOutlet UILabel *lableTime;
@property(nonatomic,weak)IBOutlet UILabel *lableTitle;
@property(nonatomic,weak)IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *stat;
@property (weak, nonatomic) IBOutlet UIButton *butt_t;
@property (weak, nonatomic) IBOutlet UILabel *ibeacon;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@end
