//
//  ViewController.h
//  harpy
//
//  Created by midnightchips on 8/19/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMLANScanner.h"
#import "deviceCell.h"

@interface WifiVC : UITableViewController <MMLANScannerDelegate>
@property(nonatomic,strong)MMLANScanner *lanScanner;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property NSUserDefaults *defaults;
@end

