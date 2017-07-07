//
//  KSYViewController.h
//  KSYAirStreamer
//
//  Created by pengbins on 04/11/2017.
//  Copyright (c) 2017 pengbins. All rights reserved.
//


#import <libksygpulive/libksystreamerengine.h>
#import <libksygpulive/libksystreamerbase.h>
#import "KSYAirTunesServer.h"

/**
 音频采集模块, 主要是重写 isHeadsetPluggedIn方法, 避免音频采集的问题
 */
@interface KSYAudioCap : KSYAUAudioCapture
@end

/**
 airplay 镜像录屏 + KSYStreamerBase 推流
 */
@interface KSYAirStreamKit : NSObject

/** airplay 接受端 */
@property KSYAirTunesServer  *airTunesServer;
/** airplay 配置信息 */
@property KSYAirTunesConfig  *airCfg;
/** 麦克风采集设备 */
@property KSYAudioCap  *aCapDev;
/** 音频mixer (音频buffer) */
@property KSYAudioMixer      *aMixer;
/** rtmp 推流地址 */
@property NSString  * streamUrl;
/** rtmp 推流视频码率 */
@property int videoBitrate;
/** rtmp 推流 */
@property KSYStreamerBase    *streamerBase;
/** 录制过程的代理 */
@property(nonatomic, weak) id<KSYAirDelegate> delegate;

/**
 启动镜像服务, 当成功建立airplay镜像连接时, 再启动音频采集和推流
 */
- (void) startService;

/**
 停止镜像服务
 */
- (void) stopService;

@end
