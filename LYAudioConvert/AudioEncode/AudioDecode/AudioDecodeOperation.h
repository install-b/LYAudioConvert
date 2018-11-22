//
//  AudioDecodeOperation.h
//  SoundTouchDemo
//
//  Created by Shangen Zhang on 2018/8/9.
//  Copyright © 2018年 Flame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AudioDefine.h"

@interface AudioDecodeOperation : NSOperation
- (id)initWithSourcePath:(NSString *)spath
         audioOutputPath:(NSString *)opath
        outputSampleRate:(Float64)slr
           outputChannel:(int)ch
          callBackTarget:(id)target
            callFunction:(SEL)action;
@end
