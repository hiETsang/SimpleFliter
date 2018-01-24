//
//  NSString+X.m
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/4.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import "NSString+X.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@implementation NSString (X)

@end

#pragma mark - 正则表达式
@implementation NSString (XPredicate)
- (BOOL)isValidateWithRegex:(NSString *)regex
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pre evaluateWithObject:self];
}

/* 邮箱验证 MODIFIED BY HELENSONG */
- (BOOL)isValidEmail
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

/* 手机号码验证 MODIFIED BY HELENSONG */
- (BOOL)isValidPhoneNum
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(147)|(15[^4,\\D])|(17[0-9])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:self];
}

/* 车牌号验证 MODIFIED BY HELENSONG */
- (BOOL)isValidCarNo
{
    NSString *carRegex = @"^[A-Za-z]{1}[A-Za-z_0-9]{5}$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    return [carTest evaluateWithObject:self];
}

/** 网址验证 */
- (BOOL)isValidUrl
{
    NSString *regex = @"^((http)|(https))+:[^\\s]+\\.[^\\s]*$";
    return [self isValidateWithRegex:regex];
}

/** 邮政编码 */
- (BOOL)isValidPostalcode {
    NSString *phoneRegex = @"^[0-8]\\d{5}(?!\\d)$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:self];
}

/** 纯汉字 */
- (BOOL)isValidChinese;
{
    NSString *phoneRegex = @"^[\u4e00-\u9fa5]+$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:self];
}

- (BOOL)isValidIP;
{
    NSString *regex = [NSString stringWithFormat:@"^(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})$"];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL rc = [pre evaluateWithObject:self];
    
    if (rc) {
        NSArray *componds = [self componentsSeparatedByString:@","];
        
        BOOL v = YES;
        for (NSString *s in componds) {
            if (s.integerValue > 255) {
                v = NO;
                break;
            }
        }
        
        return v;
    }
    
    return NO;
}

/** 身份证验证 refer to http://blog.csdn.net/afyzgh/article/details/16965107 */
- (BOOL)isValidIdCardNum
{
    NSString *value = [self copy];
    value = [value stringByReplacingOccurrencesOfString:@"X" withString:@"x"];
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    int length = 0;
    if (!value) {
        return NO;
    }else {
        length = (int)value.length;
        if (length != 15 && length !=18) {
            return NO;
        }
    }
    // 省份代码
    NSArray *areasArray =@[@"11", @"12", @"13", @"14", @"15", @"21", @"22", @"23", @"31", @"32", @"33", @"34", @"35", @"36", @"37", @"41", @"42", @"43", @"44", @"45", @"46", @"50", @"51", @"52", @"53", @"54", @"61", @"62", @"63", @"64", @"65", @"71", @"81", @"82", @"91"];
    NSString *valueStart2 = [value substringToIndex:2];
    BOOL areaFlag = NO;
    for (NSString *areaCode in areasArray) {
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag = YES;
            break;
        }
    }
    if (!areaFlag) {
        return NO;
    }
    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;
    int year = 0;
    switch (length) {
        case 15:
            year = [value substringWithRange:NSMakeRange(6,2)].intValue +1900;
            if (year % 4 ==0 || (year % 100 ==0 && year % 4 ==0)) {
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"                   options:NSRegularExpressionCaseInsensitive error:nil];// 测试出生日期的合法性
            }else {
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"           options:NSRegularExpressionCaseInsensitive error:nil];// 测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value options:NSMatchingReportProgress range:NSMakeRange(0, value.length)];
            if(numberofMatch > 0) {
                return YES;
            }else {
                return NO;
            }
        case 18:
            year = [value substringWithRange:NSMakeRange(6,4)].intValue;
            if (year % 4 ==0 || (year % 100 ==0 && year % 4 ==0)) {
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}19|20[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$"options:NSRegularExpressionCaseInsensitive error:nil];// 测试出生日期的合法性
                
            }else {
                regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[1-9][0-9]{5}19|20[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$"
                                                                         options:NSRegularExpressionCaseInsensitive error:nil];// 测试出生日期的合法性
            }
            numberofMatch = [regularExpression numberOfMatchesInString:value options:NSMatchingReportProgress range:NSMakeRange(0, value.length)];
            if(numberofMatch > 0) {
                int S = ([value substringWithRange:NSMakeRange(0,1)].intValue + [value substringWithRange:NSMakeRange(10,1)].intValue) *7 + ([value substringWithRange:NSMakeRange(1,1)].intValue + [value substringWithRange:NSMakeRange(11,1)].intValue) *9 + ([value substringWithRange:NSMakeRange(2,1)].intValue + [value substringWithRange:NSMakeRange(12,1)].intValue) *10 + ([value substringWithRange:NSMakeRange(3,1)].intValue + [value substringWithRange:NSMakeRange(13,1)].intValue) *5 + ([value substringWithRange:NSMakeRange(4,1)].intValue + [value substringWithRange:NSMakeRange(14,1)].intValue) *8 + ([value substringWithRange:NSMakeRange(5,1)].intValue + [value substringWithRange:NSMakeRange(15,1)].intValue) *4 + ([value substringWithRange:NSMakeRange(6,1)].intValue + [value substringWithRange:NSMakeRange(16,1)].intValue) *2 + [value substringWithRange:NSMakeRange(7,1)].intValue *1 + [value substringWithRange:NSMakeRange(8,1)].intValue *6 + [value substringWithRange:NSMakeRange(9,1)].intValue *3;
                int Y = S % 11;
                NSString *M = @"F";
                NSString *JYM = @"10X98765432";
                M = [JYM substringWithRange:NSMakeRange(Y,1)]; // 判断校验位
                if ([M isEqualToString:[[value substringWithRange:NSMakeRange(17,1)] uppercaseString]]) {
                    return YES;// 检测ID的校验位
                }else {
                    return NO;
                }
            }else {
                return NO;
            }
            
        default:
            return NO;
    }
    return NO;
}

