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
    /// 连接失败
    KSYAirErrorCodeConnectFailed,
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

/** airplay的状态信息 */
typedef NS_ENUM(NSUInteger, KSYAirVideoDecoder) {
    /// 软解, 解码后画面通过videoProcessingCallback回调给出
    KSYAirVideoDecoder_SOFTWARE,
    /// 硬解, 解码后画面通过videoProcessingCallback回调给出
    KSYAirVideoDecoder_VIDEOTOOLBOX,
    /// 无解码,将接收到的264码流直接通过videoBitStreamCallback回调函数给出
    KSYAirVideoDecoder_NONE = 0x1000,
};


#pragma mark - KSYAirTunesConfig
/** airplay的配置信息 */
@interface KSYAirTunesConfig : NSObject
/// AirPlay 设备的名字
@property(nonatomic, copy) NSString *airplayName;
/// 接收设备的尺寸 (默认为 960x960)
/// 如果videoSize的宽高相同, 则横竖屏旋转时,输出的分辨率保持不变;
/// 当宽高不同时, 横竖屏旋转后, 高度保持不变, 宽度会跟随设备的屏幕比例变化
/// 请注意,宽高比需要和屏幕的比例相同, 否则内部自动按照画面小的数值计算
@property(nonatomic, assign) CGSize videoSize;
/// 是否需要在宽高不同时, 在屏幕两边填上黑边 (默认为 NO)
@property(nonatomic, assign) BOOL padding;
/// 希望接收到ios发送端的视频帧率 (有效值为 10, 15, 30), 默认为30
@property(nonatomic, assign) int framerate;
/// 设置airtunes 服务的监听端口, 0 表示系统自动分配
@property(nonatomic, assign) short airTunesPort;
/// 设置视频数据的接收端口，默认是7100, 当7100被占用时, 会尝试+1 尝试10次, 如果仍然失败报告端口冲突
@property(nonatomic, assign) short airVideoPort;
/// 设备的mac地址, 默认随机生成,(长度为6字节)
@property(nonatomic, copy) NSData *macAddr;
/// AirPlay接收数据的解码器(默认为KSYAirVideoDecoder_SOFTWARE)
@property(nonatomic, assign) KSYAirVideoDecoder videoDecoder;
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
 带鉴权的构造接收server实例

 @param token 鉴权信息, 请联系商务获取
 @param error 鉴权过程中的错误信息
 @return 新构造的实例
 */
- (instancetype) initWithToken:(NSString*) token
                         error:(NSError**) error;

/**
 SDK 过期时间
 */
@property(nonatomic, readonly) NSDate* expireDate;

/**
 获取屏幕画面的回调
 */
@property(nonatomic, copy) void(^videoProcessingCallback)(CVPixelBufferRef pixelBuffer, CMTime timeInfo );

/**
 获取屏幕码流的回调
 */
@property(nonatomic, copy) void(^videoBitStreamCallback)(NSData* data, BOOL bParameterSet, CMTime timeInfo);

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

/**
 解析264的参数集

 @param data airplay原始的 参数集(sps, pps)数据
 @param psData 解析后的参数集数据, 请保证传入的是指针数组, 且每个元素都为NULL
 @param psSize 解析后的每个参数集的长度
 @param psCnt  解析出来的参数集的个数
 @return nallength的字节数
 */
int KSYAirParseParamSets(NSData* data, uint8_t* psData[], size_t psSize[], size_t * psCnt);

#define KSYAIRSTREAMER_VER 1.4.0
#define KSYAIRSTREAMER_ID  9d619a94d94a5fedbcc2657f116dfe682dd63d96
