//
//  File.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc public protocol SourceProtocol: NSObjectProtocol {
    
    var sourceRect: CGRect { get set }
    var sourceView: UIView? { get set }
    var sourceCornerRadius: CGFloat { get set }
    var thumbImage: UIImage? { get set }
    
    init(sourceView: UIView?, sourceRect: CGRect, thumbImage: UIImage?)
    
}

