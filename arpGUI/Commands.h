//
//  Commands.h
//  arpGUI
//
//  Created by midnightchips on 1/4/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Commands : NSObject 
+ (NSString *)runCommandWithOutput:(NSString *)command withArguments:(NSArray *)args errors:(BOOL)errors;
+ (void)runCommand:(NSString *)command withArguments:(NSArray *)args errors:(BOOL)errors completion:(void (^)(NSString *))completion;

@end
