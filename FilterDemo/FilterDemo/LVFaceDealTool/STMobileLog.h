//
//  STMobileLog.h
//
//  Created by sluin on 16/11/15.
//  Copyright © 2016年 SenseTime. All rights reserved.
//

#ifndef STMobileLog_h
#define STMobileLog_h

#define STLOG_WHEN_DEBUG 1

#ifdef DEBUG
#if STLOG_WHEN_DEBUG
#define STLog(format , ...) NSLog((format) , ##__VA_ARGS__);
#else
#define STLog(format , ...)
#endif
#else
#define STLog(format , ...)
#endif

#if STLOG_WHEN_DEBUG
#define TIMELOG(key) double key = CFAbsoluteTimeGetCurrent();
#define TIMEPRINT(key , dsc) printf("%s\t%.1f ms\n" , dsc , (CFAbsoluteTimeGetCurrent() - key) * 1000);
#else
#define TIMELOG(key)
#define TIMEPRINT(key , dsc)
#endif

#endif /* STMobileLog_h */
