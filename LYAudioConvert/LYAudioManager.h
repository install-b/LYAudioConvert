//
//  LYCDDeviceManager.h
//  TaiYangHua
//
//  Created by Lc on 16/1/25.
//  Copyright © 2016年 hhly. All rights reserved.
//

/**
 *  播放录音管理器
 *
 *  APP info plist need add key 'Privacy - Microphone Usage Description'
 */

#import <Foundation/Foundation.h>

@interface LYAudioManager : NSObject

/**
 * 播放器 管理单例
 */
+ (instancetype)sharedInstance;

/**
 * 检查是否有权限
 */
- (BOOL)checkMicrophoneAvailability;

#pragma mark - AudioPlayer  // 播放音频
// 播放音频
- (void)asyncPlayingWithPath:(NSString *)aFilePath
                  completion:(void(^)(NSError *error))completon;
// 停止播放
- (void)stopPlaying;
- (void)stopPlayingWithChangeCategory:(BOOL)isChange;

// 当前是否正在播放
-(BOOL)isPlaying;



#pragma mark - AudioRecorder   // 录制音频
// 开始录音 生成 wav 格式
- (void)asyncStartRecordingWithFileName:(NSString *)fileName
                             completion:(void(^)(NSError *error))completion;

// 停止录音
- (void)asyncStopRecordingWithCompletion:(void(^)(NSString *recordPath,
                                                 NSInteger aDuration,
                                                 NSError *error))completion;
// 取消录音
- (void)cancelCurrentRecording;


// 当前是否正在录音
-(BOOL)isRecording;

@end