//
//  LYAudioRecorderUtil.h
//  LYAudioManager
//
//  Created by Shangen Zhang on 2018/11/22.
//  Copyright © 2018 Flame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LYAudioRecorderUtil : NSObject

// 当前是否正在录音
- (BOOL)isRecording;

// 开始录音
- (void)asyncStartRecordingWithPreparePath:(NSString *)aFilePath
                                completion:(void(^)(NSError *error))completion;
// 停止录音
- (void)asyncStopRecordingWithCompletion:(void(^)(NSString *recordPath))completion;

// 取消录音
- (void)cancelCurrentRecording;

// 当前 recorder
- (AVAudioRecorder *)recorder;

@end
