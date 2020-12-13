//
//  File.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

public protocol CellProtocol: NSObjectProtocol {
    
    func updateCell<T: LoaderProtocol>(loaderEntity: T, at indexPath: IndexPath);
    func updateLoading(receivedSize: Int, expectedSize: Int);
    
}

public protocol SourceProtocol: NSObjectProtocol {
    
    var sourceRect: CGRect { get set }
    var sourceView: UIView? { get set }
    var sourceCornerRadius: CGFloat { get set }
    var thumbImage: UIImage? { get set }
    
    init(sourceRect: CGRect, thumbImage: UIImage?)
    init<T: UIView>(sourceView: T?, thumbImage: UIImage?)
    
}

public protocol LoaderProtocol: NSObjectProtocol {
    
    var sourceItem: SourceProtocol? { get set }
    
}

public protocol ImageLoaderProtocol: LoaderProtocol {
    
    var webImageMediator: WebImageMediatorProtocol? { get set }
    
}

public typealias WebImageMediatorProgress = ((_ receivedSize: Int, _ expectedSize: Int) -> Void)
public typealias WebImageMediatorCompleted = ((_ image: UIImage, _ error: Error, _ finished: Bool) -> Void)

public protocol WebImageMediatorProtocol: NSObjectProtocol {
    
    @discardableResult
    func loadImage(url: URL, progress: WebImageMediatorProgress, completed: WebImageMediatorCompleted) -> Any?
    @discardableResult
    func cancelLoadImage(any: Any) -> Bool
    @discardableResult
    func cancelAll() -> Bool
    
}

