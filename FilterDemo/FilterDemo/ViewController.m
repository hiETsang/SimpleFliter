//
//  ViewController.m
//  FilterDemo
//
//  Created by canoe on 2017/11/20.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import "ViewController.h"
#import "LVFaceDealHeader.h"

//view
#import "LVConfigEffectsView.h" //底部滤镜和贴纸View
#import "STGLPreview.h"         //openGL绘制显示的预览图层
#import "STTriggerView.h"       //提示摆手View
#import "HYRecordingButton.h"   //视频录制View

//model
#import "STCollectionViewDisplayModel.h"    //滤镜贴纸

//tools
#import "STMovieRecorder.h" //视频音频录制和合成
#import "STAudioManager.h"  //音频输出
#import "STEffectsAudioPlayer.h"    //音频播放
#import "STCamera.h"    //视频输出
#import "LVGetEffectsSourceTool.h"

#import "ImageViewController.h"

//是否显示脸部106个点
#define DRAW_FACE_KEY_POINTS 0
//是否允许240个点的监测
#define ENABLE_FACE_240_DETECT 0

typedef NS_ENUM(NSInteger, STWriterRecordingStatus){
    STWriterRecordingStatusIdle = 0,
    STWriterRecordingStatusStartingRecording,       //开始录制
    STWriterRecordingStatusRecording,               //录制中
    STWriterRecordingStatusStoppingRecording        //结束录制
};

@protocol STEffectsMessageDelegate <NSObject>

- (void)loadSound:(NSData *)soundData name:(NSString *)strName;
- (void)playSound:(NSString *)strName loop:(int)iLoop;
- (void)stopSound:(NSString *)strName;

@end


@interface STEffectsMessageManager : NSObject

@property (nonatomic, readwrite, weak) id<STEffectsMessageDelegate> delegate;

@end

@implementation STEffectsMessageManager

@end

STEffectsMessageManager *messageManager = nil;

@interface ViewController ()<STAudioManagerDelegate,STEffectsAudioPlayerDelegate,STEffectsMessageDelegate,STCameraDelegate,LVConfigEffectsViewDelegate,HYRecordingButtonDelegate,STMovieRecorderDelegate>
{
    st_handle_t _hSticker;  // sticker句柄  贴纸
    st_handle_t _hDetector; // detector句柄 人脸检测
    st_handle_t _hBeautify; // beautify句柄   美颜
    st_handle_t _hAttribute;// attribute句柄  人脸属性
    st_handle_t _hFilter;   // filter句柄     滤镜
    st_handle_t _hTracker;  // 通用物体跟踪句柄
    
    st_rect_t _rect;  // 通用物体位置
    float _result_score; //通用物体置信度
    
    st_mobile_106_t *_pFacesDetection; // 检测输出人脸信息数组
    st_mobile_106_t *_pFacesBeautify;  // 美颜输出人脸信息数组
    
    CVOpenGLESTextureCacheRef _cvTextureCache; //视频纹理缓存
    
    CVOpenGLESTextureRef _cvTextureOrigin;      //原始纹理
    CVOpenGLESTextureRef _cvTextureBeautify;    //美颜纹理
    CVOpenGLESTextureRef _cvTextureSticker;     //贴纸纹理
    CVOpenGLESTextureRef _cvTextureFilter;      //滤镜纹理
    
    CVPixelBufferRef _cvBeautifyBuffer;     //美颜缓存
    CVPixelBufferRef _cvStickerBuffer;      //贴纸缓存
    CVPixelBufferRef _cvFilterBuffer;       //滤镜缓存
    
    GLuint _textureOriginInput;             //原始纹理输入
    GLuint _textureBeautifyOutput;          //美颜纹理输出
    GLuint _textureStickerOutput;           //贴纸纹理输出
    GLuint _textureFilterOutput;            //滤镜纹理输出
    
}

//相机
@property(nonatomic, strong) STCamera *camera;
@property (strong, nonatomic) HYRecordingButton *recordingButton;
@property(nonatomic, strong) LVConfigEffectsView *configView;//特效美颜设置View
@property (nonatomic, strong) STTriggerView *triggerView;//请伸手掌提示

@property (nonatomic, readwrite, assign) BOOL needSnap;//需要拍照
@property (nonatomic, readwrite, assign) BOOL pauseOutput;//暂停输出
@property (nonatomic, readwrite, assign) BOOL isAppActive;//是否在前台

@property (nonatomic, readwrite, assign) BOOL specialEffectsContainerViewIsShow;//特效View是否显示
@property (nonatomic, readwrite, assign) BOOL beautyContainerViewIsShow;//美颜View是否显示
@property (nonatomic, readwrite, assign) BOOL settingViewIsShow;//设置View是否显示

@property (nonatomic, readwrite, assign) unsigned long long iCurrentAction;//当前的动作行为  0是人脸检测

@property (nonatomic, readwrite, assign) CGFloat imageWidth;//图片宽
@property (nonatomic, readwrite, assign) CGFloat imageHeight;//图片高

//bottom tab bar status
@property (nonatomic, readwrite, assign) BOOL bAttribute;//是否开启属性
@property (nonatomic, readwrite, assign) BOOL bBeauty;//是否美颜
@property (nonatomic, readwrite, assign) BOOL bSticker;//是否开启贴纸
@property (nonatomic, readwrite, assign) BOOL bTracker;//是否跟踪
@property (nonatomic, readwrite, assign) BOOL bFilter;//是否开启滤镜

@property (nonatomic, assign) BOOL isComparing;//是否是对比状态
@property (nonatomic, readwrite, assign) BOOL isNullSticker;//是否清除贴纸

//beauty value
@property (nonatomic, assign) float fSmoothStrength;//磨皮强度
@property (nonatomic, assign) float fReddenStrength;//红润强度
@property (nonatomic, assign) float fWhitenStrength;//美白强度
@property (nonatomic, assign) float fEnlargeEyeStrength;//大眼强度
@property (nonatomic, assign) float fShrinkFaceStrength;//瘦脸强度
@property (nonatomic, assign) float fShrinkJawStrength;//小脸强度
//filter value
@property (nonatomic, assign) float fFilterStrength;//滤镜强度

@property (nonatomic, strong) STGLPreview *glPreview;//预览图层
@property (nonatomic, strong) STAudioManager *audioManager;//音频管理
//@property (nonatomic, readwrite, strong) STCommonObjectContainerView *commonObjectContainerView;
//跟踪图层（可能是）
@property (nonatomic, strong) EAGLContext *glContext; //图像渲染上下文openGL
@property (nonatomic, strong) CIContext *ciContext;//核心绘图上下文

@property (nonatomic, assign) CGFloat scale;  //视频充满全屏的缩放比例
@property (nonatomic, assign) int margin;
@property (nonatomic, assign) double lastTimeAttrDetected;//最后监测属性的时间

@property (nonatomic, strong) NSMutableArray *arrPersons;//监测出的人脸数
@property (nonatomic, strong) NSMutableArray *arrPoints;//监测出的点

@property (nonatomic, readwrite, strong) STEffectsAudioPlayer *audioPlayer;//音频播放

//视频录制
@property (nonatomic, readwrite, strong) STMovieRecorder *stRecoder;//视频录制
@property (nonatomic, readwrite, strong) dispatch_queue_t callBackQueue;
@property (nonatomic, readwrite, assign, getter=isRecording) BOOL recording;
@property (nonatomic, readwrite, assign) STWriterRecordingStatus recordStatus;
@property (nonatomic, readwrite, strong) NSURL *recorderURL;
@property (nonatomic, readwrite, assign) CMFormatDescriptionRef outputVideoFormatDescription;
@property (nonatomic, readwrite, assign) CMFormatDescriptionRef outputAudioFormatDescription;
@property (nonatomic, readwrite, assign) double recordStartTime;

@end

@implementation ViewController

- (void)loadView {
    [super loadView];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    [self setDefaultValue];
}

