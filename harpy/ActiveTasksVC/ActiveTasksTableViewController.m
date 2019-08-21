//
//  ActiveTasksTableViewController.m
//  
//
//  Created by midnightchips on 8/19/19.
//

#import "ActiveTasksTableViewController.h"
#import "deviceCell.h"
#import "LANProperties.h"
#import "PingOperation.h"
#import "MMLANScanner.h"
#import "MACOperation.h"
#import "MacFinder.h"
#import "MMDevice.h"
#import "MCCommands.h"


@interface ActiveTasksTableViewController () {
    NSMutableArray *tableData;
    NSMutableArray *pfTasks;
}

@end

@implementation ActiveTasksTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    tableData = [NSMutableArray new];
    pfTasks = [NSMutableArray new];
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    self.tableView.rowHeight = 75;
    [self.tableView setEstimatedRowHeight:100];
    [self.tableView registerNib:[UINib nibWithNibName:@"deviceCell" bundle:nil] forCellReuseIdentifier:@"deviceCell"];
    [self getWifiBlocks];
    [self getPFBlocks];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getWifiBlocks];
    [self getPFBlocks];
}

- (void)getWifiBlocks {
    [tableData removeAllObjects];
    NSArray *ips = [MCCommands runningBlocksForArp];
    for (NSString *ip in ips) {
        MMDevice *device = [[MMDevice alloc] init];
        device.ipAddress = ip;
        device.macAddress = [[MacFinder ip2mac:ip] capitalizedString];
        device.hostname = [LANProperties getHostFromIPAddress:ip];
        device.brand = [MCCommands getBrandFromMac:device.macAddress];
        [tableData addObject:device];
    }
    [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    
}

- (void)getPFBlocks {
    [pfTasks removeAllObjects];
    NSArray *ips = [MCCommands listBlockedPF];
    for (NSString *ip in ips) {
        MMDevice *device = [[MMDevice alloc] init];
        device.ipAddress = ip;
        device.macAddress = [[MacFinder ip2mac:ip] capitalizedString];
        device.hostname = [LANProperties getHostFromIPAddress:ip];
        device.brand = [MCCommands getBrandFromMac:device.macAddress];
        [pfTasks addObject:device];
    }
    [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return tableData.count;
    } else {
        return pfTasks.count;
    }
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
    MMDevice *device;
    if (indexPath.section == 0) {
        device = [tableData objectAtIndex:indexPath.row];
    } else {
        device = [pfTasks objectAtIndex:indexPath.row];
    }
    
    if (device.macAddress) {
        cell.ipLabel.text = [self.defaults valueForKey:device.macAddress] ? [self.defaults valueForKey:device.macAddress] : device.ipAddress;
    } else {
        cell.ipLabel.text = device.ipAddress;
    }
    //cell.ipLabel.text = [self.defaults valueForKey:device.macAddress] ? [self.defaults valueForKey:device.macAddress] : device.ipAddress;
    cell.buildLabel.text = device.brand;
    cell.macLabel.text = device.macAddress;
    cell.hostLabel.text = device.hostname ? device.hostname : @"Unknown";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MMDevice *device;
    if (indexPath.section == 0) {
        device = [tableData objectAtIndex:indexPath.row];
    } else {
        device = [pfTasks objectAtIndex:indexPath.row];
    }
    NSString *deviceName;
    if (device.macAddress) {
        deviceName = [self.defaults valueForKey:device.macAddress] ? [self.defaults valueForKey:device.macAddress] : device.ipAddress;
    } else {
        deviceName = device.ipAddress;
    }
    
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:deviceName  message:@"Available Options" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *stopBlock = [UIAlertAction
                                actionWithTitle:@"Unblock Device"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action){
                                    if (indexPath.section == 0) {
                                        [MCCommands stopCommandOnIP:device.ipAddress];
                                        [self->tableData removeObject:device];
                                        [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                                    } else {
                                        [MCCommands unblockOnPF:device.ipAddress];
                                        [self->pfTasks removeObject:device];
                                        [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
                                    }
                                    
                                    //[self.tableView reloadData];
                                    //NSLog(@"Harpy OUTPUT %@", output);
                                }];
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                             handler:nil];
    
    [alert addAction:stopBlock];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

@end
