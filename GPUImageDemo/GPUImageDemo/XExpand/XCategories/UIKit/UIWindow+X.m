//
//  UIWindow+X.m
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/23.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import "UIWindow+X.h"

@implementation UIWindow (X)

- (UIViewController*) topMostController
{
    UIViewController *topController = [self rootViewController];
    
    //  Getting topMost ViewController
    while ([topController presentedViewController])    topController = [topController presentedViewController];
    
    //  Returning topMost ViewController
    return topController;
}

- (UIViewController*)currentViewController;
{
    UIViewController *currentViewController = [self topMostController];
    
    while ([currentViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)currentViewController topViewController])
        currentViewController = [(UINavigationController*)currentViewController topViewController];
    
    return currentViewController;
}

@end
