//
//  HarpyGlobal.m
//  harpy
//
//  Created by midnightchips on 8/20/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

#import "HarpyGlobal.h"
#import <VTAcknowledgementsViewController/VTAcknowledgementsViewController.h>


@implementation UIColor (Extended)
+ (UIColor *)tintColor {
    return [UIColor colorWithRed:0.00 green:0.48 blue:0.52 alpha:1.0];;
}
+ (UIColor *)cellSeparatorColor {
    if ([HarpyGlobal darkModeEnabled]) {
        return [UIColor colorWithRed:0.22 green:0.22 blue:0.23 alpha:1.0];
    }
    return [UIColor colorWithRed:0.78 green:0.78 blue:0.78 alpha:1.0];
}

@end

@implementation HarpyGlobal
+ (void)configureDarkMode {
    // Navigation bar
    [[UINavigationBar appearance] setTintColor:[UIColor tintColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:white}];
    // [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    if (@available(iOS 11.0, *)) {
        [[UINavigationBar appearance] setLargeTitleTextAttributes:@{NSForegroundColorAttributeName:white}];
    }
    [[UINavigationBar appearance] setBackgroundColor:nil];
    [[UINavigationBar appearance] setTranslucent:YES];
    
    // Status bar
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
#pragma clang diagnostic pop
    // Tab
    [[UITabBar appearance] setTintColor:[UIColor tintColor]];
    [[UITabBar appearance] setBackgroundColor:nil];
    [[UITabBar appearance] setBarTintColor:nil];
    [[UITabBar appearance] setTranslucent:YES];
    // [[UITabBar appearance] setShadowImage:[UIImage new]];
    [[UITabBar appearance] setBarStyle:UIBarStyleBlack];
    
    // Tables
    [[UITableView appearance] setBackgroundColor:tableColor];
    [[UITableView appearance] setSeparatorColor:[UIColor cellSeparatorColor]];
    [[UITableView appearance] setTintColor:[UIColor tintColor]];
    [[UITableViewCell appearance] setBackgroundColor:cellColor];
    
    [[UITextView appearance] setBackgroundColor:tableColor];
    [[UITextView appearance] setTextColor:white];
    [[UITextView appearance] setTintColor:[UIColor tintColor]];
    
    UIView *dark = [[UIView alloc] init];
    dark.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    [[UITableViewCell appearance] setSelectedBackgroundView:dark];
    [UILabel appearanceWhenContainedInInstancesOfClasses:@[[UITableViewCell class]]].textColor = white;
    
    // Keyboard
    [[UITextField appearance] setKeyboardAppearance:UIKeyboardAppearanceDark];
}

+ (void)configureLightMode {
    // Navigation bar
    [[UINavigationBar appearance] setTintColor:[UIColor tintColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    // [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    if (@available(iOS 11.0, *)) {
        [[UINavigationBar appearance] setLargeTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    }
    [[UINavigationBar appearance] setBarTintColor:nil];
    [[UINavigationBar appearance] setBackgroundColor:nil];
    [[UINavigationBar appearance] setTranslucent:YES];
    // Status bar
    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
#pragma clang diagnostic pop
    // Tab
    [[UITabBar appearance] setTintColor:[UIColor tintColor]];
    [[UITabBar appearance] setBackgroundColor:white];
    [[UITabBar appearance] setBarTintColor:nil];
    [[UITabBar appearance] setBarStyle:UIBarStyleDefault];
    [[UITabBar appearance] setTranslucent:YES];
    // [[UITabBar appearance] setShadowImage:[UIImage new]];
    
    // Tables
    [[UITableView appearance] setBackgroundColor:whiteTable];
    [[UITableView appearance] setTintColor:[UIColor tintColor]];
    [[UITableView appearance] setSeparatorColor:[UIColor cellSeparatorColor]];
    [[UITableViewCell appearance] setBackgroundColor:white];
    [[UITableViewCell appearance] setSelectedBackgroundView:nil];
    [UILabel appearanceWhenContainedInInstancesOfClasses:@[[UITableViewCell class]]].textColor = [UIColor blackColor];
    
    [[UITextView appearance] setBackgroundColor:whiteTable];
    [[UITextView appearance] setTextColor:[UIColor blackColor]];
    [[UITextView appearance] setTintColor:[UIColor tintColor]];
    
    // Keyboard
    [[UITextField appearance] setKeyboardAppearance:UIKeyboardAppearanceDefault];
    
    // Web views
}

+ (void)applyThemeSettings {
    if ([self darkModeEnabled]) {
        [self configureDarkMode];
    } else {
        [self configureLightMode];
    }
}

+ (BOOL)darkModeEnabled {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"darkMode"];
}

+ (void)refreshViews {
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        for (UIView *view in window.subviews) {
            [view removeFromSuperview];
            [window addSubview:view];
            CATransition *transition = [CATransition animation];
            transition.type = kCATransitionFade;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.fillMode = kCAFillModeForwards;
            transition.duration = 0.35;
            transition.subtype = kCATransitionFromTop;
            [view.layer addAnimation:transition forKey:nil];
        }
    }
}
@end
