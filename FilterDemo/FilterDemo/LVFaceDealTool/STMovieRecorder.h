#import <Foundation/Foundation.h>
#import <CoreMedia/CMFormatDescription.h>
#import <CoreMedia/CMSampleBuffer.h>

@protocol STMovieRecorderDelegate;

@interface STMovieRecorder : NSObject

- (instancetype)initWithURL:(NSURL *)URL delegate:(id<STMovieRecorderDelegate>)delegate callbackQueue:(dispatch_queue_t)queue;

- (void)addVideoTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription transform:(CGAffineTransform)transform settings:(NSDictionary *)videoSettings;

- (void)addAudioTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription settings:(NSDictionary *)audioSettings;

- (void)prepareToRecord;

- (void)appendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (void)appendVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer withPresentationTime:(CMTime)presentationTime;

- (void)appendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (void)finishRecording;

@end

@protocol STMovieRecorderDelegate <NSObject>

@required
- (void)movieRecorderDidFinishPreparing:(STMovieRecorder *)recorder;

- (void)movieRecorder:(STMovieRecorder *)recorder didFailWithError:(NSError *)error;

- (void)movieRecorderDidFinishRecording:(STMovieRecorder *)recorder;

@end
