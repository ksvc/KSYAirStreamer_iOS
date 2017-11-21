//
//  KSYViewController.m
//  KSYAirStreamer
//
//  Created by pengbins on 04/11/2017.
//  Copyright (c) 2017 pengbins. All rights reserved.
//
#import "KSYBitStreamDumpVC.h"
#import <KSYAirStreamer/KSYAirTunesServer.h>
#import "KSYUIView.h"

@interface KSYBitStreamDumpVC () <KSYAirDelegate>{
    KSYAirTunesServer * _airSer;
}

@property UIButton * btnStart;
@property UIButton * btnQuit;
@property UILabel * lblState;

@property (nonatomic, readwrite, retain) NSString * airState;

@end

@implementation KSYBitStreamDumpVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.layoutView = [[KSYUIView alloc] init];
    self.layoutView.frame = self.view.frame;
    self.layoutView.backgroundColor = [UIColor whiteColor];
    self.view = self.layoutView;
    _btnStart = [self.layoutView addButton:@"开始"];
    _btnQuit = [self.layoutView addButton:@"退出"];
    _lblState = [self.layoutView addLable:@"idle"];
    _lblState.lineBreakMode = NSLineBreakByWordWrapping;
    
    __weak typeof (self) selfWeak = self;
    self.layoutView.onBtnBlock = ^(id sender){
        [selfWeak  onBtnPress:sender];
    };
    
    NSString* token =  @"bx5s51alwro/JtVWuOmN0OmdyzwFVMtH9AL5SWoe7dmjETWIZYib876DeYUXzlgdeurwIJeXsvpSnWlj139GMOqF+OK2Lia2ixuxfOdIyi+mp7PVDwPN5O8H6vk5mITgn8NMI95tarS0pPgMnP+w5h9EAZL96bGR2QOCUK+4NSk=";
    NSError * err = nil;
    _airSer = [[KSYAirTunesServer alloc] initWithToken:token error:&err];
    if ( err ) {
        NSLog(@"auth failed: %@", err.localizedDescription);
        self.airState = err.localizedDescription;
        return;
    }
    _airSer.delegate = self;
    _airSer.videoBitStreamCallback = ^(NSData *data, BOOL bParameterSet, CMTime timeInfo) {
        if(bParameterSet) {
            ///软解的话, data.bytes 可以直接送入ffmpeg的extradata解码
            ///videotoolbox的话, 可用如下代码先解析
            size_t psCnt = 0;
            uint8_t * psData[8] ={NULL};
            size_t psLen[8] = {0};
            int nalLen = KSYAirParseParamSets(data, psData, psLen, &psCnt);
            NSLog(@"paramset %zu", psCnt);
            NSLog(@"nalLen %d", nalLen);
            for (int i = 0; i < psCnt; ++i) {
                if (psData[i]) {
                    free(psData[i]);
                }
            }
        }
        else {
            int32_t* pNalLen = (int32_t*)data.bytes;
            int32_t nalLen = CFSwapInt32(*pNalLen);
            NSLog(@"get bit stream %ld %d", (long)data.length, nalLen+4);
        }
    };
    NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self
           selector:@selector(appEnterBackground)
               name:UIApplicationDidEnterBackgroundNotification
             object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated {
    [self layoutUI];
}
- (BOOL)shouldAutorotate {
    [self layoutUI];
    return YES;
}

- (void) layoutUI {
    [super layoutUI];
    self.layoutView.btnH *= 2;
    self.layoutView.yPos += self.layoutView.btnH;
    [self.layoutView putRow1:_btnStart];
    self.layoutView.btnH *= 2;
    [self.layoutView putRow1:_lblState];
    self.layoutView.btnH = _btnStart.frame.size.height;
    [self.layoutView putRow1:_btnQuit];
}

- (void) viewWillTransitionToSize:(CGSize)size
        withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>) coordinator{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self layoutUI];
    }];
}

- (IBAction)onBtnPress:(id)sender {
    if (sender == _btnStart) {
        _btnStart.selected = ! _btnStart.selected;
        if (_btnStart.selected) {
            KSYAirTunesConfig *  cfg = [[KSYAirTunesConfig alloc] init];
            cfg.videoDecoder = KSYAirVideoDecoder_NONE;
            [_airSer startServerWithCfg:cfg];
        }
        else {
            [_airSer stopServer];
        }
    }
    else if (sender == _btnQuit) {
        [self dismissViewControllerAnimated:NO
                                 completion:nil];
    }
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - KSYAirDelegate
- (void) didStartMirroring:(KSYAirTunesServer *)server {
    self.airState = @"mirroring";
}
- (void)mirroringErrorDidOcccur:(KSYAirTunesServer *)server  withError:(NSError *)error {
    _btnStart.selected = NO;
    self.airState =  [NSString stringWithFormat:@"error: %@", error.localizedDescription];
}
- (void)didStopMirroring:(KSYAirTunesServer *)server {
    self.airState = @"idle";
    _btnStart.enabled = YES;
}
- (void) setAirState:(NSString *)airState {
    dispatch_async(dispatch_get_main_queue(), ^{
        _lblState.text = airState;
    });
}


/**  进入后台 */
- (void) appEnterBackground {
    // 开启后台任务，避免被suspend
    __block UIBackgroundTaskIdentifier bgTask;
    dispatch_queue_t bgTaskQ = dispatch_queue_create("com.ksyun.backgroundTask.queue", DISPATCH_QUEUE_SERIAL);
    bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^ {
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    dispatch_async(bgTaskQ, ^{
        int cnt = 0;
        while ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            NSLog(@"runing %d", cnt++);
            sleep(1);
        }
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
}


@end
