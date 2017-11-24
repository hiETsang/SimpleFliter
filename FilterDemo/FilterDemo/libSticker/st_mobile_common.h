#ifndef INCLUDE_STMOBILE_ST_MOBILE_COMMON_H_
#define INCLUDE_STMOBILE_ST_MOBILE_COMMON_H_

/// @defgroup st_common st common
/// @brief common definitions for st libs
/// @{


#ifdef _MSC_VER
#   ifdef __cplusplus
#       ifdef ST_STATIC_LIB
#           define ST_SDK_API  extern "C"
#       else
#           ifdef SDK_EXPORTS
#               define ST_SDK_API extern "C" __declspec(dllexport)
#           else
#               define ST_SDK_API extern "C" __declspec(dllimport)
#           endif
#       endif
#   else
#       ifdef ST_STATIC_LIB
#           define ST_SDK_API
#       else
#           ifdef SDK_EXPORTS
#               define ST_SDK_API __declspec(dllexport)
#           else
#               define ST_SDK_API __declspec(dllimport)
#           endif
#       endif
#   endif
#else /* _MSC_VER */
#   ifdef __cplusplus
#       ifdef SDK_EXPORTS
#           define ST_SDK_API extern "C" __attribute__((visibility ("default")))
#       else
#           define ST_SDK_API extern "C"
#       endif
#   else
#       ifdef SDK_EXPORTS
#           define ST_SDK_API __attribute__((visibility ("default")))
#       else
#           define ST_SDK_API
#       endif
#   endif
#endif

/// st handle declearation
typedef void *st_handle_t;

/// st result declearation
typedef int   st_result_t;

#define ST_OK                           0   ///< 正常运行

#define ST_E_INVALIDARG                 -1  ///< 无效参数
#define ST_E_HANDLE                     -2  ///< 句柄错误
#define ST_E_OUTOFMEMORY                -3  ///< 内存不足
#define ST_E_FAIL                       -4  ///< 内部错误
#define ST_E_DELNOTFOUND                -5  ///< 定义缺失
#define ST_E_INVALID_PIXEL_FORMAT       -6  ///< 不支持的图像格式
#define ST_E_FILE_NOT_FOUND             -7  ///< 文件不存在
#define ST_E_INVALID_FILE_FORMAT        -8  ///< 文件格式不正确导致加载失败
#define ST_E_FILE_EXPIRE                -9  ///< 文件过期

#define ST_E_INVALID_AUTH               -13 ///< license不合法
#define ST_E_INVALID_APPID              -14 ///< 包名错误
#define ST_E_AUTH_EXPIRE                -15 ///< license过期
#define ST_E_UUID_MISMATCH              -16 ///< UUID不匹配
#define ST_E_ONLINE_AUTH_CONNECT_FAIL   -17 ///< 在线验证连接失败
#define ST_E_ONLINE_AUTH_TIMEOUT        -18 ///< 在线验证超时
#define ST_E_ONLINE_AUTH_INVALID        -19 ///< 在线签发服务器端返回错误
#define ST_E_LICENSE_IS_NOT_ACTIVABLE   -20 ///< license不可激活
#define ST_E_ACTIVE_FAIL                -21 ///< license激活失败
#define ST_E_ACTIVE_CODE_INVALID        -22 ///< 激活码无效
#define ST_E_NO_CAPABILITY              -23 ///< license文件没有提供这个能力
#define ST_E_GET_UDID_FAIL              -24 ///< 在线签发绑定机器码的license时,无法获取机器唯一标识
#define ST_E_SUBMODEL_NOT_EXIST         -26 ///< 子模型不存在
#define ST_E_ONLINE_ACTIVATE_NO_NEED    -27 ///< 不需要在线激活
#define ST_E_ONLINE_ACTIVATE_FAIL       -28 ///< 在线激活失败
#define ST_E_ONLINE_ACTIVATE_CODE_INVALID -29 ///< 在线激活码无效
#define ST_E_ONLINE_ACTIVATE_CONNECT_FAIL -30 ///< 在线激活连接失败

