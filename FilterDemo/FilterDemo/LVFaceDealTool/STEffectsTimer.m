//
//  STEffectsTimer.m
//  SenseMeEffects
//
//  Created by Sunshine on 05/09/2017.
//  Copyright © 2017 SenseTime. All rights reserved.
//

#import "STEffectsTimer.h"

@interface STEffectsTimer ()

@property (nonatomic, readwrite, strong) NSTimer *timer;

@property (nonatomic, readwrite, assign) int hours;
@property (nonatomic, readwrite, assign) int minutes;
@property (nonatomic, readwrite, assign) int seconds;

@end

@implementation STEffectsTimer

- (instancetype)init {
    self = [super init];
    if (self) {
        
        [self setDefaultValue];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(beginTiming) userInfo:nil repeats:YES];
        [self.timer setFireDate:[NSDate distantFuture]];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
    
    return self;
}

- (void)setDefaultValue {
    _hours = 0;
    _minutes = 0;
    _seconds = -1;
}

- (void)beginTiming {
    
    ++_seconds;
    
    if (_seconds == 60) {
        
        ++_minutes;
        _seconds = 0;
    }
    
    if (_minutes == 60) {
        
        ++_hours;
        _minutes = 0;
    }
    
    if ([self.delegate respondsToSelector:@selector(effectsTimer:currentRecordHour:minutes:seconds:)]) {
        
        [self.delegate effectsTimer:self currentRecordHour:_hours minutes:_minutes seconds:_seconds];
    }
    
}

- (void)start {
    [self.timer setFireDate:[NSDate date]];
}

- (void)stop {
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)reset {
    [self setDefaultValue];
}

- (void)invalidate {
    [self.timer invalidate];
    self.timer = nil;
}

@end
