//
//  KSYAirView.h
//  KSYAirStreamer
//
//  Created by pengbins on 04/11/2017.
//  Copyright (c) 2017 pengbins. All rights reserved.
//

@import UIKit;
#import "KSYUIView.h"
#import "KSYAirStreamKit.h"

@interface KSYAirView : KSYUIView

// 推流地址
@property UITextField * txtAddr;
// 分辨率选择
@property UISegmentedControl *resolutionUI;
// 硬解/软解
@property UISegmentedControl *videoDecoderUI;
// 是否固定宽屏(锁定分辨率, 竖屏时填黑边)
@property UISwitch *paddingUI;
// 帧率选择
@property UISegmentedControl *framerateUI;
// 码率选择
@property KSYNameSlider *videoBitrateUI;
// 话筒音量
@property KSYNameSlider *micVolumeUI;
// 开始推流
@property UIButton * btn;
// 开始录制
@property UIButton * btnRec;

// 推流状态
@property NSString * strState;
// airplay 状态
@property NSString * airState;

// 从当前界面获取配置信息
@property (nonatomic, readonly) KSYAirTunesConfig * airCfg;
@end
