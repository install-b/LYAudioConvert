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


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [LYAudioManager sharedInstance];
    
    [LYAudioConvertManager sharedInstance];
}


@end
