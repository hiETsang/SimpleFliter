#ifndef INCLUDE_STMOBILE_ST_MOBILE_HUMAN_ACTION_H_
#define INCLUDE_STMOBILE_ST_MOBILE_HUMAN_ACTION_H_

#include "st_mobile_common.h"

/// 该文件中的API不保证线程安全.多线程调用时,需要确保安全调用.例如在 create handle 没有执行完就执行 process 可能造成crash;在 process 执行过程中调用 destroy 函数可能会造成crash.

/// 用于detect_config配置选项, 其中的脸部动作和手势也可用来判断action动作类型
#define ST_MOBILE_FACE_DETECT       0x00000001  ///< 人脸检测
#define ST_MOBILE_EYE_BLINK         0x00000002  ///< 眨眼（该检测耗时较长，请在需要时开启）
#define ST_MOBILE_MOUTH_AH          0x00000004  ///< 嘴巴大张
#define ST_MOBILE_HEAD_YAW          0x00000008  ///< 摇头
#define ST_MOBILE_HEAD_PITCH        0x00000010  ///< 点头
#define ST_MOBILE_BROW_JUMP         0x00000020  ///< 眉毛挑动（该检测耗时较长，请在需要时开启）
#define ST_MOBILE_HAND_OK           0x00000200  ///< OK手势
#define ST_MOBILE_HAND_SCISSOR      0x00000400  ///< 剪刀手
#define ST_MOBILE_HAND_GOOD         0x00000800  ///< 大拇哥
#define ST_MOBILE_HAND_PALM         0x00001000  ///< 手掌
#define ST_MOBILE_HAND_PISTOL       0x00002000  ///< 手枪手势
#define ST_MOBILE_HAND_LOVE         0x00004000  ///< 爱心手势
#define ST_MOBILE_HAND_HOLDUP       0x00008000  ///< 托手手势
#define ST_MOBILE_HAND_CONGRATULATE 0x00020000  ///< 恭贺（抱拳）
#define ST_MOBILE_HAND_FINGER_HEART 0x00040000  ///< 单手比爱心
#define ST_MOBILE_HAND_FINGER_INDEX 0x00100000  ///< 食指指尖
#define ST_MOBILE_SEG_BACKGROUND    0x00010000  ///< 前景背景分割
#define ST_MOBILE_FACE_240_DETECT   0x01000000  ///< 人脸240关键点 (deprecated, 请使用ST_MOBILE_DETECT_EXTRA_FACE_POINTS)

#define ST_MOBILE_DETECT_EXTRA_FACE_POINTS  0x01000000  ///< 人脸240关键点
#define ST_MOBILE_DETECT_EYEBALL_CENTER     0x02000000  ///< 眼球中心点
#define ST_MOBILE_DETECT_EYEBALL_CONTOUR    0x04000000  ///< 眼球轮廓点

/// 检测人脸106点、所有脸部动作、所有手势和前后背景。不建议使用：耗时、CPU占用率较高。建议根据需求检测相关信息
#define ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_DETECT    (ST_MOBILE_FACE_DETECT | \
                                                        ST_MOBILE_EYE_BLINK | \
                                                        ST_MOBILE_MOUTH_AH | \
                                                        ST_MOBILE_HEAD_YAW | \
                                                        ST_MOBILE_HEAD_PITCH | \
                                                        ST_MOBILE_BROW_JUMP | \
                                                        ST_MOBILE_HAND_OK | \
                                                        ST_MOBILE_HAND_SCISSOR | \
                                                        ST_MOBILE_HAND_GOOD | \
                                                        ST_MOBILE_HAND_PALM | \
                                                        ST_MOBILE_HAND_PISTOL | \
                                                        ST_MOBILE_HAND_LOVE | \
                                                        ST_MOBILE_HAND_HOLDUP | \
                                                        ST_MOBILE_HAND_CONGRATULATE | \
                                                        ST_MOBILE_HAND_FINGER_HEART | \
                                                        ST_MOBILE_HAND_FINGER_INDEX | \
                                                        ST_MOBILE_SEG_BACKGROUND)

/// @brief 手势检测结果
typedef struct st_mobile_hand_t {
    int id;                     ///< 手的id (目前总是为0)
    st_rect_t rect;             ///< 手部矩形框
    st_pointf_t *p_key_points;  ///< 手部关键点
    int key_points_count;       ///< 手部关键点个数
    unsigned long long hand_action; ///< 手部动作
    float score;                ///< 手部动作置信度
} st_mobile_hand_t, *p_st_mobile_hand_t;

