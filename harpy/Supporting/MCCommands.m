//
//  MCCommands.m
//  harpy
//
//  Created by midnightchips on 8/19/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

#import "MCCommands.h"
#import "RegExCategories.h"
//#import <UIKit/UIKit.h>

//Requires Network Commands dependency

@implementation MCCommands

+ (NSString *)rootCheck {
    NSTask *rootCheckTask = [[NSTask alloc] init];
    [rootCheckTask setLaunchPath:@"/usr/bin/whoami"];
    [MCCommands asRoot:rootCheckTask arguments:nil];
    NSPipe *outPipe = [NSPipe pipe];
    [rootCheckTask setStandardOutput:outPipe];
    
    [rootCheckTask launch];
    [rootCheckTask waitUntilExit];
    
    NSFileHandle *read = [outPipe fileHandleForReading];
    NSData *dataRead = [read readDataToEndOfFile];
    NSString *stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
    return stringRead;
    
}

+ (void)asRoot:(NSTask *)task arguments:(NSArray *)arguments {
    NSString *launchPath = task.launchPath;
    [task setLaunchPath:@"/usr/libexec/harpy/horizon"];
    NSArray *trueArguments = @[launchPath];
    if (arguments) {
        trueArguments = [trueArguments arrayByAddingObjectsFromArray:arguments];
    }
    NSLog(@"HARPY ARGS %@", trueArguments);
    [task setArguments:trueArguments];
}

+ (void)task:(NSTask *)task withArguments:(NSArray *)arguments {
    NSString *launchPath = task.launchPath;
    NSArray *trueArguments = @[launchPath];
    if (arguments) {
        trueArguments = [trueArguments arrayByAddingObjectsFromArray:arguments];
    }
    [task setArguments:trueArguments];
}

+ (NSString *)gatewayIP {
    NSString *output = resultsForCommand(@"/sbin/route -n get default");
    NSArray *outputSplit = [output componentsSeparatedByString:@"\n"];
    NSString *gateway;
    for (NSString *string in outputSplit) {
        if ([string rangeOfString:@"gateway:"].location != NSNotFound) {
            gateway = [[string componentsSeparatedByString:@":"] lastObject];
        }
    }
    gateway = [gateway stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return gateway;
}

+ (NSArray *)runningBlocksForIP:(NSString *)ip {
    NSString *output = resultsForCommand(@"/usr/libexec/harpy/horizon /bin/ps -u root");
    NSLog(@"HARPY RUNNING COMMANDS: %@", output);
    NSArray *outputSplit = [output componentsSeparatedByString:@"\n"];
    NSMutableArray *pids = [NSMutableArray new];
    for (NSString *string in outputSplit) {
        NSLog(@"HARPY CURRENT STRING: %@", string);
        if ([string rangeOfString:ip].location != NSNotFound) {
            NSMutableArray *stringSplit = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
            [stringSplit removeObject:@""];
            NSLog(@"HARPY ARRAY STUFF: %@", stringSplit);
            NSLog(@"HARPY STRING SPLIT: %@", stringSplit[1]);
            [pids addObject:stringSplit[1]];
        }
    }
    return pids;
}

+ (NSArray *)runningBlocksForArp {
    NSString *output = resultsForCommand(@"/usr/libexec/harpy/horizon /bin/ps -u root");
    NSLog(@"HARPY RUNNING COMMANDS: %@", output);
    NSArray *outputSplit = [output componentsSeparatedByString:@"\n"];
    NSMutableArray *ips = [NSMutableArray new];
    for (NSString *string in outputSplit) {
        NSLog(@"HARPY CURRENT STRING: %@", string);
        if ([string rangeOfString:@"arpspoof"].location != NSNotFound) {
            NSMutableArray *stringSplit = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
            [stringSplit removeObject:@""];
            NSLog(@"HARPY ARRAY STUFF: %@", stringSplit);
            NSLog(@"HARPY STRING SPLIT ARP: %@", stringSplit[8]);
            if (![ips containsObject:stringSplit[8]]) {
                [ips addObject:stringSplit[8]];
            }
        }
    }
    return ips;
}

+ (void)runCommandOnIP:(NSString *)ip {
    NSString *gateway = [MCCommands gatewayIP];
    NSArray *args = [[NSArray alloc] initWithObjects:@"-i", @"en0", @"-t", ip, gateway, nil];
    NSTask *runCommand = [[NSTask alloc] init];
    [runCommand setLaunchPath:@"/usr/libexec/harpy/arpspoof"];
    [MCCommands asRoot:runCommand arguments:args];
    NSPipe *pipe = [NSPipe pipe];
    [runCommand setStandardOutput:pipe];
    [runCommand launch];
}

+ (void)stopCommandOnIP:(NSString *)ip {
    NSArray *pids = [MCCommands runningBlocksForIP:ip];
    for (NSString *pid in pids) {
        NSString *killCommand = [NSString stringWithFormat:@"/usr/libexec/harpy/horizon /bin/kill %@", pid];
        NSString *killOutput = resultsForCommand(killCommand);
        NSLog(@"Output %@", killOutput);
    }
}

+ (void)checkRX {
    NSString *string = @"192.168.1.1";
    BOOL isMatch = [string isMatch:RX(@"(^127\\.)|(^192\\.168\\.)|(^10\\.)|(^172\\.1[6-9]\\.)|(^172\\.2[0-9]\\.)|(^172\\.3[0-1]\\.)|(^::1$)|(^[fF][cCdD])")];
    if (isMatch) {
        NSLog(@"Harpy IS MATCH");
    } else {
        NSLog(@"Harpy NO GOOD");
    }
}

+ (NSArray *)getPFOutput {
    NSString *command = [NSString stringWithFormat:@"/usr/libexec/harpy/horizon /usr/libexec/harpy/arp-scan -interface bridge100 --localnet --iabfile=/usr/libexec/harpy/ieee-iab.txt --ouifile=/usr/libexec/harpy/ieee-oui.txt"];
    //| grep -i '[0-9A-F]\\{2\\}\\(:[0-9A-F]\\{2\\}\\)\\{5\\}' | sort -V
    
    NSString *output = resultsForCommand(command);
    NSArray *split = [output componentsSeparatedByString:@"\n"];
    NSMutableArray *final = [NSMutableArray new];
    for (NSString *string in split) {
        if([string isMatch:RX(@"(^127\\.)|(^192\\.168\\.)|(^10\\.)|(^172\\.1[6-9]\\.)|(^172\\.2[0-9]\\.)|(^172\\.3[0-1]\\.)|(^::1$)|(^[fF][cCdD])")]) {
            [final addObject:string];
        }
    }
    
    /*UIAlertController * alert=[UIAlertController
                               
                               alertControllerWithTitle:@"Debug Output" message:[final componentsJoinedByString:@"\n"] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Ok"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action)
                                {}];
    
    [alert addAction:yesButton];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];*/
    
    return final;
}

+ (NSString *)getBrandFromMac: (NSString *)mac {
    NSArray *stringBreak = [mac componentsSeparatedByString:@":"];
    NSArray *macSearch = [NSArray arrayWithObjects: stringBreak[0], stringBreak[1], stringBreak[2], nil];
    NSString *queryString = [macSearch componentsJoinedByString:@"-"];
    return [[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]] valueForKey:queryString];
}

