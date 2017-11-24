//
//  STTriggerView.h
//
//  Created by HaifengMay on 16/11/10.
//  Copyright © 2016年 SenseTime. All rights reserved.
//

/*
 * 用于显示trigger的提示语
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, STTriggerType) {
    STTriggerTypeNod, //点头
    STTriggerTypeMoveEyebrow,//挑眉
    STTriggerTypeBlink,//眨眼
    STTriggerTypeOpenMouse,//张嘴
    STTriggerTypeTurnHead,//转头
    STTriggerTypeHandGood,//大拇哥
    STTriggerTypeHandPalm,//手掌
    STTriggerTypeHandLove,//爱心
    STTriggerTypeHandHoldUp,//托手
    STTriggerTypeHandCongratulate,//恭贺(抱拳)
    STTriggerTypeHandFingerHeart,//单手比爱心
    STTriggerTypeHandTwoIndexFinger, // 平行手指
    STTriggerTypeHandFingerIndex, //食指指尖
    STTriggerTypeHandOK, //OK手势
    STTriggerTypeHandScissor, //剪刀手
    STTriggerTypeHandPistol //手枪
};

@interface STTriggerView : UIView

- (void)showTriggerViewWithType:(STTriggerType)type;

@end
