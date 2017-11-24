#import "STMovieRecorder.h"
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, STMovieRecorderStatus) {
	STMovieRecorderStatusIdle = 0,
	STMovieRecorderStatusPreparingToRecord,
	STMovieRecorderStatusRecording,
	STMovieRecorderStatusFinishingRecordingPart1,
	STMovieRecorderStatusFinishingRecordingPart2,
	STMovieRecorderStatusFinished,
	STMovieRecorderStatusFailed
};


@interface STMovieRecorder ()
{
    AVAssetWriter *_assetWriter;
	STMovieRecorderStatus _status;
	NSURL *_URL;
	
	BOOL _haveStartedSession;
    
	CMFormatDescriptionRef _audioTrackSourceFormatDescription;
    CMFormatDescriptionRef _videoTrackSourceFormatDescription;
    
	AVAssetWriterInput *_audioInput;
    AVAssetWriterInput *_videoInput;
    
    NSDictionary *_audioTrackSettings;
	NSDictionary *_videoTrackSettings;
    
	CGAffineTransform _videoTrackTransform;
	
	__weak id<STMovieRecorderDelegate> _delegate;
    
    dispatch_queue_t _writingQueue;
	dispatch_queue_t _delegateCallbackQueue;
}

@property (nonatomic, assign) BOOL allowWriteAudio;

@end

@implementation STMovieRecorder

#pragma mark -
#pragma mark API

- (instancetype)initWithURL:(NSURL *)URL delegate:(id<STMovieRecorderDelegate>)delegate callbackQueue:(dispatch_queue_t)queue {
	
	self = [super init];
	if (self) {
		_writingQueue = dispatch_queue_create("com.apple.sample.STMovierecorder.writing", DISPATCH_QUEUE_SERIAL);
		_videoTrackTransform = CGAffineTransformIdentity;
		_URL = URL;
		_delegate = delegate;
		_delegateCallbackQueue = queue;
        _allowWriteAudio = NO;
	}
	return self;
}

- (void)addVideoTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription transform:(CGAffineTransform)transform settings:(NSDictionary *)videoSettings {
	if (formatDescription == NULL) {
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"NULL format description" userInfo:nil];
		return;			
	}
	
	@synchronized(self) {
		if (_status != STMovieRecorderStatusIdle) {
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot add tracks while not idle" userInfo:nil];
			return;
		}
		
		if (_videoTrackSourceFormatDescription) {
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot add more than one video track" userInfo:nil];
			return;
		}
		
		_videoTrackSourceFormatDescription = (CMFormatDescriptionRef)CFRetain(formatDescription);
		_videoTrackTransform = transform;
		_videoTrackSettings = [videoSettings copy];
	}
}

- (void)addAudioTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription settings:(NSDictionary *)audioSettings {
	if (formatDescription == NULL) {
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"NULL format description" userInfo:nil];
		return;			
	}
	
	@synchronized(self)
	{
		if (_status != STMovieRecorderStatusIdle) {
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot add tracks while not idle" userInfo:nil];
			return;
		}
		
		if (_audioTrackSourceFormatDescription) {
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot add more than one audio track" userInfo:nil];
			return;
		}
		
		_audioTrackSourceFormatDescription = (CMFormatDescriptionRef)CFRetain(formatDescription);
		_audioTrackSettings = [audioSettings copy];
	}
}

- (void)prepareToRecord {
	@synchronized(self) {
		if (_status != STMovieRecorderStatusIdle) {
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Already prepared, cannot prepare again" userInfo:nil];
			return;
		}
		
		[self transitionToStatus:STMovieRecorderStatusPreparingToRecord error:nil];
	}
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        @autoreleasepool {
            
            NSError *error = nil;
            // AVAssetWriter will not write over an existing file.
            [[NSFileManager defaultManager] removeItemAtURL:_URL error:NULL];
            
            _assetWriter = [[AVAssetWriter alloc] initWithURL:_URL fileType:AVFileTypeQuickTimeMovie error:&error];
            
            // Create and add inputs
            if (!error && _videoTrackSourceFormatDescription) {
                [self setupAssetWriterVideoInputWithSourceFormatDescription:_videoTrackSourceFormatDescription transform:_videoTrackTransform settings:_videoTrackSettings error:&error];
            }
            
            if (!error && _audioTrackSourceFormatDescription) {
                [self setupAssetWriterAudioInputWithSourceFormatDescription:_audioTrackSourceFormatDescription settings:_audioTrackSettings error:&error];
            }
            
            if (!error) {
                BOOL success = [_assetWriter startWriting];
                if (!success) {
                    error = _assetWriter.error;
                }
            }
            
            @synchronized(self) {
                if (error) {
                    [self transitionToStatus:STMovieRecorderStatusFailed error:error];
                }
                else {
                    [self transitionToStatus:STMovieRecorderStatusRecording error:nil];
                }
            }
        }
    });
}

