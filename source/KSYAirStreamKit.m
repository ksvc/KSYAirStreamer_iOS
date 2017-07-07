//
//  KSYViewController.m
//  KSYAirStreamer
//
//  Created by pengbins on 04/11/2017.
//  Copyright (c) 2017 pengbins. All rights reserved.
//
#import "KSYAirStreamKit.h"

@implementation KSYAudioCap
+ (BOOL) isHeadsetPluggedIn {
    return NO;
}

@end


@interface KSYAirStreamKit () <KSYAirDelegate>{
    int            _autoRetryCnt;
    BOOL           _bRetry;
    int            _maxAutoRetry;
}

@end

@implementation KSYAirStreamKit

- (id) init {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    _autoRetryCnt    = 0;
    _maxAutoRetry    = 5;
    _bRetry          = NO;
    
    NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
    [dc addObserver:self
           selector:@selector(onNetStateEvent)
               name:KSYNetStateEventNotification
             object:nil];
    [self setup];
    return self;
}
- (void) setup{
    _airTunesServer = [[KSYAirTunesServer alloc] init];
    _streamerBase   = [[KSYStreamerBase alloc] init];
    _aMixer         = [[KSYAudioMixer alloc] init];
    _aMixer.mainTrack = 0;
    [_aMixer setTrack:0 enable:YES];
    _airTunesServer.delegate = self;
    __weak typeof(self) weakSelf = self;
    _airTunesServer.videoProcessingCallback = ^(CVPixelBufferRef pixelBuffer, CMTime timeInfo) {
        [weakSelf.streamerBase processVideoPixelBuffer:pixelBuffer timeInfo:timeInfo];
    };
    _aMixer.audioProcessingCallback = ^(CMSampleBufferRef buf) {
        [weakSelf.streamerBase processAudioSampleBuffer:buf];
    };
    _streamerBase.videoCodec = KSYVideoCodec_AUTO;
    _streamerBase.streamStateChange = ^(KSYStreamState state) {
        [weakSelf onStreamStateChange:state];
    };
}
- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) startService {
    [_airTunesServer startServerWithCfg:_airCfg];
}
- (void) stopService {
    [_streamerBase stopStream];
    [_airTunesServer stopServer];
}

#pragma mark - KSYAirDelegate
- (void) didStartMirroring:(KSYAirTunesServer *)server {
    _streamerBase.videoFPS = _airCfg.framerate;
    _streamerBase.videoMaxBitrate  = _videoBitrate;
    _streamerBase.videoInitBitrate = _videoBitrate*6/10;
    _streamerBase.videoMinBitrate  = 0;
    [_streamerBase startStream:[NSURL URLWithString:_streamUrl]];
    if (_delegate && [_delegate respondsToSelector:@selector(didStartMirroring:)]) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [_delegate didStartMirroring:server];
        });
    }
    __weak typeof(self) weakSelf = self;
    _aCapDev        = [[KSYAudioCap alloc] init];
    _aCapDev.audioProcessingCallback = ^(CMSampleBufferRef buf) {
        [weakSelf.aMixer processAudioSampleBuffer:buf of:0];
    };
    [_aCapDev startCapture];
}
- (void)mirroringErrorDidOcccur:(KSYAirTunesServer *)server  withError:(NSError *)error {
    if (_delegate && [_delegate respondsToSelector:@selector(mirroringErrorDidOcccur:withError:)]) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [_delegate mirroringErrorDidOcccur:server withError:error];
        });
    }
}
- (void)didStopMirroring:(KSYAirTunesServer *)server {
    if (_delegate && [_delegate respondsToSelector:@selector(didStartMirroring:)]) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [_delegate didStopMirroring:server ];
        });
    }
    [_streamerBase stopStream];
    [_aCapDev stopCapture];
    _aCapDev = nil;
}

#pragma mark - stream state

- (void) onStreamStateChange: (KSYStreamState) state {
    if (!_streamerBase){
        return;
    }
    if (state == KSYStreamStateError){
        [self onStreamError:_streamerBase.streamErrorCode];
    }
    else if (state == KSYStreamStateConnected){
        _autoRetryCnt = _maxAutoRetry;
        _bRetry = NO;
    }
}
- (void) onNetStateEvent {
    KSYNetStateCode code = [_streamerBase netStateCode];
    if (code == KSYNetStateCode_REACHABLE) {
        if ( _streamerBase.streamState == KSYStreamStateError) {
            [self tryRtmpReconnect:1];
        }
    }
}

- (void) onStreamError: (KSYStreamErrorCode) errCode {
    NSString * name = [_streamerBase getCurKSYStreamErrorCodeName];
    NSLog(@"stream Error: %@", [name substringFromIndex:19]);
    if (errCode == KSYStreamErrorCode_CONNECT_BREAK ||
        errCode == KSYStreamErrorCode_AV_SYNC_ERROR ||
        errCode == KSYStreamErrorCode_Connect_Server_failed ||
        errCode == KSYStreamErrorCode_DNS_Parse_failed) {
        if (_bRetry == NO){
            [self tryRtmpReconnect:2];
        }
    }
    else if (errCode == KSYStreamErrorCode_RTMP_Publish_failed){
        if (_bRetry == NO){
            [self tryRtmpReconnect:5];
        }
    }
    else if (errCode == KSYStreamErrorCode_CODEC_OPEN_FAILED) {
        _streamerBase.videoCodec = KSYVideoCodec_X264;
        _autoRetryCnt = _maxAutoRetry;
        if (_bRetry == NO){
            [self tryRtmpReconnect:1];
        }
    }
}

- (void) tryRtmpReconnect:(double) delay {
    _bRetry = YES;
    int64_t delaySec = (int64_t)(delay * NSEC_PER_SEC);
    dispatch_time_t delayT = dispatch_time(DISPATCH_TIME_NOW, delaySec);
    dispatch_after(delayT, dispatch_get_main_queue(), ^{
        _bRetry = NO;
        if (_autoRetryCnt <= 0 || _streamerBase.netReachState == KSYNetReachState_Bad) {
            return;
        }
        if (!_streamerBase.isStreaming) {
            NSLog(@"retry connect %d/%d", _autoRetryCnt, _maxAutoRetry);
            _autoRetryCnt--;
            [_streamerBase startStream:_streamerBase.hostURL];
        }
    });
}
@end
