//
//  LYCDDeviceManager.m
//  TaiYangHua
//
//  Created by Lc on 16/1/25.
//  Copyright © 2016年 hhly. All rights reserved.
//

#import "LYAudioManager.h"
#import "LYAudioPlayerUtil.h"
#import "LYAudioRecorderUtil.h"


typedef NS_ENUM(NSInteger, LYAudioSession){
    LY_DEFAULT = 0,
    LY_AUDIOPLAYER,
    LY_AUDIORECORDER
};


@interface LYAudioManager (){
    // recorder
    NSDate              *_recorderStartDate;
    NSDate              *_recorderEndDate;
    NSString            *_currCategory;
    BOOL                _currActive;
    
}
@end

@implementation LYAudioManager

+ (LYAudioManager *)sharedInstance{
    static LYAudioManager *_CDDeviceManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _CDDeviceManager = [[self alloc] init];
    });
    
    return _CDDeviceManager;
}

/** 检查语音权限 */
- (BOOL)checkMicrophoneAvailability{
    __block BOOL bCanRecord = YES;
    dispatch_semaphore_t lock = dispatch_semaphore_create(1);
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            bCanRecord = granted;
            dispatch_semaphore_signal(lock);
        }];
    }
    else{
        dispatch_semaphore_signal(lock);
    }
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    return bCanRecord;
}
#pragma mark - AudioPlayer
// 播放音频
- (void)asyncPlayingWithPath:(NSString *)aFilePath
                  completion:(void(^)(NSError *error))completon{
    BOOL isNeedSetActive = YES;
    // 如果正在播放音频，停止当前播放。
    if([LYAudioPlayerUtil isPlaying]){
        [LYAudioPlayerUtil stopCurrentPlaying];
        isNeedSetActive = NO;
    }
    
    if (isNeedSetActive) {
        // 设置播放时需要的category
        [self setupAudioSessionCategory:LY_AUDIOPLAYER
                               isActive:YES];
    }
    
    NSString *mp3FilePath = [[aFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp3"];

    [LYAudioPlayerUtil asyncPlayingWithPath:mp3FilePath
                                 completion:^(NSError *error)
     {
         [self setupAudioSessionCategory:LY_DEFAULT
                                isActive:NO];
         if (completon) {
             completon(error);
         }
     }];
}

// 停止播放
- (void)stopPlaying{
    [LYAudioPlayerUtil stopCurrentPlaying];
    [self setupAudioSessionCategory:LY_DEFAULT
                           isActive:NO];
}

- (void)stopPlayingWithChangeCategory:(BOOL)isChange{
    [LYAudioPlayerUtil stopCurrentPlaying];
    if (isChange) {
        [self setupAudioSessionCategory:LY_DEFAULT
                               isActive:NO];
    }
}

// 获取播放状态
- (BOOL)isPlaying{
    return [LYAudioPlayerUtil isPlaying];
}

#pragma mark - Recorder

+(NSTimeInterval)recordMinDuration{
    return 1.0;
}

// 开始录音
- (void)asyncStartRecordingWithFileName:(NSString *)fileName
                             completion:(void(^)(NSError *error))completion{
    NSError *error = nil;
    
    // 判断当前是否是录音状态
    if ([self isRecording]) {
        if (completion) {
            error = [NSError errorWithDomain:NSLocalizedString(@"error.recordStoping", @"Record voice is not over yet")
                                        code:300
                                    userInfo:nil];
            completion(error);
        }
        return ;
    }
    
    // 文件名不存在
    if (!fileName || [fileName length] == 0) {
        error = [NSError errorWithDomain:NSLocalizedString(@"error.notFound", @"File path not exist")
                                    code:200
                                userInfo:nil];
        completion(error);
        return ;
    }
    
    if ([self isRecording]) {
        [LYAudioRecorderUtil cancelCurrentRecording];
    }
    
    [self setupAudioSessionCategory:LY_AUDIORECORDER
                           isActive:YES];
    
    _recorderStartDate = [NSDate date];
    
    NSString *recordPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    recordPath = [NSString stringWithFormat:@"%@/records/",recordPath];
    recordPath = [recordPath stringByAppendingPathComponent:fileName];
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:[recordPath stringByDeletingLastPathComponent]]){
        [fm createDirectoryAtPath:[recordPath stringByDeletingLastPathComponent]
      withIntermediateDirectories:YES
                       attributes:nil
                            error:nil];
    }
    
    [LYAudioRecorderUtil asyncStartRecordingWithPreparePath:recordPath
                                                 completion:completion];
}

