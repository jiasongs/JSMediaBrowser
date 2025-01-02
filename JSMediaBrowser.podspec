
Pod::Spec.new do |s|
  s.name         = "JSMediaBrowser"
  s.version      = "2.0.0"
  s.summary      = "图片、视频浏览器"
  s.homepage     = "https://github.com/jiasongs/JSMediaBrowser"
  s.author       = { "jiasong" => "593908937@qq.com" }
  s.platform     = :ios, "13.0"
  s.swift_versions = ["5.1"]
  s.requires_arc = true
  s.source       = { :git => "https://github.com/jiasongs/JSMediaBrowser.git", :tag => "#{s.version}" }
  s.frameworks   = "UIKit"
  s.license      = "MIT"
  
  s.dependency "JSCoreKit", "~> 1.0"
  
  s.default_subspec = "Core"
  s.subspec "Core" do |ss|
    ss.source_files = "Sources/Core/*.{swift,h,m}"
  end

  s.subspec "MediaView" do |ss|
    ss.source_files = "Sources/MediaView/Basis/*.{swift,h,m}"
    ss.dependency "JSMediaBrowser/Core"
  end

  s.subspec "MediaImage" do |ss|
    ss.source_files = "Sources/MediaView/Image/*.{swift,h,m}"
    ss.dependency "JSMediaBrowser/MediaView"
  end

  s.subspec "MediaImageForPHLivePhoto" do |ss|
    ss.source_files = "Sources/MediaView/Image/PHLivePhoto/*.{swift,h,m}"
    ss.frameworks   = "PhotosUI"
    ss.dependency "JSMediaBrowser/MediaImage"
  end

  s.subspec "MediaImageForSDWebImage" do |ss|
    ss.source_files = "Sources/MediaView/Image/SDWebImage/*.{swift,h,m}"
    ss.dependency "JSMediaBrowser/MediaImage"
    ss.dependency "SDWebImage", "~> 5.0"
  end

  s.subspec "MediaImageForKingfisher" do |ss|
    ss.source_files = "Sources/MediaView/Image/Kingfisher/*.{swift,h,m}"
    ss.dependency "JSMediaBrowser/MediaImage"
    ss.dependency "Kingfisher", "~> 8.0"
  end

  s.subspec "MediaVideo" do |ss|
    ss.source_files = "Sources/MediaView/Video/*.{swift,h,m}"
    ss.frameworks   = "AVKit"
    ss.dependency "JSMediaBrowser/MediaView"
  end

  s.subspec "Business" do |ss|
    ss.source_files = "Sources/Business/**/*.{swift,h,m}"
    ss.dependency "JSMediaBrowser/Core"
    ss.dependency "JSMediaBrowser/MediaVideo"
    ss.dependency "JSMediaBrowser/MediaImage"
  end

end
