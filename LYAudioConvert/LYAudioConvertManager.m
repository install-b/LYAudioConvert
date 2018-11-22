//
//  LYSoundTouchConvertManager.m
//  LYAudioConvert
//
//  Created by Shangen Zhang on 2018/8/9.
//  Copyright © 2018年 Flame. All rights reserved.
//

#import "LYAudioConvertManager.h"
#import "AudioConvert.h"
#import "lame.h"


#pragma mark - implementation
@implementation LYSoundTouchConfig
- (instancetype)initWithTempoChange:(NSInteger)tempoChange
                     pitchSemiTones:(NSInteger)pitchSemiTones
                         rateChange:(NSInteger)rateChange {
    if (self = [super init]) {
        _tempoChange = tempoChange;
        _pitchSemiTones = pitchSemiTones;
        _rateChange = rateChange;
    }
    return self;
}
@end


#pragma mark - LYSoundTouchConvertManager
@interface LYAudioConvertManager ()
/* 回调 */
@property (nonatomic,copy) void(^_completeBlock)(NSString *path);
@end

@implementation LYAudioConvertManager

+ (instancetype)sharedInstance {
    static LYAudioConvertManager * _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
#pragma mark - wav --> mp3
- (NSString *)convertToMP3WithWAV:(NSString *)WAVPath {
    //录音格式转换，从wav转为mp3
    NSString *mp3FilePath = [[WAVPath stringByDeletingPathExtension]
                             stringByAppendingPathExtension:@"mp3"];
    BOOL convertResult = [self convertWAV:WAVPath toMP3:mp3FilePath];
    if (convertResult) {
        // 删除录的wav
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:WAVPath error:nil];
        return mp3FilePath;
    }
    return nil;
}
- (BOOL)convertWAV:(NSString *)wavFilePath toMP3:(NSString *)mp3FilePath
{
    BOOL ret = NO;
    BOOL isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:wavFilePath];
    if (isFileExists) {
        int read, write;
        
        FILE *pcm = fopen([wavFilePath cStringUsingEncoding:1], "rb");   //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath  cStringUsingEncoding:1], "wb"); //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = (int)fread(pcm_buffer, 2 * sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
        isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:mp3FilePath];
        if (isFileExists) {
            ret = YES;
        }
    }
    
    return ret;
}

#pragma mark - 变声
- (void)startTouchSoundAudioWAV:(NSString *)WAVPath
                toMp3WithConfig:(LYSoundTouchConfig *)audioConfig
                       complete:(void(^)(NSString *path))complete {
     __completeBlock = complete;
    static AudioConvertConfig config ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config.outputFormat             = AudioConvertOutputFormat_MP3;
        config.outputSampleRate         = 8000;
        config.outputChannelsPerFrame    = 2;
    });
    config.sourceAuioPath           = [WAVPath UTF8String];
    config.soundTouchTempoChange    = (int)audioConfig.tempoChange;
    config.soundTouchPitch          = (int)audioConfig.pitchSemiTones;
    config.soundTouchRate           = (int)audioConfig.rateChange;
    
    // 开始变声
    [[AudioConvert shareAudioConvert] audioConvertBegin:config withCallBackDelegate:self];
}
#pragma mark -
- (BOOL)audioConvertOnlyDecode
{
    return  NO;
}
- (BOOL)audioConvertHasEnecode
{
    return YES;
}

- (void)audioConvertSoundTouchSuccess:(NSString *)audioPath {
    !__completeBlock ?: __completeBlock(audioPath);
}
- (void)audioConvertSoundTouchFail {
    NSLog(@"");
}
//变声回调
- (void)soundTouchFinish:(NSString *)stPath {
    
}
- (void)audioconvertDecodoDoubleChannelFinish:(NSString *)stPath {
    !__completeBlock ?: __completeBlock(stPath);
}
- (void)audioConvertEncodeSuccess:(NSString *)audioPath {
    !__completeBlock ?: __completeBlock(audioPath);
}
- (void)audioConvertEncodeFaild{
    NSLog(@"");
}

@end
