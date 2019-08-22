//
//  ViewController.m
//  harpy
//
//  Created by midnightchips on 8/19/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

#import "ViewController.h"
#import "LANProperties.h"
#import "PingOperation.h"
#import "MMLANScanner.h"
#import "MACOperation.h"
#import "MacFinder.h"
#import "MMDevice.h"
#import "MobileGestalt.h"

#import "MCCommands.h"

static inline NSString *udid(void);
static inline BOOL isValidPurchase(void);

static inline BOOL isValidPurchase() {
    __block BOOL isValid = FALSE;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    NSString *post = [NSString stringWithFormat:@"https://chariz.io/api/drm/check?udid=%@&model=%@&identifier=com.midnightchips.harpy&token=%@", udid(), (__bridge NSString *)(MGCopyAnswer((__bridge CFStringRef)@"ProductType")), TOKEN];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    [request setURL:[NSURL URLWithString:post]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            if([response objectForKey:@"status"]) {
                NSString *responseValue = [response valueForKey:@"status"];
                if ([responseValue isEqualToString:@"completed"]) {
                    isValid = TRUE;
                }
            }
        }
        dispatch_semaphore_signal(sema);
    }] resume];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    return isValid;
}

static inline NSString *udid() {
    static NSString *udid = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CFStringRef udidCF = (CFStringRef)MGCopyAnswer(kMGUniqueDeviceID);
        udid = (__bridge NSString *)udidCF;
        if (udid == NULL) {
            // send a fake UDID in case this is a simulator
            udid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        }
    });
    return udid;
}

@interface WifiVC () {
    NSMutableArray *tableData;
}

@end

@implementation WifiVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //[MCCommands checkRX];
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    tableData = [NSMutableArray new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 75;
    [self.tableView setEstimatedRowHeight:100];
    [self.tableView registerNib:[UINib nibWithNibName:@"deviceCell" bundle:nil] forCellReuseIdentifier:@"deviceCell"];
    
    self.lanScanner = [[MMLANScanner alloc] initWithDelegate:self];
    if (![self.defaults boolForKey:@"checked"]) {
        [self checkLicense];
    }
    if (![self.defaults boolForKey:@"agreed"]) {
        [self agreeToTerms];
    } else {
        [self startScanner];
    }
    
    
}

