//
//  SourceProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(MediaBrowserSourceProtocol)
public protocol SourceProtocol: NSObjectProtocol {
    
    @objc var sourceRect: CGRect { get set }
    @objc var sourceView: UIView? { get set }
    @objc var sourceCornerRadius: CGFloat { get set }
    @objc var thumbImage: UIImage? { get set }
    
    init(sourceView: UIView?, sourceRect: CGRect, thumbImage: UIImage?)
    
}

@objc(MediaBrowserImageSourceProtocol)
public protocol ImageSourceProtocol: SourceProtocol {
    
    @objc var image: UIImage? { get set }
    @objc var imageUrl: URL? { get set }
    @objc var originalImageUrl: URL? { get set }
   
}

@objc(MediaBrowserVideoSourceProtocol)
public protocol VideoSourceProtocol: SourceProtocol {
    
    @objc var videoUrl: URL? { get set }
   
}

