//
//  SettingsTableViewController.m
//  harpy
//
//  Created by midnightchips on 8/20/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "CreditCell.h"
#import <VTAcknowledgementsViewController/VTAcknowledgementsViewController.h>
#import "HarpyGlobal.h"

@interface SettingsTableViewController ()

@end

typedef enum HarpyPrefOrder : NSUInteger {
    HarpyDark,
    HarpyCredit,
    HarpyLicenses
} HarpyPrefOrder;

enum HarpyCreditRows {
    HarpyMidnight,
    harpyPinpal,
    HarpyiTollmous,
    HarpyCreature
};

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"CreditCell" bundle:nil] forCellReuseIdentifier:@"CreditCell"];
    [self.navigationController.navigationBar setTranslucent:FALSE];
    [self.navigationController.navigationBar setBarTintColor:[HarpyGlobal darkModeEnabled] ? tableColor : whiteTable];
    NSString *pack = [NSString stringWithFormat:@"v%@", PACKAGE_VERSION];
    NSString *titleString = [NSString stringWithFormat:@"Harpy\n\t\t%@",pack];
    //self.versionLabel.text = titleString;
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:titleString];
    [text addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@".SFUIDisplay-Medium" size:36],
                          NSForegroundColorAttributeName:[UIColor whiteColor]}
                  range:NSMakeRange(0, 5)];
    [text addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@".SFUIDisplay-Medium" size:26],
                          NSForegroundColorAttributeName:[[UIColor whiteColor] colorWithAlphaComponent:0.7]}
                  range:[text.string rangeOfString:pack]];
    [self.versionLabel setAttributedText:text];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarStyle:[[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"] ? UIBarStyleBlack : UIBarStyleDefault];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY <= 0) {
        CGRect frame = self.bannerImage.frame;
        frame.size.height = self.tableView.tableHeaderView.frame.size.height - scrollView.contentOffset.y;
        frame.origin.y = self.tableView.tableHeaderView.frame.origin.y + scrollView.contentOffset.y;
        self.bannerImage.frame = frame;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case HarpyDark:
            return 1;
            break;
        case HarpyCredit:
            return 4;
            break;
        case HarpyLicenses:
            return 1;
        default:
            return 0;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == HarpyDark) {
        static NSString *cellIdentifier = @"darkModeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        UISwitch *enableSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        enableSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"];
        [enableSwitch addTarget:self action:@selector(toggleDark:) forControlEvents:UIControlEventValueChanged];
        [enableSwitch setOnTintColor:[UIColor tintColor]];
        [cell setAccessoryView:enableSwitch];
        [cell.textLabel setText:@"Enable Darkmode"];
        [cell.textLabel setTextColor:[[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"] ? [UIColor whiteColor] : [UIColor blackColor]];
        return cell;
    } else if (indexPath.section == HarpyCredit) {
        static NSString *cellIdentifier = @"CreditCell";
        
        CreditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[CreditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        NSString *text = nil;
        NSString *subText = nil;
        NSString *user= nil;
        switch (indexPath.row) {
            case HarpyMidnight:
                text = @"MidnightChips";
                subText = @"Developer";
                user = @"midnightchip";
                break;
            case harpyPinpal:
                text = @"PINPAL";
                subText = @"Designer";
                user = @"TPinpal";
                break;
            case HarpyiTollmous:
                text = @"iTollMouS";
                subText = @"Supporter and A12 Tester";
                user = @"iTollMous";
                break;
            case HarpyCreature:
                text = @"CreatureSurvive";
                subText = @"Mentor";
                user = @"CreatureSurvive";
            default:
                break;
        }
        [cell setTwitterImage:[NSString stringWithFormat:@"https://avatars.io/twitter/%@", user]];
        [cell setUserName:user];
        [cell.userLabel setText:text];
        [cell.roleLabel setText:subText];
        //[cell.imageView sd_setImageWithURL:[NSURL URLWithString:link]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        return cell;
    } else if (indexPath.section == HarpyLicenses){
        static NSString *cellIdentifier = @"licenses";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        [cell.textLabel setText:@"Acknowledgements"];
        [cell.textLabel setTextColor:[[NSUserDefaults standardUserDefaults] boolForKey:@"darkMode"] ? [UIColor whiteColor] : [UIColor blackColor]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        return cell;
    } else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case HarpyDark:
            [self getTappedSwitch:indexPath];
            break;
        case HarpyCredit:
            [self getUserCell:indexPath];
            break;
        case HarpyLicenses:
            [self pushToLicenses];
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
}

- (void)getUserCell:(NSIndexPath *)indexPath {
    if (indexPath.section == HarpyCredit) {
        CreditCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self openTwitterForUser:cell.userName];
    }
}

- (void)openTwitterForUser:(NSString*)username {
    UIApplication *app = [UIApplication sharedApplication];
    
    NSURL *twitterapp = [NSURL URLWithString:[NSString stringWithFormat:@"twitter:///user?screen_name=%@", username]];
    NSURL *tweetbot = [NSURL URLWithString:[NSString stringWithFormat:@"tweetbot:///user_profile/%@", username]];
    NSURL *twitterweb = [NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@", username]];
    
    
    if ([app canOpenURL:twitterapp])
        if (@available(iOS 10.0, *)) {
            [app openURL:twitterapp options:@{} completionHandler:nil];
        } else {
            [app openURL:twitterapp];
        }
    else if ([app canOpenURL:tweetbot])
        if (@available(iOS 10.0, *)) {
            [app openURL:tweetbot options:@{} completionHandler:nil];
        } else {
            [app openURL:tweetbot];// Fallback on earlier versions
        }
    else
        if (@available(iOS 10.0, *)) {
            [app openURL:twitterweb options:@{} completionHandler:nil];
        } else {
            [app openURL:twitterweb];// Fallback on earlier versions
        }
}

- (void)getTappedSwitch:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UISwitch *switcher = (UISwitch *)cell.accessoryView;
    [switcher setOn:!switcher.on animated:YES];
    if (indexPath.section == HarpyDark) {
        [self toggleDark:switcher];
    }
}

- (void)toggleDark:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UISwitch *switcher = (UISwitch *)sender;
    BOOL oled = [defaults boolForKey:@"darkMode"];
    oled = switcher.isOn;
    [defaults setBool:oled forKey:@"darkMode"];
    [defaults synchronize];
    //[ZBDevice hapticButton];
    [HarpyGlobal applyThemeSettings];
    [HarpyGlobal refreshViews];
    [self.navigationController.navigationBar setBarTintColor:[HarpyGlobal darkModeEnabled] ? tableColor : whiteTable];
    [self resetTable];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"toggleDark" object:self];
}

- (void)resetTable {
    [self.tableView reloadData];
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.fillMode = kCAFillModeForwards;
    transition.duration = 0.35;
    transition.subtype = kCATransitionFromTop;
    [self.view.layer addAnimation:transition forKey:nil];
    [self.navigationController.navigationBar.layer addAnimation:transition forKey:nil];
    [self.tableView.layer addAnimation:transition forKey:@"UITableViewReloadDataAnimationKey"];
}

- (void)setDarkModeEnabled:(BOOL)enabled {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:enabled forKey:@"darkMode"];
    [defaults synchronize];
}

- (void)pushToLicenses {
    VTAcknowledgementsViewController *viewController = [VTAcknowledgementsViewController acknowledgementsViewController];
    viewController.headerText = NSLocalizedString(@"Special thanks to these projects.", nil); // optional
    [self.navigationController pushViewController:viewController animated:YES];
}


@end
