//
//  SourceProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(MediaBrowserSourceProtocol)
public protocol SourceProtocol: NSObjectProtocol {
    
    @objc var sourceRect: CGRect { get set }
    @objc var sourceView: UIView? { get set }
    @objc var sourceCornerRadius: CGFloat { get set }
    @objc var thumbImage: UIImage? { get set }
    
    init(sourceView: UIView?, sourceRect: CGRect, thumbImage: UIImage?)
    
}
