#
#  Be sure to run `pod spec lint LYAudioManager.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "LYAudioManager"
  s.version      = "1.0.1"
  s.summary      = "audio recoder,player and convert tool"

  s.description  = <<-DESC
                  a simple audio recoder,player and convert tool for iOS
                   DESC

  s.homepage     = "https://github.com/install-b/LYAudioConvert"


  s.license      = "MIT"

  s.author       = { "Shangen Zhang" => "gkzhangshangen@163.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/install-b/LYAudioConvert.git", :tag => s.version }
 


# sub spec  AudioDevice
  s.subspec 'AudioDevice' do |d|
    
    d.framework = "AVFoundation"
    d.source_files = 'LYAudioDevice/*.{h,m}'
    d.public_header_files = 'LYAudioDevice/*.h'

  end

#  sub spec  AudioConvert
  s.subspec 'AudioConvert' do |c|
    
    # Convert
    c.subspec 'Convert' do |con|
      con.source_files = 'LYAudioConvert/AudioConvert/**/*.{h,mm,m}'
      con.dependency 'LYAudioManager/AudioConvert/Code'
      con.dependency 'LYAudioManager/AudioConvert/SoundTouch'
    end

     # Code
    c.subspec 'Code' do |cod|

      cod.source_files = 'LYAudioConvert/AudioEncode/**/*.{h,m,mm,cpp,a}'

      cod.vendored_libraries = "LYAudioConvert/AudioEncode/**/*.a"

      cod.frameworks = "CoreAudio", "CoreFoundation", "UIKit"
    end

     #  SoundTouch
    c.subspec 'SoundTouch' do |sou|

      sou.source_files = 'LYAudioConvert/AudioSoundTouch/**/*.{h,mm,cpp}'
      sou.dependency 'LYAudioManager/AudioConvert/Code'
    end


    # c.framework = "Foundation"
    # c.source_files = 'LYAudioConvert/*.{h,m}'

   end

  #s.requires_arc = true


end
