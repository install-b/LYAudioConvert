//
//  LYAudioPlayerUtil.h
//  LYAudioManager
//
//  Created by Shangen Zhang on 2018/11/22.
//  Copyright © 2018 Flame. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYAudioPlayerUtil : NSObject
// 当前是否正在播放
- (BOOL)isPlaying;

// 得到当前播放音频路径
- (NSString *)playingFilePath;

// 播放指定路径下音频（wav）
- (void)asyncPlayingWithPath:(NSString *)aFilePath
                  completion:(void(^)(NSError *error))completon;

// 停止当前播放音频
- (void)stopCurrentPlaying;

@end
