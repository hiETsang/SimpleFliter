//
//  ImageViewController.m
//  FilterDemo
//
//  Created by canoe on 2017/11/22.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import "ImageViewController.h"
#import "LVFaceDealHeader.h"
#import "LVConfigEffectsView.h"
#import "LVGetEffectsSourceTool.h"

//model
#import "STCollectionViewDisplayModel.h"    //滤镜贴纸



@interface ImageViewController ()<LVConfigEffectsViewDelegate>
{
    st_handle_t _hSticker;  // sticker句柄   贴纸
    st_handle_t _hDetector; // detector句柄   检测
    st_handle_t _hBeautify; // beautify句柄   美颜
    st_handle_t _hFilter;   // filter句柄     滤镜
    
    st_mobile_106_t *_pFacesDetection; // 检测输出人脸信息数组
    st_mobile_106_t *_pFacesBeautify;  // 美颜输出人脸信息数组
}

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *compareButton;
@property(nonatomic, strong) LVConfigEffectsView *configView;

@property (nonatomic, readwrite, strong) UIImage *imageProcessed;

//beauty value
@property (nonatomic, assign) float fSmoothStrength;
@property (nonatomic, assign) float fReddenStrength;
@property (nonatomic, assign) float fWhitenStrength;
@property (nonatomic, assign) float fEnlargeEyeStrength;
@property (nonatomic, assign) float fShrinkFaceStrength;
@property (nonatomic, assign) float fShrinkJawStrength;
@property (nonatomic, assign) float fFilterStrength;

@property (nonatomic, readwrite, assign) unsigned long long iCurrentAction;

@property (nonatomic, readwrite, strong) NSMutableArray *arrPersons;
@property (nonatomic, readwrite, strong) NSMutableArray *arrPoints;

@property (nonatomic, readwrite, strong) EAGLContext *glContext;
@property (nonatomic, readwrite, strong) CIContext *ciContext;

@property (nonatomic, readwrite, assign) float scale;
@property (nonatomic, readwrite, assign) float topMargin;
@property (nonatomic, readwrite, assign) float leftMargin;

@property (nonatomic, readwrite, assign) BOOL bFilter;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置下方按钮
    [self createUI];
    
    //设置默认参数
    [self setDefaultValue];
    
    if (![LVGetEffectsSourceTool checkActiveCode]) {
        return;
    }
    
    //初始化相关句柄
    [self setupHandle];
    
    //处理图片并且展示
    [self processImageAndDisplay];
}

#pragma mark - 初始化数据

- (void)setDefaultValue {
    
    self.fSmoothStrength = 0.74;
    self.fReddenStrength = 0.36;
    self.fWhitenStrength = 0.30;
    self.fEnlargeEyeStrength = 0.13;
    self.fShrinkFaceStrength = 0.11;
    self.fShrinkJawStrength = 0.10;
    
    self.fFilterStrength = 1.0;
    
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
    
    self.bFilter = NO;
}


