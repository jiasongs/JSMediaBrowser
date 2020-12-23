//
//  LoaderProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/23.
//

import UIKit

public typealias SetDataBlock = (_ loader: LoaderProtocol, _ object: Any?, _ data: Data?) -> Void
public typealias DownloadProgressBlock = (_ loader: LoaderProtocol, _ progress: Progress?) -> Void
public typealias CompletedBlock = (_ loader: LoaderProtocol, _ object: Any?, _ data: Data?, _ error: Error?, _ finished: Bool) -> Void

@objc public enum LoaderState: Int {
    case none
    case start
    case loading
    case end
}

@objc public protocol LoaderProtocol: NSObjectProtocol {
    
    var sourceItem: SourceProtocol? { get set }
    var state: LoaderState { get set }
    var progress: Progress? { get set }
    var error: Error? { get set }
    
    func request(for view: UIView, setDataBlock: SetDataBlock?, downloadProgress: DownloadProgressBlock?, completed: CompletedBlock?) -> Void
    func cancelRequest(for view: UIView)
    
}

@objc public protocol ImageLoaderProtocol: LoaderProtocol {
    
    var webImageMediator: WebImageMediatorProtocol? { get set }
    
}
