# [KSYAirStreamer iOS SDK](https://ksvc.github.io/KSYAirStreamer_iOS/html/index.html)

## 一. 功能特性

[金山云录屏直播SDK][KSYAirStreamer]是金山云提供的直播解决方案的一部分，完成了iOS端全屏录制的功能，主要实现思路是本SDK内实现了一个Airplay的接收端, 开始录屏时iOS系统与SDK建立连接, SDK收到画面后, 编码发送到直播服务器. 其中编码和推流功能使用[金山云直播SDK][1]实现.

### 1.1 录屏功能
- [x] iOS8/9/10 支持
- [x] 录屏支持

### 1.2 关于上架
根据Apple的政策, 含有Airplay功能的APP无法通过App Store审查, 请注意.

## 二. SDK集成方法介绍   
### 2.1 系统要求    
* 最低支持iOS版本：iOS 8.0
* 最低支持iPhone型号：iPhone 5
* 支持CPU架构： armv7,arm64(和i386,x86_64模拟器)
* 含有i386和x86_64模拟器版本的库文件，录屏和推流功能无法在模拟器上工作

### 2.2 下载工程
本SDK 提供如下列出获取方式:     

#### 2.2.1 从[github](https://github.com/ksvc/KSYAirStreamer_iOS) clone
目录结构如下所示:
- demo        : demo工程演示本SDK的主要接口的使用
- docs/html   : appleDoc风格的网页版接口文档
- prebuilt    : 预编译库的头文件和库文件
- source      : 顶层kit类的源代码

```
$ git clone https://github.com/ksvc/KSYAirStreamer_iOS.git --depth 1
```

#### 2.2.3 使用Cocoapods 进行安装    
通过Cocoapods 能将本SDK的静态库和代码下载到本地，只需要将类似如下语句中的一句加入你的Podfile：   
```ruby
pod 'libksygpulive', '~> 2.4.0'
pod 'KSYAirStreame', '~> 0.1.0'
```

### 2.3 开始运行demo工程
demo 目录中已经有一个Podfile, 指定了本地开发版的pod    
在demo目录下执行如下命令, 即可开始编译运行demo   
```
$ cd demo
$ pod install
$ open KSYAirStreame.xcworkspace
```

注意:
1. 更新pod之后, 需要打开 xcwrokspace, 而不是xcodeproj


### 2.4 添加头文件到需要使用本SDK的文件中
```
#import <KSYAirStreamer/KSYAirStreameKit.h>
```

### 2.5 SDK版本号查询
本SDK的版本号 主要通过头文件查询
```
#define KSYAIRSTREAMER_VER  0.1.0
```

## 三. 参考文档
* wiki: https://github.com/ksvc/KSYAirStreamer_iOS/wiki
* API 文档: https://ksvc.github.io/KSYAirStreamer_iOS/html/index.html

## 四. 反馈与建议
* 主页：[金山云](http://www.ksyun.com/)
* 邮箱：<zengfanping@kingsoft.com>
* QQ讨论群：574179720 [视频云技术交流群] 
* Issues:<https://github.com/ksvc/KSYAirStreamer_iOS/issues>

<a href="http://www.ksyun.com/"><img src="https://raw.githubusercontent.com/wiki/ksvc/KSYLive_Android/images/logo.png" border="0" alt="金山云计算" /></a>

[1]:https://github.com/ksvc/KSYLive_iOS
