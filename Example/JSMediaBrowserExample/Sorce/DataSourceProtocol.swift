//
//  File.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(MediaBrowserViewSourceProtocol)
public protocol SourceProtocol: NSObjectProtocol {
    
    @objc var sourceRect: CGRect { get set }
    @objc weak var sourceView: UIView? { get set }
    @objc var sourceCornerRadius: CGFloat { get set }
    @objc var thumbImage: UIImage? { get set }
    
    init(sourceRect: CGRect, thumbImage: UIImage?)
    init(sourceView: UIView?, thumbImage: UIImage?)
    
}

@objc(MediaBrowserViewLoaderProtocol)
public protocol LoaderProtocol: NSObjectProtocol {
    
    @objc var sourceItem: SourceProtocol? { get set }
    @objc var webImageMediator: WebImageMediatorProtocol? { get set }
    
}

@objc(MediaBrowserViewCellProtocol)
public protocol CellProtocol: NSObjectProtocol {
    
    @objc var emptyView: UIView? { get }
    @objc var loadingView: UIView? { get }
    
}

public typealias WebImageMediatorProgress = ((_ receivedSize: Int, _ expectedSize: Int) -> Void)
public typealias WebImageMediatorCompleted = ((_ image: UIImage, _ error: Error, _ finished: Bool) -> Void)

@objc(MediaBrowserViewWebImageMediatorProtocol)
public protocol WebImageMediatorProtocol: NSObjectProtocol {
    
    @discardableResult
    @objc func loadImage(url: URL, progress: WebImageMediatorProgress, completed: WebImageMediatorCompleted) -> Any?
    @discardableResult
    @objc func cancelLoadImage(any: Any) -> Bool
    @discardableResult
    @objc func cancelAll() -> Bool
    
}
