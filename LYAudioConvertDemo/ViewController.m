//
//  ViewController.m
//  LYAudioConvertDemo
//
//  Created by Shangen Zhang on 2018/11/22.
//  Copyright © 2018 Flame. All rights reserved.
//

#import "ViewController.h"
#import "LYAudioConvertManager.h"
#import "LYAudioManager.h"

/*
 tempoChange 速度 <变速不变调> 范围 -50 ~ 100
 pitchSemiTones 音调  范围 -12 ~ 12
 rateChange 声音速率 范围 -50 ~ 100
 */
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;


@property (weak, nonatomic) IBOutlet UILabel *tempoChangeValueLabel;

@property (weak, nonatomic) IBOutlet UILabel *pitchSemiTonesValueLabel;

@property (weak, nonatomic) IBOutlet UILabel *rateChangeValueLabel;


@property (copy, nonatomic) NSString *recordPath;

@property (strong, nonatomic) LYSoundTouchConfig *config;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _config = [[LYSoundTouchConfig alloc] init];
}

- (void)startRecord {
    NSString *fileName = [self getFileName];
    
    self.playButton.enabled = NO;
    self.recordPath = nil;
    self.statusLabel.text = @"正在录音...";
    [[LYAudioManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error) {
        
        NSLog(@"record error: %@",error);
    }];
}

- (void)endRecord {
    self.statusLabel.text = @"结束录音，请播放";
    if ( [[LYAudioManager sharedInstance] isRecording]) {
        [[LYAudioManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
            self.recordPath = recordPath;
            self.playButton.enabled = YES;
        }];
    }
}

- (void)playConvertAudio {
    // 开始变声
    self.statusLabel.text = @"正在转码。。。";
    [[LYAudioConvertManager sharedInstance] startTouchSoundAudioWAV:self.recordPath toMp3WithConfig:self.config complete:^(NSString *path) {
        self.statusLabel.text = @"正在播放。。。";
        // 开始播放
        [[LYAudioManager sharedInstance] asyncPlayingWithPath:path completion:^(NSError *error) {
             self.statusLabel.text = @"结束播放";
        }];
        
        
    }];
}

#pragma mark - button action
- (IBAction)playAction:(id)sender {
    [self playConvertAudio];
}

- (IBAction)recordButtonTouchUpSide:(UIButton *)sender {
    [self endRecord];
}
- (IBAction)recordButtonTouchDown:(UIButton *)sender {
    [self startRecord];
}
#pragma mark - slider change

- (IBAction)changeTempoValue:(UISlider *)sender {
    int value = (int)sender.value;
    _config.tempoChange = value;
    _tempoChangeValueLabel.text = [NSString stringWithFormat:@"%d",value];
}
- (IBAction)changePitchSemiTonesValue:(UISlider *)sender {
    int value = (int)sender.value;
    _config.pitchSemiTones = value;
    _pitchSemiTonesValueLabel.text = [NSString stringWithFormat:@"%d",value];
}
- (IBAction)changeRateValue:(UISlider *)sender {
    int value = (int)sender.value;
    _config.rateChange = value;
    _rateChangeValueLabel.text = [NSString stringWithFormat:@"%d",value];
}

#pragma mark - create file path
- (NSString *)getFileName {
     NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"records"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return [filePath stringByAppendingPathComponent:[self getCurrentTimes]];
    
}

- (NSString*)getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    [formatter setDateFormat:@"YYYY-MM-dd-HH-mm-ss"];
    
    //现在时间,你可以输出来看下是什么格式
    
    NSDate *datenow = [NSDate date];
    
    //----------将nsdate按formatter格式转成nsstring
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    NSLog(@"currentTimeString =  %@",currentTimeString);
    
    return currentTimeString;
    
}
@end