/// @brief 检测结果
typedef struct st_mobile_human_action_t {
    st_mobile_face_t *p_faces;  ///< 检测到的人脸信息
    int face_count;             ///< 检测到的人脸数目
    st_mobile_hand_t *p_hands;  ///< 检测到的手的信息
    int hand_count;             ///< 检测到的手的数目 (目前仅支持检测一只手)
    st_image_t *p_background;   ///< 前后背景分割图片信息,前景为0,背景为255,边缘部分有模糊(0-255之间),输出图像大小可以调节
    float background_score;     ///< 置信度
} st_mobile_human_action_t, *p_st_mobile_human_action_t;

/// @defgroup st_mobile_human_action
/// @brief human action detection interfaces
///
/// This set of interfaces detect human action.
///
/// @{

/// @brief 创建人体行为检测句柄配置选项
/// 支持的检测类型
#define ST_MOBILE_ENABLE_FACE_DETECT            0x00000040  ///< 检测人脸
#define ST_MOBILE_ENABLE_HAND_DETECT            0x00000080  ///< 检测手势
#define ST_MOBILE_ENABLE_SEGMENT_DETECT         0x00000100  ///< 检测背景分割
#define ST_MOBILE_ENABLE_FACE_240_DETECT        0x00000200  ///< 检测人脸240点 (deprecated, 请使用ST_MOBILE_ENABLE_FACE_EXTRA_DETECT)
#define ST_MOBILE_ENABLE_FACE_EXTRA_DETECT      0x00000200  ///< 检测人脸240点
#define ST_MOBILE_ENABLE_EYEBALL_CENTER_DETECT  0x00000400  ///< 检测眼球中心
#define ST_MOBILE_ENABLE_EYEBALL_CONTOUR_DETECT 0x00000800  ///< 检测眼球轮廓
/// 检测模式
#define ST_MOBILE_DETECT_MODE_VIDEO             0x00020000  ///< 视频检测
#define ST_MOBILE_DETECT_MODE_IMAGE             0x00040000  ///< 图片检测

/// 创建人体行为检测句柄的默认配置: 设置检测模式和检测类型
/// 视频检测, 检测人脸、手势和前后背景
#define ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_VIDEO     (ST_MOBILE_DETECT_MODE_VIDEO | \
                                                        ST_MOBILE_TRACKING_ENABLE_FACE_ACTION | \
                                                        ST_MOBILE_ENABLE_FACE_DETECT | \
                                                        ST_MOBILE_ENABLE_HAND_DETECT | \
                                                        ST_MOBILE_ENABLE_SEGMENT_DETECT)
/// 图片检测, 检测人脸、手势和前后背景
#define ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_IMAGE     (ST_MOBILE_DETECT_MODE_IMAGE | \
                                                        ST_MOBILE_ENABLE_FACE_DETECT | \
                                                        ST_MOBILE_ENABLE_HAND_DETECT | \
                                                        ST_MOBILE_ENABLE_SEGMENT_DETECT)

/// @brief 创建人体行为检测句柄. Android建议使用st_mobile_human_action_create_from_buffer
/// @param[in] model_path 模型文件的路径,例如models/action.model. 为NULL时需要调用st_mobile_human_action_add_sub_model添加需要的模型
/// @param[in] config 设置创建人体行为句柄的方式,检测视频时设置为ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_VIDEO,检测图片时设置为ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_IMAGE
/// @parma[out] handle 人体行为检测句柄,失败返回NULL
/// @return 成功返回ST_OK,失败返回其他错误码,错误码定义在st_mobile_common.h中,如ST_E_FAIL等
ST_SDK_API st_result_t
st_mobile_human_action_create(
    const char *model_path,
    unsigned int config,
    st_handle_t *handle
);