- (void)appendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
	[self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeVideo];
}

- (void)appendVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer withPresentationTime:(CMTime)presentationTime {
	CMSampleBufferRef sampleBuffer = NULL;
	
	CMSampleTimingInfo timingInfo = {0,};
	timingInfo.duration = kCMTimeInvalid;
	timingInfo.decodeTimeStamp = kCMTimeInvalid;
	timingInfo.presentationTimeStamp = presentationTime;
    
    CMVideoFormatDescriptionRef videoInfo = NULL;
    CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
	
	OSStatus err = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, true, NULL, NULL, videoInfo, &timingInfo, &sampleBuffer);
    
    CFRelease(videoInfo);
    
	if (sampleBuffer) {
		[self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeVideo];
		CFRelease(sampleBuffer);
	}
	else {
		NSString *exceptionReason = [NSString stringWithFormat:@"sample buffer create failed (%i)", (int)err];
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:exceptionReason userInfo:nil];
	}
}

- (void)appendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if (self.allowWriteAudio) {
        [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeAudio];
    }
}

- (void)finishRecording {
	@synchronized(self) {
		BOOL shouldFinishRecording = NO;
		switch (_status) {
			case STMovieRecorderStatusIdle:
			case STMovieRecorderStatusPreparingToRecord:
			case STMovieRecorderStatusFinishingRecordingPart1:
			case STMovieRecorderStatusFinishingRecordingPart2:
			case STMovieRecorderStatusFinished:
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not recording" userInfo:nil];
                break;
			case STMovieRecorderStatusFailed:
				// From the client's perspective the STMovie recorder can asynchronously transition to an error state as the result of an append.
				// Because of this we are lenient when finishRecording is called and we are in an error state.
				NSLog(@"Recording has failed, nothing to do");
				break;
			case STMovieRecorderStatusRecording:
				shouldFinishRecording = YES;
				break;
		}
		
		if (shouldFinishRecording) {
			[self transitionToStatus:STMovieRecorderStatusFinishingRecordingPart1 error:nil];
		}
		else {
			return;
		}
	}
	
	dispatch_async(_writingQueue, ^{
		
		@autoreleasepool {
			@synchronized(self) {
				// We may have transitioned to an error state as we appended inflight buffers. In that case there is nothing to do now.
				if (_status != STMovieRecorderStatusFinishingRecordingPart1) {
					return;
				}
				
				// It is not safe to call -[AVAssetWriter finishWriting*] concurrently with -[AVAssetWriterInput appendSampleBuffer:]
				// We transition to STMovieRecorderStatusFinishingRecordingPart2 while on _writingQueue, which guarantees that no more buffers will be appended.
				[self transitionToStatus:STMovieRecorderStatusFinishingRecordingPart2 error:nil];
			}

			[_assetWriter finishWritingWithCompletionHandler:^{
				@synchronized(self) {
					NSError *error = _assetWriter.error;
					if (error) {
						[self transitionToStatus:STMovieRecorderStatusFailed error:error];
					}
					else {
						[self transitionToStatus:STMovieRecorderStatusFinished error:nil];
					}
				}
			}];
		}
	});
}

- (void)dealloc {
	if (_audioTrackSourceFormatDescription) {
		CFRelease(_audioTrackSourceFormatDescription);
	}
	
	if (_videoTrackSourceFormatDescription) {
		CFRelease(_videoTrackSourceFormatDescription);
	}
}

#pragma mark -
#pragma mark Internal

- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer ofMediaType:(NSString *)mediaType {
	if (sampleBuffer == NULL) {
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"NULL sample buffer" userInfo:nil];
		return;			
	}
	
	@synchronized(self) {
		if (_status < STMovieRecorderStatusRecording) {
			@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not ready to record yet" userInfo:nil];
			return;	
		}
	}
	
	CFRetain(sampleBuffer);
	dispatch_async(_writingQueue, ^{
		
		@autoreleasepool {
			@synchronized(self) {
				// From the client's perspective the STMovie recorder can asynchronously transition to an error state as the result of an append.
				// Because of this we are lenient when samples are appended and we are no longer recording.
				// Instead of throwing an exception we just release the sample buffers and return.
				if (_status > STMovieRecorderStatusFinishingRecordingPart1) {
					CFRelease(sampleBuffer);
					return;
				}
			}
			
			if (!_haveStartedSession) {
				[_assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
				_haveStartedSession = YES;
			}
			
			AVAssetWriterInput *input = (mediaType == AVMediaTypeVideo) ? _videoInput : _audioInput;
			
			if (input.readyForMoreMediaData) {
				BOOL success = [input appendSampleBuffer:sampleBuffer];
				if (!success) {
					NSError *error = _assetWriter.error;
					@synchronized(self) {
						[self transitionToStatus:STMovieRecorderStatusFailed error:error];
					}
                } else {
                    self.allowWriteAudio = YES;
                }
			} else {
				NSLog(@"%@ input not ready for more media data, dropping buffer", mediaType);
			}
			CFRelease(sampleBuffer);
		}
	});
}

// call under @synchonized(self)
- (void)transitionToStatus:(STMovieRecorderStatus)newStatus error:(NSError *)error {
	BOOL shouldNotifyDelegate = NO;
	
#if DEBUG
	NSLog(@"STMovieRecorder state transition: %@->%@", [self stringForStatus:_status], [self stringForStatus:newStatus]);
#endif
	
	if (newStatus != _status) {
		// terminal states
		if ((newStatus == STMovieRecorderStatusFinished) || (newStatus == STMovieRecorderStatusFailed)) {
			shouldNotifyDelegate = YES;
			// make sure there are no more sample buffers in flight before we tear down the asset writer and inputs
			
			dispatch_async(_writingQueue, ^{
				[self teardownAssetWriterAndInputs];
				if (newStatus == STMovieRecorderStatusFailed) {
					[[NSFileManager defaultManager] removeItemAtURL:_URL error:NULL];
				}
			});

#if DEBUG
			if (error) {
				NSLog(@"STMovieRecorder error: %@, code: %i", error, (int)error.code);
			}
#endif
		}
		else if (newStatus == STMovieRecorderStatusRecording) {
			shouldNotifyDelegate = YES;
		}
		
		_status = newStatus;
	}

	if (shouldNotifyDelegate) {
		dispatch_async(_delegateCallbackQueue, ^{
			@autoreleasepool {
				switch (newStatus) {
					case STMovieRecorderStatusRecording:
						[_delegate movieRecorderDidFinishPreparing:self];
						break;
					case STMovieRecorderStatusFinished:
						[_delegate movieRecorderDidFinishRecording:self];
						break;
					case STMovieRecorderStatusFailed:
						[_delegate movieRecorder:self didFailWithError:error];
						break;
					default:
						NSAssert1(NO, @"Unexpected recording status (%i) for delegate callback", (int)newStatus);
						break;
				}
			}
		});
	}
}

#if DEBUG

- (NSString *)stringForStatus:(STMovieRecorderStatus)status {
	NSString *statusString = nil;
	
	switch (status) {
		case STMovieRecorderStatusIdle:
			statusString = @"Idle";
			break;
		case STMovieRecorderStatusPreparingToRecord:
			statusString = @"PreparingToRecord";
			break;
		case STMovieRecorderStatusRecording:
			statusString = @"Recording";
			break;
		case STMovieRecorderStatusFinishingRecordingPart1:
			statusString = @"FinishingRecordingPart1";
			break;
		case STMovieRecorderStatusFinishingRecordingPart2:
			statusString = @"FinishingRecordingPart2";
			break;
		case STMovieRecorderStatusFinished:
			statusString = @"Finished";
			break;
		case STMovieRecorderStatusFailed:
			statusString = @"Failed";
			break;
		default:
			statusString = @"Unknown";
			break;
	}
	return statusString;
	
}

