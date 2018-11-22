//
//  LYSoundTouchConvertModel.h
//  CFAudioConvert
//
//  Created by Shangen Zhang on 2018/8/9.
//  Copyright © 2018年 Flame. All rights reserved.
//


/**
 *  音频 转化管理器
 *
 */

#import <Foundation/Foundation.h>

/**
 变声配置
 */
@interface LYSoundTouchConfig : NSObject

/* 速度 <变速不变调> 范围 -50 ~ 100 */
@property (nonatomic,assign) NSInteger tempoChange;

/* 音调  范围 -12 ~ 12 */
@property (nonatomic,assign) NSInteger pitchSemiTones;

/* 声音速率 范围 -50 ~ 100 */
@property (nonatomic,assign) NSInteger rateChange;

- (instancetype)initWithTempoChange:(NSInteger)tempoChange
                     pitchSemiTones:(NSInteger)pitchSemiTones
                         rateChange:(NSInteger)rateChange;

@end


@interface LYAudioConvertManager : NSObject


/**
  音频处理单例
 */
+ (instancetype)sharedInstance;


/**
 wav 格式--> 解码 --> 变声 --> 编码 --> mp3 格式

 @param complete 完成回调
 */
- (void)startTouchSoundAudioWAV:(NSString *)WAVPath
                toMp3WithConfig:(LYSoundTouchConfig *)config
                       complete:(void(^)(NSString *path))complete;


/**
 wav 格式 --> mp3 格式

 @param WAVPath wav 格式
 @return mp3 格式音频
 */
- (NSString *)convertToMP3WithWAV:(NSString *)WAVPath;
@end
