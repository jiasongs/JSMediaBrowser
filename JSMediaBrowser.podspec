
Pod::Spec.new do |s|
  s.name         = "JSMediaBrowser"
  s.version      = "1.0.0"
  s.summary      = "图片、视频浏览器"
  s.homepage     = "https://github.com/jiasongs/JSMediaBrowser"
  s.author       = { "jiasong" => "593908937@qq.com" }
  s.platform     = :ios, "11.0"
  s.swift_versions = ["4.2", "5.0"]
  s.requires_arc = true
  s.source       = { :git => "https://github.com/jiasongs/JSMediaBrowser.git", :tag => "#{s.version}" }
  s.frameworks   = "UIKit"
  s.license      = "MIT"
  
  s.dependency "JSCoreKit", "~> 0.2.8"
  
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
    ss.frameworks   = "PhotosUI"
    ss.dependency "JSMediaBrowser/MediaView"
  end

  s.subspec "MediaImageForSDWebImage" do |ss|
    ss.source_files = "Sources/MediaView/Image/SDWebImage/*.{swift,h,m}"
    ss.dependency "JSMediaBrowser/MediaImage"
    ss.dependency "SDWebImage", "~> 5.0"
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
