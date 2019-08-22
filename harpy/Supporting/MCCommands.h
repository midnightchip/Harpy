//
//  MCCommands.h
//  harpy
//
//  Created by midnightchips on 8/19/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSTask.h"
#import <spawn.h>
#import <signal.h>



NS_INLINE NSString *runCommandGivingResults(NSString *command) {
    FILE *proc = popen(command.UTF8String, "r");
    
    if (!proc) { return [NSString stringWithFormat:@"ERROR PROCESSING COMMAND: %@", command]; }
    
    int size = 1024;
    char data[size];
    
    NSMutableString *results = [NSMutableString string];
    
    while (fgets(data, size, proc) != NULL) {
        [results appendString:[NSString stringWithUTF8String:data]];
    }
    
    pclose(proc);
    
    return [NSString stringWithString:results];
}

#define resultsForCommand(...) runCommandGivingResults(__VA_ARGS__)

NS_INLINE void runCommand(NSString *command) {
    FILE *proc = popen(command.UTF8String, "r");
    pclose(proc);
}
#define runCommand(...) runCommand(__VA_ARGS__)


@interface MCCommands : NSObject
+ (void)asRoot:(NSTask *)task arguments:(NSArray *)arguments;
+ (void)task:(NSTask *)task withArguments:(NSArray *)arguments;
+ (void)runCommandOnIP:(NSString *)ip;
+ (void)stopCommandOnIP:(NSString *)ip;
+ (void)blockOnPF:(NSString *)ip;
+ (void)unblockOnPF:(NSString *)ip;
+ (void)checkRX;
+ (NSArray *)runningBlocksForIP:(NSString *)ip;
+ (NSString *)getBrandFromMac: (NSString *)mac;
+ (NSArray *)runningBlocksForArp;
+ (NSArray *)listBlockedPF;
+ (NSArray *)getPFOutput;
+ (NSString *)rootCheck;
+ (NSString *)gatewayIP;
@end
