//
//  HYCircleProgressView.h
//  downLoadBtn
//
//  Created by 上官惠阳 on 2016/12/23.
//  Copyright © 2016年 上官惠阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYCircleProgressView : UIView
@property (nonatomic, assign) IBInspectable CGFloat progress; //进度比例
@property (nonatomic, assign) IBInspectable CGFloat filledLineWidth; //进度条宽度
@property (nonatomic, assign) IBInspectable CGFloat emptyLineWidth; //圆边框宽度
@property (nonatomic, assign) IBInspectable CGFloat radius; //圆边框的半径
@property (nonatomic, assign) IBInspectable BOOL filledLineStyleOuter; //yes进度条在里面  on进度条在外面 默认为进度条在外面
@end
