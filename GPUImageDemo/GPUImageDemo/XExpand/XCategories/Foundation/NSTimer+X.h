//
//  NSTimer+X.h
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/25.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (X)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats;

+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats;

@end