#endif // LOG_STATUS_TRANSITIONS

- (BOOL)setupAssetWriterAudioInputWithSourceFormatDescription:(CMFormatDescriptionRef)audioFormatDescription settings:(NSDictionary *)audioSettings error:(NSError **)errorOut {
	if (!audioSettings) {
		NSLog(@"No audio settings provided, using default settings");
		audioSettings = @{ AVFormatIDKey : @(kAudioFormatMPEG4AAC) };
	}
	
	if ([_assetWriter canApplyOutputSettings:audioSettings forMediaType:AVMediaTypeAudio]) {
		_audioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:audioSettings sourceFormatHint:audioFormatDescription];
		_audioInput.expectsMediaDataInRealTime = YES;
		
		if ([_assetWriter canAddInput:_audioInput]) {
			[_assetWriter addInput:_audioInput];
		}
		else {
			if (errorOut) {
				*errorOut = [[self class] cannotSetupInputError];
			}
			return NO;
		}
	}
	else {
		if (errorOut) {
			*errorOut = [[self class] cannotSetupInputError];
		}
		return NO;
	}
	
	return YES;
}

- (BOOL)setupAssetWriterVideoInputWithSourceFormatDescription:(CMFormatDescriptionRef)videoFormatDescription transform:(CGAffineTransform)transform settings:(NSDictionary *)videoSettings error:(NSError **)errorOut {
	if (!videoSettings) {
		float bitsPerPixel;
		CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(videoFormatDescription);
		int numPixels = dimensions.width * dimensions.height;
		int bitsPerSecond;
	
		NSLog(@"No video settings provided, using default settings");
		
		// Assume that lower-than-SD resolutions are intended for streaming, and use a lower bitrate
		if (numPixels < (640 * 480)) {
			bitsPerPixel = 4.05; // This bitrate approximately matches the quality produced by AVCaptureSessionPresetMedium or Low.
		}
		else {
			bitsPerPixel = 10.1; // This bitrate approximately matches the quality produced by AVCaptureSessionPresetHigh.
		}
		
		bitsPerSecond = numPixels * bitsPerPixel;
		
		NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @(bitsPerSecond), 
												 AVVideoExpectedSourceFrameRateKey : @(30),
												 AVVideoMaxKeyFrameIntervalKey : @(30) };
		
		videoSettings = @{ AVVideoCodecKey : AVVideoCodecH264,
						   AVVideoWidthKey : @(dimensions.width),
						   AVVideoHeightKey : @(dimensions.height),
						   AVVideoCompressionPropertiesKey : compressionProperties };
	}
	
	if ([_assetWriter canApplyOutputSettings:videoSettings forMediaType:AVMediaTypeVideo]) {
		_videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoSettings sourceFormatHint:videoFormatDescription];
		_videoInput.expectsMediaDataInRealTime = YES;
		_videoInput.transform = transform;
		
		if ([_assetWriter canAddInput:_videoInput]) {
			[_assetWriter addInput:_videoInput];
		}
		else {
			if (errorOut) {
				*errorOut = [[self class] cannotSetupInputError];
			}
			return NO;
		}
	}
	else {
		if (errorOut) {
			*errorOut = [[self class] cannotSetupInputError];
		}
		return NO;
	}
	
	return YES;
}

+ (NSError *)cannotSetupInputError {
	NSString *localizedDescription = NSLocalizedString(@"Recording cannot be started", nil);
	NSString *localizedFailureReason = NSLocalizedString(@"Cannot setup asset writer input.", nil);
	NSDictionary *errorDict = @{ NSLocalizedDescriptionKey : localizedDescription,
								 NSLocalizedFailureReasonErrorKey : localizedFailureReason };
	return [NSError errorWithDomain:@"com.apple.dts.samplecode" code:0 userInfo:errorDict];
}

- (void)teardownAssetWriterAndInputs {
	_videoInput = nil;
	_audioInput = nil;
	_assetWriter = nil;
}

@end
