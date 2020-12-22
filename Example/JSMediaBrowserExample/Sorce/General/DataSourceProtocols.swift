//
//  File.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc public protocol CellProtocol: NSObjectProtocol {
    
    func updateCell(loaderEntity: LoaderProtocol, at index: Int)
    
    func loaderEntityRequestPrepare(_ loaderEntity: LoaderProtocol)
    func loaderEntity(_ loaderEntity: LoaderProtocol, didReceive progress: Progress?)
    func loaderEntity(_ loaderEntity: LoaderProtocol, didCompleted data: Any?, error: Error?, finished: Bool)
    
}

@objc public protocol SourceProtocol: NSObjectProtocol {
    
    var sourceRect: CGRect { get set }
    var sourceView: UIView? { get set }
    var sourceCornerRadius: CGFloat { get set }
    var thumbImage: UIImage? { get set }
    
    init(sourceView: UIView?, sourceRect: CGRect, thumbImage: UIImage?)
    
}

public typealias PrepareBlock = (_ loader: LoaderProtocol) -> Void
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
    
    var prepareBlock: PrepareBlock? { get set }
    var downloadProgressBlock: DownloadProgressBlock? { get set }
    var completedBlock: CompletedBlock? { get set }
    
    func request(prepare: PrepareBlock?, downloadProgress: DownloadProgressBlock?, completed: CompletedBlock?) -> Void
    
}

@objc public protocol ImageLoaderProtocol: LoaderProtocol {
    
    var webImageMediator: WebImageMediatorProtocol? { get set }
    
}

public typealias WebImageMediatorSetImageBlock = (_ image: UIImage?, _ imageData: Data?) -> Void
public typealias WebImageMediatorDownloadProgress = (_ receivedSize: Int64, _ expectedSize: Int64) -> Void
public typealias WebImageMediatorCompleted = (_ image: UIImage?, _ imageData: Data?, _ error: Error?, _ finished: Bool) -> Void

@objc public protocol WebImageMediatorProtocol: NSObjectProtocol {
    
    func setImage(for view: UIView?, url: URL?, thumbImage: UIImage?, setImageBlock: WebImageMediatorSetImageBlock?, progress: WebImageMediatorDownloadProgress?, completed: WebImageMediatorCompleted?)
    func cancelImageRequest(for view: UIView?)
}

