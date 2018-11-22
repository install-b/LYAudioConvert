//
//  LYAudioManager.m
//  LYAudioManager
//
//  Created by Shangen Zhang on 2018/11/22.
//  Copyright © 2018 Flame. All rights reserved.
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

/* 播放器 */
@property (nonatomic,strong) LYAudioPlayerUtil * player;

/* 录音器 */
@property (nonatomic,strong) LYAudioRecorderUtil * recorder;
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

- (LYAudioPlayerUtil *)player {
    if (!_player) {
        _player = [[LYAudioPlayerUtil alloc] init];
    }
    return _player;
}
- (LYAudioRecorderUtil *)recorder {
    if (!_recorder) {
        _recorder = [[LYAudioRecorderUtil alloc] init];
    }
    return _recorder;
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
    LYAudioPlayerUtil *player = [self player];
    if([player isPlaying]){
        [player stopCurrentPlaying];
        isNeedSetActive = NO;
    }
    
    if (isNeedSetActive) {
        // 设置播放时需要的category
        [self setupAudioSessionCategory:LY_AUDIOPLAYER
                               isActive:YES];
    }
    
    NSString *mp3FilePath = [[aFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"mp3"];

    [player asyncPlayingWithPath:mp3FilePath
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
    [[self player] stopCurrentPlaying];
    [self setupAudioSessionCategory:LY_DEFAULT
                           isActive:NO];
}

- (void)stopPlayingWithChangeCategory:(BOOL)isChange{
    [[self player] stopCurrentPlaying];
    if (isChange) {
        [self setupAudioSessionCategory:LY_DEFAULT
                               isActive:NO];
    }
}

// 获取播放状态
- (BOOL)isPlaying{
    return [[self player] isPlaying];
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
    
    LYAudioRecorderUtil *recoder = [self recorder];
    if ([self isRecording]) {
        [recoder cancelCurrentRecording];
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
    
    [recoder asyncStartRecordingWithPreparePath:recordPath
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
    
    LYAudioRecorderUtil *recoder = [self recorder];
    
    if([_recorderEndDate timeIntervalSinceDate:_recorderStartDate] < [LYAudioManager recordMinDuration]){
        if (completion) {
            error = [NSError errorWithDomain:NSLocalizedString(@"error.recordTooShort", @"Recording time is too short")
                                        code:400
                                    userInfo:nil];
            completion(nil,0,error);
        }
        
        [recoder asyncStopRecordingWithCompletion:^(NSString *recordPath) {
            [weakSelf setupAudioSessionCategory:LY_DEFAULT isActive:NO];
        }];
        return ;
    }
    
    [recoder asyncStopRecordingWithCompletion:^(NSString *recordPath) {
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
    [[self recorder] cancelCurrentRecording];
}

-(BOOL)isRecording{
// 获取录音状态
    return [[self recorder] isRecording];
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
