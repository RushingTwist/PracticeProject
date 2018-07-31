//
//  ScreenRecordingDetector.m
//  ScreenCaptureDetector
//
//  Created by Abhilash on 29/12/17.
//  Copyright © 2017 Abhilash. All rights reserved.
//

#import "ScreenRecordingDetector.h"
float const kScreenRecordingDetectorTimerInterval = 1.0;
NSString *kScreenRecordingDetectorRecordingStatusChangedNotification = @"kScreenRecordingDetectorRecordingStatusChangedNotification";

@interface ScreenRecordingDetector()

@property (nonatomic, assign) BOOL lastRecordingState;
@property (nonatomic, weak) NSTimer *timer;

@end
@implementation ScreenRecordingDetector


+ (instancetype)sharedInstance {
    static ScreenRecordingDetector *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
- (id)init {
    if (self = [super init]) {
        // do some init stuff here..
        self.lastRecordingState = NO; // initially the recording state is 'NO'. This is the default state.
        self.timer = NULL;
    }
    return self;
}
- (BOOL)isRecording {
    for (UIScreen *screen in UIScreen.screens) {
        if ([screen respondsToSelector:@selector(isCaptured)]) {
            // iOS 11+ has isCaptured method.
            if ([screen performSelector:@selector(isCaptured)]) {
                return YES; // screen capture is active
            } else if (screen.mirroredScreen) {
                return YES; // mirroring is active
            }
        } else {
            // iOS version below 11.0
            if (screen.mirroredScreen)
                return YES;
        }
    }
    return NO;
}
+ (void)triggerDetectorTimer {

    ScreenRecordingDetector *detector = [ScreenRecordingDetector sharedInstance];
    if (detector.timer) {
        [self stopDetectorTimer];
    }
    detector.timer = [NSTimer scheduledTimerWithTimeInterval:kScreenRecordingDetectorTimerInterval
                                                           target:detector
                                                         selector:@selector(checkCurrentRecordingStatus:)
                                                         userInfo:nil
                                                          repeats:YES];
}
- (void)checkCurrentRecordingStatus:(NSTimer *)timer {
    BOOL isRecording = [self isRecording];
    if (isRecording != self.lastRecordingState) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName: kScreenRecordingDetectorRecordingStatusChangedNotification object:nil];
        
        UIAlertAction *exitAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            exit(0);
        }];
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"信息安全警告" message:@"录屏状态下禁止继续使用移动OA, 请关闭录屏状态后重试" preferredStyle:UIAlertControllerStyleAlert];
        [alertC addAction:exitAction];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertC animated:YES completion:nil];
    }
    self.lastRecordingState = isRecording;
}
+ (void)stopDetectorTimer {
    ScreenRecordingDetector *detector = [ScreenRecordingDetector sharedInstance];
    if (detector.timer) {
        [detector.timer invalidate];
        detector.timer = NULL;
    }
}
@end
