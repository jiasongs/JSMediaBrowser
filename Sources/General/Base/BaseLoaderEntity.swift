//
//  BaseLoaderEntity.swift
//  JSMediaBrowser
//
//  Created by jiasong on 2020/12/12.
//

import UIKit

@objc(MediaBrowserLoaderEntity)
open class BaseLoaderEntity: NSObject, LoaderProtocol {
    
    public var sourceItem: SourceProtocol?
    public var progress: Progress?
    public var error: NSError?
    
    public override init() {
        super.init()
        self.didInitialize()
    }
    
    open func didInitialize() -> Void {
        self.progress = Progress(totalUnitCount: -1)
    }
    
}