// 停止录音
-(void)asyncStopRecordingWithCompletion:(void(^)(NSString *recordPath,
                                                 NSInteger aDuration,
                                                 NSError *error))completion{
    NSError *error = nil;
    // 当前是否在录音
    if(![self isRecording]){
        if (completion) {
            error = [NSError errorWithDomain:NSLocalizedString(@"error.recordNotBegin", @"Recording has not yet begun")
                                        code:300
                                    userInfo:nil];
            completion(nil,0,error);
            return;
        }
    }
    
    __weak typeof(self) weakSelf = self;
    _recorderEndDate = [NSDate date];
    
    if([_recorderEndDate timeIntervalSinceDate:_recorderStartDate] < [LYAudioManager recordMinDuration]){
        if (completion) {
            error = [NSError errorWithDomain:NSLocalizedString(@"error.recordTooShort", @"Recording time is too short")
                                        code:400
                                    userInfo:nil];
            completion(nil,0,error);
        }
        
        [LYAudioRecorderUtil asyncStopRecordingWithCompletion:^(NSString *recordPath) {
            [weakSelf setupAudioSessionCategory:LY_DEFAULT isActive:NO];
        }];
        return ;
    }
    
    [LYAudioRecorderUtil asyncStopRecordingWithCompletion:^(NSString *recordPath) {
        if (completion) {
            if (recordPath) {
                completion(recordPath,(int)[self->_recorderEndDate timeIntervalSinceDate:self->_recorderStartDate],nil);
            }
            [weakSelf setupAudioSessionCategory:LY_DEFAULT isActive:NO];
        }
    }];
}

// 取消录音
-(void)cancelCurrentRecording{
    [LYAudioRecorderUtil cancelCurrentRecording];
}

-(BOOL)isRecording{
// 获取录音状态
    return [LYAudioRecorderUtil isRecording];
}

#pragma mark - Private
-(NSError *)setupAudioSessionCategory:(LYAudioSession)session
                             isActive:(BOOL)isActive{
    BOOL isNeedActive = NO;
    if (isActive != _currActive) {
        isNeedActive = YES;
        _currActive = isActive;
    }
    NSError *error = nil;
    NSString *audioSessionCategory = nil;
    switch (session) {
        case LY_AUDIOPLAYER:
            // 设置播放category
            audioSessionCategory = AVAudioSessionCategoryPlayback;
            break;
        case LY_AUDIORECORDER:
            // 设置录音category
            audioSessionCategory = AVAudioSessionCategoryRecord;
            break;
        default:
            // 还原category
            audioSessionCategory = AVAudioSessionCategoryAmbient;
            break;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    // 如果当前category等于要设置的，不需要再设置
    if (![_currCategory isEqualToString:audioSessionCategory]) {
        [audioSession setCategory:audioSessionCategory error:nil];
    }
    if (isNeedActive) {
        BOOL success = [audioSession setActive:isActive
                                   withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                         error:&error];
        if(!success || error){
            error = [NSError errorWithDomain:NSLocalizedString(@"error.initPlayerFail", @"Failed to initialize AVAudioPlayer")
                                        code:100
                                    userInfo:nil];
            return error;
        }
    }
    _currCategory = audioSessionCategory;
    
    return error;
}

@end