#ifndef CHECK_FLAG
#define CHECK_FLAG(action,flag) (((action)&(flag)) == flag)
#endif

/// st rectangle definition
typedef struct st_rect_t {
    int left;   ///< 矩形最左边的坐标
    int top;    ///< 矩形最上边的坐标
    int right;  ///< 矩形最右边的坐标
    int bottom; ///< 矩形最下边的坐标
} st_rect_t;

/// st float type point definition
typedef struct st_pointf_t {
    float x;    ///< 点的水平方向坐标,为浮点数
    float y;    ///< 点的竖直方向坐标,为浮点数
} st_pointf_t;

/// st integer type point definition
typedef struct st_pointi_t {
    int x;      ///< 点的水平方向坐标,为整数
    int y;      ///< 点的竖直方向坐标,为整数
} st_pointi_t;

/// st pixel format definition
typedef enum {
    ST_PIX_FMT_GRAY8,   ///< Y    1        8bpp ( 单通道8bit灰度像素 )
    ST_PIX_FMT_YUV420P, ///< YUV  4:2:0   12bpp ( 3通道, 一个亮度通道, 另两个为U分量和V分量通道, 所有通道都是连续的. 只支持I420)
    ST_PIX_FMT_NV12,    ///< YUV  4:2:0   12bpp ( 2通道, 一个通道是连续的亮度通道, 另一通道为UV分量交错 )
    ST_PIX_FMT_NV21,    ///< YUV  4:2:0   12bpp ( 2通道, 一个通道是连续的亮度通道, 另一通道为VU分量交错 )
    ST_PIX_FMT_BGRA8888,///< BGRA 8:8:8:8 32bpp ( 4通道32bit BGRA 像素 )
    ST_PIX_FMT_BGR888,  ///< BGR  8:8:8   24bpp ( 3通道24bit BGR 像素 )
    ST_PIX_FMT_RGBA8888,///< RGBA 8:8:8:8 32bpp ( 4通道32bit RGBA 像素 )
    ST_PIX_FMT_RGB888   ///< RGB  8:8:8   24bpp ( 3通道24bit RGB 像素 )
} st_pixel_format;

/// image rotate type definition
typedef enum {
    ST_CLOCKWISE_ROTATE_0 = 0,  ///< 图像不需要旋转,图像中的人脸为正脸
    ST_CLOCKWISE_ROTATE_90 = 1, ///< 图像需要顺时针旋转90度,使图像中的人脸为正
    ST_CLOCKWISE_ROTATE_180 = 2,///< 图像需要顺时针旋转180度,使图像中的人脸为正
    ST_CLOCKWISE_ROTATE_270 = 3 ///< 图像需要顺时针旋转270度,使图像中的人脸为正
} st_rotate_type;

/// @brief 时间戳定义
typedef struct st_time_t {
    long int tv_sec;    ///< 秒
    long int tv_usec;   ///< 微秒
}st_time_t;

/// 图像格式定义
typedef struct st_image_t {
    unsigned char *data;    ///< 图像数据指针
    st_pixel_format pixel_format;   ///< 像素格式
    int width;              ///< 宽度(以像素为单位)
    int height;             ///< 高度(以像素为单位)
    int stride;             ///< 跨度, 即每行所占的字节数
    st_time_t time_stamp;   ///< 时间戳
} st_image_t;

/// @brief 人脸106点信息
typedef struct st_mobile_106_t {
    st_rect_t rect;         ///< 代表面部的矩形区域
    float score;            ///< 置信度
    st_pointf_t points_array[106];  ///< 人脸106关键点的数组
    float visibility_array[106];    ///< 对应点的能见度,点未被遮挡1.0,被遮挡0.0
    float yaw;              ///< 水平转角,真实度量的左负右正
    float pitch;            ///< 俯仰角,真实度量的上负下正
    float roll;             ///< 旋转角,真实度量的左负右正
    float eye_dist;         ///< 两眼间距
    int ID;                 ///< faceID: 每个检测到的人脸拥有唯一的faceID.人脸跟踪丢失以后重新被检测到,会有一个新的faceID
} st_mobile_106_t, *p_st_mobile_106_t;