- (BOOL)isValidWithMinLenth:(NSInteger)minLenth
                   maxLenth:(NSInteger)maxLenth
             containChinese:(BOOL)containChinese
        firstCannotBeDigtal:(BOOL)firstCannotBeDigtal;
{
    //  [\u4e00-\u9fa5A-Za-z0-9_]{4,20}
    NSString *hanzi = containChinese ? @"\u4e00-\u9fa5" : @"";
    NSString *first = firstCannotBeDigtal ? @"^[a-zA-Z_]" : @"";
    
    NSString *regex = [NSString stringWithFormat:@"%@[%@A-Za-z0-9_]{%d,%d}", first, hanzi, (int)(minLenth-1), (int)(maxLenth-1)];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pre evaluateWithObject:self];
}

- (BOOL)isValidWithMinLenth:(NSInteger)minLenth
                   maxLenth:(NSInteger)maxLenth
             containChinese:(BOOL)containChinese
              containDigtal:(BOOL)containDigtal
              containLetter:(BOOL)containLetter
      containOtherCharacter:(NSString *)containOtherCharacter
        firstCannotBeDigtal:(BOOL)firstCannotBeDigtal;
{
    NSString *hanzi = containChinese ? @"\u4e00-\u9fa5" : @"";
    NSString *first = firstCannotBeDigtal ? @"^[a-zA-Z_]" : @"";
    NSString *lengthRegex = [NSString stringWithFormat:@"(?=^.{%@,%@}$)", @(minLenth), @(maxLenth)];
    NSString *digtalRegex = containDigtal ? @"(?=(.*\\d.*){1})" : @"";
    NSString *letterRegex = containLetter ? @"(?=(.*[a-zA-Z].*){1})" : @"";
    NSString *characterRegex = [NSString stringWithFormat:@"(?:%@[%@A-Za-z0-9%@]+)", first, hanzi, containOtherCharacter ? containOtherCharacter : @""];
    NSString *regex = [NSString stringWithFormat:@"%@%@%@%@", lengthRegex, digtalRegex, letterRegex, characterRegex];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pre evaluateWithObject:self];
}

