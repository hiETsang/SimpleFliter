# SimpleFliter
![image](https://github.com/hiETsang/SimpleFliter/blob/master/image1.gif)  ![image2](https://github.com/hiETsang/SimpleFliter/blob/master/image2.gif)

快速在项目中集成美颜和滤镜效果，两种磨皮美白滤镜以及多种其他风格滤镜，基于GPUImage的再次封装自定义相机功能，内部还包含了系统人脸识别功能。

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
![image](https://github.com/hiETsang/SimpleFliter/blob/master/sample.png)
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
