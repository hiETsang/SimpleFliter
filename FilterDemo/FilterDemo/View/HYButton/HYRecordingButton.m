//
//  HYRecordingButton.m
//  downLoadBtn
//
//  Created by 上官惠阳 on 2016/12/23.
//  Copyright © 2016年 上官惠阳. All rights reserved.
//

#import "HYRecordingButton.h"
#import "NSLayoutConstraint+PKDownloadButton.h"
#import "UIImage+PKDownloadButton.h"

static const CGFloat kDefaultScale = 1.3;

@interface HYRecordingButton ()

@property (strong) NSTimer *timer;
@property (nonatomic, weak) UIButton *startButton;
@property (assign,nonatomic)double progressStep;
@property (assign,nonatomic) CGPoint myPoint;
@property (strong,nonatomic)UIView *centerView;
- (UIButton *)createStartButton;
- (NSArray *)createStartButtonConstraints;
- (void)updateAppearance;
- (HYCircleProgressView *)createCircleProgressView;

@end

static HYRecordingButton *CommonInit(HYRecordingButton *self) {
    if (self != nil) {
        self.progress = 0.0;
        self.recordTime = 10;
        UIButton *startButton = [self createStartButton];
        startButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:startButton];
        self.startButton = startButton;

        [self addConstraints:[self createStartButtonConstraints]];
        [self updateAppearance];
        [self setNeedsDisplay];

        //这样就成了个空心圆
        self.startButtonWidth = 0;
    }
    return self;
}
@implementation HYRecordingButton

#pragma mark - properties

- (void)setStartButtonWidth:(CGFloat)startButtonWidth {
    _startButtonWidth = startButtonWidth;

    [self.startButton setImage:[UIImage startImageOfSize:startButtonWidth
                                                   color:_centerViewCorlor?_centerViewCorlor:self.tintColor]
                     forState:UIControlStateNormal];

    [self setNeedsDisplay];
}

#pragma mark - initialization

- (instancetype)initWithCoder:(NSCoder *)decoder {
    return CommonInit([super initWithCoder:decoder]);
}

- (instancetype)initWithFrame:(CGRect)frame {
    return CommonInit([super initWithFrame:frame]);
}

#pragma mark - private methods

- (UIButton *)createStartButton {
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startButton.tintColor = [UIColor clearColor];
    _startButtonWidth = self.frame.size.width - 20;

    [startButton addTarget:self action:@selector(tapRecording) forControlEvents:UIControlEventTouchUpInside];

    if(self.onlyTap) return startButton;
    
//    [startButton addTarget:self action:@selector(<#selector#>) forControlEvents:UIControlEventTouchUpInside];
//    [startButton addTarget:self action:@selector(<#selector#>) forControlEvents:UIControlEventTouchDown];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedAction:)];
    longPress.minimumPressDuration = 0.5;
    [startButton addGestureRecognizer:longPress];

    return startButton;
}

-(void)setCenterViewCorlor:(UIColor *)centerViewCorlor
{
    _centerViewCorlor = centerViewCorlor;
    [self.startButton setImage:[UIImage startImageOfSize:_startButtonWidth color:_centerViewCorlor]
                      forState:UIControlStateNormal];
}

- (UIView *)centerView
{
    if (!_centerView) {
        _centerView = [[UIView alloc] initWithFrame:CGRectMake(9.5, 9.5, self.frame.size.width - 40, self.frame.size.width - 40)];
        _centerView.backgroundColor = _centerViewCorlor?_centerViewCorlor:[UIColor whiteColor];
        _centerView.layer.masksToBounds = YES;
        _centerView.layer.cornerRadius = (self.frame.size.width - 40)/2;
        [self addSubview:_centerView];
    }
    [self bringSubviewToFront:_centerView];
    return _centerView;
}
- (NSArray *)createStartButtonConstraints {
    NSMutableArray *constraints = [NSMutableArray array];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsForWrappedSubview:self.startButton
                                                                           withInsets:UIEdgeInsetsZero]];
    return constraints;
}

