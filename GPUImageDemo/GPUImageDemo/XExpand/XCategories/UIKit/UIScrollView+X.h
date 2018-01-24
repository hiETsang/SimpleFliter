//
//  UIScrollView+X.h
//  SubscriptionBox
//
//  Created by canoe on 2018/1/22.
//  Copyright © 2018年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (X)

/**
 允许右滑返回和scrollView滑动并存
 */
@property(nonatomic, assign) BOOL allowPanGestureEventPass;

@end
