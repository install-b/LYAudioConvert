//
//  LYAudioRecorderUtil.h
//  LYLink
//
//  Created by Lc on 16/1/25.
//  Copyright © 2016年 hhly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LYAudioRecorderUtil : NSObject

+(LYAudioRecorderUtil *)sharedInstance;

// 当前是否正在录音
+(BOOL)isRecording;

// 开始录音
+ (void)asyncStartRecordingWithPreparePath:(NSString *)aFilePath
                                completion:(void(^)(NSError *error))completion;
// 停止录音
+(void)asyncStopRecordingWithCompletion:(void(^)(NSString *recordPath))completion;

// 取消录音
+(void)cancelCurrentRecording;

// 当前 recorder
+(AVAudioRecorder *)recorder;



@end
