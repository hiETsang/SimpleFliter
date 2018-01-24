//
//  XSeparatedInputView.m
//  LEVE
//
//  Created by canoe on 2017/12/5.
//  Copyright © 2017年 dashuju. All rights reserved.
//

#import "XSeparatedInputView.h"
#import "XSILabel.h"

@interface XSeparatedInputView() <UITextFieldDelegate>

/**用于获取键盘输入的内容，实际不显示*/
@property (nonatomic,strong)UITextField *textField;
/**验证码/密码输入框的背景图片*/
@property (nonatomic,strong)UIImageView *backgroundImageView;
/**实际用于显示验证码/密码的label*/
@property (nonatomic,strong)XSILabel *label;

@end

@implementation XSeparatedInputView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 设置透明背景色，保证vertificationCodeInputView显示的frame为backgroundImageView的frame
        self.backgroundColor = [UIColor clearColor];
        // 设置验证码/密码的位数默认为四位
        self.numberOfVertificationCode = 4;
        /* 调出键盘的textField */
        self.textField = [[UITextField alloc]initWithFrame:self.bounds];
        // 隐藏textField，通过点击IDVertificationCodeInputView使其成为第一响应者，来弹出键盘
        self.textField.hidden =YES;
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        self.textField.delegate = self;
        self.textField.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        // 将textField放到最后边
        [self insertSubview:self.textField atIndex:0];
        /* 添加用于显示验证码/密码的label */
        self.label = [[XSILabel alloc]initWithFrame:self.bounds];
        self.label.numberOfVertificationCode = self.numberOfVertificationCode;
        self.label.secureTextEntry = self.secureTextEntry;
        self.label.font = self.textField.font;
        [self addSubview:self.label];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}
- (void)setBackgroudImageName:(NSString *)backgroudImageName {
    _backgroudImageName = backgroudImageName;
    // 若用户设置了背景图片，则添加背景图片
    self.backgroundImageView = [[UIImageView alloc]initWithFrame:self.bounds];
    self.backgroundImageView.image = [UIImage imageNamed:self.backgroudImageName];
    // 将背景图片插入到label的后边，避免遮挡验证码/密码的显示
    [self insertSubview:self.backgroundImageView belowSubview:self.label];
}
- (void)setNumberOfVertificationCode:(NSInteger)numberOfVertificationCode {
    _numberOfVertificationCode = numberOfVertificationCode;
    // 保持label的验证码/密码位数与IDVertificationCodeInputView一致，此时label一定已经被创建
    self.label.numberOfVertificationCode = _numberOfVertificationCode;
}
- (void)setSecureTextEntry:(bool)secureTextEntry {
    _secureTextEntry = secureTextEntry;
    self.label.secureTextEntry =_secureTextEntry;
}
-(void)becomeFirstResponder{
    [self.textField becomeFirstResponder];
}

-(void)resignFirstResponder
{
    [self.textField resignFirstResponder];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textField becomeFirstResponder];
}

-(void)textFieldDidChange:(NSNotification *)notifi
{
    if (self.didEditMaxNum) {
        self.didEditMaxNum(self.textField.text);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // 判断是不是“删除”字符
    if (string.length !=0) {//不是“删除”字符
        // 判断验证码/密码的位数是否达到预定的位数
        if (textField.text.length < self.numberOfVertificationCode) {
            self.label.text = [textField.text stringByAppendingString:string];
            self.vertificationCode = self.label.text;
            if (self.label.text.length == self.numberOfVertificationCode) {
                NSLog(@"tag 已经输入完成验证码了vertificationCode= %@",_vertificationCode);
            }
            return YES;
        } else {
            return NO;
        }
    } else {//是“删除”字符
        if (textField.text.length > 0) {
            self.label.text = [textField.text substringToIndex:textField.text.length -1];
            self.vertificationCode = self.label.text;
            return YES;
        }else
        {
            return NO;
        }
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.didEndEditing) {
        self.didEndEditing(textField.text);
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
