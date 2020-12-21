//
//  BaseLoaderEntity.swift
//  JSMediaBrowserExample
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(MediaBrowserLoaderEntity)
open class BaseLoaderEntity: NSObject, LoaderProtocol {
    
    public var sourceItem: SourceProtocol?
    public var progress: Progress?
    public var error: Error?
    
}
