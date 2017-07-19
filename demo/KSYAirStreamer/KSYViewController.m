//
//  KSYViewController.m
//  KSYAirStreamer
//
//  Created by pengbins on 04/11/2017.
//  Copyright (c) 2017 pengbins. All rights reserved.
//
#import "KSYViewController.h"
#import "KSYAirView.h"
#import "KSYAirStreamKit.h"
#import <libksygpulive/libksystreamerengine.h>

@interface KSYViewController () <KSYAirDelegate>{
    KSYAirStreamKit * _kit;
    KSYAirView * _airView;
}

@end

@implementation KSYViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _airView = [[KSYAirView alloc] init];
    self.layoutView = _airView;
    [self.view addSubview:_airView];
    __weak typeof (self) selfWeak = self;
    _airView.onBtnBlock = ^(id sender){
        [selfWeak  onBtnPress:sender];
    };
    
    
    _kit = [[KSYAirStreamKit alloc] init];
    _kit.delegate = self;
    NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self
           selector:@selector(onStreamStateChange)
               name:KSYStreamStateDidChangeNotification
             object:nil];
    [dc addObserver:self
           selector:@selector(onNetStateEvent)
               name:KSYNetStateEventNotification
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
- (void) viewWillTransitionToSize:(CGSize)size
        withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>) coordinator{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self layoutUI];
    }];
}

- (IBAction)onBtnPress:(id)sender {
    if (sender == _airView.btn) {
        if (_kit == nil) {
            return;
        }
        _airView.btn.selected = !_airView.btn.selected;
        if (_airView.btn.selected) {
            _kit.airCfg = [_airView airCfg];
            _kit.videoBitrate = (int)_airView.videoBitrateUI.value;
            _kit.streamUrl = _airView.txtAddr.text;
            [_kit startService];
            _airView.airState = @"开始启动服务...";
        }
        else {
            [_kit stopService];
            _airView.airState = @"开始停止服务...";
        }
    }
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) onStreamStateChange {
    if (_kit.streamerBase){
        _airView.strState = [_kit.streamerBase getCurStreamStateName];
        if (_kit.streamerBase.streamState == KSYStreamStateError) {
            _airView.strState = [_kit.streamerBase getCurKSYStreamErrorCodeName];
        }
        NSLog(@"stream State %@", _airView.strState);
    }
}

- (void) onNetStateEvent {
    if (_kit.streamerBase){
        switch (_kit.streamerBase.netStateCode) {
            case KSYNetStateCode_SEND_PACKET_SLOW: {  // 1
                break;
            }
            case KSYNetStateCode_EST_BW_RAISE: {  // 2
                break;
            }
            case KSYNetStateCode_EST_BW_DROP: {  // 3
                break;
            }
            case KSYNetStateCode_REACHABLE: {
                NSLog(@"network reachable");
            }
            case KSYNetStateCode_UNREACHABLE: {
                NSLog(@"network unreachable");
            }
            default:break;
        }
    }
}

#pragma mark - KSYAirDelegate
- (void) didStartMirroring:(KSYAirTunesServer *)server {
    _airView.airState = @"mirroring";
}
- (void)mirroringErrorDidOcccur:(KSYAirTunesServer *)server  withError:(NSError *)error {
    _airView.airState = error.localizedDescription;
    _airView.btn.selected = NO;
    [_kit stopService];
}
- (void)didStopMirroring:(KSYAirTunesServer *)server {
    _airView.airState = @"idle";
}
@end
