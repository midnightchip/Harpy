//
//  Commands.m
//  Harpy
//
//  Created by midnightchips on 1/4/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//
@import UIKit;
#import "Commands.h"
#import <spawn.h>
#import <signal.h>
#import "NSTask.h"

#define CSAppAlertLog(format, ...) { UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ;", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:format, ##__VA_ARGS__] preferredStyle:UIAlertControllerStyleAlert]; [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]]; [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];}
@implementation Commands

+ (NSString *)runCommandWithOutput:(NSString *)command withArguments:(NSArray *)args errors:(BOOL)errors {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:command];
    [task setCurrentDirectoryPath:@"/"];
    [task setArguments:args];
    NSPipe *out = [NSPipe pipe];
    [task setStandardOutput:out];
    if(errors) [task setStandardError:out];
    [task launch];
    [task waitUntilExit];
    return [[NSMutableString alloc] initWithData:[[out fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
}

+ (void)runCommandOnIP:(NSString *)ip{
   NSOperationQueue *queue = [NSOperationQueue new];
    queue.qualityOfService = NSQualityOfServiceBackground;
    [queue addOperationWithBlock:^{
        NSString *gateway = resultsForCommand(@"/sbin/route -n get default | grep 'gateway' | awk '{print $2}'");
        NSString *command = [NSString stringWithFormat:@"/usr/bin/crux /usr/local/bin/arpspoof -i en0 -t %@ %@",ip, gateway];
        [Commands runCommandForever:@"/bin/bash" withArguments:@[@"-c", command] errors:NO];
    }];
    
}

+(void)stopCommandOnIP:(NSString *)ip{
    NSArray *components = [NSArray new];
    NSString *fullCommand = [NSString stringWithFormat:@"/usr/bin/crux /bin/ps -u root | grep %@ | awk '{print $2}'", ip];
    NSString *pids = resultsForCommand(fullCommand);
    components = [pids componentsSeparatedByString:@"\n"];
    if (components.count) {
        NSString *killPID = components[0];
        NSString *killCommand = [NSString stringWithFormat:@"/usr/bin/crux /bin/kill %@", killPID];
        NSString *killOutput = resultsForCommand(killCommand);
        NSLog(@"Output %@", killOutput);
        
    }
}

+ (void)runCommandForever:(NSString *)command withArguments:(NSArray *)args errors:(BOOL)errors {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:command];
    [task setCurrentDirectoryPath:@"/"];
    [task setArguments:args];
    NSPipe *out = [NSPipe pipe];
    [task setStandardOutput:out];
    if(errors) [task setStandardError:out];
    [task launch];
}

+ (void)runCommandAndExit:(NSString *)command withArguments:(NSArray *)args errors:(BOOL)errors {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:command];
    [task setCurrentDirectoryPath:@"/"];
    [task setArguments:args];
    NSPipe *out = [NSPipe pipe];
    [task setStandardOutput:out];
    if(errors) [task setStandardError:out];
    [task launch];
    [task waitUntilExit];
}


+ (void)runCommand:(NSString *)command withArguments:(NSArray *)args errors:(BOOL)errors completion:(void (^)(NSString *))completion {
    
    NSTask *task = [NSTask new];
    NSPipe *pipe = [NSPipe pipe];
    
    task.launchPath = command;
    task.arguments = args;
    task.currentDirectoryPath = @"/";
    task.standardInput = [NSFileHandle fileHandleWithNullDevice];
    task.standardOutput = pipe;
    task.standardError = errors ? pipe : nil;
    
    [task launch];
    [task waitUntilExit];
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    while (task.running) {}
    dispatch_semaphore_signal(sem);
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    completion([[NSMutableString alloc] initWithData:[[task.standardOutput fileHandleForReading] availableData] encoding:NSUTF8StringEncoding]);
    
}

+ (void)blockIPonPF:(NSString *)ip{
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.qualityOfService = NSQualityOfServiceBackground;
    [queue addOperationWithBlock:^{
        //NSString *gateway = resultsForCommand(@"/sbin/route -n get default | grep 'gateway' | awk '{print $2}'");
        [Commands runCommandAndExit:@"/bin/bash" withArguments:@[@"-c", @"/usr/bin/crux /sbin/pfctl -d"] errors:NO];
        NSString *command = [NSString stringWithFormat:@"/usr/bin/crux /sbin/pfctl -t blackIP -T add %@",ip];
        [Commands runCommandAndExit:@"/bin/bash" withArguments:@[@"-c", command] errors:NO];
        [Commands runCommandAndExit:@"/bin/bash" withArguments:@[@"-c", @"/usr/bin/crux /sbin/pfctl -ef /etc/pf.conf"] errors:NO];
        
    }];
    
}

+ (void)enableIPonPF:(NSString *)ip{
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.qualityOfService = NSQualityOfServiceBackground;
    [queue addOperationWithBlock:^{
        //NSString *gateway = resultsForCommand(@"/sbin/route -n get default | grep 'gateway' | awk '{print $2}'");
        [Commands runCommandAndExit:@"/bin/bash" withArguments:@[@"-c", @"/usr/bin/crux /sbin/pfctl -d"] errors:NO];
        NSString *command = [NSString stringWithFormat:@"/usr/bin/crux /sbin/pfctl -t blackIP -T delete %@",ip];
        [Commands runCommandAndExit:@"/bin/bash" withArguments:@[@"-c", command] errors:NO];
        [Commands runCommandAndExit:@"/bin/bash" withArguments:@[@"-c", @"/usr/bin/crux /sbin/pfctl -ef /etc/pf.conf"] errors:NO];
        
    }];
    
}





@end
