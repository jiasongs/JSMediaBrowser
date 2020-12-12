//
//  File.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc public protocol MediaBrowserViewSourceProtocol: NSObjectProtocol {
    
    @objc var sourceRect: CGRect { get set }
    @objc weak var sourceView: UIView? { get set }
    @objc var sourceCornerRadius: CGFloat { get set }
    @objc var thumbImage: UIImage? { get set }
    
    init(sourceRect: CGRect, thumbImage: UIImage?)
    init(sourceView: UIView?, thumbImage: UIImage?)
    
}

@objc public protocol MediaBrowserViewLoaderProtocol: NSObjectProtocol {
    
    @objc var sourceItem: MediaBrowserViewSourceProtocol? { get set }
    
}

@objc public protocol MediaBrowserViewCellProtocol: NSObjectProtocol {
    
    @objc var emptyView: UIView? { get }
    @objc var loadingView: UIView? { get }
    
}
