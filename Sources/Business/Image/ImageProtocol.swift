//
//  ImageProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2021/1/5.
//

import UIKit

public typealias SetDataBlock = (_ loader: LoaderProtocol, _ object: Any?, _ data: Data?) -> Void
public typealias DownloadProgressBlock = (_ loader: LoaderProtocol, _ progress: Progress?) -> Void
public typealias CompletedBlock = (_ loader: LoaderProtocol, _ object: Any?, _ data: Data?, _ error: NSError?, _ cancelled: Bool, _ finished: Bool) -> Void

@objc(MediaBrowserImageSourceProtocol)
public protocol ImageSourceProtocol: SourceProtocol {
    
    @objc var image: UIImage? { get set }
    @objc var imageUrl: URL? { get set }
    @objc var originalImageUrl: URL? { get set }
   
}

@objc(MediaBrowserImageLoaderProtocol)
public protocol ImageLoaderProtocol: LoaderProtocol {
    
    @objc var webImageMediator: WebImageMediatorProtocol? { get set }
    
    @objc func request(forView view: UIView, setDataBlock: SetDataBlock?, downloadProgress: DownloadProgressBlock?, completed: CompletedBlock?) -> Void
    @objc func cancelRequest(forView view: UIView)
    
}