-(void)setDefaultValue
{
    //默认开启美颜，其他的关闭
    self.bAttribute = NO;
    self.bBeauty = YES;
    self.bFilter = NO;
    self.bSticker = NO;
    self.bTracker = NO;
    
    self.isNullSticker = NO;//空贴纸
    
    self.fFilterStrength = 1.0;//滤镜的强度默认为1
    
    self.iCurrentAction = 0;//当前动作  0是人脸检测
    
    self.needSnap = NO;//是否需要拍照  点击拍照按钮会变成YES
    self.pauseOutput = NO;//暂停输出
    self.isAppActive = YES;//app是否活跃
    
    self.imageWidth = 720;
    self.imageHeight = 1280;
    
    self.recordStatus = STWriterRecordingStatusIdle;
    self.recording = NO;
    self.recorderURL = [[NSURL alloc] initFileURLWithPath:[NSString pathWithComponents:@[NSTemporaryDirectory(), @"Movie.MOV"]]];//视频输出路径
    
    self.outputAudioFormatDescription = nil; //音频输出描述
    self.outputVideoFormatDescription = nil; //视频输出描述
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.pauseOutput = NO;
    //开始音视频的会话
    [self.camera startRunning];
    [self.audioManager startRunning];
}

//页面消失时停止输出
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.pauseOutput = YES;
    [self.camera stopRunning];
    [self.audioManager stopRunning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置下方按钮
    [self createUI];
    
    //音频录制输出管理
    self.audioManager = [[STAudioManager alloc] init];
    self.audioManager.delegate = self;
    
    //音频播放
    self.audioPlayer = [[STEffectsAudioPlayer alloc] init];
    self.audioPlayer.delegate = self;
    
    //
    messageManager = [[STEffectsMessageManager alloc] init];
    messageManager.delegate = self;
    
    //监听app状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAudioInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
    
    //数据初始化
    [self initResource];
}

#pragma mark - 数据初始化
-(void)initResource
{
    //相机设置
    [self setupCameraAndPreView];
    
    self.ciContext = [CIContext contextWithEAGLContext:self.glContext options:@{kCIContextWorkingColorSpace : [NSNull null]}];
    
    [EAGLContext setCurrentContext:self.glContext];
    
    // 初始化结果文理及纹理缓存
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.glContext, NULL, &_cvTextureCache);
    
    if (err) {
        
        NSLog(@"CVOpenGLESTextureCacheCreate %d" , err);
    }
    //初始化返回的纹理openGL
    [self initResultTexture];
    //初始化美颜等参数
    [self resetSettings];
    
    ///ST_MOBILE：初始化句柄之前需要验证License
    if ([LVGetEffectsSourceTool checkActiveCode]) {
        ///ST_MOBILE：初始化相关的句柄
        [self setupHandle];
    }
    
    //是否暂停输出
    self.pauseOutput = NO;
}

//设置相机和显示图层
-(void)setupCameraAndPreView
{
    self.camera = [[STCamera alloc] init];
    self.camera.bOutputYUV = NO;
    self.camera.sessionPreset = AVCaptureSessionPreset1280x720;
    self.camera.delegate = self;
    
    //获取视频尺寸
    CGRect previewRect = [self.camera getZoomedRectWithRect:CGRectMake(0 , 0 , kScreenWidth, kScreenHeight) scaleToFit:NO];
    // 获取OpenGLES2.0 渲染环境
    self.glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    EAGLContext *previewContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:self.glContext.sharegroup];
    
    //初始化View用来显示预览界面
    self.glPreview = [[STGLPreview alloc] initWithFrame:previewRect context:previewContext];
    [self.view insertSubview:self.glPreview atIndex:0];
    
    //跟踪物体View  暂时不做
}

- (STTriggerView *)triggerView {
    
    if (!_triggerView) {
        
        _triggerView = [[STTriggerView alloc] init];
    }
    
    return _triggerView;
}

//底部按钮等
-(void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat itemWidth = 70;
    HYRecordingButton *recordCircleView;
    recordCircleView = [[HYRecordingButton alloc] initWithFrame:CGRectMake((kScreenWidth - itemWidth)/2,kScreenHeight - itemWidth - 55, itemWidth, itemWidth)];
    recordCircleView.tintColor = [UIColor whiteColor];
    recordCircleView.filledLineStyleOuter = NO;
    recordCircleView.isClickedAmpl = YES;
    recordCircleView.delegate = self;
    recordCircleView.onlyTap = NO;
    [self.view addSubview:recordCircleView];
    _recordingButton = recordCircleView;
    
    UIButton *compare = [UIButton buttonWithType:UIButtonTypeCustom];
    compare.frame = CGRectMake(20,[[UIScreen mainScreen] bounds].size.height - 120 , 60, 40);
    [compare setTitle:@"对比" forState:UIControlStateNormal];
    compare.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:compare];
    [compare addTarget:self action:@selector(compare:) forControlEvents:UIControlEventTouchDown];
    [compare addTarget:self action:@selector(cancelCompare:) forControlEvents:UIControlEventTouchUpInside];
    [compare addTarget:self action:@selector(cancelCompare:) forControlEvents:UIControlEventTouchDragExit];
    
    self.configView = [[LVConfigEffectsView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 200)];
    self.configView.delegate = self;
    [self.view addSubview:self.configView];
    
    [self.view addSubview:self.triggerView];
    
    //上下滑
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHideLastDatePhotoView:)];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:swipeUp];
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHideLastDatePhotoView:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeDown];
}

#pragma mark - 数据销毁
-(void)dealloc
{
    //取消贴纸和物体跟踪
    [self didSelectedRemoveAllEffectButton];
    
    self.pauseOutput = YES;
    [self.camera stopRunning];
    [self.audioManager stopRunning];
    
    dispatch_sync(self.camera.bufferQueue, ^{
        //销毁所有的句柄和图层
        [self releaseResources];
    });
    
    self.camera = nil;
}

- (void)releaseResources
{
    [EAGLContext setCurrentContext:self.glContext];
    
    if (_hSticker) {
        
        st_mobile_sticker_destroy(_hSticker);
        _hSticker = NULL;
    }
    if (_hBeautify) {
        
        st_mobile_beautify_destroy(_hBeautify);
        _hBeautify = NULL;
    }
    
    if (_hDetector) {
        
        st_mobile_human_action_destroy(_hDetector);
        _hDetector = NULL;
    }
    
    if (_hAttribute) {
        
        st_mobile_face_attribute_destroy(_hAttribute);
        _hAttribute = NULL;
    }
    
    if (_pFacesDetection) {
        
        free(_pFacesDetection);
        _pFacesDetection = NULL;
    }
    
    if (_pFacesBeautify) {
        
        free(_pFacesBeautify);
        _pFacesBeautify = NULL;
    }
    
    if (_hFilter) {
        
        st_mobile_gl_filter_destroy(_hFilter);
        _hFilter = NULL;
    }
    
    if (_hTracker) {
        st_mobile_object_tracker_destroy(_hTracker);
        _hTracker = NULL;
    }
    
    [self releaseResultTexture];
    
    if (_cvTextureCache) {
        
        CFRelease(_cvTextureCache);
        _cvTextureCache = NULL;
    }
    
    //    glFinish();
    
    [EAGLContext setCurrentContext:nil];
    
    self.glContext = nil;
    
    [self.glPreview removeFromSuperview];
    self.glPreview = nil;
    
//    [self.commonObjectContainerView removeFromSuperview];
//    self.commonObjectContainerView = nil;
    
    self.ciContext = nil;
}



#pragma mark - 初始化美颜滤镜等相关的句柄