- (void)setupHandle {
    st_result_t iRet = ST_OK;
    
    // 设置SDK OpenGL 环境 , 只有在正确的 OpenGL 环境下 SDK 才会被正确初始化 .
    self.glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.ciContext = [CIContext contextWithEAGLContext:self.glContext
                                               options:@{kCIContextWorkingColorSpace : [NSNull null]}];
    
    [EAGLContext setCurrentContext:self.glContext];
    
    //初始化检测模块句柄
    NSString *strModelPath = [[NSBundle mainBundle] pathForResource:@"action5.0.0" ofType:@"model"];
    
    uint32_t config = 0;
    
#if ENABLE_FACE_240_DETECT
    config = ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_IMAGE | ST_MOBILE_ENABLE_FACE_EXTRA_DETECT | ST_MOBILE_ENABLE_EYEBALL_CENTER_DETECT | ST_MOBILE_ENABLE_EYEBALL_CONTOUR_DETECT;
#else
    config = ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_IMAGE;
#endif
    
    TIMELOG(key);
    
    iRet = st_mobile_human_action_create(strModelPath.UTF8String,
                                         config,
                                         &_hDetector);
    
    TIMEPRINT(key,"human action create time:");
    
    if (ST_OK != iRet || !_hDetector) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"算法SDK初始化失败，可能是模型路径错误，SDK权限过期，与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    
    
    //初始化贴纸模块句柄 , 默认开始时无贴纸 , 所以第一个路径参数传空
    TIMELOG(keySticker);
    
    iRet = st_mobile_sticker_create(NULL , &_hSticker);
    
    TIMEPRINT(keySticker, "sticker create time:");
    
    if (ST_OK != iRet || !_hSticker) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"贴纸SDK初始化失败 , SDK权限过期，或者与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
    } else {
        
        iRet = st_mobile_sticker_set_waiting_material_loaded(_hSticker, true);
        
        if (iRet != ST_OK) {
            NSLog(@"st_mobile_sticker_set_waiting_material_loaded failed: %d", iRet);
        }
        
        iRet = st_mobile_sticker_set_max_imgmem(_hSticker, 30);
        
        if (iRet != ST_OK) {
            NSLog(@"st_mobile_sticker_set_max_imgmem failed: %d", iRet);
        }
        
        //声音贴纸回调，图片版可以不设置
//        st_mobile_sticker_set_sound_callback_funcs(_hSticker, load_sound_pic, play_sound_pic, stop_sound_pic);
    }
    
    if (ST_OK != iRet) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"st_mobile_sticker_set_waiting_material_loaded failed." delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    
    
    
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
}

#pragma mark - 销毁数据
- (void)releaseResources {
    
    if ([EAGLContext currentContext] != self.glContext) {
        
        [EAGLContext setCurrentContext:self.glContext];
    }
    
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
    
    if (_hFilter) {
        
        st_mobile_gl_filter_destroy(_hFilter);
        _hFilter = NULL;
    }
    
    [EAGLContext setCurrentContext:nil];
}

#pragma mark - 控制操作

-(void)didSelectedEffectModel:(STCollectionViewDisplayModel *)model
{
    if (_hSticker) {
        
        if ([EAGLContext currentContext] != self.glContext) {
            
            [EAGLContext setCurrentContext:self.glContext];
        }
        
        // 获取触发动作类型
        unsigned long long iAction = 0;
        
        const char *stickerPath = [model.strPath UTF8String];
        
        st_result_t iRet = st_mobile_sticker_change_package(_hSticker, stickerPath);
        
        if (iRet != ST_OK) {
            
            STLog(@"st_mobile_sticker_change_package error %d" , iRet);
            
            return;
            
        }else{
            
            iRet = st_mobile_sticker_get_trigger_action(_hSticker, &iAction);
            
            if (ST_OK != iRet) {
                
                STLog(@"st_mobile_sticker_get_trigger_action error %d" , iRet);
                
                return;
            }
            
        }
        
        self.iCurrentAction = iAction;
        
        [self processImageAndDisplay];
    }
}

-(void)didSelectedFilterModel:(STCollectionViewDisplayModel *)model
{
    // 切换滤镜
    if (_hFilter && self.bFilter) {
        
        // 切换滤镜不会修改强度 , 这里根据实际需求实现 , 这里重置为 0.5.
        self.fFilterStrength = 0.5;
        
        
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
    }
    
    [self processImageAndDisplay];
}

-(void)didSelectedRemoveAllEffectButton
{
    //此处需要将贴纸取消
    if (_hSticker) {
        if ([EAGLContext currentContext] != self.glContext) {
            
            [EAGLContext setCurrentContext:self.glContext];
        }
        
        st_result_t iRet = st_mobile_sticker_change_package(_hSticker, NULL);
        
        if (iRet != ST_OK) {
            STLog(@"st_mobile_sticker_change_package error %d", iRet);
        }
        [self processImageAndDisplay];
    }
    
}

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
        
        [self processImageAndDisplay];
    }
    
}

#pragma mark - 处理图片然后展示