- (void)checkLicense {
    if (isValidPurchase()) {
        [self.defaults setBool:TRUE forKey:@"checked"];
        [self.defaults synchronize];
    }
    if(![self.defaults boolForKey:@"checked"]) {
        UIAlertController * alert=[UIAlertController
                                   
                                   alertControllerWithTitle:@"Warning" message:@"This copy of Harpy is pirated.\nPirates commonly modify packages that can take advantage of you and your device. Please consider buying a copy rather than pirating."preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"Ok I'll buy it."
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 if (@available(iOS 10.0, *)) {
                                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://repo.chariz.io/package/com.midnightchips.harpy/"] options:@{} completionHandler:nil];
                                 } else {
                                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://repo.chariz.io/package/com.midnightchips.harpy/"]];
                                 }
                             }];
        
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Nah, I like people stealing my data."
                                 style:UIAlertActionStyleCancel
                                 handler:^(UIAlertAction * action)
                                 {
                                 }];
        [alert addAction:cancel];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)agreeToTerms {
    UIAlertController * alert=[UIAlertController
                               
                               alertControllerWithTitle:@"Warning" message:@"Using this application on any network without permission is ILLEGAL.\nI am not responsible for anything you do with this application.\nPress 'I agree.' if you agree, otherwise the app will be closed."preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"I agree."
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self.defaults setBool:TRUE forKey:@"agreed"];
                             [self.defaults synchronize];
                             [self startScanner];
                         }];
    
    UIAlertAction* cancel = [UIAlertAction
                         actionWithTitle:@"I do not agree."
                         style:UIAlertActionStyleCancel
                         handler:^(UIAlertAction * action)
                         {
                             exit(0);
                         }];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)startScanner {
    [self.lanScanner start];
    [self.progressView setProgress:0.0f];
    [self.progressView setHidden:FALSE];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Scanner
- (void)lanScanDidFailedToScan {
    NSLog(@"Failed to Scan");
    self.navigationItem.title = @"Unknown";
    UIAlertController * alert=[UIAlertController
                               
                               alertControllerWithTitle:@"Scan Failed" message:@"Please make sure you are connected to a WiFi Network, and try again."preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                { }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)lanScanDidFindNewDevice:(MMDevice *)device {
    //NSLog(@"New Device %@", device.ipAddress);
    [tableData addObject:device];
    [self.tableView reloadData];
}

- (void)lanScanDidFinishScanningWithStatus:(MMLanScannerStatus)status {
    //NSLog(@"MMLanScannerStatus %u", status);
    if (status == 0) {
        self.navigationItem.title = [LANProperties fetchSSIDInfo];
    }
    
    [self.progressView setHidden:TRUE];
}

- (void)lanScanProgressPinged:(float)pingedHosts from:(NSInteger)overallHosts {
    //NSLog(@"Total Pinged: %f from overall: %ld", pingedHosts, (long)overallHosts);
    [self.progressView setProgress:pingedHosts/overallHosts];
}


#pragma mark TableView Delegates
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    deviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceCell" forIndexPath:indexPath];
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[deviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"deviceCell"];
    }
    MMDevice *device = [tableData objectAtIndex:indexPath.row];
    if (device.macAddress) {
        cell.ipLabel.text = [self.defaults valueForKey:device.macAddress] ? [self.defaults valueForKey:device.macAddress] : device.ipAddress;
    } else {
        cell.ipLabel.text = device.ipAddress;
    }
    if (device.isLocalDevice) {
        cell.buildLabel.text = @"Apple, Inc.";
#if TARGET_OS_SIMULATOR
        cell.macLabel.text = @"Sim";
        cell.hostLabel.text = @"Host SIM";
#else
        cell.macLabel.text = (__bridge NSString *)(MGCopyAnswer((__bridge CFStringRef)@"WifiAddress"));
        cell.hostLabel.text = (__bridge NSString *)(MGCopyAnswer((__bridge CFStringRef)@"UserAssignedDeviceName"));
#endif
    } else {
        //cell.ipLabel.text = [self.defaults valueForKey:device.macAddress] ? [self.defaults valueForKey:device.macAddress] : device.ipAddress;
        cell.buildLabel.text = device.brand;
        cell.macLabel.text = device.macAddress;
        cell.hostLabel.text = device.hostname ? device.hostname : @"Unknown";
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"TOTAL ROWS: %lu", (unsigned long)tableData.count);
    return tableData.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

-  (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MMDevice *device = [tableData objectAtIndex:indexPath.row];
    
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:[self.defaults valueForKey:device.macAddress] ? [self.defaults valueForKey:device.macAddress] : device.ipAddress message:@"Available Options" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *setNick = [UIAlertAction
                         actionWithTitle:@"Set Nickname"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action){
                             [self setNickName:device];
                         }];
    
    UIAlertAction *removeNick = [UIAlertAction
                              actionWithTitle:@"Remove Nickname"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action){
                                  [self removeNickName:device];
                              }];
    UIAlertAction *blockDevice = [UIAlertAction
                                 actionWithTitle:@"Attempt to Block Device"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action){
                                     [MCCommands runCommandOnIP:device.ipAddress];
                                     //NSLog(@"Harpy OUTPUT %@", output);
                                 }];
    
    UIAlertAction *stopBlock = [UIAlertAction
                                  actionWithTitle:@"Unblock Device"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action){
                                      [MCCommands stopCommandOnIP:device.ipAddress];
                                      //NSLog(@"Harpy OUTPUT %@", output);
                                  }];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:nil];
    
    [alert addAction:setNick];
    if (![device isLocalDevice] && [device macAddress]) {
        if ([self.defaults objectForKey:device.macAddress]) {
            [alert addAction:removeNick];
        }
    }
    if ([[MCCommands runningBlocksForIP:device.ipAddress] count]) {
        [alert addAction:stopBlock];
    } else {
        [alert addAction:blockDevice];
    }
/*#if TARGET_OS_IOS
    else if ([device isLocalDevice]){
        if ([self.defaults objectForKey:(__bridge NSString *)(MGCopyAnswer((__bridge CFStringRef)@"WifiAddress"))]) {
            [alert addAction:removeNick];
        }
    }
#endif*/
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

- (void)removeNickName: (MMDevice *)device {
    [self.defaults removeObjectForKey:device.macAddress];
    [self.defaults synchronize];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self->tableData indexOfObject:device] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setNickName: (MMDevice *)device {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Set Nickname"
                                                                              message: @"Input the new name for this device"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Nickname";
        textField.textColor = [UIColor blackColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        //DeviceCell *cell = [self.tableV cellForRowAtIndexPath:indexPath];
        NSString *checkString = [namefield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([checkString length] > 0){
            //cell.ipLabel.text = namefield.text;
            if (![device isLocalDevice] && [device macAddress]) {
                [self.defaults setObject:namefield.text forKey:device.macAddress];
                [self.defaults synchronize];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self->tableData indexOfObject:device] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
/*#if TARGET_OS_IOS
            else if ([device isLocalDevice]){
                [self.defaults setObject:namefield.text forKey:(__bridge NSString *)(MGCopyAnswer((__bridge CFStringRef)@"WifiAddress"))];
                [self.defaults synchronize];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self->tableData indexOfObject:device] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
#endif*/
            
        }
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}



#pragma mark Nav Buttons
- (IBAction)reloadPressed:(UIBarButtonItem *)sender {
    [tableData removeAllObjects];
    [self.tableView reloadData];
    [self startScanner];
}
@end
