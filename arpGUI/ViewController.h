//
//  ViewController.h
//  arpGUI
//
//  Created by midnightchips on 1/4/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Commands.h"
#import "UIRefreshControl+beginRefreshing.h"

NS_INLINE NSString *runCommandGivingResults(NSString *command) {
    FILE *proc = popen(command.UTF8String, "r");
    
    if (!proc) { return [NSString stringWithFormat:@"ERROR PROCESSING COMMAND: %@", command]; }
    
    int size = 1024;
    char data[size];
    
    NSMutableString *results = [NSMutableString string];
    
    while (fgets(data, size, proc) != NULL) {
        [results appendString:[NSString stringWithUTF8String:data]];
    }
    
    pclose(proc);
    
    return [NSString stringWithString:results];
}

#define resultsForCommand(...) runCommandGivingResults(__VA_ARGS__)

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

