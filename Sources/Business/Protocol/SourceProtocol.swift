//
//  SourceProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(JSMediaBrowserSourceProtocol)
public protocol SourceProtocol: NSObjectProtocol {
    
    @objc var sourceRect: CGRect { get set }
    @objc var thumbImage: UIImage? { get set }
    
    init(sourceRect: CGRect, thumbImage: UIImage?)
    
}