/// @brief 创建人体行为检测句柄
/// @param[in] buffer 模型缓存起始地址,为NULL时需要调用st_mobile_human_action_add_sub_model添加需要的模型
/// @param[in] buffer_size 模型缓存大小
/// @param[in] config 设置创建人体行为句柄的方式,检测视频时设置为ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_VIDEO,检测图片时设置为ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_IMAGE
/// @parma[out] handle 人体行为检测句柄,失败返回NULL
/// @return 成功返回ST_OK,失败返回其他错误码,错误码定义在st_mobile_common.h中,如ST_E_FAIL等
ST_SDK_API st_result_t
st_mobile_human_action_create_from_buffer(
    const unsigned char* buffer,
    unsigned int buffer_size,
    unsigned int config,
    st_handle_t *handle
);

/// @brief 通过子模型创建人体行为检测句柄, st_mobile_human_action_create和st_mobile_human_action_create_with_sub_models只能调一个
/// @param[in] model_path_arr 模型文件路径指针数组. 根据加载的子模型确定支持检测的类型. 如果包含相同的子模型, 后面的会覆盖前面的.
/// @param[in] model_count 模型文件数目
/// @param[in] detect_mode 设置检测模式. 检测视频时设置为ST_MOBILE_DETECT_MODE_VIDEO, 检测图片时设置为ST_MOBILE_DETECT_MODE_IMAGE
/// @parma[out] handle 人体行为检测句柄,失败返回NULL
/// @return 成功返回ST_OK,失败返回其他错误码,错误码定义在st_mobile_common.h中,如ST_E_FAIL等
ST_SDK_API st_result_t
st_mobile_human_action_create_with_sub_models(
    const char **model_path_arr,
    int model_count,
    unsigned int detect_mode,
    st_handle_t *handle
);

/// @brief 添加子模型. 非线程安全，不支持在执行st_mobile_human_action_detect的过程中覆盖正在使用的子模型. Android建议使用st_mobile_human_action_add_sub_model_from_buffer
/// @parma[in] handle 人体行为检测句柄
/// @param[in] model_path 模型文件的路径. 后添加的会覆盖之前添加的同类子模型。加载模型耗时较长, 建议在初始化创建句柄时就加载模型
ST_SDK_API st_result_t
st_mobile_human_action_add_sub_model(
    st_handle_t handle,
    const char *model_path
);
/// @brief 添加子模型. 非线程安全，不支持在执行st_mobile_human_action_detect的过程中添加子模型
/// @parma[in] handle 人体行为检测句柄
/// @param[in] buffer 模型缓存起始地址
/// @param[in] buffer_size 模型缓存大小
ST_SDK_API st_result_t
st_mobile_human_action_add_sub_model_from_buffer(
    st_handle_t handle,
    const unsigned char* buffer,
    unsigned int buffer_size
);

/// @brief 释放人体行为检测句柄
/// @param[in] handle 已初始化的人体行为句柄
ST_SDK_API
void st_mobile_human_action_destroy(
    st_handle_t handle
);

/// @brief 人体行为检测
/// @param[in] handle 已初始化的人体行为句柄
/// @param[in] image 用于检测的图像数据
/// @param[in] pixel_format 用于检测的图像数据的像素格式. 检测人脸建议使用NV12、NV21、YUV420P(转灰度图较快),检测手势和前后背景建议使用BGR、BGRA、RGB、RGBA
/// @param[in] image_width 用于检测的图像的宽度(以像素为单位)
/// @param[in] image_height 用于检测的图像的高度(以像素为单位)
/// @param[in] image_stride 用于检测的图像的跨度(以像素为单位),即每行的字节数；目前仅支持字节对齐的padding,不支持roi
/// @param[in] orientation 图像中人脸的方向
/// @param[in] detect_config 需要检测的人体行为,例如ST_MOBILE_EYE_BLINK | ST_MOBILE_MOUTH_AH | ST_MOBILE_HAND_LOVE | ST_MOBILE_SEG_BACKGROUND
/// @param[out] p_human_action 检测到的人体行为,由用户分配内存. 会覆盖上一次的检测结果.
/// @return 成功返回ST_OK,失败返回其他错误码,错误码定义在st_mobile_common.h中,如ST_E_FAIL等
ST_SDK_API st_result_t
st_mobile_human_action_detect(
    st_handle_t handle,
    const unsigned char *image,
    st_pixel_format pixel_format,
    int image_width,
    int image_height,
    int image_stride,
    st_rotate_type orientation,
    unsigned long long detect_config,
    st_mobile_human_action_t *p_human_action
);

/// @brief 重置, 清除所有缓存信息. 当前检测图像和前一帧检测图像差别较大(图片检测)时调用
ST_SDK_API st_result_t
st_mobile_human_action_reset(
    st_handle_t handle
);

