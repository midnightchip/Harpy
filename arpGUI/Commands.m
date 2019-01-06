//
//  Commands.m
//  arpGUI
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



@end