- (void)setupHandle {
    //结果声明
    st_result_t iRet = ST_OK;
    
    [EAGLContext setCurrentContext:self.glContext];
    
    //初始化检测模块句柄
    NSString *strModelPath = [[NSBundle mainBundle] pathForResource:@"action5.0.0" ofType:@"model"];
    
    uint32_t config = 0;
#if ENABLE_FACE_240_DETECT
    
    config = ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_VIDEO | ST_MOBILE_ENABLE_FACE_EXTRA_DETECT | ST_MOBILE_ENABLE_EYEBALL_CENTER_DETECT | ST_MOBILE_ENABLE_EYEBALL_CONTOUR_DETECT;
    
#else
    
    config = ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_VIDEO;
    
#endif
    //初始化人体行为监测句柄
    TIMELOG(key);
    
    iRet = st_mobile_human_action_create(strModelPath.UTF8String,
                                         config,
                                         &_hDetector);
    
    TIMEPRINT(key,"human action create time:");
    
    if (ST_OK != iRet || !_hDetector) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"算法SDK初始化失败，可能是模型路径错误，SDK权限过期，与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    
    //    NSString *strEyeCenter = [[NSBundle mainBundle] pathForResource:@"M_Eyeball_Center" ofType:@"model"];
    //    NSString *strEyeContour = [[NSBundle mainBundle] pathForResource:@"M_Eyeball_Contour" ofType:@"model"];
    //
    //    iRet = st_mobile_human_action_add_sub_model(_hDetector, strEyeCenter.UTF8String);
    //
    //    if (iRet != ST_OK) {
    //        NSLog(@"st mobile human action add eye center model failed: %d", iRet);
    //    }
    //
    //    iRet = st_mobile_human_action_add_sub_model(_hDetector, strEyeContour.UTF8String);
    //
    //    if (iRet != ST_OK) {
    //        NSLog(@"st mobile human action add eye contour model failed: %d", iRet);
    //    }
    
    //初始化贴纸模块句柄 , 默认开始时无贴纸 , 所以第一个路径参数传空
    TIMELOG(keySticker);
    
    iRet = st_mobile_sticker_create(NULL , &_hSticker);
    
    TIMEPRINT(keySticker, "sticker create time:");
    
    if (ST_OK != iRet || !_hSticker) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"贴纸SDK初始化失败 , SDK权限过期，或者与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    //设置带声音贴纸的播放
    st_mobile_sticker_set_sound_callback_funcs(_hSticker, load_sound, play_sound, stop_sound);
    
    //初始化人脸属性模块句柄
    //    NSString *strAttriModelPath = [[NSBundle mainBundle] pathForResource:@"face_attribute_1.0.1" ofType:@"model"];
    //
    //    iRet = st_mobile_face_attribute_create(strAttriModelPath.UTF8String, &_hAttribute);
    //
    //    if (ST_OK != iRet || !_hAttribute) {
    //
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"属性SDK初始化失败，可能是模型路径错误，SDK权限过期，与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
    //
    //        [alert show];
    //    }
    
    
    //初始化美颜模块句柄
    iRet = st_mobile_beautify_create(&_hBeautify);
    
    if (ST_OK != iRet || !_hBeautify) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"美颜SDK初始化失败，可能是模型路径错误，SDK权限过期，与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
    }else{
        
        // 设置默认红润参数
        iRet = st_mobile_beautify_setparam(_hBeautify, ST_BEAUTIFY_REDDEN_STRENGTH, self.fReddenStrength);
        
        if (ST_OK != iRet){
            
            STLog(@"st_mobile_beautify_setparam REDDEN:error %d" ,iRet);
        }
        
        // 设置默认磨皮参数
        iRet = st_mobile_beautify_setparam(_hBeautify, ST_BEAUTIFY_SMOOTH_STRENGTH, self.fSmoothStrength);
        
        if (ST_OK != iRet) {
            
            STLog(@"st_mobile_beautify_setparam SMOOTH:error %d" ,iRet);
        }
        
        // 设置默认大眼参数
        iRet = st_mobile_beautify_setparam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, self.fEnlargeEyeStrength);
        
        if (ST_OK != iRet) {
            
            STLog(@"st_mobile_beautify_setparam ENLARGE_EYE:error %d" , iRet);
        }
        
        // 设置默认瘦脸参数
        iRet = st_mobile_beautify_setparam(_hBeautify, ST_BEAUTIFY_SHRINK_FACE_RATIO, self.fShrinkFaceStrength);
        
        if (ST_OK != iRet) {
            
            STLog(@"st_mobile_beautify_setparam SHRINK_FACE:error %d" , iRet);
        }
        
        // 设置小脸参数
        iRet = st_mobile_beautify_setparam(_hBeautify, ST_BEAUTIFY_SHRINK_JAW_RATIO, self.fShrinkJawStrength);
        
        if (ST_OK != iRet) {
            
            STLog(@"st_mobile_beautify_setparam SHRINK_JAW %d" , iRet);
        }
        
        // 设置美白参数
        iRet = st_mobile_beautify_setparam(_hBeautify, ST_BEAUTIFY_WHITEN_STRENGTH, self.fWhitenStrength);
        
        if (ST_OK != iRet) {
            
            STLog(@"st_mobile_beautify_setparam WHITEN:error %d" , iRet);
        }
    }
    
    // 初始化滤镜句柄
    iRet = st_mobile_gl_filter_create(&_hFilter);
    
    if (ST_OK != iRet || !_hFilter) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"滤镜SDK初始化失败，可能是SDK权限过期或与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    
    
    // 初始化通用物体追踪句柄
    iRet = st_mobile_object_tracker_create(&_hTracker);
    
    if (ST_OK != iRet || !_hTracker) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"通用物体跟踪SDK初始化失败，可能是SDK权限过期或与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
    }
}


#pragma mark - 按钮等操作
-(void)showOrHideLastDatePhotoView:(UISwipeGestureRecognizer *)swipe
{
    if (swipe.direction == UISwipeGestureRecognizerDirectionDown) {
        if (self.configView.frame.origin.y != kScreenHeight) {
            [UIView animateWithDuration:0.3 animations:^{
                self.configView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 200);
            }];
        }
    }
    if (swipe.direction == UISwipeGestureRecognizerDirectionUp) {
        if (self.configView.frame.origin.y == kScreenHeight) {
            [UIView animateWithDuration:0.3 animations:^{
                self.configView.frame = CGRectMake(0, kScreenHeight - 200, kScreenWidth, 200);
            }];
        }
    }
}

-(void)compare:(UIButton *)button
{
    self.isComparing = YES;
    self.recordingButton.userInteractionEnabled = NO;
}

-(void)cancelCompare:(UIButton *)button
{
    self.isComparing = NO;
    self.recordingButton.userInteractionEnabled = YES;
}

