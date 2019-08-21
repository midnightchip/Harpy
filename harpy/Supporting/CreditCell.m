//
//  CreditCell.m
//  harpy
//
//  Created by midnightchips on 8/20/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

#import "CreditCell.h"
#import <SDWebImage/SDWebImage.h>

@implementation CreditCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatarCell.layer.cornerRadius = 10;
    self.avatarCell.clipsToBounds = TRUE;
}

- (void)setTwitterImage:(NSString *)link {
    [self.avatarCell sd_setImageWithURL:[NSURL URLWithString:link]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
