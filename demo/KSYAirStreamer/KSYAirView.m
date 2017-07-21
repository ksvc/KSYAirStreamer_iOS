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
    _resolutionUI.selectedSegmentIndex = 0;
    _framerateUI    = [self addSliderName:@"帧率" From:2 To:30 Init:24];
    _videoBitrateUI = [self addSliderName:@"码率" From:300 To:2000 Init:800];

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
    self.btnH = self.btnH*2;
    [self putWide: _txtAddr andNarrow: _doneBtn];
    [self putLable:_lblRes andView:_resolutionUI ];
    [self putRow:@[_framerateUI] ];
    [self putRow:@[_videoBitrateUI] ];
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
    cfg.framerate = _framerateUI.value;
    NSString * name = [_txtAddr.text substringFromIndex:_txtAddr.text.length-3];
    cfg.airplayName = [NSString stringWithFormat:@"ksyair_%@", name];
    cfg.videoSize = [self getResolution];
    return cfg;
}
- (int) getResolution {
    switch (_resolutionUI.selectedSegmentIndex) {
        case 0:
            return 720;
        case 1:
            return 960;
        default:
            return 1280;
    }
}
@end