/** 去掉两端空格和换行符 */
- (NSString *)stringByTrimmingBlank
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/** 去掉html格式 */
- (NSString *)removeHtmlFormat;
{
    NSString *str = [NSString stringWithFormat:@"%@", self];
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*>" options:NSRegularExpressionCaseInsensitive error:&error];
    if (!error) {
        str = [regex stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, str.length) withTemplate:@"$2$1"];
    } else {
        NSLog(@"%@", error);
    }
    
    NSArray *html_code = @[
                           @"\"", @"'", @"&", @"<", @">",
                           @"", @"¡", @"¢", @"£", @"¤",
                           @"¥", @"¦", @"§", @"¨", @"©",
                           @"ª", @"«", @"¬", @"", @"®",
                           @"¯", @"°", @"±", @"²", @"³",
                           
                           @"´", @"µ", @"¶", @"·", @"¸",
                           @"¹", @"º", @"»", @"¼", @"½",
                           @"¾", @"¿", @"×", @"÷", @"À",
                           @"Á", @"Â", @"Ã", @"Ä", @"Å",
                           @"Æ", @"Ç", @"È", @"É", @"Ê",
                           
                           @"Ë", @"Ì", @"Í", @"Î", @"Ï",
                           @"Ð", @"Ñ", @"Ò", @"Ó", @"Ô",
                           @"Õ", @"Ö", @"Ø", @"Ù", @"Ú",
                           @"Û", @"Ü", @"Ý", @"Þ", @"ß",
                           @"à", @"á", @"â", @"ã", @"ä",
                           
                           @"å", @"æ", @"ç", @"è", @"é",
                           @"ê", @"ë", @"ì", @"í", @"î",
                           @"ï", @"ð", @"ñ", @"ò", @"ó",
                           @"ô", @"õ", @"ö", @"ø", @"ù",
                           @"ú", @"û", @"ü", @"ý", @"þ",
                           
                           @"ÿ", @"∀", @"∂", @"∃", @"∅",
                           @"∇", @"∈", @"∉", @"∋", @"∏",
                           @"∑", @"−", @"∗", @"√", @"∝",
                           @"∞", @"∠", @"∧", @"∨", @"∩",
                           @"∪", @"∫", @"∴", @"∼", @"≅",
                           
                           @"≈", @"≠", @"≡", @"≤", @"≥",
                           @"⊂", @"⊃", @"⊄", @"⊆", @"⊇",
                           @"⊕", @"⊗", @"⊥", @"⋅", @"Α",
                           @"Β", @"Γ", @"Δ", @"Ε", @"Ζ",
                           @"Η", @"Θ", @"Ι", @"Κ", @"Λ",
                           
                           @"Μ", @"Ν", @"Ξ", @"Ο", @"Π",
                           @"Ρ", @"Σ", @"Τ", @"Υ", @"Φ",
                           @"Χ", @"Ψ", @"Ω", @"α", @"β",
                           @"γ", @"δ", @"ε", @"ζ", @"η",
                           @"θ", @"ι", @"κ", @"λ", @"μ",
                           
                           @"ν", @"ξ", @"ο", @"π", @"ρ",
                           @"ς", @"σ", @"τ", @"υ", @"φ",
                           @"χ", @"ψ", @"ω", @"ϑ", @"ϒ",
                           @"ϖ", @"Œ", @"œ", @"Š", @"š",
                           @"Ÿ", @"ƒ", @"ˆ", @"˜", @"",
                           
                           @"", @"", @"", @"", @"",
                           @"", @"–", @"—", @"‘", @"’",
                           @"‚", @"“", @"”", @"„", @"†",
                           @"‡", @"•", @"…", @"‰", @"′",
                           @"″", @"‹", @"›", @"‾", @"€",
                           
                           @"™", @"←", @"↑", @"→", @"↓",
                           @"↔", @"↵", @"⌈", @"⌉", @"⌊",
                           @"⌋", @"◊", @"♠", @"♣", @"♥",
                           @"♦",
                           ];
    NSArray *code = @[
                      @"&quot;", @"&apos;", @"&amp;", @"&lt;", @"&gt;",
                      @"&nbsp;", @"&iexcl;", @"&cent;", @"&pound;", @"&curren;",
                      @"&yen;", @"&brvbar;", @"&sect;", @"&uml;", @"&copy;",
                      @"&ordf;", @"&laquo;", @"&not;", @"&shy;", @"&reg;",
                      @"&macr;", @"&deg;", @"&plusmn;", @"&sup2;", @"&sup3;",
                      
                      @"&acute;", @"&micro;", @"&para;", @"&middot;", @"&cedil;",
                      @"&sup1;", @"&ordm;", @"&raquo;", @"&frac14;", @"&frac12;",
                      @"&frac34;", @"&iquest;", @"&times;", @"&divide;", @"&Agrave;",
                      @"&Aacute;", @"&Acirc;", @"&Atilde;", @"&Auml;", @"&Aring;",
                      @"&AElig;", @"&Ccedil;", @"&Egrave;", @"&Eacute;", @"&Ecirc;",
                      
                      @"&Euml;", @"&Igrave;", @"&Iacute;", @"&Icirc;", @"&Iuml;",
                      @"&ETH;", @"&Ntilde;", @"&Ograve;", @"&Oacute;", @"&Ocirc;",
                      @"&Otilde;", @"&Ouml;", @"&Oslash;", @"&Ugrave;", @"&Uacute;",
                      @"&Ucirc;", @"&Uuml;", @"&Yacute;", @"&THORN;", @"&szlig;",
                      @"&agrave;", @"&aacute;", @"&acirc;", @"&atilde;", @"&auml;",
                      
                      @"&aring;", @"&aelig;", @"&ccedil;", @"&egrave;", @"&eacute;",
                      @"&ecirc;", @"&euml;", @"&igrave;", @"&iacute;", @"&icirc;",
                      @"&iuml;", @"&eth;", @"&ntilde;", @"&ograve;", @"&oacute;",
                      @"&ocirc;", @"&otilde;", @"&ouml;", @"&oslash;", @"&ugrave;",
                      @"&uacute;", @"&ucirc;", @"&uuml;", @"&yacute;", @"&thorn;",
                      
                      @"&yuml;", @"&forall;", @"&part;", @"&exists;", @"&empty;",
                      @"&nabla;", @"&isin;", @"&notin;", @"&ni;", @"&prod;",
                      @"&sum;", @"&minus;", @"&lowast;", @"&radic;", @"&prop;",
                      @"&infin;", @"&ang;", @"&and;", @"&or;", @"&cap;",
                      @"&cup;", @"&int;", @"&there4;", @"&sim;", @"&cong;",
                      
                      @"&asymp;", @"&ne;", @"&equiv;", @"&le;", @"&ge;",
                      @"&sub;", @"&sup;", @"&nsub;", @"&sube;", @"&supe;",
                      @"&oplus;", @"&otimes;", @"&perp;", @"&sdot;", @"&Alpha;",
                      @"&Beta;", @"&Gamma;", @"&Delta;", @"&Epsilon;", @"&Zeta;",
                      @"&Eta;", @"&Theta;", @"&Iota;", @"&Kappa;", @"&Lambda;",
                      
                      @"&Mu;", @"&Nu;", @"&Xi;", @"&Omicron;", @"&Pi;",
                      @"&Rho;", @"&Sigma;", @"&Tau;", @"&Upsilon;", @"&Phi;",
                      @"&Chi;", @"&Psi;", @"&Omega;", @"&alpha;", @"&beta;",
                      @"&gamma;", @"&delta;", @"&epsilon;", @"&zeta;", @"&eta;",
                      @"&theta;", @"&iota;", @"&kappa;", @"&lambda;", @"&mu;",
                      
                      @"&nu;", @"&xi;", @"&omicron;", @"&pi;", @"&rho;",
                      @"&sigmaf;", @"&sigma;", @"&tau;", @"&upsilon;", @"&phi;",
                      @"&chi;", @"&psi;", @"&omega;", @"&thetasym;", @"&upsih;",
                      @"&piv;", @"&OElig;", @"&oelig;", @"&Scaron;", @"&scaron;",
                      @"&Yuml;", @"&fnof;", @"&circ;", @"&tilde;", @"&ensp;",
                      
                      @"&emsp;", @"&thinsp;", @"&zwnj;", @"&zwj;", @"&lrm;",
                      @"&rlm;", @"&ndash;", @"&mdash;", @"&lsquo;", @"&rsquo;",
                      @"&sbquo;", @"&ldquo;", @"&rdquo;", @"&bdquo;", @"&dagger;",
                      @"&Dagger;", @"&bull;", @"&hellip;", @"&permil;", @"&prime;",
                      @"&Prime;", @"&lsaquo;", @"&rsaquo;", @"&oline;", @"&euro;",
                      
                      @"&trade;", @"&larr;", @"&uarr;", @"&rarr;", @"&darr;",
                      @"&harr;", @"&crarr;", @"&lceil;", @"&rceil;", @"&lfloor;",
                      @"&rfloor;", @"&loz;", @"&spades;", @"&clubs;", @"&hearts;",
                      @"&diams;",
                      ];
    NSArray *code_hex = @[
                          @"&#34;", @"&#39;", @"&#38;", @"&#60;", @"&#62;",
                          @"&#160;", @"&#161;", @"&#162;", @"&#163;", @"&#164;",
                          @"&#165;", @"&#166;", @"&#167;", @"&#168;", @"&#169;",
                          @"&#170;", @"&#171;", @"&#172;", @"&#173;", @"&#174;",
                          @"&#175;", @"&#176;", @"&#177;", @"&#178;", @"&#179;",
                          
                          @"&#180;", @"&#181;", @"&#182;", @"&#183;", @"&#184;",
                          @"&#185;", @"&#186;", @"&#187;", @"&#188;", @"&#189;",
                          @"&#190;", @"&#191;", @"&#215;", @"&#247;", @"&#192;",
                          @"&#193;", @"&#194;", @"&#195;", @"&#196;", @"&#197;",
                          @"&#198;", @"&#199;", @"&#200;", @"&#201;", @"&#202;",
                          
                          @"&#203;", @"&#204;", @"&#205;", @"&#206;", @"&#207;",
                          @"&#208;", @"&#209;", @"&#210;", @"&#211;", @"&#212;",
                          @"&#213;", @"&#214;", @"&#216;", @"&#217;", @"&#218;",
                          @"&#219;", @"&#220;", @"&#221;", @"&#222;", @"&#223;",
                          @"&#224;", @"&#225;", @"&#226;", @"&#227;", @"&#228;",
                          
                          @"&#229;", @"&#230;", @"&#231;", @"&#232;", @"&#233;",
                          @"&#234;", @"&#235;", @"&#236;", @"&#237;", @"&#238;",
                          @"&#239;", @"&#240;", @"&#241;", @"&#242;", @"&#243;",
                          @"&#244;", @"&#245;", @"&#246;", @"&#248;", @"&#249;",
                          @"&#250;", @"&#251;", @"&#252;", @"&#253;", @"&#254;",
                          
                          @"&#255;", @"&#8704;", @"&#8706;", @"&#8707;", @"&#8709;",
                          @"&#8711;", @"&#8712;", @"&#8713;", @"&#8715;", @"&#8719;",
                          @"&#8721;", @"&#8722;", @"&#8727;", @"&#8730;", @"&#8733;",
                          @"&#8734;", @"&#8736;", @"&#8743;", @"&#8744;", @"&#8745;",
                          @"&#8746;", @"&#8747;", @"&#8756;", @"&#8764;", @"&#8773;",
                          
                          @"&#8776;", @"&#8800;", @"&#8801;", @"&#8804;", @"&#8805;",
                          @"&#8834;", @"&#8835;", @"&#8836;", @"&#8838;", @"&#8839;",
                          @"&#8853;", @"&#8855;", @"&#8869;", @"&#8901;", @"&#913;",
                          @"&#914;", @"&#915;", @"&#916;", @"&#917;", @"&#918;",
                          @"&#919;", @"&#920;", @"&#921;", @"&#922;", @"&#923;",
                          
                          @"&#924;", @"&#925;", @"&#926;", @"&#927;", @"&#928;",
                          @"&#929;", @"&#931;", @"&#932;", @"&#933;", @"&#934;",
                          @"&#935;", @"&#936;", @"&#937;", @"&#945;", @"&#946;",
                          @"&#947;", @"&#948;", @"&#949;", @"&#950;", @"&#951;",
                          @"&#952;", @"&#953;", @"&#954;", @"&#923;", @"&#956;",
                          
                          @"&#925;", @"&#958;", @"&#959;", @"&#960;", @"&#961;",
                          @"&#962;", @"&#963;", @"&#964;", @"&#965;", @"&#966;",
                          @"&#967;", @"&#968;", @"&#969;", @"&#977;", @"&#978;",
                          @"&#982;", @"&#338;", @"&#339;", @"&#352;", @"&#353;",
                          @"&#376;", @"&#402;", @"&#710;", @"&#732;", @"&#8194;",
                          
                          @"&#8195;", @"&#8201;", @"&#8204;", @"&#8205;", @"&#8206;",
                          @"&#8207;", @"&#8211;", @"&#8212;", @"&#8216;", @"&#8217;",
                          @"&#8218;", @"&#8220;", @"&#8221;", @"&#8222;", @"&#8224;",
                          @"&#8225;", @"&#8226;", @"&#8230;", @"&#8240;", @"&#8242;",
                          @"&#8243;", @"&#8249;", @"&#8250;", @"&#8254;", @"&#8364;",
                          
                          @"&#8482;", @"&#8592;", @"&#8593;", @"&#8594;", @"&#8595;",
                          @"&#8596;", @"&#8629;", @"&#8968;", @"&#8969;", @"&#8970;",
                          @"&#8971;", @"&#9674;", @"&#9824;", @"&#9827;", @"&#9829;",
                          @"&#9830;",
                          ];
    
    NSInteger idx = 0;
    for (NSString *obj in code) {
        str = [str stringByReplacingOccurrencesOfString:(NSString *)obj withString:html_code[idx]];
        idx++;
    }
    return str;
}

