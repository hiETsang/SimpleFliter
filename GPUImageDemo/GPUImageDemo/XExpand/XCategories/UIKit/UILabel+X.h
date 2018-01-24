//
//  UILabel+X.h
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/18.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (X)

+(instancetype)labelWithTitle:(NSString *)title
                         font:(UIFont *)font
                    textColor:(UIColor *)color
                textAlignment:(NSTextAlignment)textAlignment;

@end

#pragma mark - 修改间距
@interface UILabel (XSpace)

/**
 *  改变行间距
 */
- (void)changeLineSpace:(float)space;
/**
 *  改变字间距
 */
- (void)changeWordSpace:(float)space;
/**
 *  改变行间距和字间距
 */
- (void)changeSpaceWithLineSpace:(float)lineSpace WordSpace:(float)wordSpace;

@end

#pragma mark - 自动下载非系统字体(苹果提供的其他字体)
@interface UILabel (XAutoDownloadFont)

-(void)setCustomFontWithName:(NSString *)fontName size:(CGFloat)fontSize;

@end