#pragma mark - 控制操作
//选中特效和贴纸
-(void)didSelectedEffectModel:(STCollectionViewDisplayModel *)model
{
    //物体跟踪
    if (model.modelType == STEffectsTypeObjectTrack) {
        
//        self.bTracker = YES;
//
//        if (self.commonObjectContainerView.currentCommonObjectView) {
//            [self.commonObjectContainerView.currentCommonObjectView removeFromSuperview];
//        }
//        _commonObjectViewSetted = NO;
//        _commonObjectViewAdded = NO;
//
//        UIImage *image = model.image;
//        [self.commonObjectContainerView addCommonObjectViewWithImage:image];
//        self.commonObjectContainerView.currentCommonObjectView.onFirst = YES;
//
    } else {
        
        self.pauseOutput = YES;
        
        self.bSticker = YES;
        
        if ([EAGLContext currentContext] != self.glContext) {
            
            [EAGLContext setCurrentContext:self.glContext];
        }
        
        self.triggerView.hidden = YES;
        
        // 需要保证 SDK 的线程安全 , 顺序调用.
        dispatch_sync(self.camera.bufferQueue, ^{
            
            if (self.isNullSticker) {
                self.isNullSticker = NO;
            }
            
            // 获取触发动作类型
            unsigned long long iAction = 0;
            
            const char *stickerPath = [model.strPath UTF8String];
            
            st_result_t iRet = st_mobile_sticker_change_package(_hSticker, stickerPath);
            
            if (iRet != ST_OK) {
                
                STLog(@"st_mobile_sticker_change_package error %d" , iRet);
            }else{
                
                // 需要在 st_mobile_sticker_change_package 之后调用才可以获取新素材包的 trigger action .
                iRet = st_mobile_sticker_get_trigger_action(_hSticker, &iAction);
                
                if (ST_OK != iRet) {
                    
                    STLog(@"st_mobile_sticker_get_trigger_action error %d" , iRet);
                    
                    return;
                }
                
                if (0 != iAction) {//有 trigger信息
                    if (CHECK_FLAG(iAction, ST_MOBILE_BROW_JUMP))
                        [self.triggerView showTriggerViewWithType:STTriggerTypeMoveEyebrow];
                    if (CHECK_FLAG(iAction, ST_MOBILE_EYE_BLINK))
                        [self.triggerView showTriggerViewWithType:STTriggerTypeBlink];
                    if (CHECK_FLAG(iAction, ST_MOBILE_HEAD_YAW))
                        [self.triggerView showTriggerViewWithType:STTriggerTypeTurnHead];
                    if (CHECK_FLAG(iAction, ST_MOBILE_HEAD_PITCH))
                        [self.triggerView showTriggerViewWithType:STTriggerTypeNod];
                    if (CHECK_FLAG(iAction, ST_MOBILE_MOUTH_AH))
                        [self.triggerView showTriggerViewWithType:STTriggerTypeOpenMouse];
                    if (CHECK_FLAG(iAction, ST_MOBILE_HAND_GOOD))
                        [self.triggerView showTriggerViewWithType:STTriggerTypeHandGood];
                    if (CHECK_FLAG(iAction, ST_MOBILE_HAND_PALM))
                        [self.triggerView showTriggerViewWithType:STTriggerTypeHandPalm];
                    if (CHECK_FLAG(iAction, ST_MOBILE_HAND_LOVE))
                        [self.triggerView showTriggerViewWithType:STTriggerTypeHandLove];
                    if (CHECK_FLAG(iAction, ST_MOBILE_HAND_HOLDUP))
                        [self.triggerView showTriggerViewWithType:STTriggerTypeHandHoldUp];
                    if (CHECK_FLAG(iAction, ST_MOBILE_HAND_CONGRATULATE))
                        [self.triggerView showTriggerViewWithType:STTriggerTypeHandCongratulate];
                    if (CHECK_FLAG(iAction, ST_MOBILE_HAND_FINGER_HEART))
                        [self.triggerView showTriggerViewWithType:STTriggerTypeHandFingerHeart];
                    
                    if (CHECK_FLAG(iAction, ST_MOBILE_HAND_FINGER_INDEX)) {
                        [self.triggerView showTriggerViewWithType:STTriggerTypeHandFingerIndex];
                    }
                    
                    if (CHECK_FLAG(iAction, ST_MOBILE_HAND_OK)) {
                        [self.triggerView showTriggerViewWithType:STTriggerTypeHandOK];
                    }
                    
                    if (CHECK_FLAG(iAction, ST_MOBILE_HAND_SCISSOR)) {
                        [self.triggerView showTriggerViewWithType:STTriggerTypeHandScissor];
                    }
                    
                    if (CHECK_FLAG(iAction, ST_MOBILE_HAND_PISTOL)) {
                        [self.triggerView showTriggerViewWithType:STTriggerTypeHandPistol];
                    }
                }
            }
            
            self.iCurrentAction = iAction;
        });
        
//        self.strStickerPath = model.strPath;
        self.pauseOutput = NO;
        
    }
}
//选中滤镜
-(void)didSelectedFilterModel:(STCollectionViewDisplayModel *)model
{
    self.bFilter = model.index > 0;
    
    // 切换滤镜
    if (_hFilter && self.bFilter) {
        
        self.pauseOutput = YES;
        
        // 切换滤镜不会修改强度 , 这里根据实际需求实现 , 这里重置为 0.5.
        self.fFilterStrength = 0.5;
        
        dispatch_sync(self.camera.bufferQueue, ^{
            
            if ([EAGLContext currentContext] != self.glContext) {
                
                [EAGLContext setCurrentContext:self.glContext];
            }
            
            st_result_t iRet = st_mobile_gl_filter_set_style(_hFilter, [model.strPath UTF8String]);
            
            if (ST_OK != iRet) {
                
                STLog(@"st_mobile_gl_filter_set_style %d" , iRet);
            }
            
            iRet = st_mobile_gl_filter_set_param(_hFilter, ST_GL_FILTER_STRENGTH, self.fFilterStrength);
            
            if (ST_OK != iRet) {
                
                STLog(@"st_mobile_gl_filter_set_param %d" , iRet);
            }
        });
    }
    
    self.pauseOutput = NO;
}
//选择清空所有滤镜
-(void)didSelectedRemoveAllEffectButton
{
    if (_hSticker) {
        self.isNullSticker = YES;
    }
    
    if (_hTracker) {
        
//        if (self.commonObjectContainerView.currentCommonObjectView) {
//
//            [self.commonObjectContainerView.currentCommonObjectView removeFromSuperview];
//        }
    }
    
    self.bTracker = NO;
}
//滑动滑杆
-(void)didSliderValueChanged:(UISlider *)sender
{
    if (_hBeautify) {
        
        st_result_t iRet = ST_OK;
        
        switch (sender.tag) {
                
            case STViewTagShrinkFaceSlider:
            {
                self.fShrinkFaceStrength = sender.value / 100;
                self.configView.thinFaceView.maxLabel.text = [NSString stringWithFormat:@"%d", (int)(sender.value)];
                iRet = st_mobile_beautify_setparam(_hBeautify, ST_BEAUTIFY_SHRINK_FACE_RATIO, self.fShrinkFaceStrength);
                if (ST_OK != iRet) {
                    STLog(@"ST_BEAUTIFY_SHRINK_FACE_RATIO: %d", iRet);
                }
            }
                break;
            case STViewTagEnlargeEyeSlider:
            {
                self.fEnlargeEyeStrength = sender.value / 100;
                self.configView.enlargeEyesView.maxLabel.text = [NSString stringWithFormat:@"%d", (int)(sender.value)];
                iRet = st_mobile_beautify_setparam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, self.fEnlargeEyeStrength);
                if (ST_OK != iRet) {
                    STLog(@"ST_BEAUTIFY_ENLARGE_EYE_RATIO: %d", iRet);
                }
            }
                break;
                
            case STViewTagShrinkJawSlider:
            {
                self.fShrinkJawStrength = sender.value / 100;
                self.configView.smallFaceView.maxLabel.text = [NSString stringWithFormat:@"%d", (int)(sender.value)];
                iRet = st_mobile_beautify_setparam(_hBeautify, ST_BEAUTIFY_SHRINK_JAW_RATIO, self.fShrinkJawStrength);
                if (ST_OK != iRet) {
                    STLog(@"ST_BEAUTIFY_SHRINK_JAW_RATIO: %d", iRet);
                }
            }
                break;
                
            case STViewTagSmoothSlider:
            {
                self.fSmoothStrength = sender.value / 100;
                self.configView.dermabrasionView.maxLabel.text = [NSString stringWithFormat:@"%d", (int)(sender.value)];
                iRet = st_mobile_beautify_setparam(_hBeautify, ST_BEAUTIFY_SMOOTH_STRENGTH, self.fSmoothStrength);
                if (ST_OK != iRet) {
                    STLog(@"ST_BEAUTIFY_SMOOTH_STRENGTH: %d", iRet);
                }
            }
                break;
                
            case STViewTagReddenSlider:
            {
                self.fReddenStrength = sender.value / 100;
                self.configView.ruddyView.maxLabel.text = [NSString stringWithFormat:@"%d", (int)(sender.value)];
                iRet = st_mobile_beautify_setparam(_hBeautify, ST_BEAUTIFY_REDDEN_STRENGTH, self.fReddenStrength);
                if (ST_OK != iRet) {
                    STLog(@"ST_BEAUTIFY_REDDEN_STRENGTH: %d", iRet);
                }
            }
                break;
                
            case STViewTagWhitenSlider:
            {
                self.fWhitenStrength = sender.value / 100;
                self.configView.whitenView.maxLabel.text = [NSString stringWithFormat:@"%d", (int)(sender.value)];
                iRet = st_mobile_beautify_setparam(_hBeautify, ST_BEAUTIFY_WHITEN_STRENGTH, self.fWhitenStrength);
                if (ST_OK != iRet) {
                    STLog(@"ST_BEAUTIFY_WHITEN_STRENGTH: %d", iRet);
                }
            }
                break;
                
        }
        
        
        if (self.fShrinkFaceStrength == 0 &&
            self.fEnlargeEyeStrength == 0 &&
            self.fShrinkJawStrength == 0 &&
            self.fSmoothStrength == 0 &&
            self.fReddenStrength == 0 &&
            self.fWhitenStrength == 0) {
            
            self.bBeauty = NO;
            
        } else {
            
            self.bBeauty = YES;
        }
        
    }
}

