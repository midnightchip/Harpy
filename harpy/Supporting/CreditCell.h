//
//  CreditCell.h
//  harpy
//
//  Created by midnightchips on 8/20/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreditCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *avatarCell;
@property (strong, nonatomic) IBOutlet UILabel *userLabel;
@property (strong, nonatomic) IBOutlet UILabel *roleLabel;
@property NSString *userName;
- (void)setTwitterImage:(NSString *)link;
@end
