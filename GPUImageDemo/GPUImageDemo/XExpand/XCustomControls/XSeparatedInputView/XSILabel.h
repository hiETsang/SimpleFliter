//
//  XSILabel.h
//  LEVE
//
//  Created by canoe on 2017/12/5.
//  Copyright © 2017年 dashuju. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XSILabel : UILabel

/**验证码/密码的位数*/
@property (nonatomic,assign)NSInteger numberOfVertificationCode;
/**控制验证码/密码是否密文显示*/
@property (nonatomic,assign)bool secureTextEntry;  

@end
