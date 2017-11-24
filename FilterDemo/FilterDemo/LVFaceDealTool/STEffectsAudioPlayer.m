//
//  STEffectsAudioPlayer.m
//
//  Created by sluin on 2017/8/16.
//  Copyright © 2017年 SenseTime. All rights reserved.
//

#import "STEffectsAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface STEffectsAudioPlayer () <AVAudioPlayerDelegate>

@property (nonatomic , strong) AVAudioPlayer *audioPlayer;
@property (nonatomic , copy) NSString *strCurrentAudioName;

@end



@implementation STEffectsAudioPlayer


- (void)setFVolume:(float)fVolume
{
    _audioPlayer.volume = fVolume;
    _fVolume = fVolume;
}

- (BOOL)isPlaying
{
    return self.audioPlayer.isPlaying;
}

- (BOOL)loadSound:(NSData *)soundData name:(NSString *)strName
{
    [self.audioPlayer stop];
    
    NSError *error = nil;
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:soundData fileTypeHint:AVFileTypeMPEGLayer3 error:&error];
    
    if (error || !self.audioPlayer) {
        
        NSLog(@"STEffectsAudioPlayer loadSound failed : %@" , [error localizedDescription]);
        
        return NO;
    }
    
    self.audioPlayer.delegate = self;
    
    BOOL isReadyToPlay = [self.audioPlayer prepareToPlay];
    
    if (!isReadyToPlay) {
        
        NSLog(@"STEffectsAudioPlayer is not ready to play.");
    }else{
        
        self.strCurrentAudioName = strName;
    }
    
    return isReadyToPlay;
}

- (BOOL)playSound:(NSString *)strName loop:(int)iLoop
{
    if ([strName isEqualToString:self.strCurrentAudioName]) {
        
        int iNumberOfLoop = iLoop - 1;
        
        [self.audioPlayer setNumberOfLoops:iNumberOfLoop];
        [self.audioPlayer setCurrentTime:0];
        
        return [self.audioPlayer play];
    }else{
    
        return NO;
    }
}

- (void)stopSound:(NSString *)strName
{
    if ([strName isEqualToString:self.strCurrentAudioName]) {
        
        [self.audioPlayer stop];
    }
}

#pragma - mark -
#pragma - mark AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (self.delegate
        &&
        [self.delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:successfully:name:)])
    {
        [self.delegate audioPlayerDidFinishPlaying:self successfully:flag name:self.strCurrentAudioName];
    }
    
    NSLog(@"finish !!!! %d" , flag);
}


@end
