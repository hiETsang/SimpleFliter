//
//  STAudioManager.h
//  SenseMeEffects
//
//  Created by Sunshine on 22/09/2017.
//  Copyright © 2017 SenseTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

//音频

@protocol STAudioManagerDelegate <NSObject>

// call back in callbackQueue
- (void)audioCaptureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

@end

@interface STAudioManager : NSObject

@property (nonatomic, weak) id<STAudioManagerDelegate> delegate;
@property (nonatomic, readonly) dispatch_queue_t callbackQueue;
@property (nonatomic, readonly) AVCaptureConnection *audioConnection;
@property (nonatomic, strong) NSDictionary *audioCompressingSettings;

- (void)startRunning;
- (void)stopRunning;

@end