- (void)processImageAndDisplay
{
    if (![LVGetEffectsSourceTool checkActiveCode]) {
        return;
    }
    
    self.view.userInteractionEnabled = NO;
    
    int iWidth = self.image.size.width;
    int iHeight= self.image.size.height;
    
    _scale = fmaxf(iWidth / CGRectGetWidth(self.showImageView.frame), iHeight / CGRectGetHeight(self.showImageView.frame));
    _topMargin = (kScreenHeight - iHeight / _scale) / 2;
    _leftMargin = (kScreenWidth - iWidth / _scale) / 2;
    
    GLuint textureResult = [self processImageAndReturnTexture];
    CGImageRef cgImage = [self getCGImageWithTexture:textureResult width:self.image.size.width height:self.image.size.height];
    UIImage *imageResult = [UIImage imageWithCGImage:cgImage];
    
    self.imageProcessed = imageResult;
    self.showImageView.image = self.imageProcessed;
    
    CGImageRelease(cgImage);
    
    if ([EAGLContext currentContext] != self.glContext) {
        [EAGLContext setCurrentContext:self.glContext];
    }
    
    glDeleteTextures(1, &textureResult);
    
    self.view.userInteractionEnabled = YES;
}

static void activeAndBindTexture(GLenum textureActive, GLuint *textureBind, Byte *sourceImage, GLenum sourceFormat, GLsizei iWidth, GLsizei iHeight) {
    
    glActiveTexture(textureActive);
    glBindTexture(GL_TEXTURE_2D, *textureBind);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, iWidth, iHeight, 0, sourceFormat, GL_UNSIGNED_BYTE, sourceImage);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glFlush();
}


