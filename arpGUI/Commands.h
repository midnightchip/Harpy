//
//  Commands.h
//  Harpy
//
//  Created by midnightchips on 1/4/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@interface Commands : NSObject 
+ (NSString *)runCommandWithOutput:(NSString *)command withArguments:(NSArray *)args errors:(BOOL)errors;
+ (void)runCommand:(NSString *)command withArguments:(NSArray *)args errors:(BOOL)errors completion:(void (^)(NSString *))completion;
+ (void)runCommandForever:(NSString *)command withArguments:(NSArray *)args errors:(BOOL)errors;
+ (void)runCommandOnIP:(NSString *)ip;
+ (void)stopCommandOnIP:(NSString *)ip;

+ (void)blockIPonPF:(NSString *)ip;
+ (void)enableIPonPF:(NSString *)ip;
+ (NSString *)getError;
+ (NSString *)getFullOutput;
+ (NSString *)getFullOutputNoGrep;

@end
