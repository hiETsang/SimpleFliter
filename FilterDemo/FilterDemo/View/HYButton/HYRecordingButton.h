//
//  HYRecordingButton.h
//  downLoadBtn
//
//  Created by 上官惠阳 on 2016/12/23.
//  Copyright © 2016年 上官惠阳. All rights reserved.
//

#import "HYCircleProgressView.h"
@class HYRecordingButton;

@protocol HYRecordingButtonDelegate <NSObject>
@optional
//录制视频开始
- (void)startRecordingAtRecordingButton:(HYRecordingButton *)recordingButton withProgress:(double)progress andPoint:(CGPoint)point;
//录制视频中
- (void)recordingButton:(HYRecordingButton *)recordingButton didUpdateProgress:(double)progress andPoint:(CGPoint)point;
//录制视频结束
- (void)finishedRecordingAtRecordingButton:(HYRecordingButton *)recordingButton withProgress:(double)progress andPoint:(CGPoint)point;
//手指移动
- (void)chagedRecordingAtRecordingButton:(HYRecordingButton *)recordingButton withProgress:(double)progress andPoint:(CGPoint)point;

//拍照
- (void)takingAtRecordingButton:(HYRecordingButton *)recordingButton;
@end
@interface HYRecordingButton : HYCircleProgressView
@property (nonatomic, weak) id <HYRecordingButtonDelegate> delegate;
@property (nonatomic, assign) IBInspectable CGFloat startButtonWidth;//里面按钮的长宽
@property (assign, nonatomic)NSTimeInterval recordTime;//录制的时间
@property (assign, nonatomic)NSTimeInterval currentRecordTime;//已经录制了多长时间
@property (assign,nonatomic)BOOL isClickedAmpl;//是否点击放大
@property (assign, nonatomic)BOOL onlyTap;//是否只能单击
@property(nonatomic, strong) UIColor *centerViewCorlor;//内部圆的颜色
@end