/** 工商税号 */
- (BOOL)isValidTaxNo
{
    NSString *emailRegex = @"[0-9]\\d{13}([0-9]|X)$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}
@end

#pragma mark - 文字尺寸计算
@implementation NSString (XSize)


/**
 *  @brief 计算文字的高度
 *
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 */
- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    } else {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return ceil(textSize.height);
}

/**
 *  @brief 计算文字的宽度
 *
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 */
- (CGFloat)widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    } else {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(CGFLOAT_MAX, height)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return ceil(textSize.width);
}

/**
 *  @brief 计算文字的大小
 *
 *  @param font  字体(默认为系统字体)
 *  @param width 约束宽度
 */
- (CGSize)sizeWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    } else {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}

/**
 *  @brief 计算文字的大小
 *
 *  @param font   字体(默认为系统字体)
 *  @param height 约束高度
 */
- (CGSize)sizeWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    } else {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(CGFLOAT_MAX, height)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    textSize = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                  options:(NSStringDrawingUsesLineFragmentOrigin |
                                           NSStringDrawingTruncatesLastVisibleLine)
                               attributes:attributes
                                  context:nil].size;
#endif
    
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}

@end


#pragma mark - hash加密

@implementation NSString (XHash)
- (NSString *)md5String
{
    const char *string = self.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_MD5_DIGEST_LENGTH];
    CC_MD5(string, length, bytes);
    return [self stringFromBytes:bytes length:CC_MD5_DIGEST_LENGTH];
}
- (NSString *)sha1String
{
    const char *string = self.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(string, length, bytes);
    return [self stringFromBytes:bytes length:CC_SHA1_DIGEST_LENGTH];
}
- (NSString *)sha256String
{
    const char *string = self.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(string, length, bytes);
    return [self stringFromBytes:bytes length:CC_SHA256_DIGEST_LENGTH];
}
- (NSString *)sha512String
{
    const char *string = self.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(string, length, bytes);
    return [self stringFromBytes:bytes length:CC_SHA512_DIGEST_LENGTH];
}

