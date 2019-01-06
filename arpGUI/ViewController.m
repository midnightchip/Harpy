//
//  ViewController.m
//  arpGUI
//
//  Created by midnightchips on 1/4/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

#import "ViewController.h"

#define CSAppAlertLog(format, ...) { UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ;", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:format, ##__VA_ARGS__] preferredStyle:UIAlertControllerStyleAlert]; [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]]; [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];}


@interface ViewController ()
@property UIRefreshControl *refreshControl;
@end

@implementation ViewController 
{
    NSMutableArray<NSString *> *tableData;
    NSMutableArray<NSString*> *fullInfo;
    NSMutableArray<NSString*> *ipAdress;
    NSMutableArray<NSString*> *macAddress;
    NSMutableArray<NSString*> *manName;
    NSMutableArray<NSString*> *hostName;
    NSArray<NSString *> *split;
    NSString *output;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //Reload View
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor blackColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshDevices)
                  forControlEvents:UIControlEventValueChanged];
    self.refreshControl.
    
    self.tableView.refreshControl = self.refreshControl;
    //Device Arrays
    ipAdress = [NSMutableArray new];
    macAddress = [NSMutableArray new];
    manName = [NSMutableArray new];
    hostName = [NSMutableArray new];
    self.view.backgroundColor = [UIColor blackColor];
}
-(void)viewDidAppear:(BOOL)animated{
    /*fullInfo = [[[self getFullOutput] componentsSeparatedByString:@"\n"]mutableCopy];
    tableData = [[self createArrays:fullInfo]mutableCopy];*/
    self.navigationItem.title = @"Getting Devices";
    [self refreshDevices];
}

- (NSArray<NSString *> *)createArrays:(NSArray *)fullString{
    //[fullString enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
    [ipAdress removeAllObjects];
    [macAddress removeAllObjects];
    [manName removeAllObjects];
    for(NSString *line in fullString){
        NSArray *components = [NSArray new];
        components = [line componentsSeparatedByString:@"\t"];
        if (components.count >= 3) {
            [self->ipAdress addObject:components[0]];
            [self->macAddress addObject:components[1]];
            [self->manName addObject:components[2]];
        }
        //[self->ipAdress addObject:[NSString stringWithFormat: @"%ld", (long)components.count]];
        
    }
    return ipAdress;
}

- (void)refreshDevices{
    [fullInfo removeAllObjects];
    [tableData removeAllObjects];
    fullInfo = [[[self getFullOutput] componentsSeparatedByString:@"\n"]mutableCopy];
    tableData = [[self createArrays:fullInfo]mutableCopy];
    [self.tableView reloadData];
    [[NSOperationQueue currentQueue] addOperationWithBlock:^{
    [self.refreshControl endRefreshing];
    }];
}

- (NSString *)getFullOutput{
    NSString *availableInterfaces = [Commands runCommandWithOutput:@"/bin/bash" withArguments:@[@"-c", @"/sbin/ifconfig | grep bridge100"] errors:NO];
    NSString *command = [NSString stringWithFormat:@"/usr/bin/crux /usr/local/bin/arp-scan -interface %@ --localnet | grep  '[0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}' | sort -V", [availableInterfaces length] > 0 ? @"bridge100" : @"en0"];
    
    self.navigationItem.title =  [NSString stringWithFormat:@"arpGUI: %@", [availableInterfaces length] > 0 ? @"HotSpot" : @"Wifi" ];
    
    return resultsForCommand(command);//(@"/usr/bin/crux /usr/local/bin/arp-scan -interface en0 --localnet | grep  '[0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}\\.[0-9]\\{1,3\\}' | sort -V");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    tableView.backgroundColor = [UIColor blackColor];
    
    /*UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }*/
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = @"Hey I work";
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor redColor];
    [cell setSelectedBackgroundView:bgColorView];
    return cell;
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([tableData count]){
        return [tableData count];
    }
    else{
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No devices connected. \n Please enable Wifi/Hotspot and pull to refresh.";
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont systemFontOfSize:20];
        [messageLabel sizeToFit];
        
        tableView.backgroundView = messageLabel;
        tableView.backgroundColor = [UIColor blackColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.navigationItem.title =  @"arpGUI: Unavailable";
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{ //[fullInfo objectAtIndex:indexPath.row]
    NSString *deviceInfo = [NSString stringWithFormat:@"%@ \n %@", [macAddress objectAtIndex:indexPath.row], [manName objectAtIndex:indexPath.row]];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[tableData objectAtIndex:indexPath.row] message:deviceInfo preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    <#code#>
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
    <#code#>
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    <#code#>
}

- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    <#code#>
}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    <#code#>
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    <#code#>
}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    <#code#>
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
    <#code#>
}

- (void)setNeedsFocusUpdate {
    <#code#>
}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
    <#code#>
}

- (void)updateFocusIfNeeded {
    <#code#>
}
*/
@end
