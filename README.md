# SimpleFliter
![image]([SimpleFliter/Image-2.gif at master · hiETsang/SimpleFliter · GitHub]https://github.com/hiETsang/SimpleFliter/blob/master/Image-2.gif)  ![image2](https://github.com/hiETsang/SimpleFliter/blob/master/Image.gif)

快速在项目中免费集成美颜和滤镜效果，两种美白以及多种滤镜效果的集成，基于GPUImage的再次封装自定义相机功能，注释清楚，内部还包含了系统人脸识别功能。

## 功能
* 对图片美白磨皮
* 对图片加滤镜
* 实时相机美白磨皮
* 实时相机加滤镜
* 简易切换滤镜
* 人脸识别
* 选择相机区域检测人脸
* 拍照
* 录制视频

## 使用
![image](https://github.com/hiETsang/SimpleFliter/blob/master/FEBFD875-C6F4-4FEF-BDA0-9CECBB62807D.png)
* 滤镜包括两种美白磨皮的滤镜以及十余种instagram风格滤镜。
* 相机使用
```javascript
- (void)viewDidLoad {
    [super viewDidLoad];
    self.capture = [[LVCaptureController alloc] initWithQuality:AVCaptureSessionPresetHigh position:LVCapturePositionFront enableRecording:YES];
    [self.capture attachToViewController:self withFrame:self.view.bounds];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.capture start];
}
```

如果对你有帮助可以顺手点个🌟！