Pod::Spec.new do |s|
  s.name             = 'KSYAirStreamer'
  s.version          = '1.1.0'
  s.summary          = 'airplay receiver => rtmp streamer'

  s.description      = <<-DESC
    * for iOS screen broadcast
    * airplay receiver to receive video frome an iOS devices
    * transcode video
    * publish rtmp stream
                       DESC

  s.homepage         = 'https://github.com/ksvc/KSYAirStreamer_iOS'
  s.license          = { 
:type => 'Proprietary',
:text => <<-LICENSE
      Copyright 2017 kingsoft Ltd. All rights reserved.
      LICENSE
  }
  s.author           = { 'pengbins' => 'pengbin@kingsoft.com' }
  s.source           = {
      :git => 'https://github.com/ksvc/KSYAirStreamer_iOS.git',
      :tag => s.version.to_s
  }
  s.requires_arc = true
  s.ios.library = 'z', 'iconv', 'stdc++.6', 'bz2'
  s.ios.frameworks   = [ 'AVFoundation', 'VideoToolbox', 'MediaPlayer']
  s.ios.deployment_target = '8.0'
  s.source_files =  ['prebuilt/include/**/*.h','source/*.{h,m}']
  s.vendored_library = 'prebuilt/libs/libksyairserver.a'
  #s.vendored_library = 'prebuilt/libs/libksyairserver_auth.a'
  s.dependency 'libksygpulive/libksygpulive'
  s.dependency 'CocoaAsyncSocket'
end