- (GLuint)processImageAndReturnTexture
{
    TIMELOG(frameCostKey);
    if (self.image) {
        
        if (UIImageOrientationUp != self.image.imageOrientation) {
            UIGraphicsBeginImageContext(self.image.size);
            [self.image drawInRect:CGRectMake(0, 0, self.image.size.width, self.image.size.height)];
            self.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
    
    double dCost = 0.0;
    double dStart = CFAbsoluteTimeGetCurrent();
    
    unsigned char * pBGRAImageIn = malloc(sizeof(unsigned char) * self.image.size.width * self.image.size.height * 4);
    
    //获取图像数据
    [self convertUIImage:self.image toBGRABytes:pBGRAImageIn];
    
    int iBytesPerRow = self.image.size.width * 4;
    int iWidth = self.image.size.width;
    int iHeight = self.image.size.height;
    
    st_result_t iRet = ST_OK;
    st_mobile_human_action_t detectResult;
    memset(&detectResult, 0, sizeof(st_mobile_human_action_t));
    st_mobile_106_t *pFacesFinal = NULL;
    int iFaceCount = 0;
    
    // 人脸信息检测
    if (_hDetector) {
        
        BOOL needFaceDetection = (self.fEnlargeEyeStrength > 0 || self.fShrinkFaceStrength > 0 || self.fShrinkJawStrength > 0) && _hBeautify;
        
        if (needFaceDetection) {
            
#if ENABLE_FACE_240_DETECT
            self.iCurrentAction = self.iCurrentAction | ST_MOBILE_FACE_DETECT | ST_MOBILE_DETECT_EXTRA_FACE_POINTS | ST_MOBILE_DETECT_EYEBALL_CENTER | ST_MOBILE_DETECT_EYEBALL_CONTOUR;
#else
            self.iCurrentAction = self.iCurrentAction | ST_MOBILE_FACE_DETECT;
#endif
            
        }
        
        if (self.iCurrentAction > 0) {
            
            _arrPoints = [NSMutableArray array];
            _arrPersons = [NSMutableArray array];
            
            TIMELOG(keyDetect);
            
            iRet = st_mobile_human_action_detect(_hDetector,
                                                 pBGRAImageIn,
                                                 ST_PIX_FMT_BGRA8888,
                                                 iWidth,
                                                 iHeight,
                                                 iBytesPerRow,
                                                 ST_CLOCKWISE_ROTATE_0,
                                                 self.iCurrentAction,
                                                 &detectResult);
            
            TIMEPRINT(keyDetect, "st_mobile_human_action_detect time:");
            
            if(iRet == ST_OK) {
                
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
                
                goto releaseResource;
            }
        }
    }
    
    // 设置 OpenGL 环境 , 需要与初始化 SDK 时一致
    if ([EAGLContext currentContext] != self.glContext) {
        [EAGLContext setCurrentContext:self.glContext];
    }
    
    GLuint textureOriginInput = 0;
    GLuint textureBeautifyOutput = 0;
    GLuint textureStickerOutput = 0;
    GLuint textureFilterOutput = 0;
    
    GLuint textureResult = textureOriginInput;
    
    // 配置原图纹理
    glGenTextures(1, &textureOriginInput);
    activeAndBindTexture(GL_TEXTURE1, &textureOriginInput, pBGRAImageIn, GL_BGRA, iWidth, iHeight);
    
    textureResult = textureOriginInput;
    
    ///ST_MOBILE 以下为美颜部分
    if (_hBeautify) {
        
        // 配置美颜输出纹理
        glGenTextures(1, &textureBeautifyOutput);
        activeAndBindTexture(GL_TEXTURE2, &textureBeautifyOutput, NULL, GL_RGBA, iWidth, iHeight);
        
        TIMELOG(keyBeautify);
        
        iRet = st_mobile_beautify_process_texture(_hBeautify,
                                                  textureOriginInput,
                                                  iWidth,
                                                  iHeight,
                                                  pFacesFinal,
                                                  iFaceCount,
                                                  textureBeautifyOutput,
                                                  _pFacesBeautify);
        
        TIMEPRINT(keyBeautify, "st_mobile_beautify_process_texture time:");
        
        if (ST_OK != iRet) {
            
            pFacesFinal = NULL;
            
            STLog(@"st_mobile_beautify_process_texture failed %d" , iRet);
            
            goto releaseResource;
        }
        
        pFacesFinal = _pFacesBeautify;
        textureResult = textureBeautifyOutput;
    }
    
    
    ///ST_MOBILE 以下为贴纸部分
    if (_hSticker) {
        
        //通过 pFacesFinal 更新 detectResult
        for (int i = 0; i < iFaceCount; i ++) {
            
            detectResult.p_faces[i].face106 = pFacesFinal[i];
        }
        
        // 配置贴纸输出纹理
        glGenTextures(1, &textureStickerOutput);
        activeAndBindTexture(GL_TEXTURE3, &textureStickerOutput, NULL, GL_RGBA, iWidth, iHeight);
        
        TIMELOG(stickerProcessKey);
        
        iRet = st_mobile_sticker_process_texture(_hSticker ,
                                                 textureResult,
                                                 iWidth,
                                                 iHeight,
                                                 ST_CLOCKWISE_ROTATE_0,
                                                 false,
                                                 &detectResult,
                                                 NULL,
                                                 textureStickerOutput);
        
        TIMEPRINT(stickerProcessKey, "st_mobile_sticker_process_texture time:");
        
        if (ST_OK != iRet) {
            
            pFacesFinal = NULL;
            
            STLog(@"st_mobile_sticker_process_texture %d" , iRet);
            
            goto releaseResource;
        }
        
        textureResult = textureStickerOutput;
    }
    
    
    ///ST_MOBILE 以下为滤镜部分
    if (_hFilter && self.bFilter) {
        
        // 配置滤镜输出纹理
        glGenTextures(1, &textureFilterOutput);
        activeAndBindTexture(GL_TEXTURE3, &textureFilterOutput, NULL, GL_RGBA, iWidth, iHeight);
        
        TIMELOG(keyFilter);
        
        iRet = st_mobile_gl_filter_process_texture(
                                                   _hFilter,
                                                   textureResult,
                                                   iWidth,
                                                   iHeight,
                                                   textureFilterOutput
                                                   );
        
        if (ST_OK != iRet) {
            
            STLog(@"st_mobile_gl_filter_process_texture %d" , iRet);
            
            goto releaseResource;
        }
        
        textureResult = textureFilterOutput;
        
        TIMEPRINT(keyFilter, "st_mobile_gl_filter_process_texture time:");
    }
    
    
releaseResource:
    
    if (pBGRAImageIn) {
        free(pBGRAImageIn);
    }
    
    if (_pFacesDetection) {
        free(_pFacesDetection);
    }
    
    if (_pFacesBeautify) {
        free(_pFacesBeautify);
    }
    
    if (textureResult != textureOriginInput) {
        glDeleteTextures(1, &textureOriginInput);
    }
    
    if (textureResult != textureBeautifyOutput) {
        glDeleteTextures(1, &textureBeautifyOutput);
    }
    
    if (textureResult != textureStickerOutput) {
        glDeleteTextures(1, &textureStickerOutput);
    }
    
    if (textureResult != textureFilterOutput) {
        glDeleteTextures(1, &textureFilterOutput);
    }
    
    dCost = CFAbsoluteTimeGetCurrent() - dStart;
    //    [self.lblSpeed setText:[NSString stringWithFormat:@"单帧耗时: %.0fms" ,dCost * 1000.0]];
    
    TIMEPRINT(frameCostKey, "every frame cost time");
    
    return textureResult;
}

- (void)convertUIImage:(UIImage *)uiImage toBGRABytes:(unsigned char *)pImage {
    
    CGImageRef cgImage = [uiImage CGImage];
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    int iWidth = uiImage.size.width;
    int iHeight = uiImage.size.height;
    int iBytesPerPixel = 4;
    int iBytesPerRow = iBytesPerPixel * iWidth;
    int iBitsPerComponent = 8;
    
    CGContextRef context = CGBitmapContextCreate(pImage,
                                                 iWidth,
                                                 iHeight,
                                                 iBitsPerComponent,
                                                 iBytesPerRow,
                                                 colorspace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst
                                                 );
    if (!context) {
        CGColorSpaceRelease(colorspace);
        return;
    }
    
    CGRect rect = CGRectMake(0 , 0 , iWidth , iHeight);
    CGContextDrawImage(context , rect ,cgImage);
    CGColorSpaceRelease(colorspace);
    CGContextRelease(context);
}


- (CGImageRef)getCGImageWithTexture:(GLuint)iTexture width:(int)iWidth height:(int)iHeight {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CIImage *ciImage = [CIImage imageWithTexture:iTexture size:CGSizeMake(iWidth, iHeight) flipped:YES colorSpace:colorSpace];
    
    CGImageRef cgImage = [self.ciContext createCGImage:ciImage fromRect:CGRectMake(0, 0, iWidth, iHeight)];
    
    CGColorSpaceRelease(colorSpace);
    
    return cgImage;
}



#pragma mark - UI
//底部按钮等
-(void)createUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.showImageView.image = self.image;
    
    self.configView = [[LVConfigEffectsView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 200)];
    self.configView.delegate = self;
    [self.view addSubview:self.configView];
    
    //
    [self.compareButton addTarget:self action:@selector(compare:) forControlEvents:UIControlEventTouchDown];
    [self.compareButton addTarget:self action:@selector(cancelCompare:) forControlEvents:UIControlEventTouchUpInside];
    [self.compareButton addTarget:self action:@selector(cancelCompare:) forControlEvents:UIControlEventTouchDragExit];
    
    //上下滑
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHideLastDatePhotoView:)];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:swipeUp];
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHideLastDatePhotoView:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:swipeDown];
}

#pragma mark - 按钮操作
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

- (IBAction)backButtonClick:(id)sender {
    [self releaseResources];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonClick:(id)sender {
    
    [self.backButton setEnabled:NO];
    [self.saveButton setEnabled:NO];
    
    if (self.imageProcessed.CGImage) {
        
        //保存图片
        ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [assetLibrary writeImageToSavedPhotosAlbum:self.imageProcessed.CGImage
                                           orientation:ALAssetOrientationUp
                                       completionBlock:^(NSURL *assetURL, NSError *error) {
                                            }];
        });
    }else{
        
    }
}

-(void)compare:(UIButton *)button
{
    self.showImageView.image = self.image;
    self.backButton.enabled = NO;
    self.saveButton.enabled = NO;
}

-(void)cancelCompare:(UIButton *)button
{
    self.showImageView.image = self.imageProcessed;
    self.backButton.enabled = YES;
    self.saveButton.enabled = YES;
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