- (NSString *)hmacMD5StringWithKey:(NSString *)key {
    return [self hmacStringUsingAlg:kCCHmacAlgMD5 withKey:key];
}
- (NSString *)hmacSHA1StringWithKey:(NSString *)key
{
    return [self hmacStringUsingAlg:kCCHmacAlgSHA1 withKey:key];
    
}
- (NSString *)hmacSHA256StringWithKey:(NSString *)key
{
    return [self hmacStringUsingAlg:kCCHmacAlgSHA256 withKey:key];
    
}
- (NSString *)hmacSHA512StringWithKey:(NSString *)key
{
    return [self hmacStringUsingAlg:kCCHmacAlgSHA512 withKey:key];
    
}
#pragma mark - Helpers
- (NSString *)hmacStringUsingAlg:(CCHmacAlgorithm)alg withKey:(NSString *)key {
    size_t size;
    switch (alg) {
        case kCCHmacAlgMD5: size = CC_MD5_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA1: size = CC_SHA1_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA224: size = CC_SHA224_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA256: size = CC_SHA256_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA384: size = CC_SHA384_DIGEST_LENGTH; break;
        case kCCHmacAlgSHA512: size = CC_SHA512_DIGEST_LENGTH; break;
        default: return nil;
    }
    
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *messageData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *mutableData = [NSMutableData dataWithLength:size];
    CCHmac(alg, keyData.bytes, keyData.length, messageData.bytes, messageData.length, mutableData.mutableBytes);
    return [self stringFromBytes:(unsigned char *)mutableData.bytes length:(int)mutableData.length];
}
- (NSString *)stringFromBytes:(unsigned char *)bytes length:(int)length
{
    NSMutableString *mutableString = @"".mutableCopy;
    for (int i = 0; i < length; i++)
        [mutableString appendFormat:@"%02x", bytes[i]];
    return [NSString stringWithString:mutableString];
}
@end
