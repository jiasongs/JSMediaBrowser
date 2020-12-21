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
    public var state: LoaderState = .none
    public var progress: Progress?
    public var error: Error?
    public var willLoadBlock: willLoadBlock?
    public var downloadProgressBlock: DownloadProgressBlock?
    public var completedBlock: CompletedBlock?
    
    public override init() {
        super.init()
        self.didInitialize()
    }
    
    open func didInitialize() -> Void {
        self.progress = Progress(totalUnitCount: 0)
    }
    
    public func request() -> Void {
        
    }
    
}
