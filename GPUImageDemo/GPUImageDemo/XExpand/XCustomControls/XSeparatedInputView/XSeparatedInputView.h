//
//  XSeparatedInputView.h
//  LEVE
//
//  Created by canoe on 2017/12/5.
//  Copyright © 2017年 dashuju. All rights reserved.
//

#import <UIKit/UIKit.h>

//单个输入验证码  中间间隔断

@interface XSeparatedInputView : UIView
/**背景图片*/
@property (nonatomic,copy)NSString *backgroudImageName;
/**验证码/密码的位数*/
@property (nonatomic,assign)NSInteger numberOfVertificationCode;
/**控制验证码/密码是否密文显示*/
@property (nonatomic,assign)bool secureTextEntry;
/**验证码/密码内容，可以通过该属性拿到验证码/密码输入框中验证码/密码的内容*/
@property (nonatomic,copy)NSString *vertificationCode;

-(void)becomeFirstResponder;
-(void)resignFirstResponder;

/** 每一次输入都会回调 */
@property (nonatomic,copy) void (^didEditMaxNum)(NSString *str);

/** 结束编辑 */
@property (nonatomic,copy) void (^didEndEditing)(NSString *str);

@end
