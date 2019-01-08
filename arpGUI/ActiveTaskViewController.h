//
//  ActiveTaskViewController.h
//  Harpy
//
//  Created by midnightchips on 1/6/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Commands.h"
#import "UIBarButtonItem+blocks.h"
#import "MCDataProvider.h"


@interface ActiveTaskViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
