//
//  UILabel+X.m
//  CommonConfigDemo
//
//  Created by canoe on 2017/12/18.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import "UILabel+X.h"
#import <CoreText/CoreText.h>

@implementation UILabel (X)

+(instancetype)labelWithTitle:(NSString *)title font:(UIFont *)font textColor:(UIColor *)color textAlignment:(NSTextAlignment)textAlignment
{
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = font;
    label.textColor = color;
    label.textAlignment = textAlignment?textAlignment:NSTextAlignmentLeft;
    return label;
}

@end


#pragma mark - 修改间距
@implementation UILabel (XSpace)
- (void)changeLineSpace:(float)space
{
    
    NSString *labelText = self.text;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:space];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    [attributedString addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, [labelText length])];
    self.attributedText = attributedString;
    [self sizeToFit];
    
}

- (void)changeWordSpace:(float)space {
    
    NSString *labelText = self.text;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText attributes:@{NSKernAttributeName:@(space)}];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    [attributedString addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, [labelText length])];
    self.attributedText = attributedString;
    
    [self sizeToFit];
    
}

- (void)changeSpaceWithLineSpace:(float)lineSpace WordSpace:(float)wordSpace {
    
    NSString *labelText = self.text;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText attributes:@{NSKernAttributeName:@(wordSpace)}];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpace];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
    [attributedString addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, [labelText length])];
    self.attributedText = attributedString;
    [self sizeToFit];
    
}
@end

#pragma mark - 自动下载非系统字体(苹果提供的其他字体)

@implementation UILabel (XAutoDownloadFont)

-(void)setCustomFontWithName:(NSString *)fontName size:(CGFloat)fontSize
{
    UIFont* aFont = [UIFont fontWithName:fontName size:fontSize];
    // If the font is already downloaded
    if (aFont && ([aFont.fontName compare:fontName] == NSOrderedSame || [aFont.familyName compare:fontName] == NSOrderedSame)) {
        // Go ahead and display the sample text.
        self.font = aFont;
    }
    
    // Create a dictionary with the font's PostScript name.
    NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:fontName, kCTFontNameAttribute, nil];
    
    // Create a new font descriptor reference from the attributes dictionary.
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)attrs);
    
    NSMutableArray *descs = [NSMutableArray arrayWithCapacity:0];
    [descs addObject:(__bridge id)desc];
    CFRelease(desc);
    
    __block BOOL errorDuringDownload = NO;
    
    // Start processing the font descriptor..
    // This function returns immediately, but can potentially take long time to process.
    // The progress is notified via the callback block of CTFontDescriptorProgressHandler type.
    // See CTFontDescriptor.h for the list of progress states and keys for progressParameter dictionary.
    CTFontDescriptorMatchFontDescriptorsWithProgressHandler( (__bridge CFArrayRef)descs, NULL,  ^(CTFontDescriptorMatchingState state, CFDictionaryRef progressParameter) {
        
        //NSLog( @"state %d - %@", state, progressParameter);
        
        double progressValue = [[(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingPercentage] doubleValue];
        
        if (state == kCTFontDescriptorMatchingDidBegin) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                
                NSLog(@"Begin Matching");
            });
        } else if (state == kCTFontDescriptorMatchingDidFinish) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                
                // Log the font URL in the console
                CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName, 0., NULL);
                CFStringRef fontURL = CTFontCopyAttribute(fontRef, kCTFontURLAttribute);
                CFRelease(fontURL);
                CFRelease(fontRef);
                
                if (!errorDuringDownload) {
                    //TODO:
                    self.font = [UIFont fontWithName:fontName size:fontSize];
                    NSLog(@"%@ downloaded", fontName);
                }
            });
        } else if (state == kCTFontDescriptorMatchingWillBeginDownloading) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                NSLog(@"Begin Downloading");
            });
        } else if (state == kCTFontDescriptorMatchingDidFinishDownloading) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                //TODO:
                self.font = [UIFont fontWithName:fontName size:fontSize];
                NSLog(@"Finish downloading");
            });
        } else if (state == kCTFontDescriptorMatchingDownloading) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                NSLog(@"Downloading %.0f%% complete", progressValue);
            });
        } else if (state == kCTFontDescriptorMatchingDidFailWithError) {
            // An error has occurred.
            // Get the error message
            NSError *error = [(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingError];
            if (error != nil) {
                NSLog(@"%@",[error description]);
            } else {
                NSLog(@"ERROR MESSAGE IS NOT AVAILABLE!");
            }
            // Set our flag
            errorDuringDownload = YES;
            
            dispatch_async( dispatch_get_main_queue(), ^ {
                NSLog(@"Download error: %@", [error description]);
            });
        }
        
        return (bool)YES;
    });
}

@end
