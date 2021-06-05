//
//  SourceProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

public protocol SourceProtocol: AnyObject {
    
    var sourceRect: CGRect { get set }
    var thumbImage: UIImage? { get set }
    
    init(sourceRect: CGRect, thumbImage: UIImage?)
    
}
