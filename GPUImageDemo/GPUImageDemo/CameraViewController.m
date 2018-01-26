//
//  CameraViewController.m
//  GPUImageDemo
//
//  Created by canoe on 2018/1/24.
//  Copyright © 2018年 canoe. All rights reserved.
//

#import "CameraViewController.h"
#import "GPUImageBeautifyFilter.h"
#import "GPUImage.h"
#import "UIImage+X.h"
#import "LFGPUImageBeautyFilter.h"

/***  当前屏幕宽度 */
#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
/***  当前屏幕高度 */
#define kScreenHeight  [[UIScreen mainScreen] bounds].size.height

@interface CameraViewController ()<GPUImageVideoCameraDelegate>
@property(nonatomic, strong) GPUImageStillCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *filterView;
@property (nonatomic, strong) UIButton *beautifyButton;

@property(nonatomic,assign) int mCount;
@property(nonatomic, assign) BOOL openDetection;//是否开启人脸检测

@property(nonatomic, strong) UIImageView *currentImageView;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetMedium cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.delegate = self;
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.filterView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    self.filterView.center = self.view.center;
    
    [self.view addSubview:self.filterView];
    [self.videoCamera addTarget:self.filterView];
    [self.videoCamera startCameraCapture];
    
    self.beautifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.beautifyButton.backgroundColor = [UIColor whiteColor];
    [self.beautifyButton setTitle:@"开启" forState:UIControlStateNormal];
    [self.beautifyButton setTitle:@"关闭" forState:UIControlStateSelected];
    [self.beautifyButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.beautifyButton addTarget:self action:@selector(beautify) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.beautifyButton];
    self.beautifyButton.frame = CGRectMake(200, 600, 100, 40);
    
    self.currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth/4, kScreenHeight/4)];
    [self.view addSubview:self.currentImageView];
    
    self.openDetection = YES;
    
}

- (void)beautify {
    if (self.beautifyButton.selected) {
        self.beautifyButton.selected = NO;
        [self.videoCamera removeAllTargets];
        LFGPUImageBeautyFilter *filter = [[LFGPUImageBeautyFilter alloc] init];
        [self.videoCamera addTarget:filter];
        [filter addTarget:self.filterView];
    }
    else {
        self.beautifyButton.selected = YES;
        [self.videoCamera removeAllTargets];
        GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
        [self.videoCamera addTarget:beautifyFilter];
        [beautifyFilter addTarget:self.filterView];
    }
}


#pragma mark - delegate
-(void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    self.mCount++;
    if (self.mCount % 5 == 0) {
        //每隔5帧检测一次人脸
        image = [self inputCIImageForDetector:image];
        self.mCount = 0;
    }
}


#pragma mark -- 检测捕捉到的图像进行人脸检测
-(CIImage *)inputCIImageForDetector:(CIImage *)image{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:CIDetectorAccuracyLow
                                                     forKey:CIDetectorAccuracy];
    CIDetector *detector=[CIDetector detectorOfType:CIDetectorTypeFace context:nil options:opts];
    //对图片进行裁剪
    CGAffineTransform transform = CGAffineTransformIdentity;
    if (self.videoCamera.cameraPosition == AVCaptureDevicePositionFront) {
        transform = CGAffineTransformScale(transform, -1, 1);
    }
    transform = CGAffineTransformTranslate(transform, 0, image.extent.size.height);
    transform = CGAffineTransformRotate(transform, -M_PI_2);
    
    CIImage * cropImage = [image imageByApplyingTransform:transform];//[self cropImage:image];iOS CIImageOrientation
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.currentImageView.image = [self uiImageConvertFromCIImage:cropImage];
    });
    
    //如果开启人脸检测
    if (self.openDetection) {
        NSArray *faceArray = [detector featuresInImage:cropImage
                                               options:nil];
        
        //没有检测到人脸 返回
        if (!faceArray.count) {
//            if ([self.faceDetectionDelegate respondsToSelector:@selector(faceDetectionSuccess:faceCount:)]) {
//                [self.faceDetectionDelegate faceDetectionSuccess:NO faceCount:0];
//            }
//            _faceDetectImage = nil;
//            _faceDetectRect = CGRectZero;
            NSLog(@"没有人脸 ---------> ");
            return image;
        }
        
//        if ([self.faceDetectionDelegate respondsToSelector:@selector(faceDetectionSuccess:faceCount:)]) {
//            [self.faceDetectionDelegate faceDetectionSuccess:YES faceCount:faceArray.count];
//        }
    
        if (faceArray.count == 1) {
//            if ([self.faceDetectionDelegate respondsToSelector:@selector(faceDetectionSuccessWithImage:)]) {
//                [self.faceDetectionDelegate faceDetectionSuccessWithImage:[self uiImageConvertFromCIImage:cropImage]];
//            }
            NSLog(@"！！！人脸");
        }
    }else
    {
//        if ([self.faceDetectionDelegate respondsToSelector:@selector(faceDetectionSuccessWithImage:)]) {
//            [self.faceDetectionDelegate faceDetectionSuccessWithImage:[self uiImageConvertFromCIImage:cropImage]];
//        }
    }
    return image;
}



-(UIImage *)uiImageConvertFromCIImage:(CIImage *)ciImage
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:ciImage fromRect:[ciImage extent]];
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return image;
}


//-(CIImage *)cropImage:(CIImage *)image
//{
//    if (CGRectEqualToRect(self.detectionRect, CGRectZero)) {
//        return image;
//    }
//
//    float scaleWidth = image.extent.size.width/self.view.width;
//
//    float scaleHeight = image.extent.size.height/(self.view.width * kScreenHeight/kScreenWidth);
//
//
//    CGRect newRect = CGRectZero;
//    newRect.origin.x = self.detectionRect.origin.x * scaleWidth;
//    newRect.origin.y = self.detectionRect.origin.y * scaleHeight;
//    newRect.size.width = self.detectionRect.size.width * scaleWidth;
//    newRect.size.height = self.detectionRect.size.height * scaleHeight;
//
//    CIContext *context = [CIContext contextWithOptions:nil];
//    CGImageRef ref = [context createCGImage:image fromRect:newRect];
//    CIImage *resultImage = [[CIImage alloc] initWithCGImage:ref];
//    CGImageRelease(ref);
//    return resultImage;
//}


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
