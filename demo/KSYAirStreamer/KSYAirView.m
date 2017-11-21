//
//  KSYAirView.m
//  KSYAirStreamer
//
//  Created by pengbins on 04/11/2017.
//  Copyright (c) 2017 pengbins. All rights reserved.
//
#import "KSYAirView.h"

@interface KSYAirView (){

}
@property UIButton * doneBtn;
// 推流状态控件
@property UILabel * lblState;
@property UILabel * lblRes;
@property UILabel * lblPadding;
@property UILabel * lblFPS;

@end

@implementation KSYAirView

- (id) init {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    // hostURL = rtmpSrv + streamName(随机数,避免多个demo推向同一个流
    NSString *rtmpSrv = @"rtmp://test.uplive.ks-cdn.com/live";
    NSString *devCode = [[KSYUIView getUuid] substringToIndex:3];
    NSString *url     = [NSString stringWithFormat:@"%@/%@", rtmpSrv, devCode];
    _txtAddr = [self addTextField:url ];
    _doneBtn =  [self addButton:@"ok"];
    
    _lblRes = [self addLable:@"分辨率"];
    _resolutionUI = [self addSegCtrlWithItems:@[@"低",@"中", @"高"]];
    _resolutionUI.selectedSegmentIndex = 2;
    _videoDecoderUI = [self addSegCtrlWithItems:@[@"软解码",@"硬解码"]];
    _videoDecoderUI.selectedSegmentIndex = 1;
    _btnRec = [self addButton:@"_ 无解码 "];
    
    CGSize sz = [[UIScreen mainScreen] bounds].size;
    int hgt = MAX(sz.width, sz.height);
    if (hgt <=568) {
        _videoDecoderUI.hidden = YES;
        _videoDecoderUI.selectedSegmentIndex = 0;
    }
    _lblFPS = [self addLable:@"帧率"];
    _framerateUI    = [self addSegCtrlWithItems:@[@"10",@"15", @"30"]];
    _framerateUI.selectedSegmentIndex = 1;
    _lblPadding = [self addLable:@"固定宽屏"];
    _paddingUI = [self addSwitch:NO];
    _videoBitrateUI = [self addSliderName:@"码率" From:500 To:3000 Init:1400];
    _micVolumeUI = [self addSliderName:@"音量" From:0 To:2 Init:1];
    
    _btn = [self addButton:@"开始"];
    [_btn setTitle:@"停止" forState:UIControlStateSelected ];
    _airState = @"";
    _strState = @"";
    _lblState = [self addLable:@"idle"];
    _lblState.numberOfLines = 3;
    return self;
}
- (void) dealloc {

}
//UIControlEventTouchUpInside
- (IBAction)onBtn:(id)sender{
    if (sender == _doneBtn){
        [_txtAddr resignFirstResponder];
        return;
    }
    [super onBtn:sender];
}
- (void) layoutUI {
    [super layoutUI];
    if ( self.width < self.height) {
        self.btnH = self.btnH*1.5;
    }
    [self putWide: _txtAddr andNarrow: _doneBtn];
    [self putLable:_lblRes andView:_resolutionUI ];
    [self putWide:_videoDecoderUI andNarrow:_btnRec];
    [self putRow:@[_lblFPS,_framerateUI, _lblPadding, _paddingUI ] ];
    [self putRow:@[_videoBitrateUI] ];
    [self putRow:@[_micVolumeUI] ];
    [self putRow:@[_btn] ];
    
    self.btnH = self.height - self.yPos - self.gap;
    [self putRow1:_lblState];
}
@synthesize strState = _strState;
- (NSString *)strState {
    return _strState;
}
- (void)setStrState:(NSString *)strState {
    _strState = strState;
    _lblState.text = [NSString stringWithFormat:@"%@\n%@",_airState, _strState];
}
@synthesize airState = _airState;
- (NSString *)airState {
    return _airState;
}
- (void)setAirState:(NSString *)airState {
    _airState = airState;
    _lblState.text = [NSString stringWithFormat:@"%@\n%@",_airState, _strState];
}

- (KSYAirTunesConfig *) airCfg {
    KSYAirTunesConfig *cfg = [[KSYAirTunesConfig alloc] init];
    cfg.framerate = [_framerateUI titleForSegmentAtIndex:_framerateUI.selectedSegmentIndex].intValue;
    NSString * name = [_txtAddr.text substringFromIndex:_txtAddr.text.length-3];
    cfg.airplayName = [NSString stringWithFormat:@"ksyair_%@", name];
    int targetWdt =[self getResolution];
    if(_paddingUI.isOn) {
        cfg.padding = YES;
        CGSize screenSz = [UIScreen mainScreen].bounds.size;
        CGFloat wdt = MAX(screenSz.width, screenSz.height);
        CGFloat hgt = MIN(screenSz.width, screenSz.height);
        CGFloat targetHgt =ceil(targetWdt*hgt/wdt);
        if (targetHgt< 720) { // wdt and hgt must larger than 720
            targetHgt = targetWdt;
            cfg.padding = NO;
            _paddingUI.on = NO;
        }
        cfg.videoSize = CGSizeMake(targetWdt, targetHgt);
    }
    else {
        cfg.videoSize = CGSizeMake(targetWdt, targetWdt);
    }
    if (_videoDecoderUI.selectedSegmentIndex == 0) {
        cfg.videoDecoder = KSYAirVideoDecoder_SOFTWARE;
    }
    else {
        cfg.videoDecoder = KSYAirVideoDecoder_VIDEOTOOLBOX;
    }
    return cfg;
}
- (int) getResolution {
    switch (_resolutionUI.selectedSegmentIndex) {
        case 0:
            return 720;
        case 1:
            return 960;
        case 2:
            return 1280;
        default:
            return 1280;
    }
}
- (IBAction)onSegCtrl:(id)sender {
    [super onSegCtrl:sender];
    if (sender == _resolutionUI ) {
        _paddingUI.enabled = NO;
        if (_resolutionUI.selectedSegmentIndex == 2) {
            _paddingUI.enabled = YES;
        }
    }
}
@end
