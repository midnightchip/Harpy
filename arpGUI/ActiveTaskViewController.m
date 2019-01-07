//
//  ActiveTaskViewController.m
//  arpGUI
//
//  Created by midnightchips on 1/6/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

#import "ActiveTaskViewController.h"

@interface ActiveTaskViewController ()
@property UIRefreshControl *refreshControl;
@property UIBarButtonItem *editButton;
@property UIBarButtonItem *doneButton;
@end

@implementation ActiveTaskViewController
{
    NSMutableArray *tableData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setToolbarItems:@[
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop actionHandler:^{
                                [self unblockSelectedIPs:[self.tableView indexPathsForSelectedRows]];
                                }]
                            
        ]];
    
    self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit actionHandler:^{
        [self.tableView setEditing:YES animated:YES];
        [self.navigationItem setRightBarButtonItem:self.doneButton animated:YES];
        [self.navigationController setToolbarHidden:NO animated:YES];
    }];
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone actionHandler:^{
        [self.tableView setEditing:NO animated:YES];
        [self.navigationItem setRightBarButtonItem:self.editButton animated:YES];
        [self.navigationController setToolbarHidden:YES animated:YES];
    }];
    
    self.navigationItem.rightBarButtonItem = self.editButton;
    self.navigationController.toolbar.barTintColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];
    self.navigationController.toolbar.backgroundColor = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:1.0];
    self.navigationController.toolbar.translucent = NO;
    
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor blackColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshTable)
                  forControlEvents:UIControlEventValueChanged];
    NSString *title = [NSString stringWithFormat:@"Checking for Devices..."];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                forKey:NSForegroundColorAttributeName];
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
    self.refreshControl.attributedTitle = attributedTitle;
    
    self.tableView.refreshControl = self.refreshControl;
    
    self.tableView.backgroundColor = [UIColor blackColor];
    self.navigationItem.title = @"Blocked Devices";
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self refreshTable];
}

-(void)refreshTable{
    [tableData removeAllObjects];
    NSString *processes = resultsForCommand(@"/usr/bin/crux /bin/ps -u root | grep /usr/local/bin/arpspoof | awk '{print $9}'");
    tableData = [self ipsFromArp:processes];
    //tableData = [[MCDataProvider runningTasks] copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    });
}

- (NSMutableArray *)ipsFromArp:(NSString *)string{
    NSMutableArray *components = [NSMutableArray new];
    components = [[string componentsSeparatedByString:@"\n"]mutableCopy];
    return components;
}

- (void)unblockSelectedIPs:(NSArray *)cellLocations{
    [self.tableView setEditing:NO animated:YES];
    [self.navigationItem setRightBarButtonItem:self.editButton animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    for (NSIndexPath *indexPath in cellLocations){
        [Commands stopCommandOnIP:tableData[indexPath.row]];
    }
    [self refreshTable];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *identifier = @"blockedDevices";
    tableView.backgroundColor = [UIColor blackColor];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        cell.backgroundColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.25]; //[UIColor redColor];
        [cell setSelectedBackgroundView:bgColorView];
    }
    
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{ //[fullInfo objectAtIndex:indexPath.row]
    if (tableView.isEditing) return;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unblock this Device?" message:[tableData objectAtIndex:indexPath.row] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *attackAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Commands stopCommandOnIP:[self->tableData objectAtIndex:indexPath.row]];
        });
        [self refreshTable];
             
            
    }];
    [alert addAction:okAction];
    [alert addAction:attackAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



/*
- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
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
