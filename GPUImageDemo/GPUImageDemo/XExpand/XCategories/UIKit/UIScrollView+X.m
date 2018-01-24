//
//  UIScrollView+X.m
//  SubscriptionBox
//
//  Created by canoe on 2018/1/22.
//  Copyright © 2018年 canoe. All rights reserved.
//

#import "UIScrollView+X.h"
#import "UIView+X.h"
#import <objc/runtime.h>

static const void *KallowPanGestureEventPass = @"allowPanGestureEventPass";

@implementation UIScrollView (X)

-(void)setAllowPanGestureEventPass:(BOOL)allowPanGestureEventPass
{
    objc_setAssociatedObject(self, KallowPanGestureEventPass, [NSNumber numberWithBool:allowPanGestureEventPass], OBJC_ASSOCIATION_ASSIGN);
    if (allowPanGestureEventPass) {
        [self.panGestureRecognizer requireGestureRecognizerToFail:[self screenEdgePanGestureRecognizer]];
    }
}

-(BOOL)allowPanGestureEventPass
{
    return [objc_getAssociatedObject(self, KallowPanGestureEventPass) boolValue];
}

-(UIScreenEdgePanGestureRecognizer *)screenEdgePanGestureRecognizer
{
    UIScreenEdgePanGestureRecognizer *screenEdgePanGestureRecognizer = nil;
    if ([self findNavigationController].view.gestureRecognizers.count > 0)
    {
        for (UIGestureRecognizer *recognizer in [self findNavigationController].view.gestureRecognizers)
        {
            if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]])
            {
                screenEdgePanGestureRecognizer = (UIScreenEdgePanGestureRecognizer *)recognizer;
                break;
            }
        }
    }
    NSAssert(screenEdgePanGestureRecognizer != nil, @"can't find scrollView's navigationController");
    return screenEdgePanGestureRecognizer;
}

/**
 当前View的navigationController
 */
-(UINavigationController *)findNavigationController
{
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            UIViewController *viewController = (UIViewController *)nextResponder;
            if (viewController.navigationController) {
                return viewController.navigationController;
            }else
            {
                return nil;
            }
        }
    }
    return nil;
}

@end