/// @brief track106配置选项,对应st_mobile_tracker_106_create和st_mobile_human_action_create中的config参数,具体配置如下：
// 使用单线程或双线程track：处理图片必须使用单线程,处理视频建议使用多线程 (创建human_action handle建议使用ST_MOBILE_DETECT_MODE_VIDEO/ST_MOBILE_DETECT_MODE_IMAGE)
#define ST_MOBILE_TRACKING_MULTI_THREAD         0x00000000  ///< 多线程,功耗较多,卡顿较少
#define ST_MOBILE_TRACKING_SINGLE_THREAD        0x00010000  ///< 单线程,功耗较少,对于性能弱的手机,会偶尔有卡顿现象
#define ST_MOBILE_TRACKING_ENABLE_DEBOUNCE      0x00000010  ///< 打开人脸106点和三维旋转角度去抖动
#define ST_MOBILE_TRACKING_ENABLE_FACE_ACTION   0x00000020  ///< 检测脸部动作：张嘴、眨眼、抬眉、点头、摇头

/// @brief 人脸检测结果
typedef struct st_mobile_face_t {
    st_mobile_106_t face106;            ///< 人脸信息，包含矩形框、106点、head pose信息等
    st_pointf_t *p_extra_face_points;   ///< 眼睛、眉毛、嘴唇关键点. 没有检测到时为NULL
    int extra_face_points_count;        ///< 眼睛、眉毛、嘴唇关键点个数. 检测到时为ST_MOBILE_EXTRA_FACE_POINTS_COUNT, 没有检测到时为0
    st_pointf_t *p_eyeball_center;      ///< 眼球中心关键点. 没有检测到时为NULL
    int eyeball_center_points_count;    ///< 眼球中心关键点个数. 检测到时为ST_MOBILE_EYEBALL_CENTER_POINTS_COUNT, 没有检测到时为0
    st_pointf_t *p_eyeball_contour;     ///< 眼球轮廓关键点. 没有检测到时为NULL
    int eyeball_contour_points_count;   ///< 眼球轮廓关键点个数. 检测到时为ST_MOBILE_EYEBALL_CONTOUR_POINTS_COUNT, 没有检测到时为0
    unsigned long long face_action;     ///< 脸部动作
} st_mobile_face_t, *p_st_mobile_face_t;


/// @brief 设置眨眼动作的阈值,置信度为[0,1], 默认阈值为0.5
ST_SDK_API void
st_mobile_set_eyeblink_threshold(
    float threshold
);
/// @brief 设置张嘴动作的阈值,置信度为[0,1], 默认阈值为0.5
ST_SDK_API void
st_mobile_set_mouthah_threshold(
    float threshold
);
/// @brief 设置摇头动作的阈值,置信度为[0,1], 默认阈值为0.5
ST_SDK_API void
st_mobile_set_headyaw_threshold(
    float threshold
);
/// @brief 设置点头动作的阈值,置信度为[0,1], 默认阈值为0.5
ST_SDK_API void
st_mobile_set_headpitch_threshold(
    float threshold
);
/// @brief 设置挑眉毛动作的阈值,置信度为[0,1], 默认阈值为0.5
ST_SDK_API void
st_mobile_set_browjump_threshold(
    float threshold
);

/// @brief 设置人脸106点平滑的阈值. 若不设置, 使用默认值. 默认值0.8, 建议取值范围：[0.0, 1.0]. 阈值越大, 去抖动效果越好, 跟踪延时越大
ST_SDK_API void
st_mobile_set_smooth_threshold(
    float threshold
);

/// @brief 设置人脸三维旋转角度去抖动的阈值. 若不设置, 使用默认值. 默认值0.5, 建议取值范围：[0.0, 1.0]. 阈值越大, 去抖动效果越好, 跟踪延时越大
ST_SDK_API void
st_mobile_set_headpose_threshold(
    float threshold
);

