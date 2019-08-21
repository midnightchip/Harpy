//
//  deviceCell.h
//  
//
//  Created by midnightchips on 8/19/19.
//

#import <UIKit/UIKit.h>

@interface deviceCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *ipLabel;
@property (strong, nonatomic) IBOutlet UILabel *macLabel;
@property (strong, nonatomic) IBOutlet UILabel *hostLabel;
@property (strong, nonatomic) IBOutlet UILabel *buildLabel;

@end
