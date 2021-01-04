//
//  LoaderProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/23.
//

import UIKit

public typealias SetDataBlock = (_ loader: LoaderProtocol, _ object: Any?, _ data: Data?) -> Void
public typealias DownloadProgressBlock = (_ loader: LoaderProtocol, _ progress: Progress?) -> Void
public typealias CompletedBlock = (_ loader: LoaderProtocol, _ object: Any?, _ data: Data?, _ error: NSError?, _ cancelled: Bool, _ finished: Bool) -> Void

@objc(MediaBrowserLoaderProtocol)
public protocol LoaderProtocol: NSObjectProtocol {
    
    @objc var sourceItem: SourceProtocol? { get set }
    @objc var progress: Progress? { get set }
    @objc var error: NSError? { get set }
    
}

@objc(MediaBrowserImageLoaderProtocol)
public protocol ImageLoaderProtocol: LoaderProtocol {
    
    @objc var webImageMediator: WebImageMediatorProtocol? { get set }
    
    @objc func request(forView view: UIView, setDataBlock: SetDataBlock?, downloadProgress: DownloadProgressBlock?, completed: CompletedBlock?) -> Void
    @objc func cancelRequest(forView view: UIView)
    
}

@objc(MediaBrowserVideoLoaderProtocol)
public protocol VideoLoaderProtocol: LoaderProtocol {
    
}
