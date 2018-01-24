//
//  UITextView+X.h
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/23.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (X)

@end


#pragma mark - 双指放大缩小字体
/*
 UITextView *textView = [[UITextView alloc] initWithFrame:self.view.frame];
 [self.view addSubview:textView];
 textView.zoomEnabled = YES;
 textView.minFontSize = 10;
 textView.maxFontSize = 40;
 */
@interface UITextView (XPinchZoom)

@property (nonatomic) CGFloat maxFontSize, minFontSize;

@property (nonatomic, getter = isZoomEnabled) BOOL zoomEnabled;

@end



#pragma mark - 带PlaceHolder
@interface UITextView (XPlaceHolder) <UITextViewDelegate>
//用于显示placeholder的textView
@property (nonatomic, strong) UITextView *placeHolderTextView;

- (void)addPlaceHolder:(NSString *)placeHolder;

@end


