
Pod::Spec.new do |s|
  s.name         = "JSMediaBrowser"
  s.version      = "0.0.1"
  s.summary      = "图片、视频浏览器"
  s.homepage     = "https://github.com/jiasongs/JSMediaBrowser"
  s.author       = { "jiasong" => "593908937@qq.com" }
  s.platform     = :ios, "10.0"
  s.swift_versions = ['5.0', '5.1', '5.2']
  s.source       = { :git => "https://github.com/jiasongs/JSMediaBrowser.git", :tag => "#{s.version}" }
  s.frameworks   = 'Foundation'
  s.source_files = "JSMediaBrowser", "JSMediaBrowser/*.{swift,h,m}", "JSMediaBrowser/**/*.{swift,h,m}"
  s.license      = "MIT"
  s.requires_arc = true

  s.dependency 'JSCoreKit', '~> 0.0.6'
end
