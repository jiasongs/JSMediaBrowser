//
//  LoaderProtocol.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/23.
//

import UIKit

@objc(MediaBrowserLoaderProtocol)
public protocol LoaderProtocol: NSObjectProtocol {
    
    @objc var sourceItem: SourceProtocol? { get set }
    @objc var progress: Progress? { get set }
    @objc var error: NSError? { get set }
    
}