#pragma mark - HYRecordingButtonDelegate 拍照和录制
//录制视频开始
- (void)startRecordingAtRecordingButton:(HYRecordingButton *)recordingButton withProgress:(double)progress andPoint:(CGPoint)point
{
#pragma mark 这里需要加一个权限监测
    self.configView.hidden = YES;
    
    @synchronized (self) {
        
        if (self.recordStatus != STWriterRecordingStatusIdle) {
            
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Already recording" userInfo:nil];
            return;
        }
        
        self.recordStatus = STWriterRecordingStatusStartingRecording;
        
        _callBackQueue = dispatch_queue_create("com.sensetime.recordercallback", DISPATCH_QUEUE_SERIAL);
        
        STMovieRecorder *recorder = [[STMovieRecorder alloc] initWithURL:self.recorderURL delegate:self callbackQueue:_callBackQueue];
        //添加视频轨道
            [recorder addVideoTrackWithSourceFormatDescription:self.outputVideoFormatDescription transform:CGAffineTransformIdentity settings:self.camera.videoCompressingSettings];
        //添加音轨
            [recorder addAudioTrackWithSourceFormatDescription:self.outputAudioFormatDescription settings:self.audioManager.audioCompressingSettings];
        
        _stRecoder = recorder;
        
        self.recording = YES;
        //准备录制
        [_stRecoder prepareToRecord];
        
        self.recordStartTime = CFAbsoluteTimeGetCurrent();
        //    NSLog(@"st_effects_recored_time start: %f", self.recordStartTime);
        
    }
}

//录制视频中
- (void)recordingButton:(HYRecordingButton *)recordingButton didUpdateProgress:(double)progress andPoint:(CGPoint)point
{
    
}
//录制视频结束
- (void)finishedRecordingAtRecordingButton:(HYRecordingButton *)recordingButton withProgress:(double)progress andPoint:(CGPoint)point
{
    if (self.recording) {
        
        self.configView.hidden = NO;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self stopRecorder];
        });
    }
}

//拍照
- (void)takingAtRecordingButton:(HYRecordingButton *)recordingButton
{
    self.needSnap = YES;
}

#pragma mark - STMovieRecorderDelegate 视频录制回调

- (void)movieRecorder:(STMovieRecorder *)recorder didFailWithError:(NSError *)error {
    
    @synchronized (self) {
        
        self.stRecoder = nil;
        self.recording = NO;
        self.recordStatus = STWriterRecordingStatusIdle;
    }
    
    NSLog(@"movie recorder did fail with error: %@", error.localizedDescription);
}

- (void)movieRecorderDidFinishPreparing:(STMovieRecorder *)recorder {
    
    @synchronized(self) {
        if (_recordStatus != STWriterRecordingStatusStartingRecording) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Expected to be in StartingRecording state" userInfo:nil];
            return;
        }
        
        self.recordStatus = STWriterRecordingStatusRecording;
    }
}

- (void)movieRecorderDidFinishRecording:(STMovieRecorder *)recorder {
    
    @synchronized(self) {
        
        if (_recordStatus != STWriterRecordingStatusStoppingRecording) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Expected to be in StoppingRecording state" userInfo:nil];
            return;
        }
        
        self.recordStatus = STWriterRecordingStatusIdle;
    }
    
    _stRecoder = nil;
    
    self.recording = NO;
    
    double recordTime = CFAbsoluteTimeGetCurrent() - self.recordStartTime;
    //    NSLog(@"st_effects_recored_time end: %f", recordTime);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (recordTime < 2.0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"视频录制时间小于2s，请重新录制" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            
            [library writeVideoAtPathToSavedPhotosAlbum:_recorderURL completionBlock:^(NSURL *assetURL, NSError *error) {
                
                [[NSFileManager defaultManager] removeItemAtURL:_recorderURL error:NULL];
                
            }];
        }
    });
}

#pragma mark - STAudioManagerDelegate 音频的输出
- (void)audioCaptureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    self.outputAudioFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    //保证只有一个线程在执行
    @synchronized (self) {
        //如果正在录制，那么将音频SampleBuffer录制
        if (self.recordStatus == STWriterRecordingStatusRecording) {
            [self.stRecoder appendAudioSampleBuffer:sampleBuffer];
        }
    }
}

