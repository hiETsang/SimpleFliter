//
//  STTriggerView.m
//
//  Created by HaifengMay on 16/11/10.
//  Copyright © 2016年 SenseTime. All rights reserved.
//

#import "STTriggerView.h"
#import "STParamUtil.h"
#import "LVFaceDealHeader.h"

@interface STTriggerView ()
{
    dispatch_source_t _timer;
}
@property (nonatomic , strong) UIImageView *imageView;
@property (nonatomic , strong) UILabel *txtLabel;
@property (nonatomic , assign) double dStartTime;

@end


@implementation STTriggerView

- (instancetype) init{
    CGRect frame = CGRectMake(0, 0, 200, 40);
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.height, self.frame.size.height)];
        [self.imageView setBackgroundColor:[UIColor clearColor]];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:self.imageView];
        
        self.txtLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.imageView.frame) + 10, 0, CGRectGetWidth(self.frame) - CGRectGetWidth(self.imageView.frame), self.frame.size.height)];
        [self.txtLabel setBackgroundColor: [UIColor clearColor]];
        [self.txtLabel setTextColor:[UIColor whiteColor]];
        [self.txtLabel setFont:[UIFont systemFontOfSize:22]];
        [self.txtLabel setTextAlignment:NSTextAlignmentLeft];
        self.txtLabel.minimumScaleFactor = 0.5;
        self.txtLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.txtLabel];
        self.hidden = YES;
        self.center = CGPointMake(kScreenWidth/2, kScreenHeight/2);
        
        _dStartTime = CFAbsoluteTimeGetCurrent();
        
        uint64_t interval = NSEC_PER_SEC / 1000 * 33;
        dispatch_queue_t queue = dispatch_queue_create("com.sensetime.sticker.timer", NULL);
        
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, 0), interval, 0);
        
        __weak typeof(self) weakSelf = self;
        dispatch_source_set_event_handler(_timer, ^{
            
            if (!weakSelf.hidden && (CFAbsoluteTimeGetCurrent() - weakSelf.dStartTime) > 3.0) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    weakSelf.hidden = YES;
                });
            }
        });
        
        dispatch_resume(_timer);
    }
    return self;
}

- (void) showTriggerViewWithType:(STTriggerType) type {
    
    _dStartTime = CFAbsoluteTimeGetCurrent();
    
    switch (type) {
            
        case STTriggerTypeNod:
            [self.imageView setImage:[UIImage imageNamed:@"点头"]];
            self.txtLabel.text = @"请点点头～";
            break;
        case STTriggerTypeBlink:
            [self.imageView setImage:[UIImage imageNamed:@"眨眼"]];
            self.txtLabel.text = @"请眨眨眼～";
            break;
        case STTriggerTypeTurnHead:
            [self.imageView setImage:[UIImage imageNamed:@"转头"]];
            self.txtLabel.text = @"请摇摇头～";
            break;
        case STTriggerTypeOpenMouse:
            [self.imageView setImage:[UIImage imageNamed:@"张嘴"]];
            self.txtLabel.text = @"请张张嘴～";
            break;
        case STTriggerTypeMoveEyebrow:
            [self.imageView setImage:[UIImage imageNamed:@"挑眉"]];
            self.txtLabel.text = @"请挑挑眉～";
            break;
        case STTriggerTypeHandGood:
            [self.imageView setImage:[UIImage imageNamed:@"大拇哥"]];
            self.txtLabel.text = @"请比个赞～";
            break;
            
        case STTriggerTypeHandPalm:
            [self.imageView setImage:[UIImage imageNamed:@"手掌"]];
            self.txtLabel.text = @"请伸手掌～";
            break;
            
        case STTriggerTypeHandLove:
            [self.imageView setImage:[UIImage imageNamed:@"爱心"]];
            self.txtLabel.text = @"请双手比心～";
            break;
            
        case STTriggerTypeHandHoldUp:
            [self.imageView setImage:[UIImage imageNamed:@"托起"]];
            self.txtLabel.text = @"请托个手～";
            break;
            
        case STTriggerTypeHandCongratulate:
            [self.imageView setImage:[UIImage imageNamed:@"抱拳"]];
            self.txtLabel.text = @"请抱个拳～";
            break;
            
        case STTriggerTypeHandFingerHeart:
            [self.imageView setImage:[UIImage imageNamed:@"单手爱心"]];
            self.txtLabel.text = @"请单手比心～";
            break;
        case STTriggerTypeHandTwoIndexFinger:
            [self.imageView setImage:[UIImage imageNamed:@"two_index_finger"]];
            self.txtLabel.text = @"请如图所示伸出手指～";
            break;
            
        case STTriggerTypeHandPistol:
            [self.imageView setImage:[UIImage imageNamed:@"hand_gun"]];
            self.txtLabel.text = @"请比个手枪～";
            break;
            
        case STTriggerTypeHandScissor:
            [self.imageView setImage:[UIImage imageNamed:@"hand_victory"]];
            self.txtLabel.text = @"请比个剪刀手～";
            break;
            
        case STTriggerTypeHandOK:
            [self.imageView setImage:[UIImage imageNamed:@"hand_ok"]];
            self.txtLabel.text = @"请亮出OK手势～";
            break;
            
        case STTriggerTypeHandFingerIndex:
            [self.imageView setImage:[UIImage imageNamed:@"hand_finger"]];
            self.txtLabel.text = @"请伸出食指～";
            break;
            
        default:
            break;
    }
    
    self.hidden = NO;
}

@end
