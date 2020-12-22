//
//  File.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc public protocol CellProtocol: NSObjectProtocol {
    
    func updateCell(loaderEntity: LoaderProtocol, at index: Int)
    
    func loaderEntityWillBecomeDownload(_ loaderEntity: LoaderProtocol)
    func loaderEntity(_ loaderEntity: LoaderProtocol, didReceive progress: Progress?)
    func loaderEntity(_ loaderEntity: LoaderProtocol, didCompletion data: Any?, error: Error?, finished: Bool)
    
}

@objc public protocol SourceProtocol: NSObjectProtocol {
    
    var sourceRect: CGRect { get set }
    var sourceView: UIView? { get set }
    var sourceCornerRadius: CGFloat { get set }
    var thumbImage: UIImage? { get set }
    
    init(sourceView: UIView?, sourceRect: CGRect, thumbImage: UIImage?)
    
}

public typealias WillBecomeDownloadBlock = (_ loader: LoaderProtocol) -> Void
public typealias DownloadProgressBlock = (_ loader: LoaderProtocol, _ progress: Progress?) -> Void
public typealias CompletedBlock = (_ loader: LoaderProtocol, _ data: Any?, _ error: Error?, _ finished: Bool) -> Void

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
    var willBecomeDownloadBlock: WillBecomeDownloadBlock? { get set }
    var downloadProgressBlock: DownloadProgressBlock? { get set }
    var completedBlock: CompletedBlock? { get set }
    
    func request() -> Void
    
}

@objc public protocol ImageLoaderProtocol: LoaderProtocol {
    
    var webImageMediator: WebImageMediatorProtocol? { get set }
    
}

public typealias WebImageMediatorDownloadProgress = (_ receivedSize: Int64, _ expectedSize: Int64) -> Void
public typealias WebImageMediatorCompleted = (_ data: Any?, _ error: Error?, _ finished: Bool) -> Void

@objc public protocol WebImageMediatorProtocol: NSObjectProtocol {
    
    @discardableResult
    func loadImage(url: URL?, progress: WebImageMediatorDownloadProgress?, completed: WebImageMediatorCompleted?) -> Any?
    @discardableResult
    func cancelLoadImage(with data: Any) -> Bool
    
}