/// 支持的颜色转换格式
typedef enum {
    ST_BGRA_YUV420P = 0,    ///< ST_PIX_FMT_BGRA8888到ST_PIX_FMT_YUV420P转换
    ST_BGR_YUV420P = 1,     ///< ST_PIX_FMT_BGR888到ST_PIX_FMT_YUV420P转换
    ST_BGRA_NV12 = 2,       ///< ST_PIX_FMT_BGRA8888到ST_PIX_FMT_NV12转换
    ST_BGR_NV12 = 3,        ///< ST_PIX_FMT_BGR888到ST_PIX_FMT_NV12转换
    ST_BGRA_NV21 = 4,       ///< ST_PIX_FMT_BGRA8888到ST_PIX_FMT_NV21转换
    ST_BGR_NV21 = 5,        ///< ST_PIX_FMT_BGR888到ST_PIX_FMT_NV21转换
    ST_YUV420P_BGRA = 6,    ///< ST_PIX_FMT_YUV420P到ST_PIX_FMT_BGRA8888转换
    ST_YUV420P_BGR = 7,     ///< ST_PIX_FMT_YUV420P到ST_PIX_FMT_BGR888转换
    ST_NV12_BGRA = 8,       ///< ST_PIX_FMT_NV12到ST_PIX_FMT_BGRA8888转换
    ST_NV12_BGR = 9,        ///< ST_PIX_FMT_NV12到ST_PIX_FMT_BGR888转换
    ST_NV21_BGRA = 10,      ///< ST_PIX_FMT_NV21到ST_PIX_FMT_BGRA8888转换
    ST_NV21_BGR = 11,       ///< ST_PIX_FMT_NV21到ST_PIX_FMT_BGR888转换
    ST_BGRA_GRAY = 12,      ///< ST_PIX_FMT_BGRA8888到ST_PIX_FMT_GRAY8转换
    ST_BGR_BGRA = 13,       ///< ST_PIX_FMT_BGR888到ST_PIX_FMT_BGRA8888转换
    ST_BGRA_BGR = 14,       ///< ST_PIX_FMT_BGRA8888到ST_PIX_FMT_BGR888转换
    ST_YUV420P_GRAY = 15,   ///< ST_PIX_FMT_YUV420P到ST_PIX_FMT_GRAY8转换
    ST_NV12_GRAY = 16,      ///< ST_PIX_FMT_NV12到ST_PIX_FMT_GRAY8转换
    ST_NV21_GRAY = 17,      ///< ST_PIX_FMT_NV21到ST_PIX_FMT_GRAY8转换
    ST_BGR_GRAY = 18,       ///< ST_PIX_FMT_BGR888到ST_PIX_FMT_GRAY8转换
    ST_GRAY_YUV420P = 19,   ///< ST_PIX_FMT_GRAY8到ST_PIX_FMT_YUV420P转换
    ST_GRAY_NV12 = 20,      ///< ST_PIX_FMT_GRAY8到ST_PIX_FMT_NV12转换
    ST_GRAY_NV21 = 21,      ///< ST_PIX_FMT_GRAY8到ST_PIX_FMT_NV21转换
    ST_NV12_YUV420P = 22,   ///< ST_PIX_FMT_NV12到ST_PIX_FMT_YUV420P转换
    ST_NV21_YUV420P = 23,   ///< ST_PIX_FMT_NV21到ST_PIX_FMT_YUV420P转换
    ST_NV21_RGBA = 24,      ///< ST_PIX_FMT_NV21到ST_PIX_FMT_RGBA8888转换
    ST_BGR_RGBA = 25,       ///< ST_PIX_FMT_BGR888到ST_PIX_FMT_RGBA8888转换
    ST_BGRA_RGBA = 26,      ///< ST_PIX_FMT_BGRA8888到ST_PIX_FMT_RGBA8888转换
    ST_RGBA_BGRA = 27,      ///< ST_PIX_FMT_RGBA8888到ST_PIX_FMT_BGRA8888转换
    ST_GRAY_BGR = 28,       ///< ST_PIX_FMT_GRAY8到ST_PIX_FMT_BGR888转换
    ST_GRAY_BGRA = 29,      ///< ST_PIX_FMT_GRAY8到ST_PIX_FMT_BGRA8888转换
    ST_NV12_RGBA = 30,      ///< ST_PIX_FMT_NV12到ST_PIX_FMT_RGBA8888转换
    ST_NV12_RGB = 31,       ///< ST_PIX_FMT_NV12到ST_PIX_FMT_RGB888转换
    ST_RGBA_NV12 = 32,      ///< ST_PIX_FMT_RGBA8888到ST_PIX_FMT_NV12转换
    ST_RGB_NV12 = 33,       ///< ST_PIX_FMT_RGB888到ST_PIX_FMT_NV12转换
    ST_RGBA_BGR = 34,       ///< ST_PIX_FMT_RGBA888到ST_PIX_FMT_BGR888转换
    ST_BGRA_RGB = 35,       ///< ST_PIX_FMT_BGRA888到ST_PIX_FMT_RGB888转换
    ST_RGBA_GRAY = 36,      ///< ST_PIX_FMT_RGBA8888到ST_PIX_FMT_GRAY8转换
    ST_RGB_GRAY = 37,       ///< ST_PIX_FMT_RGB888到ST_PIX_FMT_GRAY8转换
    ST_RGB_BGR = 38,        ///< ST_PIX_FMT_RGB888到ST_PIX_FMT_BGR888转换
    ST_BGR_RGB = 39,        ///< ST_PIX_FMT_BGR888到ST_PIX_FMT_RGB888转换
    ST_YUV420P_RGBA = 40,   ///< ST_PIX_FMT_YUV420P到ST_PIX_FMT_RGBA8888转换
    ST_RGBA_YUV420P = 41,   ///< ST_PIX_FMT_RGBA8888到ST_PIX_FMT_YUV420P转换
    ST_RGBA_NV21 = 42       ///< ST_PIX_FMT_RGBA8888到ST_PIX_FMT_NV21转换
} st_color_convert_type;

