//
//  ViewController.m
//  GPUImageDemo
//
//  Created by canoe on 2017/11/24.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"
#import "FWApplyFilter.h"
#import "TZImagePickerController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *testImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;

@property(nonatomic, strong) UIImage *orginImage;
@property(nonatomic, strong) UIImage *currentImage;

@property(nonatomic, assign) NSInteger index;
@property(nonatomic, strong) NSArray *titleArray;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.orginImage = [UIImage imageNamed:@"test"];
    self.testImageView.image = self.orginImage;
    self.index = 0;
    
    self.titleArray = @[@"原图", @"经典LOMO", @"流年", @"HDR", @"碧波", @"上野", @"优格", @"彩虹瀑", @"云端", @"淡雅", @"粉红佳人", @"复古", @"候鸟", @"黑白", @"一九〇〇", @"古铜色", @"哥特风", @"移轴",@"我也不知道叫啥",@"狂拽酷炫"];
}

-(void)setIndex:(NSInteger)index
{
    _index = index;
    self.titleLabel.text = self.titleArray[index];
    switch (index) {
        case 0:
            self.currentImage = self.orginImage;
            break;
            
        case 1:
            self.currentImage= [FWApplyFilter applySketchFilter:self.orginImage];
            break;
            
        case 2:
            self.currentImage = [FWApplyFilter applySoftEleganceFilter:self.orginImage];
            break;
            
        case 3:
            self.currentImage =[FWApplyFilter applyMissetikateFilter:self.orginImage];
            break;
            
        case 4:
            self.currentImage =[FWApplyFilter applyNashvilleFilter:self.orginImage];
            break;
            
        case 5:
            self.currentImage =[FWApplyFilter applyLordKelvinFilter:self.orginImage];
            break;
            
        case 6:
            self.currentImage = [FWApplyFilter applyAmatorkaFilter:self.orginImage];
            break;
            
        case 7:
            self.currentImage = [FWApplyFilter applyRiseFilter:self.orginImage];
            break;
            
        case 8:
            self.currentImage= [FWApplyFilter applyHudsonFilter:self.orginImage];
            break;
            
        case 9:
            self.currentImage = [FWApplyFilter applyXproIIFilter:self.orginImage];
            break;
            
        case 10:
            self.currentImage =[FWApplyFilter apply1977Filter:self.orginImage];
            break;
            
        case 11:
            self.currentImage =[FWApplyFilter applyValenciaFilter:self.orginImage];
            break;
            
        case 12:
            self.currentImage =[FWApplyFilter applyWaldenFilter:self.orginImage];
            break;
            
        case 13:
            self.currentImage = [FWApplyFilter applyLomofiFilter:self.orginImage];
            break;
            
        case 14:
            self.currentImage = [FWApplyFilter applyInkwellFilter:self.orginImage];
            break;
            
        case 15:
            self.currentImage= [FWApplyFilter applySierraFilter:self.orginImage];
            break;
            
        case 16:
            self.currentImage = [FWApplyFilter applyEarlybirdFilter:self.orginImage];
            break;
            
        case 17:
            self.currentImage =[FWApplyFilter applySutroFilter:self.orginImage];
            break;
            
        case 18:
            self.currentImage = [FWApplyFilter applyToasterFilter:self.orginImage];
            break;
            
        case 19:
            self.currentImage =[FWApplyFilter applyBrannanFilter:self.orginImage];
            break;
            
        case 20:
            self.currentImage = [FWApplyFilter applyHefeFilter:self.orginImage];
            break;
}
    self.testImageView.image = self.currentImage;
}

#pragma mark - 点击操作

- (IBAction)previousButtonClick:(id)sender {
    if (self.index == 0) {
        self.index = self.titleArray.count - 1;
    }else
    {
        self.index --;
    }
}

- (IBAction)nextButtonClick:(id)sender {
    if (self.index == self.titleArray.count - 1) {
        self.index = 0;
    }else
    {
        self.index ++;
    }
}

- (IBAction)compare:(id)sender {
    self.testImageView.image = self.orginImage;
}

- (IBAction)cancelCompare:(id)sender {
    self.testImageView.image = self.currentImage;
}

- (IBAction)chooseImage:(id)sender {
    TZImagePickerController *tz = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    __weak __typeof(self)weakSelf = self;
    [tz setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        weakSelf.orginImage = [weakSelf fixOrientation:photos[0]];
        weakSelf.testImageView.image = weakSelf.orginImage;
            weakSelf.index = 0;
    }];
    [self presentViewController:tz animated:YES completion:nil];
}

- (IBAction)beatuyFace:(id)sender {
    self.currentImage = [FWApplyFilter applyBeautifyFilter:self.currentImage];
     self.testImageView.image = self.currentImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//修正图片方向
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


@end