#pragma mark - STCameraDelegate 视频的输出
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    //应用未激活状态不做任何渲染
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    
    if (!self.isAppActive) {
        return;
    }
    
    if (self.pauseOutput) {
        
        return;
    }
    
    //get pts
    CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    double current = CFAbsoluteTimeGetCurrent();
    
    //    NSLog(@"st_effects_recored_time : %f", current);
    //停止录制
    if (self.recording && (current - self.recordStartTime) > 10) {
        //录制
        [self stopRecorder];
        
        self.recording = NO;

        dispatch_async(dispatch_get_main_queue(), ^{
            self.configView.hidden = NO;
        });
    }
    
    TIMELOG(frameCostKey);
    
    //获取每一帧图像信息
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    unsigned char* pBGRAImageIn = (unsigned char*)CVPixelBufferGetBaseAddress(pixelBuffer);
    double dCost = 0.0;
    double dStart = CFAbsoluteTimeGetCurrent();
    
    int iBytesPerRow = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
    int iWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    int iHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    
    size_t iTop , iBottom , iLeft , iRight;
    CVPixelBufferGetExtendedPixels(pixelBuffer, &iLeft, &iRight, &iTop, &iBottom);
    
    iWidth = iWidth + (int)iLeft + (int)iRight;
    iHeight = iHeight + (int)iTop + (int)iBottom;
    iBytesPerRow = iBytesPerRow + (int)iLeft + (int)iRight;
    
    _scale = MAX(kScreenHeight / iHeight, kScreenWidth / iWidth);
    _margin = (iWidth * _scale - kScreenWidth) / 2;
    
    //如果有需要旋转图像使人脸为正
    st_rotate_type stMobileRotate = [self getRotateType];
    
    st_result_t iRet = ST_OK;
    st_mobile_human_action_t detectResult;
    memset(&detectResult, 0, sizeof(st_mobile_human_action_t));
    st_mobile_106_t *pFacesFinal = NULL;
    int iFaceCount = 0;
    
    // 如果需要做属性,每隔一秒做一次属性
    double dTimeNow = CFAbsoluteTimeGetCurrent();
    BOOL isAttributeTime = (dTimeNow - self.lastTimeAttrDetected) >= 1.0;
    
    if (isAttributeTime) {
        
        self.lastTimeAttrDetected = dTimeNow;
    }
    
    ///ST_MOBILE 以下为通用物体跟踪部分
    /*if (_bTracker && _hTracker) {
        
        if (self.isCommonObjectViewAdded) {
            
            if (!self.isCommonObjectViewSetted) {
                
                iRet = st_mobile_object_tracker_set_target(_hTracker, pBGRAImageIn, ST_PIX_FMT_BGRA8888, iWidth, iHeight, iBytesPerRow, &_rect);
                
                if (iRet != ST_OK) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"设置通用物体位置失败" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
                    [alert show];
                    _rect.left = 0;
                    _rect.top = 0;
                    _rect.right = 0;
                    _rect.bottom = 0;
                }
                
                self.commonObjectViewSetted = YES;
            }
            
            if (self.isCommonObjectViewSetted) {
                
                TIMELOG(keyTracker);
                iRet = st_mobile_object_tracker_track(_hTracker, pBGRAImageIn, ST_PIX_FMT_BGRA8888, iWidth, iHeight, iBytesPerRow, &_rect, &_result_score);
                NSLog(@"tracking, result_score: %f,rect.left: %d, rect.top: %d, rect.right: %d, rect.bottom: %d", _result_score, _rect.left, _rect.top, _rect.right, _rect.bottom);
                TIMEPRINT(keyTracker, "st_mobile_object_tracker_track time:");
                
                if (iRet != ST_OK) {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"通用物体跟踪失败" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
                    [alert show];
                    
                    _rect.left = 0;
                    _rect.top = 0;
                    _rect.right = 0;
                    _rect.bottom = 0;
                }
                
                CGRect rectDisplay = CGRectMake(_rect.left * _scale - _margin,
                                                _rect.top * _scale,
                                                _rect.right * _scale - _rect.left * _scale,
                                                _rect.bottom * _scale - _rect.top * _scale);
                CGPoint center = CGPointMake(rectDisplay.origin.x + rectDisplay.size.width / 2,
                                             rectDisplay.origin.y + rectDisplay.size.height / 2);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (self.commonObjectContainerView.currentCommonObjectView.isOnFirst) {
                        //用作同步,防止再次改变currentCommonObjectView的位置
                        
                    } else if ((_rect.left == 0 && _rect.top == 0 && _rect.right == 0 && _rect.bottom == 0) || _result_score < 0.1) {
                        
                        [self.commonObjectContainerView.currentCommonObjectView removeFromSuperview];
                        [self.collectionView clearSelectedStateExcept:STEffectsTypeNone];
                        [self.collectionView reloadData];
                        
                        self.bTracker = NO;
                        
                    } else {
                        self.commonObjectContainerView.currentCommonObjectView.center = center;
                    }
                });
            }
        }
    }
     */
    
    ///ST_MOBILE 人脸信息检测部分
    if (_hDetector) {
        
        BOOL needFaceDetection = ((self.fEnlargeEyeStrength > 0 || self.fShrinkFaceStrength > 0 || self.fShrinkJawStrength > 0) && _hBeautify) || (self.bAttribute && isAttributeTime && _hAttribute);
        
        unsigned long long iConfig = self.iCurrentAction;
        
        if (needFaceDetection) {
            iConfig = self.iCurrentAction | ST_MOBILE_FACE_DETECT;
        }
#if ENABLE_FACE_240_DETECT
        
        iConfig = self.iCurrentAction | ST_MOBILE_FACE_DETECT | ST_MOBILE_DETECT_EXTRA_FACE_POINTS | ST_MOBILE_DETECT_EYEBALL_CENTER | ST_MOBILE_DETECT_EYEBALL_CONTOUR;
        
#endif
        
        if (iConfig > 0) {
            
            TIMELOG(keyDetect);
            
            iRet = st_mobile_human_action_detect(_hDetector,
                                                 pBGRAImageIn,
                                                 ST_PIX_FMT_BGRA8888,
                                                 iWidth,
                                                 iHeight,
                                                 iBytesPerRow,
                                                 stMobileRotate,
                                                 iConfig,
                                                 &detectResult);
            
            TIMEPRINT(keyDetect, "st_mobile_human_action_detect time:");
            
            if(iRet == ST_OK) {
                
                _arrPersons = [NSMutableArray array];
                _arrPoints = [NSMutableArray array];
                
                iFaceCount = detectResult.face_count;
                
                _pFacesDetection = (st_mobile_106_t *)malloc(sizeof(st_mobile_106_t) * iFaceCount);
                _pFacesBeautify = (st_mobile_106_t *)malloc(sizeof(st_mobile_106_t) * iFaceCount);
                memset(_pFacesDetection, 0, sizeof(st_mobile_106_t) * iFaceCount);
                memset(_pFacesBeautify, 0, sizeof(st_mobile_106_t) * iFaceCount);
                
                //构造人脸信息数组
                for (int i = 0; i < iFaceCount; i++) {
                    
                    _pFacesDetection[i] = detectResult.p_faces[i].face106;
#if DRAW_FACE_KEY_POINTS
                    [self getFaceKeyPoints:detectResult atIndex:i];
#endif
                }
#if DRAW_FACE_KEY_POINTS
                [self showFaceKeyPoints:iFaceCount];
#endif
                pFacesFinal = _pFacesDetection;
            }else{
                
                STLog(@"st_mobile_human_action_detect failed %d" , iRet);
                
                goto unlockBufferAndFlushCache;
            }
        }
    }
    
    
    
    //    ///ST_MOBILE 以下为attribute部分 , 当人脸数大于零且人脸信息数组不为空时每秒做一次属性检测.
    //    if (self.bAttribute && _hAttribute) {
    //
    //        if (iFaceCount > 0 && _pFacesDetection && isAttributeTime) {
    //
    //            TIMELOG(attributeKey);
    //
    //            st_mobile_attribute_t *pAttrArray;
    //
    //            // attribute detect
    //            iRet = st_mobile_face_attribute_detect(_hAttribute,
    //                                                   pBGRAImageIn,
    //                                                   ST_PIX_FMT_BGRA8888,
    //                                                   iWidth,
    //                                                   iHeight,
    //                                                   iBytesPerRow,
    //                                                   _pFacesDetection,
    //                                                   1, // 这里仅取一张脸也就是第一张脸的属性作为演示
    //                                                   &pAttrArray);
    //            if (iRet != ST_OK) {
    //
    //                pFacesFinal = NULL;
    //
    //                STLog(@"st_mobile_face_attribute_detect failed. %d" , iRet);
    //
    //                goto unlockBufferAndFlushCache;
    //            }
    //
    //            TIMEPRINT(attributeKey, "st_mobile_face_attribute_detect time: ");
    //
    //
    //            // 取第一个人的属性集合作为示例
    //            st_mobile_attribute_t attributeDisplay = pAttrArray[0];
    //
    //            //获取属性描述
    //            NSString *strAttrDescription = [self getDescriptionOfAttribute:attributeDisplay];
    //
    //            dispatch_async(dispatch_get_main_queue(), ^{
    //
    //                [self.lblAttribute setText:[@"第一张人脸: " stringByAppendingString:strAttrDescription]];
    //                [self.lblAttribute setHidden:NO];
    //            });
    //        }
    //    }else{
    //
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //
    //            [self.lblAttribute setText:@""];
    //            [self.lblAttribute setHidden:YES];
    //        });
    //    }
    
    
    // 设置 OpenGL 环境 , 需要与初始化 SDK 时一致
    if ([EAGLContext currentContext] != self.glContext) {
        [EAGLContext setCurrentContext:self.glContext];
    }
    
    // 当图像尺寸发生改变时需要对应改变纹理大小
    if (iWidth != self.imageWidth || iHeight != self.imageHeight) {
        
        [self releaseResultTexture];
        
        self.imageWidth = iWidth;
        self.imageHeight = iHeight;
        
        [self initResultTexture];
    }
    
    // 获取原图纹理
    BOOL isTextureOriginReady = [self setupOriginTextureWithPixelBuffer:pixelBuffer];
    
    GLuint textureResult = _textureOriginInput;
    
    CVPixelBufferRef resultPixelBufffer = pixelBuffer;
    
    if (isTextureOriginReady) {
        
        ///ST_MOBILE 以下为美颜部分  对openGL上的纹理进行美颜处理
        if (_bBeauty && _hBeautify) {
            
            TIMELOG(keyBeautify);
            
            iRet = st_mobile_beautify_process_texture(_hBeautify,
                                                      _textureOriginInput,
                                                      iWidth,
                                                      iHeight,
                                                      pFacesFinal,
                                                      iFaceCount,
                                                      _textureBeautifyOutput,
                                                      _pFacesBeautify);
            
            TIMEPRINT(keyBeautify, "st_mobile_beautify_process_texture time:");
            
            if (ST_OK != iRet) {
                
                pFacesFinal = NULL;
                
                STLog(@"st_mobile_beautify_process_texture failed %d" , iRet);
                
                goto unlockBufferAndFlushCache;
            }
            
            pFacesFinal = _pFacesBeautify;
            textureResult = _textureBeautifyOutput;
            resultPixelBufffer = _cvBeautifyBuffer;
        }
        
    }else{
        
        goto unlockBufferAndFlushCache;
    }
    //如果去除所有贴纸
    if (self.isNullSticker) {
        iRet = st_mobile_sticker_change_package(_hSticker, NULL);
        
        if (ST_OK != iRet) {
            NSLog(@"st_mobile_sticker_change_package error %d", iRet);
        }
    }
    
    ///ST_MOBILE 以下为贴纸部分
    if (_bSticker && _hSticker) {
        
        //通过 pFacesFinal 更新 detectResult
        for (int i = 0; i < iFaceCount; i ++) {
            
            detectResult.p_faces[i].face106 = pFacesFinal[i];
        }
        
        TIMELOG(stickerProcessKey);
        
        iRet = st_mobile_sticker_process_texture(_hSticker,
                                                 textureResult,
                                                 iWidth,
                                                 iHeight,
                                                 stMobileRotate,
                                                 false,
                                                 &detectResult,
                                                 item_callback,
                                                 _textureStickerOutput);
        
        TIMEPRINT(stickerProcessKey, "st_mobile_sticker_process_texture time:");
        
        if (ST_OK != iRet) {
            
            pFacesFinal = NULL;
            
            STLog(@"st_mobile_sticker_process_texture %d" , iRet);
            
            goto unlockBufferAndFlushCache;
        }
        
        textureResult = _textureStickerOutput;
        resultPixelBufffer = _cvStickerBuffer;
    }
    
    
    ///ST_MOBILE 以下为滤镜部分
    if (_bFilter && _hFilter) {
        
        TIMELOG(keyFilter);
        
        iRet = st_mobile_gl_filter_process_texture(_hFilter, textureResult, iWidth, iHeight, _textureFilterOutput);
        
        if (ST_OK != iRet) {
            
            STLog(@"st_mobile_gl_filter_process_texture %d" , iRet);
            
            goto unlockBufferAndFlushCache;
        }
        
        TIMEPRINT(keyFilter, "st_mobile_gl_filter_process_texture time:");
        
        textureResult = _textureFilterOutput;
        resultPixelBufffer = _cvFilterBuffer;
    }
    
    //需要拍照  那么就拍照
    if (self.needSnap) {
        
        self.needSnap = NO;
        //输出照片
        [self snapWithTexture:textureResult width:iWidth height:iHeight];
    }
    
    if (self.isComparing) {
        textureResult = _textureOriginInput;
    }
    
    if (!self.outputVideoFormatDescription) {
        CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &(_outputVideoFormatDescription));
    }
    
    @synchronized (self) {
        //如果正在录制，那么合成视频
        if (self.recordStatus == STWriterRecordingStatusRecording) {
            [self.stRecoder appendVideoPixelBuffer:resultPixelBufffer withPresentationTime:timestamp];
        }
    }
    //绘制纹理
    [self.glPreview renderTexture:textureResult];
    
    //如果对纹理进行的贴纸滤镜等操作失败，那么释放