+ (void)blockOnPF:(NSString *)ip {
    //Purge
    runCommand(@"/usr/libexec/harpy/horizon /sbin/pfctl -d");
    //Set new rule
    NSString *commandString = [NSString stringWithFormat:@"/usr/libexec/harpy/horizon /sbin/pfctl -t blackListIP -T add %@", ip];
    runCommand(commandString);
    //load conf
    runCommand(@"/usr/libexec/harpy/horizon /sbin/pfctl -ef /usr/libexec/harpy/pf.conf");
}

+ (void)unblockOnPF:(NSString *)ip {
    //purge
    runCommand(@"/usr/libexec/harpy/horizon /sbin/pfctl -d");
    //Set new rule
    NSString *commandString = [NSString stringWithFormat:@"/usr/libexec/harpy/horizon /sbin/pfctl -t blackListIP -T delete %@", ip];
    runCommand(commandString);
    //load conf
    runCommand(@"/usr/libexec/harpy/horizon /sbin/pfctl -ef /usr/libexec/harpy/pf.conf");
}

+ (NSArray *)listBlockedPF {
    NSString *string = resultsForCommand(@"/usr/libexec/harpy/horizon /sbin/pfctl -t blackListIP -T show");
    NSMutableArray *ips = [NSMutableArray new];
    NSMutableArray<NSString *> *components = [[string componentsSeparatedByCharactersInSet:
                                               [NSCharacterSet newlineCharacterSet]]mutableCopy];
    //NSMutableArray *removeArray = [NSMutableArray new];
    for(NSString *string in components){
        if(!([string length] == 0)){
            NSString *cleaned = [string stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceCharacterSet]];
            if(![ips containsObject:cleaned] && ![cleaned isEqualToString:@"root"]){
                [ips addObject:cleaned];
            }
            
        }
    }
    return ips;
}



@end
