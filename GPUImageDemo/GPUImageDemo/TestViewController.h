//
//  TestViewController.h
//  GPUImageDemo
//
//  Created by canoe on 2018/1/25.
//  Copyright © 2018年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestViewController : UIViewController

/** 点击拍照 */
@property (nonatomic,copy) void (^didFinishCapture)(UIImage *image);

@end