unlockBufferAndFlushCache:
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    CVOpenGLESTextureCacheFlush(_cvTextureCache, 0);
    
    if (_cvTextureOrigin) {
        
        CFRelease(_cvTextureOrigin);
        _cvTextureOrigin = NULL;
    }
    
    if (_pFacesDetection) {
        free(_pFacesDetection);
        _pFacesDetection = NULL;
    }
    
    if (_pFacesBeautify) {
        free(_pFacesBeautify);
        _pFacesBeautify = NULL;
    }
    
    dCost = CFAbsoluteTimeGetCurrent() - dStart;
    dispatch_async(dispatch_get_main_queue(), ^{
        
//        [self.lblSpeed setText:[NSString stringWithFormat:@"单帧耗时: %.0fms" ,dCost * 1000.0]];
//        [self.lblCPU setText:[NSString stringWithFormat:@"CPU占用率: %.1f%%" , [STParamUtil getCpuUsage]]];
        
    });
    
    TIMEPRINT(frameCostKey, "every frame cost time");
    
}

#pragma mark - 拍照和视频
//拍照
- (void)snapWithTexture:(GLuint)iTexture width:(int)iWidth height:(int)iHeight
{
    self.pauseOutput = YES;
//        ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(iWidth, iHeight), NO, 0.0);
        [self.glPreview drawViewHierarchyInRect:CGRectMake(0, 0, iWidth, iHeight) afterScreenUpdates:YES];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        if (image) {
            ImageViewController *vc = [[ImageViewController alloc] init];
            vc.image = image;
            [self presentViewController:vc animated:YES completion:nil];
        }
    });
    
    self.pauseOutput = NO;
}

- (void)stopRecorder {
    
    @synchronized (self) {
        
        if (self.recordStatus != STWriterRecordingStatusRecording) {
            return;
        }
        
        self.recordStatus = STWriterRecordingStatusStoppingRecording;
        
        [_stRecoder finishRecording];
    }
}

#pragma mark - 贴纸的一些回调，贴纸声音播放和素材渲染

void item_callback(const char* material_name, st_material_status status) {
    
    switch (status){
        case ST_MATERIAL_BEGIN:
            STLog(@"begin %s" , material_name);
            break;
        case ST_MATERIAL_END:
            STLog(@"end %s" , material_name);
            break;
        case ST_MATERIAL_PROCESS:
            STLog(@"process %s", material_name);
            break;
        default:
            STLog(@"error");
            break;
    }
}

void load_sound(void* sound, const char* sound_name, int length) {
    
    //    NSLog(@"STEffectsAudioPlayer load sound");
    
    if ([messageManager.delegate respondsToSelector:@selector(loadSound:name:)]) {
        
        NSData *soundData = [NSData dataWithBytes:sound length:length];
        NSString *strName = [NSString stringWithUTF8String:sound_name];
        
        [messageManager.delegate loadSound:soundData name:strName];
    }
}

void play_sound(const char* sound_name, int loop) {
    
    //    NSLog(@"STEffectsAudioPlayer play sound");
    
    if ([messageManager.delegate respondsToSelector:@selector(playSound:loop:)]) {
        
        NSString *strName = [NSString stringWithUTF8String:sound_name];
        
        [messageManager.delegate playSound:strName loop:loop];
    }
}

void stop_sound(const char* sound_name) {
    
    //    NSLog(@"STEffectsAudioPlayer stop sound");
    
    if ([messageManager.delegate respondsToSelector:@selector(stopSound:)]) {
        
        NSString *strName = [NSString stringWithUTF8String:sound_name];
        
        [messageManager.delegate stopSound:strName];
    }
}

#pragma mark - STEffectsMessageManagerDelegate

- (void)loadSound:(NSData *)soundData name:(NSString *)strName {
    if ([self.audioPlayer loadSound:soundData name:strName]) {
        NSLog(@"STEffectsAudioPlayer load %@ successfully", strName);
    }
}

- (void)playSound:(NSString *)strName loop:(int)iLoop {
    
    if ([self.audioPlayer playSound:strName loop:iLoop]) {
        NSLog(@"STEffectsAudioPlayer play %@ successfully", strName);
    }
}

- (void)stopSound:(NSString *)strName {
    [self.audioPlayer stopSound:strName];
}

