//
//  PFTableViewController.m
//  harpy
//
//  Created by midnightchips on 8/19/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

#import "PFTableViewController.h"
#import "LANProperties.h"
#import "PingOperation.h"
#import "MMLANScanner.h"
#import "MACOperation.h"
#import "MacFinder.h"
#import "MMDevice.h"
#import "MCCommands.h"
#import "deviceCell.h"
#import "MobileGestalt.h"

@interface PFTableViewController () {
    NSMutableArray<MMDevice *> *tableData;
    NSDictionary *brandDict;
}

@end

@implementation PFTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.defaults = [NSUserDefaults standardUserDefaults];
    tableData = [NSMutableArray new];
    [self.tableView registerNib:[UINib nibWithNibName:@"deviceCell" bundle:nil] forCellReuseIdentifier:@"deviceCell"];
    self.tableView.rowHeight = 75;
    [self.tableView setEstimatedRowHeight:100];
    [self refreshPFDevices];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshPFDevices {
    NSLog(@"HARPY RUNNING PF THING");
    [self getDevices:[MCCommands getPFOutput]];
}


- (void)getDevices:(NSArray *)fullString{
    [tableData removeAllObjects];
    for(NSString *line in fullString){
        NSArray *components = [NSArray new];
        components = [line componentsSeparatedByString:@"\t"];
        if (components.count >= 3) {
            MMDevice *device = [[MMDevice alloc] init];
            device.ipAddress = components[0];
            device.macAddress = [components[1] uppercaseString];
            device.hostname = [LANProperties getHostFromIPAddress:components[0]];
            device.brand = [MCCommands getBrandFromMac:device.macAddress];
            [tableData addObject:device];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

-  (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
                                      [MCCommands blockOnPF:device.ipAddress];
                                      //NSLog(@"Harpy OUTPUT %@", output);
                                  }];
    
    UIAlertAction *stopBlock = [UIAlertAction
                                actionWithTitle:@"Unblock Device"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action){
                                    [MCCommands unblockOnPF:device.ipAddress];
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
    if ([[MCCommands listBlockedPF] containsObject:device.ipAddress]) {
        [alert addAction:stopBlock];
    } else {
        [alert addAction:blockDevice];
    }
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
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
        }
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)removeNickName: (MMDevice *)device {
    [self.defaults removeObjectForKey:device.macAddress];
    [self.defaults synchronize];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self->tableData indexOfObject:device] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

@end
