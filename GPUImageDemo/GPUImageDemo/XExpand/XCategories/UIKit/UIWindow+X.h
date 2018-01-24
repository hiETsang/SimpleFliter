//
//  UIWindow+X.h
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/23.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (X)

/*!
 @method topMostController
 
 @return Returns the current Top Most ViewController in hierarchy.
 */
- (UIViewController*) topMostController;

/*!
 @method currentViewController
 
 @return Returns the topViewController in stack of topMostController.
 */
- (UIViewController*)currentViewController;

@end
