//
//  MCDataProvider.m
//  arpGUI
//
//  Created by midnightchips on 1/6/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

#import "MCDataProvider.h"

@implementation MCDataProvider

+ (MCDataProvider *)sharedProvider {
    static dispatch_once_t once;
    static MCDataProvider *sharedProvider;
    dispatch_once(&once, ^{
        sharedProvider = [MCDataProvider new];
    });
    return sharedProvider;
}

+ (NSMutableArray<NSString *> *)runningTasks {
    return [self.class sharedProvider].runningTasks;
}

+ (void)addTask:(NSString *)task {
    if (task)
        [[self.class sharedProvider].runningTasks addObject:task];
}

+ (void)removeTask:(NSString *)task {
    [[self.class sharedProvider].runningTasks removeObject:task];
}

+ (void)addTasks:(NSArray<NSString *> *)tasks {
    if (tasks)
        [[self.class sharedProvider].runningTasks addObjectsFromArray:tasks];
}

+ (void)removeTasks:(NSArray<NSString *> *)tasks {
    if (tasks)
        [[self.class sharedProvider].runningTasks removeObjectsInArray:tasks];
}

- (instancetype)init {
    if ((self = [super init])) {
        self.runningTasks = [NSMutableArray new];
    }
    
    return self;
}

@end