- (HYCircleProgressView *)createCircleProgressView {
    HYCircleProgressView *circleProgressView = [[HYCircleProgressView alloc] init];

    return circleProgressView;
}
#pragma mark - appearance

- (void)updateAppearance {

    [self.startButton setImage:[UIImage startImageOfSize:_startButtonWidth color:_centerViewCorlor?_centerViewCorlor:self.tintColor]
                     forState:UIControlStateNormal];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    [self updateAppearance];
}
#pragma mark method
- (void)longPressedAction:(UILongPressGestureRecognizer *)longPress
{
    CGPoint point = [longPress locationInView:((UIViewController *)_delegate).view];
    _myPoint = point;
    if ([longPress state] == UIGestureRecognizerStateBegan) {
        [self startRecording];
    }else if ([longPress state] == UIGestureRecognizerStateChanged) {
        if (_delegate && [_delegate respondsToSelector:@selector(chagedRecordingAtRecordingButton: withProgress: andPoint:)]) {
            [_delegate chagedRecordingAtRecordingButton:self withProgress:self.progress andPoint:_myPoint];
        }
    }else if ([longPress state] == UIGestureRecognizerStateEnded) {
        [self cancelRecording];
    }
}
- (void)startRecording {
    if(self.isClickedAmpl){
        [self scaleAnimation];
    }
    self.startButtonWidth = self.frame.size.width - 40;

    self.centerView.hidden = NO;

    self.tintColor = [UIColor greenColor];

    self.progress = 0.;

    self.progressStep = 0.008f;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.progressStep
                                                  target:self
                                                selector:@selector(increaseProgress)
                                                userInfo:nil
                                                 repeats:YES];
    
    if (_delegate && [_delegate respondsToSelector:@selector(startRecordingAtRecordingButton:withProgress:andPoint:)]) {
        [_delegate startRecordingAtRecordingButton:self withProgress:self.progress andPoint:_myPoint];
    }
}
- (void)cancelRecording {
    if (self.progress == 0) {
        return;
    }
    self.startButtonWidth = 0;

    self.centerView.hidden = YES;

    if(self.isClickedAmpl){
        self.transform = CGAffineTransformScale(self.transform,1/kDefaultScale,1/kDefaultScale);
        NSLog(@"x = %g",self.frame.size.width);
    }
    self.tintColor = [UIColor whiteColor];

    [self.timer invalidate];
    if (_delegate && [_delegate respondsToSelector:@selector(finishedRecordingAtRecordingButton:withProgress:andPoint:)]) {
        _currentRecordTime = self.recordTime * self.progress;
        [_delegate finishedRecordingAtRecordingButton:self withProgress:self.progress andPoint:_myPoint];
    }

    self.progress = 0;
}
- (void)increaseProgress {
    if (1. - self.progress > self.progressStep) {
        self.progress += 1.0/(self.recordTime/self.progressStep);
        if (_delegate && [_delegate respondsToSelector:@selector(recordingButton:didUpdateProgress:andPoint:)]) {
            [_delegate recordingButton:self didUpdateProgress:self.progress andPoint:_myPoint];
        }
    }else {
        self.progress = 1.;

        [self cancelRecording];
    }
}
- (void)tapRecording
{
    if (_delegate && [_delegate respondsToSelector:@selector(takingAtRecordingButton:)]) {
        [_delegate takingAtRecordingButton:self];
    }
}
#pragma mark 缩放动画
- (void)scaleAnimation
{
    [UIView animateWithDuration:1.5 animations:^{
        self.transform = CGAffineTransformScale(self.transform,kDefaultScale,kDefaultScale);
    }completion:^(BOOL finished){
        NSLog(@"x = %g",self.frame.size.width);
    }];
}
@end