#pragma mark - STEffectsAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(STEffectsAudioPlayer *)player successfully:(BOOL)flag name:(NSString *)strName {
    if (_hSticker) {
        st_mobile_sticker_set_sound_completed(_hSticker, [strName UTF8String]);
    }
}

#pragma mark - app活跃状态通知
-(void)appWillResignActive
{
    //app失去响应
    self.isAppActive = NO;
    
    if (self.isComparing) {
        self.isComparing = NO;
    }
    
    if (self.recording) {
        
        [self stopRecorder];
        
        self.recording = NO;
    }
    
    [self.camera stopRunning];
    
    if (self.audioPlayer.strCurrentAudioName) {
        [self stopSound:self.audioPlayer.strCurrentAudioName];
        st_mobile_sticker_set_sound_completed(_hSticker, [self.audioPlayer.strCurrentAudioName UTF8String]);
    }
}

-(void)appDidEnterBackground
{
    self.isAppActive = NO;
}

-(void)appDidBecomeActive
{
    self.isAppActive = YES;
}

-(void)appWillEnterForeground
{
    [self.camera startRunning];
    self.isAppActive = YES;
}

-(void)handleAudioInterruption:(NSNotification *)notificaiton
{
    //app播放声音被打断处理
}

#pragma mark - 一些辅助的方法
//获取旋转类型  如果图像倒转需要旋转图像
- (st_rotate_type)getRotateType
{
    BOOL isFrontCamera = self.camera.devicePosition == AVCaptureDevicePositionFront;
    BOOL isVideoMirrored = self.camera.videoConnection.isVideoMirrored;
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    switch (deviceOrientation) {
            
        case UIDeviceOrientationPortrait:
            return ST_CLOCKWISE_ROTATE_0;
            
        case UIDeviceOrientationPortraitUpsideDown:
            return ST_CLOCKWISE_ROTATE_180;
            
        case UIDeviceOrientationLandscapeLeft:
            return ((isFrontCamera && isVideoMirrored) || (!isFrontCamera && !isVideoMirrored)) ? ST_CLOCKWISE_ROTATE_270 : ST_CLOCKWISE_ROTATE_90;
            
        case UIDeviceOrientationLandscapeRight:
            return ((isFrontCamera && isVideoMirrored) || (!isFrontCamera && !isVideoMirrored)) ? ST_CLOCKWISE_ROTATE_90 : ST_CLOCKWISE_ROTATE_270;
            
        default:
            return ST_CLOCKWISE_ROTATE_0;
    }
}


#pragma mark - 创建结果纹理(这一部分我看不懂)

- (void)initResultTexture {
    // 创建结果纹理
    [self setupTextureWithPixelBuffer:&_cvBeautifyBuffer
                                    w:self.imageWidth
                                    h:self.imageHeight
                            glTexture:&_textureBeautifyOutput
                            cvTexture:&_cvTextureBeautify];
    
    [self setupTextureWithPixelBuffer:&_cvStickerBuffer
                                    w:self.imageWidth
                                    h:self.imageHeight
                            glTexture:&_textureStickerOutput
                            cvTexture:&_cvTextureSticker];
    
    
    [self setupTextureWithPixelBuffer:&_cvFilterBuffer
                                    w:self.imageWidth
                                    h:self.imageHeight
                            glTexture:&_textureFilterOutput
                            cvTexture:&_cvTextureFilter];
}


- (BOOL)setupTextureWithPixelBuffer:(CVPixelBufferRef *)pixelBufferOut
                                  w:(int)iWidth
                                  h:(int)iHeight
                          glTexture:(GLuint *)glTexture
                          cvTexture:(CVOpenGLESTextureRef *)cvTexture {
    CFDictionaryRef empty = CFDictionaryCreate(kCFAllocatorDefault,
                                               NULL,
                                               NULL,
                                               0,
                                               &kCFTypeDictionaryKeyCallBacks,
                                               &kCFTypeDictionaryValueCallBacks);
    
    CFMutableDictionaryRef attrs = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                                             1,
                                                             &kCFTypeDictionaryKeyCallBacks,
                                                             &kCFTypeDictionaryValueCallBacks);
    
    CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
    
    CVReturn cvRet = CVPixelBufferCreate(kCFAllocatorDefault,
                                         iWidth,
                                         iHeight,
                                         kCVPixelFormatType_32BGRA,
                                         attrs,
                                         pixelBufferOut);
    
    if (kCVReturnSuccess != cvRet) {
        
        NSLog(@"CVPixelBufferCreate %d" , cvRet);
    }
    
    cvRet = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                         _cvTextureCache,
                                                         *pixelBufferOut,
                                                         NULL,
                                                         GL_TEXTURE_2D,
                                                         GL_RGBA,
                                                         self.imageWidth,
                                                         self.imageHeight,
                                                         GL_BGRA,
                                                         GL_UNSIGNED_BYTE,
                                                         0,
                                                         cvTexture);
    
    CFRelease(attrs);
    CFRelease(empty);
    
    if (kCVReturnSuccess != cvRet) {
        
        NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage %d" , cvRet);
        
        return NO;
    }
    
    *glTexture = CVOpenGLESTextureGetName(*cvTexture);
    glBindTexture(CVOpenGLESTextureGetTarget(*cvTexture), *glTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return YES;
}


- (BOOL)setupOriginTextureWithPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CVReturn cvRet = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                  _cvTextureCache,
                                                                  pixelBuffer,
                                                                  NULL,
                                                                  GL_TEXTURE_2D,
                                                                  GL_RGBA,
                                                                  self.imageWidth,
                                                                  self.imageHeight,
                                                                  GL_BGRA,
                                                                  GL_UNSIGNED_BYTE,
                                                                  0,
                                                                  &_cvTextureOrigin);
    
    if (!_cvTextureOrigin || kCVReturnSuccess != cvRet) {
        
        NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage %d" , cvRet);
        
        return NO;
    }
    
    _textureOriginInput = CVOpenGLESTextureGetName(_cvTextureOrigin);
    glBindTexture(GL_TEXTURE_2D , _textureOriginInput);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return YES;
}

//释放纹理
- (void)releaseResultTexture {
    _textureBeautifyOutput = 0;
    _textureStickerOutput = 0;
    _textureFilterOutput = 0;
    
    if (_cvTextureOrigin) {
        
        CFRelease(_cvTextureOrigin);
        _cvTextureOrigin = NULL;
    }
    
    CVPixelBufferRelease(_cvTextureBeautify);
    CVPixelBufferRelease(_cvTextureSticker);
    CVPixelBufferRelease(_cvTextureFilter);
    
    CVPixelBufferRelease(_cvBeautifyBuffer);
    CVPixelBufferRelease(_cvStickerBuffer);
    CVPixelBufferRelease(_cvFilterBuffer);
}

#pragma mark - 重新配置美颜等参数

- (void)resetSettings {
    
    self.configView.noneStickerImageView.highlighted = YES;
    
    self.fSmoothStrength = 0.74;
    self.fReddenStrength = 0.36;
    self.fWhitenStrength = 0.30;
    self.fEnlargeEyeStrength = 0.13;
    self.fShrinkFaceStrength = 0.11;
    self.fShrinkJawStrength = 0.10;
    
    self.configView.thinFaceView.slider.value = 11;
    self.configView.thinFaceView.maxLabel.text = @"11";
    
    self.configView.enlargeEyesView.slider.value = 13;
    self.configView.enlargeEyesView.maxLabel.text = @"13";
    
    self.configView.smallFaceView.slider.value = 10;
    self.configView.smallFaceView.maxLabel.text = @"10";
    
    self.configView.dermabrasionView.slider.value = 74;
    self.configView.dermabrasionView.maxLabel.text = @"74";
    
    self.configView.ruddyView.slider.value = 36;
    self.configView.ruddyView.maxLabel.text = @"36";
    
    self.configView.whitenView.slider.value = 30;
    self.configView.whitenView.maxLabel.text = @"30";
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
