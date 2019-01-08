//
//  MCDataProvider.h
//  Harpy
//
//  Created by midnightchips on 1/6/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCDataProvider : NSObject

@property (nonatomic, strong) NSMutableArray<NSString *> *runningTasks;

+ (NSMutableArray *)runningTasks;

+ (void)addTask:(id)task ;
+ (void)removeTask:(id)task;
+ (void)addTasks:(NSArray *)tasks;
+ (void)removeTasks:(NSArray *)tasks;

@end
