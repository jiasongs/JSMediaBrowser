//
//  File.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc public protocol CellProtocol: NSObjectProtocol {
    
    func updateCell(loaderEntity: LoaderProtocol, at index: Int)
    
//    func willLoad()
//    func downloadProgress()
//    func completed()
//    public var willLoadBlock: willLoadBlock?
//    public var downloadProgressBlock: DownloadProgressBlock?
//    public var completedBlock: CompletedBlock?
}

@objc public protocol SourceProtocol: NSObjectProtocol {
    
    var sourceRect: CGRect { get set }
    var sourceView: UIView? { get set }
    var sourceCornerRadius: CGFloat { get set }
    var thumbImage: UIImage? { get set }
    
    init(sourceView: UIView?, sourceRect: CGRect, thumbImage: UIImage?)
    
}

public typealias willLoadBlock = () -> Void
public typealias DownloadProgressBlock = (_ receivedSize: Int, _ expectedSize: Int) -> Void
public typealias CompletedBlock = (_ data: Any?, _ error: Error?, _ finished: Bool) -> Void

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
    var willLoadBlock: willLoadBlock! { get set }
    var downloadProgressBlock: DownloadProgressBlock! { get set }
    var completedBlock: CompletedBlock! { get set }
    
    func request() -> Void
    
}

@objc public protocol ImageLoaderProtocol: LoaderProtocol {
    
    var webImageMediator: WebImageMediatorProtocol? { get set }
    
}

@objc public protocol WebImageMediatorProtocol: NSObjectProtocol {
    
    @discardableResult
    func loadImage(url: URL?, progress: DownloadProgressBlock?, completed: CompletedBlock?) -> Any?
    @discardableResult
    func cancelLoadImage(with data: Any) -> Bool
    
}

