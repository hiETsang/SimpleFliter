//
//  TestViewController.m
//  GPUImageDemo
//
//  Created by canoe on 2018/1/25.
//  Copyright © 2018年 canoe. All rights reserved.
//

#import "TestViewController.h"
#import "LVCaptureController.h"

@interface TestViewController ()

@property(nonatomic, strong) LVCaptureController *capture;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.capture = [[LVCaptureController alloc] initWithQuality:AVCaptureSessionPresetHigh position:LVCapturePositionRear enableRecording:YES];
    [self.capture attachToViewController:self withFrame:self.view.bounds];
    [self.capture capture:^(LVCaptureController *camera, UIImage *image, NSError *error) {
        
    }];
    [self.capture start];
    self.capture.tapToFocus = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