/// @brief human_action参数类型
typedef enum {
    /// background结果中长边的长度[10,长边长度](默认长边240,短边=长边/原始图像长边*原始图像短边).值越大,背景分割的耗时越长,边缘部分效果越好.
    ST_HUMAN_ACTION_PARAM_BACKGROUND_MAX_SIZE = 1,
    /// 背景分割羽化程度[0,1](默认值0.35),0 完全不羽化,1羽化程度最高,在strenth较小时,羽化程度基本不变.值越大,前景与背景之间的过度边缘部分越宽.
    ST_HUMAN_ACTION_PARAM_BACKGROUND_BLUR_STRENGTH = 2,
    /// 设置检测到的最大人脸数目N(默认值10),持续track已检测到的N个人脸直到人脸数小于N再继续做detect.值越大,检测到的人脸数目越多,但相应耗时越长.
    ST_HUMAN_ACTION_PARAM_FACELIMIT = 3,
    /// 设置tracker每多少帧进行一次detect(默认值有人脸时30,无人脸时30/3=10). 值越大,cpu占用率越低, 但检测出新人脸的时间越长.
    ST_HUMAN_ACTION_PARAM_FACE_DETECT_INTERVAL = 4,
    /// 设置106点平滑的阈值[0.0,1.0](默认值0.5), 值越大, 点越稳定,但相应点会有滞后.
    ST_HUMAN_ACTION_PARAM_SMOOTH_THRESHOLD = 5,
    /// 设置head_pose去抖动的阈值[0.0,1.0](默认值0.5),值越大, pose信息的值越稳定,但相应值会有滞后.
    ST_HUMAN_ACTION_PARAM_HEADPOSE_THRESHOLD = 6,
    /// 设置手势检测每多少帧进行一次 detect (默认有手时30帧detect一次, 无手时10(30/3)帧detect一次). 值越大,cpu占用率越低, 但检测出新人脸的时间越长.
    ST_HUMAN_ACTION_PARAM_HAND_DETECT_INTERVAL = 7,
    /// 设置前后背景检测结果灰度图的方向是否需要旋转（0: 不旋转, 保持竖直; 1: 旋转, 方向和输入图片一致. 默认不旋转)
    ST_HUMAN_ACTION_PARAM_BACKGROUND_RESULT_ROTATE = 8,
    /// 设置每多少帧检测一次人脸. 默认每帧检测一次. 最多每10帧检测一次. 开启隔帧检测后, 只能对拷贝出来的检测结果做镜像.
    ST_HUMAN_ACTION_PARAM_FACE_PROCESS_INTERVAL = 11,
    /// 设置每多少帧检测一次手势. 默认每帧检测一次. 最多每10帧检测一次. 开启隔帧检测后, 只能对拷贝出来的检测结果做镜像.
    ST_HUMAN_ACTION_PARAM_HAND_PROCESS_INTERVAL = 12,
    /// 设置每多少帧检测一次背景. 默认每帧检测一次. 最多每10帧检测一次. 开启隔帧检测后, 只能对拷贝出来的检测结果做镜像.
    ST_HUMAN_ACTION_PARAM_BACKGROUND_PROCESS_INTERVAL = 13
} st_human_action_type;

/// @brief 设置human_action参数
/// @param[in] handle 已初始化的human_action句柄
/// @param[in] type human_action参数关键字,例如ST_HUMAN_ACTION_PARAM_BACKGROUND_MAX_SIZE
/// @param[in] value 参数取值
/// @return 成功返回ST_OK,错误则返回错误码,错误码定义在st_mobile_common.h 中,如ST_E_FAIL等
ST_SDK_API st_result_t
st_mobile_human_action_setparam(
    st_handle_t handle,
    st_human_action_type type,
    float value
);

/// @brief 镜像human_action检测结果. 隔帧检测时, 需要将检测结果拷贝出来再镜像
/// @param[in] image_width 检测human_action的图像的宽度(以像素为单位)
/// @param[in,out] p_human_action 需要镜像的human_action检测结果
ST_SDK_API void
st_mobile_human_action_mirror(
    int image_width,
    st_mobile_human_action_t *p_human_action
);

#endif  // INCLUDE_STMOBILE_ST_MOBILE_HUMAN_ACTION_H_
