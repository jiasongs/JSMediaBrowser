//
//  VideoProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/5.
//

import UIKit
import AVKit

@objc(MediaBrowserVideoSourceProtocol)
public protocol VideoSourceProtocol: SourceProtocol {
    
    @objc var videoUrl: URL? { get set }
    @objc var videoAsset: AVAsset? { get set }
   
}

@objc(MediaBrowserVideoLoaderProtocol)
public protocol VideoLoaderProtocol: LoaderProtocol {
    
}

@objc(MediaBrowserViedeoActionViewProtocol)
public protocol ViedeoActionViewProtocol: NSObjectProtocol  {
    
    
}
