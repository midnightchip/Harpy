//
//  ActiveTasksTableViewController.h
//  
//
//  Created by midnightchips on 8/19/19.
//

#import <UIKit/UIKit.h>

@interface ActiveTasksTableViewController : UITableViewController
@property NSUserDefaults *defaults;
- (void)getWifiBlocks;
@end
