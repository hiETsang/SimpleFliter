//
//  STEffectsTimer.h
//  SenseMeEffects
//
//  Created by Sunshine on 05/09/2017.
//  Copyright © 2017 SenseTime. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STEffectsTimer;

@protocol STEffectsTimerDelegate <NSObject>

- (void)effectsTimer:(STEffectsTimer *)timer currentRecordHour:(int)hours minutes:(int)minutes seconds:(int)seconds;

@end

@interface STEffectsTimer : NSObject

@property (nonatomic, readwrite, weak) id<STEffectsTimerDelegate> delegate;

- (instancetype)init NS_DESIGNATED_INITIALIZER;


- (void)start;
- (void)stop;
- (void)reset;

- (void)invalidate;

@end
