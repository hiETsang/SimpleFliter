//
//  STEffectsAudioPlayer.h
//
//  Created by sluin on 2017/8/16.
//  Copyright © 2017年 SenseTime. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STEffectsAudioPlayerDelegate;

@interface STEffectsAudioPlayer : NSObject

@property (nonatomic , assign) float fVolume; /* The volume for the sound. The nominal range is from 0.0 to 1.0. */
@property (nonatomic , readonly) BOOL isPlaying;
@property (nonatomic , readonly) NSString *strCurrentAudioName;

@property (nonatomic , weak) id<STEffectsAudioPlayerDelegate> delegate;

- (BOOL)loadSound:(NSData *)soundData name:(NSString *)strName;
- (BOOL)playSound:(NSString *)strName loop:(int)iLoop; /*  */
- (void)stopSound:(NSString *)strName;

@end

@protocol STEffectsAudioPlayerDelegate <NSObject>

- (void)audioPlayerDidFinishPlaying:(STEffectsAudioPlayer *)player successfully:(BOOL)flag name:(NSString *)strName;

@end