/// @brief 进行颜色格式转换, 不建议使用关于YUV420P的转换,速度较慢
/// @param[in] image_src 用于待转换的图像数据
/// @param[out] image_dst 转换后的图像数据
/// @param[in] image_width 用于转换的图像的宽度(以像素为单位)
/// @param[in] image_height 用于转换的图像的高度(以像素为单位)
/// @param[in] type 需要转换的颜色格式
/// @return 正常返回ST_OK,否则返回错误类型
ST_SDK_API st_result_t
st_mobile_color_convert(
    const unsigned char *image_src,
    unsigned char *image_dst,
    int image_width,
    int image_height,
    st_color_convert_type type
);

/// @brief 旋转图像
/// @param[in] image_src 待旋转的图像数据
/// @param[out] image_dst 旋转后的图像数据, 由客户分配内存 (不能和image_src使用相同的内存)。旋转后，图像会变成紧凑的（没有padding）
/// @param[in] image_width 待旋转的图像的宽度, 旋转后图像的宽度可能会发生变化，由用户处理
/// @param[in] image_height 待旋转的图像的高度, 旋转后图像的高度可能会发生变化，由用户处理
/// @param[in] image_stride 待旋转的图像的跨度, 旋转后图像的跨度可能会发生变化，由用户处理
/// @param[in] pixel_format 待旋转的图像的格式
/// @param[in] rotate_type 旋转角度
ST_SDK_API st_result_t
st_mobile_image_rotate(
    const unsigned char *image_src,
    unsigned char *image_dst,
    int image_width,
    int image_height,
    int image_stride,
    st_pixel_format pixel_format,
    st_rotate_type rotate_type
);

/// @}

#endif // INCLUDE_STMOBILE_ST_MOBILE_COMMON_H_
