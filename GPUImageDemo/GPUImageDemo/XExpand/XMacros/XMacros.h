//
//  XMacros.h
//  CommonConfigDemo
//
//  Created by canoe on 2017/11/28.
//  Copyright © 2017年 canoe. All rights reserved.
//

#ifndef XMacros_h
#define XMacros_h

// MainScreen Height&Width
#define KScreenHeight      [[UIScreen mainScreen] bounds].size.height
#define KScreenWidth       [[UIScreen mainScreen] bounds].size.width

//不同屏幕尺寸字体适配
#define kScreenWidthRatio  (KScreenWidth / 375.0)
#define kScreenHeightRatio (KScreenHeight / 667.0)
#define kRatioWidth(x)  ceilf((x) * kScreenWidthRatio)
#define kRatioHeight(x) ceilf((x) * kScreenHeightRatio)

//色值
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)
// rgb颜色转换（16进制->10进制）
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//App版本号
#define appMPVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]


#endif /* XMacros_h */
