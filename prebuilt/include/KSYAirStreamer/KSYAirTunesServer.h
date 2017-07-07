//
//  KSYAirTunesServer.h
//  KSYAirStreamer
//
//  Created by yiqian on 11/04/2017.
//  Copyright © 2017 pengbins. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
/** airplay的错误码Domain */
FOUNDATION_EXTERN NSString *const KSYAirErrorDomain NS_AVAILABLE_IOS(7_0);
/** airplay的错误码 */
typedef NS_ENUM(NSUInteger, KSYAirErrorCode) {
    /// AirPlay端口冲突
    KSYAirErrorCodePortConflict,
    /// 网络未连接
    KSYAirErrorCodeNetworkDisconnection,
    /// 连接AirPlay超时
    KSYAirErrorCodeAirPlaySelectTimeout,
    /// 连接断开
    KSYAirErrorCodeConnectBreak,
    /// 其他错误
    KSYAirErrorCodeOther
};

/** airplay的状态信息 */
typedef NS_ENUM(NSUInteger, KSYAirState) {
    /// 初始状态, 空闲
    KSYAirState_Idle,
    /// 连接中
    KSYAirState_Connecting,
    /// 镜像中, 连接完成了
    KSYAirState_Mirroring,
    /// 断开连接中
    KSYAirState_Disconnecting,
    /// 发生错误了
    KSYAirState_Error,
};


#pragma mark - KSYAirTunesConfig
/** airplay的配置信息 */
@interface KSYAirTunesConfig : NSObject
/// AirPlay 设备的名字
@property(nonatomic, copy) NSString *airplayName;
/// 接收设备的尺寸(竖屏时高度为videoSize, 宽度根据屏幕比例计算得到,横屏时反之)
@property(nonatomic, assign) int videoSize;
/// 希望接收到ios发送端的视频帧率 默认30
@property(nonatomic, assign) int framerate;
/// 设置airtunes 服务的监听端口, 0 表示系统自动分配
@property(nonatomic, assign) short airTunesPort;
/// 设置视频数据的接收端口，默认是7100, 当7100被占用时, 会尝试+1 尝试10次, 如果仍然失败报告端口冲突
@property(nonatomic, assign) short airVideoPort;
/// 设备的mac地址, 默认随机生成,(长度为6字节)
@property(nonatomic, copy) NSData *macAddr;
@end


#pragma mark - KSYAirDelegate
@class KSYAirTunesServer;

/**
 airplay 镜像状态变化的代理
 */
@protocol KSYAirDelegate <NSObject>
@required
/**
 airplay 镜像成功开始了

 @param server airplay服务对象
 */
- (void)didStartMirroring:(KSYAirTunesServer *)server;

@required
/**
 airplay 镜像 遇到错误了

 @param server airplay服务对象
 @param error  遇到的错误, code 参见 KSYAirErrorCode的定义
 */
- (void)mirroringErrorDidOcccur:(KSYAirTunesServer *)server  withError:(NSError *)error;

@required
/**
 airplay 镜像成功结束了

 @param server airplay服务对象
 */
- (void)didStopMirroring:(KSYAirTunesServer *)server;

@end

#pragma mark - KSYAirTunesServer

/**
 Airplay 接收server
 */
@interface KSYAirTunesServer : NSObject

/**
 获取屏幕画面的回调
 */
@property(nonatomic, copy) void(^videoProcessingCallback)(CVPixelBufferRef pixelBuffer, CMTime timeInfo );

/**
 录制过程的通知代理
 */
@property(nonatomic, weak) id<KSYAirDelegate> delegate;

/**
 airplay 录制状态
 */
@property(nonatomic, readonly) KSYAirState airState;

/**
 启动服务

 @param cfg 服务的配置信息
 */
- (void) startServerWithCfg:(KSYAirTunesConfig*)cfg;

/**
 停止服务
 */
- (void) stopServer;

/**
 查询 errorcode 的名称

 @param errCode 错误码
 @return 错误码的名称字符串
 */
- (NSString*) getKSYAirErrorName : (KSYAirErrorCode) errCode;

@end

#define KSYAIRSTREAMER_VER 0.1.0
#define KSYAIRSTREAMER_ID  19bbdd453a06de17e9278b9fa828a6b86326e7a4
