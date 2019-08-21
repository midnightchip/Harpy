//
//  HarpyGlobal.h
//  harpy
//
//  Created by midnightchips on 8/20/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

#define white [UIColor whiteColor]
#define tableColor [UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0]
#define cellColor [UIColor colorWithRed:0.11 green:0.11 blue:0.114 alpha:1.0]
#define separator [UIColor colorWithRed:0.22 green:0.22 blue:0.23 alpha:1.0]
#define whiteTable [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1.0]

@interface UIColor (Extended)
+ (UIColor *)tintColor;
+ (UIColor *)cellSeparatorColor;
@end

@interface HarpyGlobal : NSObject
+ (void)applyThemeSettings;
+ (void)refreshViews;
+ (BOOL)darkModeEnabled;
@end
