//
//  File.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc public protocol CellProtocol: NSObjectProtocol {
    
    func updateCell(loaderEntity: LoaderProtocol, at index: Int);
    func updateLoading(receivedSize: Int, expectedSize: Int);
    
}

@objc public protocol SourceProtocol: NSObjectProtocol {
    
    var sourceRect: CGRect { get set }
    var sourceView: UIView? { get set }
    var sourceCornerRadius: CGFloat { get set }
    var thumbImage: UIImage? { get set }
    
    init(sourceView: UIView?, sourceRect: CGRect, thumbImage: UIImage?)
    
}

@objc public protocol LoaderProtocol: NSObjectProtocol {
    
    var sourceItem: SourceProtocol? { get set }
    var progress: Progress? { get set }
    var error: Error? { get set }
    
//    var progress: (_ receivedSize: Int, _ expectedSize: Int) -> Void?
    
    
}

@objc public protocol ImageLoaderProtocol: LoaderProtocol {
    
    var webImageMediator: WebImageMediatorProtocol? { get set }
    
}

public typealias WebImageMediatorProgress = (_ receivedSize: Int, _ expectedSize: Int) -> Void
public typealias WebImageMediatorCompleted = (_ image: UIImage, _ error: Error, _ finished: Bool) -> Void

@objc public protocol WebImageMediatorProtocol: NSObjectProtocol {
    
    @discardableResult
    func loadImage(url: URL, progress: WebImageMediatorProgress, completed: WebImageMediatorCompleted) -> Any?
    @discardableResult
    func cancelLoadImage(any: Any) -> Bool
    @discardableResult
    func cancelAll() -> Bool
    
}

