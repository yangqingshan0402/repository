//
//  SimpleTableViewCell.m
//  TestMyTableView
//
//  Created by GY on 13-5-27.
//  Copyright (c) 2013年 guyu. All rights reserved.
//

#import "SimpleTableViewCell.h"

@implementation SimpleTableViewCell

@synthesize uiImage = _uiImage;
@synthesize lableTime = _lableTime;
@synthesize lableTitle = _lableTitle;
@synthesize status = _status;
@synthesize ibeacon = _ibeacon;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
